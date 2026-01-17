import json
from collections import defaultdict
from datetime import datetime, timedelta
from io import BytesIO
from pprint import pprint

import requests
from django.conf import settings
from django.contrib.auth.hashers import check_password
from django.core.cache import cache
from django.core.exceptions import ObjectDoesNotExist
from django.db import transaction
from django.db.models import Q
from django.http import HttpResponse
from django.shortcuts import get_object_or_404, render
from django.template.loader import render_to_string
from django.utils import timezone
from drf_yasg import openapi
from drf_yasg.utils import swagger_auto_schema
from rest_framework import status
from rest_framework.authtoken.models import Token
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView  # <-- Ensure APIView is imported

from .models import *
from .serializers import *
from .utils.async_utils import run_async
from .utils.cache_utils import (cache_response, get_cached_response,
                                get_cached_user, invalidate_user_cache)


def invite_redirect(request):
    token = request.GET.get('token', '')
    email = request.GET.get('email', '')
    app_url = f'ac-manager://register?token={token}&email={email}'
    return render(request, 'invite_redirect.html', {'app_url': app_url})


def privacy(request):
    return render(request, 'privacy.html')


class RegistrationAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Rejestracja nowego użytkownika",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['email', 'password'],
            properties={
                'email': openapi.Schema(type=openapi.TYPE_STRING, description='Email użytkownika'),
                'password': openapi.Schema(type=openapi.TYPE_STRING, description='Hasło użytkownika'),
                'first_name': openapi.Schema(type=openapi.TYPE_STRING, description='Imię'),
                'last_name': openapi.Schema(type=openapi.TYPE_STRING, description='Nazwisko'),
                'street': openapi.Schema(type=openapi.TYPE_STRING, description='Ulica'),
                'city': openapi.Schema(type=openapi.TYPE_STRING, description='Miasto'),
                'code': openapi.Schema(type=openapi.TYPE_STRING, description='Kod pocztowy'),
                'phone': openapi.Schema(type=openapi.TYPE_STRING, description='Numer telefonu'),
                'rodzaj_klienta': openapi.Schema(type=openapi.TYPE_STRING, description='Rodzaj klienta (osoba_prywatna/firma)', default='osoba_prywatna'),
                'nazwa_firmy': openapi.Schema(type=openapi.TYPE_STRING, description='Nazwa firmy'),
                'nip': openapi.Schema(type=openapi.TYPE_STRING, description='NIP'),
                'numer_domu': openapi.Schema(type=openapi.TYPE_STRING, description='Numer domu'),
                'mieszkanie': openapi.Schema(type=openapi.TYPE_STRING, description='Mieszkanie'),
                'invitation_token': openapi.Schema(type=openapi.TYPE_STRING, description='Token zaproszenia'),
            }
        ),
        responses={
            200: openapi.Response('Rejestracja zakończona pomyślnie'),
            201: openapi.Response('Użytkownik utworzony'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        pprint(request.data)
        email = request.data.get('email')
        password = request.data.get('password')
        first_name = request.data.get('first_name')
        last_name = request.data.get('last_name')
        street = request.data.get('street')
        city = request.data.get('city')
        code = request.data.get('code')
        phone = request.data.get('phone')

        # Nowe pola
        rodzaj_klienta = request.data.get('rodzaj_klienta', 'osoba_prywatna')
        nazwa_firmy = request.data.get('nazwa_firmy', '')
        nip = request.data.get('nip', '')
        numer_domu = request.data.get('numer_domu', '')
        mieszkanie = request.data.get('mieszkanie', '')

        invitation_token = request.data.get(
            'invitation_token')  # Token zaproszenia

        if not email or not password:
            return Response({'error': 'Email and password are required.'}, status=400)

        # Weryfikacja tokenu zaproszenia
        invitation = None
        if invitation_token:
            try:
                invitation = Invitation.objects.get(
                    token=invitation_token, email=email)
                if not invitation.is_valid():
                    return Response({'error': 'Zaproszenie wygasło lub zostało już użyte.'}, status=400)
            except Invitation.DoesNotExist:
                return Response({'error': 'Nieprawidłowy token zaproszenia.'}, status=400)

        # Sprawdź czy użytkownik już istnieje
        try:
            ac_user = ACUser.objects.get(email=email)

            # Jeśli użytkownik istnieje BEZ tokenu zaproszenia, zwróć błąd
            if not invitation_token:
                return Response({'error': 'User already exists.'}, status=400)

            # Jeśli użytkownik istnieje Z tokenem zaproszenia, zaktualizuj jego dane
            with transaction.atomic():
                # Aktualizuj dane użytkownika
                ac_user.first_name = first_name
                ac_user.last_name = last_name
                ac_user.set_password(password)
                ac_user.has_account = True
                ac_user.save()

                # Aktualizuj lub utwórz dane adresowe
                user_data, created = UserData.objects.get_or_create(
                    ac_user=ac_user)
                user_data.ulica = street
                user_data.miasto = city
                user_data.kod_pocztowy = code
                user_data.numer_telefonu = phone
                user_data.rodzaj_klienta = rodzaj_klienta
                user_data.nazwa_firmy = nazwa_firmy
                user_data.nip = nip
                user_data.numer_domu = numer_domu
                user_data.mieszkanie = mieszkanie
                user_data.save()

                # Powiąż użytkownika z klientem z zaproszenia
                if invitation:
                    client = invitation.client
                    sender = invitation.created_by

                    # Powiąż użytkownika z klientem (monter/admin)
                    if sender.is_monter():
                        sender.clients.add(ac_user)
                        # Dodaj również do admina jeśli monter ma parent
                        if sender.parent:
                            sender.parent.clients.add(ac_user)
                    elif sender.is_admin():
                        sender.clients.add(ac_user)

                    # Oznacz zaproszenie jako użyte
                    invitation.used = True
                    invitation.used_at = timezone.now()
                    invitation.save()

                # Wygeneruj nowy token
                token = ac_user.generate_token()

                return Response({
                    'user_type': ac_user.user_type,
                    'token': token,
                    'message': 'Rejestracja zakończona pomyślnie. Możesz się teraz zalogować.'
                }, status=200)

        except ACUser.DoesNotExist:
            # Użytkownik nie istnieje - utwórz nowego
            with transaction.atomic():
                ac_user = ACUser(email=email, password=password,
                                 first_name=first_name, last_name=last_name)
                ac_user.set_password(password)
                ac_user.save()
                token = ac_user.generate_token()
                user_data = UserData.objects.create(
                    ac_user=ac_user,
                    ulica=street,
                    miasto=city,
                    kod_pocztowy=code,
                    numer_telefonu=phone,
                    rodzaj_klienta=rodzaj_klienta,
                    nazwa_firmy=nazwa_firmy,
                    nip=nip,
                    numer_domu=numer_domu,
                    mieszkanie=mieszkanie
                )
                user_data.save()

                # Jeśli rejestracja przez zaproszenie, powiąż z klientem
                if invitation:
                    client = invitation.client
                    sender = invitation.created_by

                    # Oznacz że użytkownik ma teraz konto w aplikacji
                    ac_user.has_account = True
                    ac_user.save()

                    # Powiąż użytkownika z klientem (monter/admin)
                    if sender.is_monter():
                        sender.clients.add(ac_user)
                        # Dodaj również do admina jeśli monter ma parent
                        if sender.parent:
                            sender.parent.clients.add(ac_user)
                    elif sender.is_admin():
                        sender.clients.add(ac_user)

                    # Oznacz zaproszenie jako użyte
                    invitation.used = True
                    invitation.used_at = timezone.now()
                    invitation.save()

                return Response({
                    'user_type': ac_user.user_type,
                    'token': token,
                    'message': 'Rejestracja zakończona pomyślnie. Możesz się teraz zalogować.'
                }, status=201)


class InvitationDataAPIView(APIView):
    """
    Endpoint do pobierania danych użytkownika na podstawie tokenu zaproszenia.
    Używany przy wypełnianiu formularza rejestracji.
    """
    permission_classes = [AllowAny]

    @swagger_auto_schema(
        operation_description="Pobierz dane użytkownika na podstawie tokenu zaproszenia",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['invitation_token'],
            properties={
                'invitation_token': openapi.Schema(type=openapi.TYPE_STRING, description='Token zaproszenia'),
                'email': openapi.Schema(type=openapi.TYPE_STRING, description='Email (opcjonalny)'),
            }
        ),
        responses={
            200: openapi.Response('Dane użytkownika'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        invitation_token = request.data.get('invitation_token')
        email = request.data.get('email')

        if not invitation_token:
            return Response({'error': 'Token zaproszenia jest wymagany.'}, status=400)

        try:
            # Znajdź zaproszenie
            invitation = Invitation.objects.get(token=invitation_token)

            # Sprawdź czy zaproszenie jest ważne
            if not invitation.is_valid():
                return Response({'error': 'Zaproszenie wygasło lub zostało już użyte.'}, status=400)

            # Sprawdź czy email się zgadza (jeśli został podany)
            if email and invitation.email != email:
                return Response({'error': 'Email nie pasuje do zaproszenia.'}, status=400)

            # Pobierz dane klienta powiązanego z zaproszeniem
            client = invitation.client

            # Pobierz dane adresowe użytkownika jeśli istnieją
            user_data = None
            try:
                user_data = UserData.objects.get(ac_user=client)
            except UserData.DoesNotExist:
                pass

            # Przygotuj dane do zwrócenia
            response_data = {
                'email': invitation.email,
                'first_name': client.first_name or '',
                'last_name': client.last_name or '',
            }

            # Dodaj dane adresowe jeśli istnieją
            if user_data:
                response_data['ulica'] = user_data.ulica or ''
                response_data['miasto'] = user_data.miasto or ''
                response_data['kod_pocztowy'] = user_data.kod_pocztowy or ''
                response_data['numer_telefonu'] = user_data.numer_telefonu or ''
                response_data['rodzaj_klienta'] = user_data.rodzaj_klienta or 'osoba_prywatna'
                response_data['nazwa_firmy'] = user_data.nazwa_firmy or ''
                response_data['nip'] = user_data.nip or ''
                response_data['numer_domu'] = user_data.numer_domu or ''
                response_data['mieszkanie'] = user_data.mieszkanie or ''
            else:
                response_data['ulica'] = ''
                response_data['miasto'] = ''
                response_data['kod_pocztowy'] = ''
                response_data['numer_telefonu'] = ''
                response_data['rodzaj_klienta'] = 'osoba_prywatna'
                response_data['nazwa_firmy'] = ''
                response_data['nip'] = ''
                response_data['numer_domu'] = ''
                response_data['mieszkanie'] = ''

            return Response(response_data, status=200)

        except Invitation.DoesNotExist:
            return Response({'error': 'Nieprawidłowy token zaproszenia.'}, status=400)


class ResetAPIView(APIView):
    @swagger_auto_schema(request_body=ResetPasswordSerializer)
    def post(self, request):
        pprint(request.data)
        serializer = ResetPasswordSerializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data['email']
            try:
                ac_user = ACUser.objects.get(email=email)
                ac_user.set_password('bbb')
                ac_user.save()
                return Response({'status': 'password reset'}, status=200)
            except ACUser.DoesNotExist:
                return Response({'error': 'Invalid email'}, status=400)
        return Response(serializer.errors, status=400)


class SendInvitationAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Wyślij zaproszenie do klienta",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'email', 'client_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'email': openapi.Schema(type=openapi.TYPE_STRING, description='Email klienta'),
                'client_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID klienta'),
            }
        ),
        responses={
            200: openapi.Response('Zaproszenie wysłane'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')
        email = request.data.get('email')
        client_id = request.data.get('client_id')

        if not token or not email or not client_id:
            return Response({'error': 'Token, email i client_id są wymagane.'}, status=400)

        sender = get_cached_user(token)
        if not sender or not sender.check_token(token):
            return Response({'error': 'Nieprawidłowy token.'}, status=400)

        # Sprawdź czy użytkownik ma uprawnienia (admin lub monter)
        if not (sender.is_admin() or sender.is_monter()):
            return Response({'error': 'Brak uprawnień.'}, status=403)

        # Pobierz klienta
        try:
            client = ACUser.objects.get(id=client_id)
        except ACUser.DoesNotExist:
            return Response({'error': 'Klient nie znaleziony.'}, status=404)

        # Sprawdź czy klient należy do nadawcy (dla montera)
        if sender.is_monter() and client not in sender.get_clients():
            return Response({'error': 'Klient nie jest przypisany do Ciebie.'}, status=403)

        # Sprawdź czy klient ma już konto - jeśli ma, nie można wysyłać zaproszeń
        client.check_if_has_account()
        if client.has_account:
            return Response({
                'error': 'Klient ma już konto w aplikacji. Nie można wysłać zaproszenia.',
            }, status=400)

        # Sprawdź czy zaproszenie dla tego emaila już istnieje i jest aktywne
        existing_invitation = Invitation.objects.filter(
            email=email,
            client=client,
            used=False,
            expires_at__gt=timezone.now()
        ).first()

        if existing_invitation:
            # Jeśli istnieje aktywne zaproszenie, zaktualizuj token i datę wygaśnięcia
            existing_invitation.generate_token()
            existing_invitation.expires_at = timezone.now() + timedelta(days=7)
            existing_invitation.save()
            invitation = existing_invitation
        else:
            # Utwórz nowe zaproszenie
            invitation = Invitation(
                email=email,
                client=client,
                created_by=sender,
                expires_at=timezone.now() + timedelta(days=7)
            )
            invitation.generate_token()
            invitation.save()

        # Wygeneruj link - użyj schematu aplikacji
        protocol = 'https' if not settings.DEBUG else 'http'
        host = request.get_host()
        base_url = f"{protocol}://{host}"
        invitation_url = f"{base_url}/api/invite/?token={invitation.token}&email={email}"

        # Alternatywnie, możesz użyć uniwersalnego linka HTTPS
        # invitation_url = f"https://yourdomain.com/invite?token={invitation.token}&email={email}"

        # Wyślij email synchronicznie (jak w testowej komendzie)
        try:
            import os
            from pathlib import Path

            from django.core.mail import send_mail

            # Upewnij się, że zmienne środowiskowe są załadowane (jak w settings.py)
            # settings.py używa load_dotenv() podczas importu, ale w kontekście API
            # może to nie działać, więc ładujemy je ręcznie
            try:
                from dotenv import load_dotenv

                # Załaduj .env z katalogu projektu (tam gdzie manage.py)
                # Używamy tej samej logiki co w settings.py
                BASE_DIR = Path(__file__).resolve().parent.parent.parent
                env_path = BASE_DIR / '.env'
                if env_path.exists():
                    # override=True aby nadpisać istniejące wartości
                    load_dotenv(env_path, override=True)
                else:
                    print(f'=== PLIK .env NIE ISTNIEJE W: {env_path} ===')
            except ImportError:
                print('=== DOTENV NIE JEST DOSTĘPNY ===')
            except Exception as e:
                print(f'=== BŁĄD ŁADOWANIA .env: {str(e)} ===')

            # Sprawdź wartości po załadowaniu .env
            password_env_after = os.getenv('EMAIL_HOST_PASSWORD', None)
            print(
                f'EMAIL_HOST_PASSWORD (from env after load): {"***" if password_env_after else "Nie ustawione"}')

            # Loguj konfigurację email dla debugowania (tak jak w test_email.py)
            print(f'=== DEBUG EMAIL CONFIG ===')
            print(
                f'EMAIL_HOST: {getattr(settings, "EMAIL_HOST", "Nie ustawione")}')
            print(
                f'EMAIL_PORT: {getattr(settings, "EMAIL_PORT", "Nie ustawione")}')
            print(
                f'EMAIL_USE_TLS: {getattr(settings, "EMAIL_USE_TLS", "Nie ustawione")}')
            print(
                f'EMAIL_HOST_USER: {getattr(settings, "EMAIL_HOST_USER", "Nie ustawione")}')
            password_setting = getattr(settings, "EMAIL_HOST_PASSWORD", None)
            print(
                f'EMAIL_HOST_PASSWORD (from settings): {"***" if password_setting else "Nie ustawione"}')
            print(
                f'EMAIL_HOST_PASSWORD (from env): {"***" if password_env_after else "Nie ustawione"}')
            print(
                f'DEFAULT_FROM_EMAIL: {getattr(settings, "DEFAULT_FROM_EMAIL", "Nie ustawione")}')
            print(f'Recipient: {email}')
            print(f'========================')

            subject = 'Zaproszenie do aplikacji AC Manager'
            message = f'''Witaj!

Zostałeś zaproszony do aplikacji AC Manager przez {sender.first_name} {sender.last_name}.

Kliknij w poniższy link, aby się zarejestrować:
{invitation_url}

Link jest ważny przez 7 dni.

Pozdrawiamy,
Zespół AC Manager'''

            # Problem: settings.py używa wartości załadowanych podczas importu
            # Jeśli zmienne środowiskowe nie były dostępne podczas startu Django,
            # użyjemy wartości bezpośrednio ze zmiennych środowiskowych (jeśli są dostępne)
            # lub z settings.py jako fallback

            # Sprawdź, czy możemy użyć wartości ze zmiennych środowiskowych
            email_host = os.getenv('EMAIL_HOST', getattr(
                settings, 'EMAIL_HOST', 'mail69.mydevil.net'))
            email_port = int(os.getenv('EMAIL_PORT', str(
                getattr(settings, 'EMAIL_PORT', 587))))
            email_use_tls = os.getenv('EMAIL_USE_TLS', str(
                getattr(settings, 'EMAIL_USE_TLS', True))).lower() == 'true'
            email_host_user = os.getenv('EMAIL_HOST_USER', getattr(
                settings, 'EMAIL_HOST_USER', 'noreply@acmanager.usermd.net'))
            email_host_password = os.getenv('EMAIL_HOST_PASSWORD', getattr(
                settings, 'EMAIL_HOST_PASSWORD', 'Testowe123'))

            # Jeśli hasło ze zmiennych środowiskowych jest dostępne, użyj go
            # W przeciwnym razie użyjemy wartości z settings.py
            if password_env_after:
                email_host_password = password_env_after
                print(f'=== UŻYWAM HASŁA ZE ZMIENNYCH ŚRODOWISKOWYCH ===')
            else:
                print(f'=== UŻYWAM HASŁA Z SETTINGS.PY ===')

            # Utwórz backend email z wartościami (możliwe że ze zmiennych środowiskowych)
            from django.core.mail.backends.smtp import EmailBackend
            email_backend = EmailBackend(
                host=email_host,
                port=email_port,
                username=email_host_user,
                password=email_host_password,
                use_tls=email_use_tls,
                fail_silently=False,
            )

            # Wyślij email używając bezpośrednio backendu
            from django.core.mail.message import EmailMessage
            email_message = EmailMessage(
                subject=subject,
                body=message,
                from_email=getattr(
                    settings, 'DEFAULT_FROM_EMAIL', 'noreply@acmanager.pl'),
                to=[email],
                connection=email_backend,
            )
            email_message.send()
        except Exception as e:
            # Loguj szczegółowy błąd
            import traceback
            error_details = traceback.format_exc()
            print(f'=== BŁĄD WYSYŁANIA EMAILA ===')
            print(f'Błąd: {str(e)}')
            print(f'Szczegóły: {error_details}')
            print(f'============================')

            # Zwróć błąd do klienta
            return Response({
                'error': f'Nie udało się wysłać emaila: {str(e)}',
                'invitation_id': invitation.id,
            }, status=500)

        # Zwróć odpowiedź natychmiast, nie czekając na wysłanie emaila
        return Response({
            'status': 'Zaproszenie wysłane',
            'invitation_id': invitation.id,
            'expires_at': invitation.expires_at.isoformat(),
            'message': 'Email z zaproszeniem został wysłany. Możesz wysyłać zaproszenia wielokrotnie, dopóki klient nie utworzy konta.'
        }, status=200)


class LoginAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Logowanie użytkownika",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['email', 'password'],
            properties={
                'email': openapi.Schema(type=openapi.TYPE_STRING, description='Email użytkownika'),
                'password': openapi.Schema(type=openapi.TYPE_STRING, description='Hasło użytkownika'),
            }
        ),
        responses={
            200: openapi.Response('Logowanie pomyślne', schema=openapi.Schema(
                type=openapi.TYPE_OBJECT,
                properties={
                    'first_name': openapi.Schema(type=openapi.TYPE_STRING),
                    'last_name': openapi.Schema(type=openapi.TYPE_STRING),
                    'avatar': openapi.Schema(type=openapi.TYPE_STRING),
                    'user_type': openapi.Schema(type=openapi.TYPE_STRING),
                    'token': openapi.Schema(type=openapi.TYPE_STRING),
                }
            )),
            400: openapi.Response('Błąd logowania'),
        }
    )
    def post(self, request):
        pprint(request.data)
        email = request.data.get('email')
        password = request.data.get('password')
        if not email or not password:
            return Response({'error': 'Email and password are required.'}, status=400)

        try:
            ac_user = ACUser.objects.get(email=email)
            if ac_user.check_password(password):
                token = ac_user.generate_token()
                return Response({'first_name': ac_user.first_name, 'last_name': ac_user.last_name, 'avatar': ac_user.url, 'user_type': ac_user.user_type, 'token': token}, status=200)
            else:
                return Response({'error': 'Invalid password.'}, status=400)

        except ACUser.DoesNotExist:
            return Response({'error': 'Invalid email'}, status=400)


class DataAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz dane użytkownika",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
            }
        ),
        responses={
            200: openapi.Response('Dane użytkownika'),
            404: openapi.Response('Użytkownik nie znaleziony'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')

        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        user_data = UserData.objects.get(ac_user=ac_user)
        data = UserDataSerializer(instance=user_data)

        response_data = data.data
        response_data['id'] = ac_user.id  # Dodaj ID ACUser
        response_data['first_name'] = ac_user.first_name
        response_data['last_name'] = ac_user.last_name
        response_data['email'] = ac_user.email
        response_data['user_type'] = ac_user.user_type

        return Response(response_data, status=200)


class DataChildAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz dane podwładnego użytkownika",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'user_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'user_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID użytkownika podwładnego'),
            }
        ),
        responses={
            200: openapi.Response('Dane użytkownika'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')
        user_id = request.data.get('user_id')

        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'Wrong Token.'}, status=400)
        child = ACUser.objects.get(id=user_id)
        if ac_user.check_token(token):
            # Sprawdź i zaktualizuj has_account dla istniejących użytkowników
            if child.is_klient():
                child.check_if_has_account()

            if ac_user.is_admin():
                if child.is_monter() and child.parent_id == ac_user.id:
                    user_data = UserData.objects.get(ac_user=child)
                    data = UserDataSerializer(instance=user_data)
                    response_data = data.data
                    response_data['id'] = child.id  # Dodaj ID ACUser
                    response_data['first_name'] = child.first_name
                    response_data['email'] = child.email
                    response_data['last_name'] = child.last_name
                    response_data['has_account'] = child.has_account
                    return Response(response_data, status=200)
                if child.is_klient():
                    # TODO sprawdzic czy klient jest pod admina
                    user_data = UserData.objects.get(ac_user=child)
                    data = UserDataSerializer(instance=user_data)
                    response_data = data.data
                    response_data['id'] = child.id  # Dodaj ID ACUser
                    response_data['first_name'] = child.first_name
                    response_data['email'] = child.email
                    response_data['last_name'] = child.last_name
                    response_data['has_account'] = child.has_account
                    return Response(response_data, status=200)
                return Response({'error': 'Wrong child.'}, status=400)
            if ac_user.is_monter():
                if child.is_klient() and child in ac_user.get_clients():
                    user_data = UserData.objects.get(ac_user=child)
                    data = UserDataSerializer(instance=user_data)

                    response_data = data.data
                    response_data['id'] = child.id  # Dodaj ID ACUser
                    response_data['first_name'] = ac_user.first_name
                    response_data['email'] = child.email
                    response_data['last_name'] = ac_user.last_name
                    response_data['has_account'] = child.has_account

                    return Response(response_data, status=200)
                return Response({'error': 'Wrong child.'}, status=400)
            return Response({'error': 'User is not admin or monter'}, status=400)
        return Response({'error': 'Wrong Token.'}, status=400)


class MonterListAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz listę montażystów",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
            }
        ),
        responses={
            200: openapi.Response('Lista montażystów'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user or not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)
        if ac_user.is_admin():
            # Optymalizacja: użyj select_related dla group i prefetch_related dla userdata
            monter_list = ac_user.get_children().select_related(
                'group').prefetch_related('userdata')
        else:
            return Response({'error': 'User is not Admin'}, status=400)

        monter_by_group = defaultdict(list)
        for monter in monter_list:
            group_name = 'ungrouped' if monter.group is None else monter.group.nazwa
            group_id = None if monter.group is None else monter.group.id
            # UserData jest już załadowane dzięki prefetch_related
            try:
                user_data = monter.userdata
            except UserData.DoesNotExist:
                user_data = None

            if not user_data:
                continue

            data = UserDataSerializer(instance=user_data)
            tmp = data.data
            tmp['id'] = monter.id
            tmp['avatar'] = monter.url
            tmp['first_name'] = monter.first_name
            tmp['last_name'] = monter.last_name
            tmp['group_id'] = group_id
            tmp['email'] = monter.email
            monter_by_group[group_name].append(tmp)
        return Response(monter_by_group, content_type='application/json', status=200)


class GroupListAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz listę grup",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
            }
        ),
        responses={
            200: openapi.Response('Lista grup'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user or not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)
        if ac_user.is_admin():
            groups = Group.objects.filter(owner=ac_user.id)
            groups_json = []
            for group in groups:
                tmp = {}
                tmp['nazwa'] = group.nazwa
                tmp['id'] = group.id
                number_of_users = ACUser.objects.filter(
                    group_id=group.id).count()
                tmp['number_of_users'] = number_of_users
                groups_json.append(tmp)
            return Response(groups_json, status=200)
        return Response({'error': 'User is not Admin'}, status=400)


class KlientListAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz listę klientów",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'page': openapi.Schema(type=openapi.TYPE_INTEGER, description='Numer strony (domyślnie 1)', default=1),
                'page_size': openapi.Schema(type=openapi.TYPE_INTEGER, description='Rozmiar strony (domyślnie 20)', default=20),
            }
        ),
        responses={
            200: openapi.Response('Lista klientów'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user or not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)
        if ac_user.is_klient():
            return Response({'error': 'User is Klient'}, status=400)

        # Paginacja
        page = int(request.data.get('page', 1))
        page_size = int(request.data.get('page_size', 20))

        # Cache key dla odpowiedzi
        cache_key = f'clients_list_{ac_user.id}_page_{page}_size_{page_size}'

        # Spróbuj pobrać z cache
        cached_result = get_cached_response(cache_key)
        if cached_result:
            return Response(cached_result, status=200)

        # Optymalizacja: użyj prefetch_related aby uniknąć problemu N+1
        # Sortowanie po stronie serwera - sortuj po first_name
        klient_list_queryset = ac_user.get_clients().prefetch_related(
            'userdata').order_by('first_name')

        # Oblicz całkowitą liczbę klientów przed paginacją
        total_count = klient_list_queryset.count()

        # Zastosuj paginację
        start_index = (page - 1) * page_size
        end_index = start_index + page_size
        klient_list = klient_list_queryset[start_index:end_index]

        klient_list_json = []

        # Optymalizacja: przygotuj listę klientów do aktualizacji has_account w batch
        clients_to_update = []

        for klient in klient_list:
            # Sprawdź i zaktualizuj has_account dla istniejących użytkowników
            # Optymalizacja: sprawdzamy tylko jeśli has_account nie jest ustawione
            if klient.has_account is None:
                # Sprawdź czy hasło jest różne od domyślnego "aaa"
                if not check_password('aaa', klient.password):
                    klient.has_account = True
                    clients_to_update.append(klient)

            # UserData jest już załadowane dzięki prefetch_related
            # Używamy getattr z fallback, aby uniknąć dodatkowego zapytania
            try:
                data = klient.userdata
            except UserData.DoesNotExist:
                data = None

            if data:
                # Użycie serializatora
                klient_serialized = ACUserSerializer(klient).data
                data_serialized = UserDataSerializer(data).data

                # Łączenie danych z dwóch serializatorów
                merged_data = {**klient_serialized, **data_serialized}
                klient_list_json.append(merged_data)

        # Optymalizacja: zaktualizuj has_account dla wszystkich klientów w jednym batch update
        if clients_to_update:
            ACUser.objects.bulk_update(clients_to_update, ['has_account'])

        # Przygotuj odpowiedź
        result = {
            'klient_list': klient_list_json,
            'pagination': {
                'page': page,
                'page_size': page_size,
                'total_count': total_count,
                'has_next': end_index < total_count,
                'has_previous': page > 1,
            }
        }

        # Cache'uj odpowiedź na 5 minut
        cache_response(cache_key, result, 300)

        # Zwróć dane z informacjami o paginacji
        return Response(result, status=200)


class CreateMonterAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Utwórz nowego montażystę",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'email', 'first_name', 'last_name'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'email': openapi.Schema(type=openapi.TYPE_STRING, description='Email montażysty'),
                'first_name': openapi.Schema(type=openapi.TYPE_STRING, description='Imię'),
                'last_name': openapi.Schema(type=openapi.TYPE_STRING, description='Nazwisko'),
                'street': openapi.Schema(type=openapi.TYPE_STRING, description='Ulica'),
                'mieszkanie': openapi.Schema(type=openapi.TYPE_STRING, description='Mieszkanie'),
                'city': openapi.Schema(type=openapi.TYPE_STRING, description='Miasto'),
                'code': openapi.Schema(type=openapi.TYPE_STRING, description='Kod pocztowy'),
                'phone': openapi.Schema(type=openapi.TYPE_STRING, description='Numer telefonu'),
                'group_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID grupy'),
            }
        ),
        responses={
            200: openapi.Response('Montażysta utworzony'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')
        admin = get_cached_user(token)
        if not admin or not admin.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)
        if admin.is_admin():
            email = request.data.get('email')
            first_name = request.data.get('first_name')
            last_name = request.data.get('last_name')
            street = request.data.get('street')
            mieszkanie = request.data.get('mieszkanie')
            city = request.data.get('city')
            code = request.data.get('code')
            phone = request.data.get('phone')
            if not email:
                return Response({'error': 'Email and password are required.'}, status=400)
            try:
                ac_user = ACUser.objects.get(email=email)
                return Response({'error': 'User already exists.'}, status=400)
            except ACUser.DoesNotExist:
                with transaction.atomic():
                    ac_user = ACUser(email=email, password="aaa", first_name=first_name,
                                     last_name=last_name, parent_id=admin.id, user_type='monter')
                    if 'group_id' in request.data:
                        group_id = request.data['group_id']
                        if group_id is not None and group_id != 'null':
                            # Upewniamy się, że to jest liczba
                            ac_user.group_id = int(group_id)
                    else:
                        ac_user.group_id = None  # Jeśli group_id jest 'null', ustawiamy na None

                    ac_user.save()
                    token = ac_user.generate_token()
                    user_data = UserData.objects.create(
                        ac_user=ac_user, ulica=street, mieszkanie=mieszkanie, miasto=city, kod_pocztowy=code, numer_telefonu=phone)
                    user_data.save()
                    return Response({'Status': 'User Created'}, status=201)
        return Response({'error': 'User is not Admin'}, status=400)


class RemoveKlientAPIVIew(APIView):
    @swagger_auto_schema(
        operation_description="Usuń klienta",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'klient_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'klient_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID klienta do usunięcia'),
            }
        ),
        responses={
            200: openapi.Response('Klient usunięty'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        token = request.data.get('token')
        klient_id = request.data.get('klient_id')
        parent = get_cached_user(token)
        if not parent or not parent.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)
        if parent.is_klient():
            return Response({'error': 'User is client'}, status=400)
        if not request.data.get('klient_id'):
            return Response({'error': 'Not found klient_id'}, status=400)

        klient = ACUser.objects.get(id=klient_id)
        if parent.is_admin():
            parent.clients.remove(klient)
            monter_list = parent.get_children()
            for monter in monter_list:
                monter.clients.remove(klient)
        if parent.is_monter():
            parent.clients.remove(klient)
        return Response({'status': 'Klient deleted'}, status=200)


class ListyKlientowAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz listę list klientów użytkownika",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
            }
        ),
        responses={
            200: openapi.Response('Lista list klientów'),
            400: openapi.Response('Błąd walidacji'),
            404: openapi.Response('Użytkownik nie znaleziony'),
        }
    )
    def post(self, request):
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found'}, status=404)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token'}, status=400)

        if ac_user.is_klient():
            return Response({'error': 'User is Klient'}, status=400)

        # Get lists created by this user (sorted by id for consistency)
        listy_klientow = ListyKlientow.objects.filter(
            ac_user=ac_user).order_by('id')

        # Serialize the data
        serializer = ListyKlientowSerializer(listy_klientow, many=True)

        print('listy_klientow', serializer.data)
        listy_klientow_json = []
        for lista in serializer.data:
            listy_klientow_json.append(lista)

        return Response({'listy_klientow': listy_klientow_json}, status=200)


class ListyKlientowAddAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Dodaj nową listę klientów",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'nazwa'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'nazwa': openapi.Schema(type=openapi.TYPE_STRING, description='Nazwa listy'),
            }
        ),
        responses={
            201: openapi.Response('Lista utworzona'),
            400: openapi.Response('Błąd walidacji lub lista już istnieje'),
            404: openapi.Response('Użytkownik nie znaleziony'),
        }
    )
    def post(self, request):
        token = request.data.get('token')
        nazwa = request.data.get('nazwa')

        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found'}, status=404)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token'}, status=400)

        if ac_user.is_klient():
            return Response({'error': 'User is Klient'}, status=400)

        try:
            # Check if list with this name already exists
            if ListyKlientow.objects.filter(ac_user=ac_user, nazwa=nazwa).exists():
                return Response({'error': 'List with this name already exists'}, status=400)

            lista = ListyKlientow.objects.create(
                ac_user=ac_user,
                nazwa=nazwa,
                created_date=timezone.now()
            )
            serializer = ListyKlientowSerializer(lista)
            return Response(serializer.data, status=201)
        except Exception as e:
            return Response({'error': str(e)}, status=400)


class ListyKlientowAddKlientToListaAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Dodaj klienta do listy",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'klient_id', 'lista_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'klient_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID klienta'),
                'lista_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID listy'),
            }
        ),
        responses={
            200: openapi.Response('Klient dodany do listy'),
            400: openapi.Response('Błąd walidacji'),
            404: openapi.Response('Lista lub klient nie znaleziony'),
        }
    )
    def post(self, request):
        token = request.data.get('token')
        klient_id = request.data.get('klient_id')
        lista_id = request.data.get('lista_id')

        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found'}, status=404)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token'}, status=400)

        if ac_user.is_klient():
            return Response({'error': 'User is Klient'}, status=400)

        try:
            klient = ACUser.objects.get(id=klient_id)
            user_data = UserData.objects.get(ac_user=klient)
            user_data.lista_klientow = lista_id
            user_data.save()

            return Response({'status': 'Klient added to list'}, status=200)
        except ObjectDoesNotExist:
            return Response({'error': 'List or client not found'}, status=404)


class ListyKlientowRemoveKlientFromListaAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Usuń klienta z listy",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'klient_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'klient_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID klienta'),
            }
        ),
        responses={
            200: openapi.Response('Klient usunięty z listy'),
            400: openapi.Response('Błąd walidacji'),
            404: openapi.Response('Użytkownik nie znaleziony'),
        }
    )
    def post(self, request):
        token = request.data.get('token')
        klient_id = request.data.get('klient_id')

        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found'}, status=404)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token'}, status=400)

        if ac_user.is_klient():
            return Response({'error': 'User is Klient'}, status=400)

        try:
            klient = ACUser.objects.get(id=klient_id)
            user_data = UserData.objects.get(ac_user=klient)
            user_data.lista_klientow = None
            user_data.save()

            return Response({'status': 'Klient removed from list'}, status=200)
        except ObjectDoesNotExist:
            return Response({'error': 'Client not found'}, status=404)


class CheckEmailAPIView(APIView):
    """Endpoint do sprawdzania czy email już istnieje w bazie"""
    @swagger_auto_schema(request_body=CheckEmailSerializer)
    def post(self, request):
        serializer = CheckEmailSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=400)

        token = serializer.validated_data['token']
        email = serializer.validated_data['email']
        exclude_user_id = serializer.validated_data.get('exclude_user_id')

        # Weryfikacja tokenu
        parent = get_cached_user(token)
        if not parent or not parent.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        # Ignoruj emaile @temp.local (tymczasowe)
        if email.endswith('@temp.local'):
            return Response({'exists': False, 'email': email}, status=200)

        # Sprawdź czy email istnieje (z opcjonalnym wykluczeniem użytkownika - dla edycji)
        try:
            ac_user = ACUser.objects.get(email=email)
            # Jeśli to edycja tego samego użytkownika, email jest dostępny
            if exclude_user_id and ac_user.id == exclude_user_id:
                return Response({'exists': False, 'email': email}, status=200)
            return Response({'exists': True, 'email': email}, status=200)
        except ACUser.DoesNotExist:
            return Response({'exists': False, 'email': email}, status=200)


class CreateKlientAPIView(APIView):
    @swagger_auto_schema(request_body=CreateKlientSerializer)
    def post(self, request):
        serializer = CreateKlientSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=400)
        token = serializer.validated_data['token']
        parent = get_cached_user(token)
        if not parent or not parent.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)
        email = serializer.validated_data.get('email', '')
        first_name = serializer.validated_data.get('first_name', '')
        last_name = serializer.validated_data.get('last_name', '')
        client_type = serializer.validated_data.get(
            'rodzaj_klienta', 'osoba_prywatna')
        typ_klienta = serializer.validated_data.get(
            'typ_klienta', 'aktualny')
        street = serializer.validated_data.get('ulica', '')
        mieszkanie = serializer.validated_data.get('mieszkanie', '')
        city = serializer.validated_data.get('miasto', '')
        code = serializer.validated_data.get('kod_pocztowy', '')
        numer_domu = serializer.validated_data.get('numer_domu', '')
        phone = serializer.validated_data.get('numer_telefonu', '')
        nazwa_firmy = serializer.validated_data.get('nazwa_firmy', '')
        nip = serializer.validated_data.get('nip', '')
        client_status = serializer.validated_data.get('client_status', '0')
        url = serializer.validated_data.get(
            'url', 'http://51.68.143.33/static/default_user.png')

        if not first_name or not last_name:
            return Response({'error': 'Imię i nazwisko są wymagane.'}, status=400)

        # Generowanie tymczasowego emaila dla osób prywatnych bez emaila
        if not email and client_type == 'osoba_prywatna':
            import uuid
            temp_uuid = str(uuid.uuid4())[:8]
            email = f"{first_name.lower()}.{last_name.lower()}.{temp_uuid}@temp.local"

        # Sprawdź czy współrzędne są już w request.data (z geokodowania po stronie klienta)
        longitude = serializer.validated_data.get('longitude')
        latitude = serializer.validated_data.get('latitude')

        # Jeśli współrzędne nie zostały przesłane, wykonaj geokodowanie
        if longitude is None or latitude is None:
            address = f"{street}, {city}, {code}"
            geocode_url = f"https://nominatim.openstreetmap.org/search?q={address}&format=json"

            try:
                response = requests.get(geocode_url)
                response.raise_for_status()
                geocode_data = response.json()
                if geocode_data:
                    longitude = geocode_data[0]['lon']
                    latitude = geocode_data[0]['lat']
                else:
                    longitude, latitude = None, None
            except requests.RequestException:
                longitude, latitude = None, None

        if parent.is_admin():
            # Sprawdzenie duplikatów tylko dla prawdziwych emaili (nie @temp.local)
            if email and not email.endswith('@temp.local'):
                try:
                    ac_user = ACUser.objects.get(email=email)
                    return Response({'error': 'User already exists.'}, status=400)
                except ACUser.DoesNotExist:
                    pass

            with transaction.atomic():
                ac_user = ACUser(
                    email=email, password="aaa", first_name=first_name, last_name=last_name, user_type='klient', url=url)
                ac_user.set_password("aaa")
                ac_user.save()
                token = ac_user.generate_token()
                user_data = UserData.objects.create(ac_user=ac_user, rodzaj_klienta=client_type, ulica=street, mieszkanie=mieszkanie, miasto=city, kod_pocztowy=code, numer_domu=numer_domu,
                                                    numer_telefonu=phone, nazwa_firmy=nazwa_firmy, nip=nip, longitude=longitude, latitude=latitude, typ_klienta=typ_klienta, client_status=client_status)
                parent.clients.add(ac_user)
                user_data.save()
                return Response({'Status': 'User Created', 'client_id': ac_user.id, 'message': 'User and user data updated successfully', 'token': token}, status=201)
        if parent.is_monter():
            try:
                ac_user = ACUser.objects.get(email=email)
                return Response({'error': 'User already exists.'}, status=400)
            except ACUser.DoesNotExist:
                with transaction.atomic():
                    ac_user = ACUser(
                        email=email, password="aaa", first_name=first_name, last_name=last_name, user_type='klient', url=url)
                    ac_user.set_password("aaa")
                    ac_user.save()

                    token = ac_user.generate_token()
                    user_data = UserData.objects.create(ac_user=ac_user, ulica=street, miasto=city, mieszkanie=mieszkanie, kod_pocztowy=code, numer_domu=numer_domu,
                                                        numer_telefonu=phone, nazwa_firmy=nazwa_firmy, nip=nip, longitude=longitude, latitude=latitude, typ_klienta=typ_klienta, client_status=client_status)
                    parent.clients.add(ac_user)
                    admin = ACUser.objects.get(id=parent.parent_id)
                    admin.clients.add(ac_user)
                    user_data.save()
                    return Response({'Status': 'User Created', 'client_id': ac_user.id, 'message': 'User and user data updated successfully', 'token': token}, status=201)
        return Response({'error': 'User is not Admin or Monter'}, status=400)


class RemoveUserAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Usuń użytkownika (tylko dla admina)",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'id_user'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'id_user': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID użytkownika do usunięcia'),
            }
        ),
        responses={
            200: openapi.Response('Użytkownik usunięty'),
            400: openapi.Response('Błąd walidacji lub użytkownik nie istnieje'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user or not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)
        if ac_user.is_admin():
            try:
                user_to_delete = ACUser.objects.get(
                    id=request.data.get('id_user'), parent_id=ac_user.id)
                user_to_delete.delete()
                return Response({'status': 'User delete'}, status=200)
            except ACUser.DoesNotExist:
                return Response({'error': 'User not exist'}, status=400)
        return Response({'error': 'User is not Admin'}, status=400)


class ChangeOwnDataAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Zmień własne dane użytkownika",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'first_name': openapi.Schema(type=openapi.TYPE_STRING, description='Imię'),
                'last_name': openapi.Schema(type=openapi.TYPE_STRING, description='Nazwisko'),
                'password': openapi.Schema(type=openapi.TYPE_STRING, description='Nowe hasło'),
                'kod_pocztowy': openapi.Schema(type=openapi.TYPE_STRING, description='Kod pocztowy'),
                'miasto': openapi.Schema(type=openapi.TYPE_STRING, description='Miasto'),
                'nazwa_firmy': openapi.Schema(type=openapi.TYPE_STRING, description='Nazwa firmy'),
                'nip': openapi.Schema(type=openapi.TYPE_STRING, description='NIP'),
                'numer_telefonu': openapi.Schema(type=openapi.TYPE_STRING, description='Numer telefonu'),
                'rodzaj_klienta': openapi.Schema(type=openapi.TYPE_STRING, description='Rodzaj klienta'),
                'typ_klienta': openapi.Schema(type=openapi.TYPE_STRING, description='Typ klienta'),
                'ulica': openapi.Schema(type=openapi.TYPE_STRING, description='Ulica'),
                'mieszkanie': openapi.Schema(type=openapi.TYPE_STRING, description='Mieszkanie'),
                'longitude': openapi.Schema(type=openapi.TYPE_NUMBER, description='Długość geograficzna'),
                'latitude': openapi.Schema(type=openapi.TYPE_NUMBER, description='Szerokość geograficzna'),
            }
        ),
        responses={
            200: openapi.Response('Dane zaktualizowane pomyślnie'),
            400: openapi.Response('Błąd walidacji'),
            401: openapi.Response('Nieprawidłowy token'),
            404: openapi.Response('Użytkownik nie znaleziony'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')

        if not token:
            return Response({'error': 'Token missing'}, status=400)

        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found'}, status=404)

        if not ac_user.check_token(token):
            return Response({'error': 'Invalid token'}, status=401)

        try:
            user_data = ac_user.userdata
        except UserData.DoesNotExist:
            return Response({'error': 'User data not found'}, status=404)

        # Poniższy słownik zawiera mapowanie między polami przesyłanymi w zapytaniu a polami modelu UserData
        acuser_field_mapping = {
            'first_name': 'first_name',
            'last_name': 'last_name',
        }

        user_data_field_mapping = {
            'kod_pocztowy': 'kod_pocztowy',
            'miasto': 'miasto',
            'nazwa_firmy': 'nazwa_firmy',
            'nip': 'nip',
            'numer_telefonu': 'numer_telefonu',
            'rodzaj_klienta': 'rodzaj_klienta',
            'typ_klienta': 'typ_klienta',
            'ulica': 'ulica',
            'mieszkanie': 'mieszkanie',
            'longitude': 'longitude',
            'latitude': 'latitude',
        }

        if 'password' in request.data:
            ac_user.set_password(request.data['password'])
            ac_user.save()

        # Update ACUser data
        acuser_data_to_update = {}
        for request_field, model_field in acuser_field_mapping.items():
            value = request.data.get(request_field)
            if value is not None:
                acuser_data_to_update[model_field] = value

        ACUser.objects.filter(pk=ac_user.pk).update(**acuser_data_to_update)
        # Update UserData
        user_data_to_update = {}
        for request_field, model_field in user_data_field_mapping.items():
            value = request.data.get(request_field)
            if value is not None:
                user_data_to_update[model_field] = value

        UserData.objects.filter(pk=user_data.pk).update(**user_data_to_update)

        return Response({'message': 'User and user data updated successfully'}, status=200)


class ChangeChildDataAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Zmień dane podwładnego użytkownika",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'user_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'user_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID użytkownika podwładnego'),
                'first_name': openapi.Schema(type=openapi.TYPE_STRING, description='Imię'),
                'last_name': openapi.Schema(type=openapi.TYPE_STRING, description='Nazwisko'),
                'group': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID grupy'),
                'kod_pocztowy': openapi.Schema(type=openapi.TYPE_STRING, description='Kod pocztowy'),
                'miasto': openapi.Schema(type=openapi.TYPE_STRING, description='Miasto'),
                'nazwa_firmy': openapi.Schema(type=openapi.TYPE_STRING, description='Nazwa firmy'),
                'nip': openapi.Schema(type=openapi.TYPE_STRING, description='NIP'),
                'numer_telefonu': openapi.Schema(type=openapi.TYPE_STRING, description='Numer telefonu'),
                'rodzaj_klienta': openapi.Schema(type=openapi.TYPE_STRING, description='Rodzaj klienta'),
                'typ_klienta': openapi.Schema(type=openapi.TYPE_STRING, description='Typ klienta'),
                'ulica': openapi.Schema(type=openapi.TYPE_STRING, description='Ulica'),
                'numer_domu': openapi.Schema(type=openapi.TYPE_STRING, description='Numer domu'),
                'house_number': openapi.Schema(type=openapi.TYPE_STRING, description='Numer domu (alternatywa)'),
                'mieszkanie': openapi.Schema(type=openapi.TYPE_STRING, description='Mieszkanie'),
                'longitude': openapi.Schema(type=openapi.TYPE_NUMBER, description='Długość geograficzna'),
                'latitude': openapi.Schema(type=openapi.TYPE_NUMBER, description='Szerokość geograficzna'),
                'client_status': openapi.Schema(type=openapi.TYPE_STRING, description='Status klienta'),
            }
        ),
        responses={
            200: openapi.Response('Dane zaktualizowane pomyślnie'),
            400: openapi.Response('Błąd walidacji'),
            401: openapi.Response('Nieprawidłowy token'),
            404: openapi.Response('Użytkownik nie znaleziony'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')
        user_id = request.data.get('user_id')
        if not token:
            return Response({'error': 'Token missing'}, status=400)

        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found'}, status=404)

        if not ac_user.check_token(token):
            return Response({'error': 'Invalid token'}, status=401)

        try:
            client = ACUser.objects.get(id=user_id)
        except ACUser.DoesNotExist:
            return Response({'error': 'Klient not found'}, status=404)

        if ac_user.is_admin():

            my_monters = ACUser.objects.filter(
                parent=ac_user, user_type=ACUser.MONTER)
            if client.is_monter():
                if client.parent_id != ac_user.id:
                    return Response({'error': 'Client not child of admin'}, status=404)
            else:
                if client not in ac_user.get_clients():
                    return Response({'error': 'Client not child of admin'}, status=404)
        if ac_user.is_monter():
            if client not in ac_user.get_clients():
                return Response({'error': 'Client not child of monter'}, status=404)
        if ac_user.is_klient():
            return Response({'error': 'User is Klient'}, status=404)

        try:
            user_data = client.userdata
        except UserData.DoesNotExist:
            return Response({'error': 'User data not found'}, status=404)

        # Mapowanie między polami przesyłanymi w zapytaniu a polami modelu UserData oraz ACUser
        acuser_field_mapping = {
            'first_name': 'first_name',
            'last_name': 'last_name',
            'group': 'group',
        }

        user_data_field_mapping = {
            'kod_pocztowy': 'kod_pocztowy',
            'miasto': 'miasto',
            'nazwa_firmy': 'nazwa_firmy',
            'nip': 'nip',
            'numer_telefonu': 'numer_telefonu',
            'rodzaj_klienta': 'rodzaj_klienta',
            'typ_klienta': 'typ_klienta',
            'ulica': 'ulica',
            'numer_domu': 'numer_domu',
            'mieszkanie': 'mieszkanie',
            'longitude': 'longitude',
            'latitude': 'latitude',
            'client_status': 'client_status',
        }

        # Update ACUser data
        acuser_data_to_update = {}
        for request_field, model_field in acuser_field_mapping.items():
            value = request.data.get(request_field)
            if value is not None:
                acuser_data_to_update[model_field] = value

        ACUser.objects.filter(pk=client.pk).update(**acuser_data_to_update)

        # Update UserData
        user_data_to_update = {}
        for request_field, model_field in user_data_field_mapping.items():
            value = request.data.get(request_field)
            if value is not None:
                user_data_to_update[model_field] = value

        # Special handling for house_number field (may be used instead of numer_domu)
        house_number = request.data.get('house_number')
        if house_number is not None:
            user_data_to_update['numer_domu'] = house_number

        UserData.objects.filter(pk=user_data.pk).update(**user_data_to_update)

        return Response({'message': 'User and user data updated successfully'}, status=200)


class AddChildren(APIView):
    @swagger_auto_schema(
        operation_description="Dodaj podwładnych do użytkownika (admin lub monter)",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['id_user', 'children_Ids'],
            properties={
                'id_user': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID użytkownika (admina lub montażysty)'),
                'children_Ids': openapi.Schema(
                    type=openapi.TYPE_ARRAY,
                    items=openapi.Schema(type=openapi.TYPE_INTEGER),
                    description='Lista ID podwładnych do dodania'
                ),
            }
        ),
        responses={
            200: openapi.Response('Podwładni dodani pomyślnie'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        ac_user = ACUser.objects.get(id=request.data.get('id_user'))
        children_Ids = request.data.get('children_Ids')
        if ac_user.is_admin():
            for children_Id in children_Ids:
                child = ACUser.objects.get(id=children_Id)
                child.parent = ac_user
                child.save()
        if ac_user.is_monter():
            for children_Id in children_Ids:
                child = ACUser.objects.get(id=children_Id)
                ac_user.clients.add(child)
        return Response({'response': 'Added children'}, status=200)


class TasksAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz listę zadań użytkownika",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
            }
        ),
        responses={
            200: openapi.Response('Lista zadań'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user or not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        # Cache key dla odpowiedzi
        cache_key = f'tasks_list_{ac_user.id}'

        # Spróbuj pobrać z cache
        cached_result = get_cached_response(cache_key)
        if cached_result:
            return Response(cached_result, status=200)

        if ac_user.is_admin():
            monter_list = ac_user.get_children()
        elif ac_user.is_monter():
            monter_list = [ac_user]
        else:
            return Response({'error': 'User is Klient'}, status=200)

        # Optymalizacja: użyj __in zamiast pętli aby uniknąć wielu zapytań
        monter_ids = [monter.id for monter in monter_list]
        # Optymalizacja: użyj select_related dla instalacji i klienta oraz prefetch_related dla userdata
        # aby uniknąć N+1 queries
        # Dodatkowo: ogranicz do 100 najnowszych zadań i sortuj po dacie
        task_list = Task.objects.filter(
            assigned_monter_id__in=monter_ids
        ).select_related(
            'instalacja',
            'instalacja__klient',
            'assigned_monter'
        ).prefetch_related('instalacja__klient__userdata').order_by('-start_date')[:100]

        # Optymalizacja: użyj many=True zamiast pętli
        serializer = TaskSerializer(task_list, many=True)
        result = serializer.data

        # Cache'uj odpowiedź na 2 minuty (zadania mogą się często zmieniać)
        cache_response(cache_key, result, 120)

        return Response(result, status=200)


class CreateTaskAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Utwórz nowe zadanie (tylko dla montażysty)",
        request_body=TaskSerializer,
        responses={
            201: openapi.Response('Zadanie utworzone'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user or not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)
        if ac_user.is_monter():
            additional_data = {"assigned_monter": ac_user.id}
            request.data.update(additional_data)
            serializer = TaskSerializer(data=request.data)
            if serializer.is_valid():
                serializer.save()
                return Response({'status': 'Task Added'}, status=201)
            return Response(serializer.errors, status=400)
        return Response({'error': 'User is not monter'}, status=400)


class CertyfikatAddAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Dodaj certyfikat",
        request_body=CertificateSerializer,
        responses={
            201: openapi.Response('Certyfikat utworzony'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'Wrong Token.'}, status=400)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        if not (ac_user.is_admin() or ac_user.is_monter()):
            return Response({'error': 'User is not Admin or Monter'}, status=400)

        serializer = CertificateSerializer(data=request.data, partial=True)
        if not serializer.is_valid():
            return Response(serializer.errors, status=400)

        # Save the object with additional data
        serializer.save(ac_user=ac_user)
        return Response({'status': 'Certificate created'}, status=201)


class CertyfikatListAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz listę certyfikatów",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
            }
        ),
        responses={
            200: openapi.Response('Lista certyfikatów'),
            400: openapi.Response('Błąd walidacji'),
            404: openapi.Response('Użytkownik nie znaleziony'),
        }
    )
    def post(self, request):
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        certyficate_json = []
        admin_ids = []

        if ac_user.is_admin():
            admin_ids.append(ac_user.id)
        elif ac_user.is_monter() and ac_user.parent:
            admin_ids.append(ac_user.parent_id)
        elif ac_user.is_klient():
            monters = ac_user.monter.all()
            for monter in monters:
                if monter.is_admin():
                    admin_ids.append(monter.id)

        if not admin_ids:
            return Response({'error': 'No admins found.'}, status=404)

        # Optymalizacja: użyj many=True zamiast pętli
        certificates = Certificate.objects.filter(ac_user__id__in=admin_ids)
        serializer = CertificateSerializer(
            certificates, many=True, context={'request': request})
        return Response({'certyficates': serializer.data}, status=200)


class CertyfikatDeleteAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Usuń certyfikat",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'certyfikat_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'certyfikat_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID certyfikatu'),
            }
        ),
        responses={
            200: openapi.Response('Certyfikat usunięty'),
            400: openapi.Response('Błąd walidacji'),
            403: openapi.Response('Brak uprawnień'),
            404: openapi.Response('Certyfikat nie znaleziony'),
        }
    )
    def post(self, request):
        pprint(request.data)
        certificate_id = request.data.get('certyfikat_id')
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        # Weryfikacja uprawnień jako admin lub monter
        if not (ac_user.is_admin() or ac_user.is_monter()):
            return Response({'error': 'User is not Admin or Monter'}, status=403)

        # Wyszukanie i usunięcie certyfikatu
        print(certificate_id)
        print(ac_user)
        try:
            certificate = Certificate.objects.get(
                id=certificate_id, ac_user=ac_user)
            certificate.delete()
            return Response({'status': 'Certificate deleted'}, status=200)
        except:
            return Response({'error': 'Certificate not found'}, status=404)


class SzkolenieAddAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Dodaj szkolenie (tylko dla admina)",
        request_body=SzkolenieSerializer,
        responses={
            201: openapi.Response('Szkolenie utworzone'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'Wrong Token.'}, status=400)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        if not ac_user.is_admin():
            return Response({'error': 'User is not Admin'}, status=400)

        serializer = SzkolenieSerializer(data=request.data, partial=True)
        if not serializer.is_valid():
            return Response(serializer.errors, status=400)

        # Save the object with additional data
        serializer.save(ac_user=ac_user)
        return Response({'status': 'Szkolenie created'}, status=201)


class SzkolenieListAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz listę szkoleń",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
            }
        ),
        responses={
            200: openapi.Response('Lista szkoleń'),
            400: openapi.Response('Błąd walidacji'),
            404: openapi.Response('Użytkownik nie znaleziony'),
        }
    )
    def post(self, request):
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        szkolenia_json = []
        admin_ids = []

        if ac_user.is_admin():
            admin_ids.append(ac_user.id)
        elif ac_user.is_monter() and ac_user.parent:
            admin_ids.append(ac_user.parent_id)
        elif ac_user.is_klient():
            monters = ac_user.monter.all()
            for monter in monters:
                if monter.is_admin():
                    admin_ids.append(monter.id)

        if not admin_ids:
            return Response({'error': 'No admins found.'}, status=404)

        # Optymalizacja: użyj many=True zamiast pętli
        szkolenia = Szkolenie.objects.filter(ac_user__id__in=admin_ids)
        serializer = SzkolenieSerializer(
            szkolenia, many=True, context={'request': request})
        return Response({'szkolenia': serializer.data}, status=200)


class SzkolenieDeleteAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Usuń szkolenie (tylko dla admina)",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'szkolenie_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'szkolenie_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID szkolenia'),
            }
        ),
        responses={
            200: openapi.Response('Szkolenie usunięte'),
            400: openapi.Response('Błąd walidacji'),
            403: openapi.Response('Brak uprawnień'),
            404: openapi.Response('Szkolenie nie znalezione'),
        }
    )
    def post(self, request):
        szkolenie_id = request.data.get('szkolenie_id')
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        # Weryfikacja uprawnień jako admin
        if not ac_user.is_admin():
            return Response({'error': 'User is not Admin'}, status=403)

        # Wyszukanie i usunięcie certyfikatu
        try:
            szkolenie = Szkolenie.objects.get(id=szkolenie_id, ac_user=ac_user)
            szkolenie.delete()
            return Response({'status': 'Szkolenie deleted'}, status=200)
        except:
            return Response({'error': 'Szkolenie not found'}, status=404)


class KatalogAddAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Dodaj katalog (tylko dla admina)",
        request_body=KatalogSerializer,
        responses={
            201: openapi.Response('Katalog utworzony'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'Wrong Token.'}, status=400)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        if not ac_user.is_admin():
            return Response({'error': 'User is not Admin'}, status=400)

        serializer = KatalogSerializer(data=request.data, partial=True)
        if not serializer.is_valid():
            return Response(serializer.errors, status=400)

        # Save the object with additional data
        serializer.save(ac_user=ac_user)
        return Response({'status': 'Katalog created'}, status=201)


class KatalogListAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz listę katalogów",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
            }
        ),
        responses={
            200: openapi.Response('Lista katalogów'),
            400: openapi.Response('Błąd walidacji'),
            404: openapi.Response('Użytkownik nie znaleziony'),
        }
    )
    def post(self, request):
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        katalogi_json = []
        admin_ids = []

        if ac_user.is_admin():
            admin_ids.append(ac_user.id)
        elif ac_user.is_monter() and ac_user.parent:
            admin_ids.append(ac_user.parent_id)
        elif ac_user.is_klient():
            monters = ac_user.monter.all()
            for monter in monters:
                if monter.is_admin():
                    admin_ids.append(monter.id)

        if not admin_ids:
            return Response({'error': 'No admins found.'}, status=404)

        # Optymalizacja: użyj many=True zamiast pętli
        katalogi = Katalog.objects.filter(ac_user__id__in=admin_ids)
        serializer = KatalogSerializer(
            katalogi, many=True, context={'request': request})
        return Response({'katalogi': serializer.data}, status=200)


class KatalogDeleteAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Usuń katalog (tylko dla admina)",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'katalog_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'katalog_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID katalogu'),
            }
        ),
        responses={
            200: openapi.Response('Katalog usunięty'),
            400: openapi.Response('Błąd walidacji'),
            403: openapi.Response('Brak uprawnień'),
            404: openapi.Response('Katalog nie znaleziony'),
        }
    )
    def post(self, request):
        katalog_id = request.data.get('katalog_id')
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        # Weryfikacja uprawnień jako admin
        if not ac_user.is_admin():
            return Response({'error': 'User is not Admin'}, status=403)

        # Wyszukanie i usunięcie certyfikatu
        try:
            katalog = Katalog.objects.get(id=katalog_id, ac_user=ac_user)
            katalog.delete()
            return Response({'status': 'Katalog deleted'}, status=200)
        except:
            return Response({'error': 'Katalog not found'}, status=404)


class CennikAddAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Dodaj cennik (tylko dla admina)",
        request_body=CennikSerializer,
        responses={
            201: openapi.Response('Cennik utworzony'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'Wrong Token.'}, status=400)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        if not ac_user.is_admin():
            return Response({'error': 'User is not Admin'}, status=400)

        serializer = CennikSerializer(data=request.data, partial=True)
        if not serializer.is_valid():
            return Response(serializer.errors, status=400)

        # Save the object with additional data
        serializer.save(ac_user=ac_user)
        return Response({'status': 'Cennik created'}, status=201)


class UpdateEmployeeTeamAPIView(APIView):
    """
    API endpoint to update an employee's team (group).
    Expects POST with {"employeeId": int, "newTeamId": int or null, "token": str}
    """
    permission_classes = [AllowAny]

    @swagger_auto_schema(
        operation_description="Zaktualizuj grupę pracownika",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['employeeId', 'token'],
            properties={
                'employeeId': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID pracownika'),
                'newTeamId': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID nowej grupy (null aby usunąć z grupy)', nullable=True),
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
            }
        ),
        responses={
            200: openapi.Response('Grupa pracownika zaktualizowana'),
            400: openapi.Response('Błąd walidacji'),
            401: openapi.Response('Nieprawidłowy token'),
            403: openapi.Response('Brak uprawnień'),
            404: openapi.Response('Pracownik lub grupa nie znaleziona'),
        }
    )
    def post(self, request):
        from pprint import pprint
        pprint(request.data)
        employee_id = request.data.get('employeeId')
        new_team_id = request.data.get('newTeamId')
        token = request.data.get('token')
        if not employee_id or token is None:
            return Response({'error': 'employeeId and token are required.'}, status=400)

        try:
            employee = ACUser.objects.get(id=employee_id)
        except ACUser.DoesNotExist:
            return Response({'error': 'Employee not found.'}, status=404)

        # Authenticate admin by token
        admin = get_cached_user(token)
        if not admin or not admin.check_token(token):
            return Response({'error': 'Invalid token.'}, status=401)
        if not admin.is_admin():
            return Response({'error': 'Only admin can update employee team.'}, status=403)

        # Only allow moving employees that are children of this admin
        if employee.parent_id != admin.id:
            return Response({'error': 'Employee does not belong to this admin.'}, status=403)

        # Set new team (group)
        if new_team_id is None:
            employee.group = None
        else:
            try:
                group = Group.objects.get(id=new_team_id, owner=admin.id)
            except Group.DoesNotExist:
                return Response({'error': 'Group not found or does not belong to admin.'}, status=404)
            employee.group = group
        employee.save()
        return Response({'status': 'Employee team updated.'}, status=200)


class CennikListAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz listę cenników",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
            }
        ),
        responses={
            200: openapi.Response('Lista cenników'),
            400: openapi.Response('Błąd walidacji'),
            404: openapi.Response('Użytkownik nie znaleziony'),
        }
    )
    def post(self, request):
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        cenniki_json = []
        admin_ids = []

        if ac_user.is_admin():
            admin_ids.append(ac_user.id)
        elif ac_user.is_monter() and ac_user.parent:
            admin_ids.append(ac_user.parent_id)
        elif ac_user.is_klient():
            monters = ac_user.monter.all()
            for monter in monters:
                if monter.is_admin():
                    admin_ids.append(monter.id)

        if not admin_ids:
            return Response({'error': 'No admins found.'}, status=404)

        # Optymalizacja: użyj many=True zamiast pętli
        cenniki = Cennik.objects.filter(ac_user__id__in=admin_ids)
        serializer = CennikSerializer(
            cenniki, many=True, context={'request': request})
        return Response({'cenniki': serializer.data}, status=200)


class CennikDeleteAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Usuń cennik (tylko dla admina)",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'cennik_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'cennik_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID cennika'),
            }
        ),
        responses={
            200: openapi.Response('Cennik usunięty'),
            400: openapi.Response('Błąd walidacji'),
            403: openapi.Response('Brak uprawnień'),
            404: openapi.Response('Cennik nie znaleziony'),
        }
    )
    def post(self, request):
        cennik_id = request.data.get('cennik_id')
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        # Weryfikacja uprawnień jako admin
        if not ac_user.is_admin():
            return Response({'error': 'User is not Admin'}, status=403)

        # Wyszukanie i usunięcie certyfikatu
        try:
            cennik = Cennik.objects.get(id=cennik_id, ac_user=ac_user)
            cennik.delete()
            return Response({'status': 'Cennik deleted'}, status=200)
        except:
            return Response({'error': 'Cennik not found'}, status=404)


class UlotkaAddAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Dodaj ulotkę (tylko dla admina)",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'file': openapi.Schema(type=openapi.TYPE_FILE, description='Plik ulotki'),
            }
        ),
        responses={
            201: openapi.Response('Ulotka utworzona'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'Wrong Token.'}, status=400)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        if not ac_user.is_admin():
            return Response({'error': 'User is not Admin'}, status=400)

        serializer = UlotkaSerializer(data=request.data, partial=True)
        if not serializer.is_valid():
            return Response(serializer.errors, status=400)

        # Save the object with additional data
        serializer.save(ac_user=ac_user)
        return Response({'status': 'Ulotka created'}, status=201)


class UlotkaListAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz listę ulotek",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
            }
        ),
        responses={
            200: openapi.Response('Lista ulotek'),
            400: openapi.Response('Błąd walidacji'),
            404: openapi.Response('Użytkownik nie znaleziony'),
        }
    )
    def post(self, request):
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        ulotki_json = []
        admin_ids = []

        if ac_user.is_admin():
            admin_ids.append(ac_user.id)
        elif ac_user.is_monter() and ac_user.parent:
            admin_ids.append(ac_user.parent_id)
        elif ac_user.is_klient():
            monters = ac_user.monter.all()
            for monter in monters:
                if monter.is_admin():
                    admin_ids.append(monter.id)

        if not admin_ids:
            return Response({'error': 'No admins found.'}, status=404)

        # Optymalizacja: użyj many=True zamiast pętli
        ulotki = Ulotka.objects.filter(ac_user__id__in=admin_ids)
        serializer = UlotkaSerializer(
            ulotki, many=True, context={'request': request})
        return Response({'ulotki': serializer.data}, status=200)


class UlotkaDeleteAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Usuń ulotkę (tylko dla admina)",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'ulotka_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'ulotka_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID ulotki'),
            }
        ),
        responses={
            200: openapi.Response('Ulotka usunięta'),
            400: openapi.Response('Błąd walidacji'),
            403: openapi.Response('Brak uprawnień'),
            404: openapi.Response('Ulotka nie znaleziona'),
        }
    )
    def post(self, request):
        ulotka_id = request.data.get('ulotka_id')
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        # Weryfikacja uprawnień jako admin
        if not ac_user.is_admin():
            return Response({'error': 'User is not Admin'}, status=403)

        # Wyszukanie i usunięcie certyfikatu
        try:
            ulotka = Ulotka.objects.get(id=ulotka_id, ac_user=ac_user)
            ulotka.delete()
            return Response({'status': 'Ulotka deleted'}, status=200)
        except:
            return Response({'error': 'Ulotka not found'}, status=404)


class PhotoListApiView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz listę zdjęć z opcjonalnymi filtrami",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'klient': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID klienta (filtr)'),
                'montaz_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID montażu (filtr)'),
                'serwis_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID serwisu (filtr)'),
                'instalacja_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID instalacji (filtr)'),
            }
        ),
        responses={
            200: openapi.Response('Lista zdjęć'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user or not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)
        if ac_user.is_monter() or ac_user.is_admin():
            photo_json = []
            photo_set = Photo.objects.all()
            if ac_user.is_monter():
                if request.data.get('klient'):
                    photo_set = Photo.objects.filter(
                        klient=request.data.get('klient'))
            elif ac_user.is_admin():
                photo_set = Photo.objects.all()

            # Filtruj po montaz_id jeśli jest podane
            if request.data.get('montaz_id'):
                photo_set = photo_set.filter(
                    montaz=request.data.get('montaz_id'))

            # Filtruj po serwis_id jeśli jest podane
            if request.data.get('serwis_id'):
                photo_set = photo_set.filter(
                    serwis=request.data.get('serwis_id'))

            # Filtruj po instalacja_id jeśli jest podane
            if request.data.get('instalacja_id'):
                photo_set = photo_set.filter(
                    instalacja=request.data.get('instalacja_id'))

            print(
                f"Found {photo_set.count()} photos for user {ac_user.email}")
            for photo in photo_set:
                photo_data = PhotoSerializer(instance=photo, context={
                                             'request': request}).data
                print(
                    f"Photo ID {photo.id}: image path = {photo_data.get('image')}")
                photo_json.append(photo_data)
            print("Returning photo_json:", photo_json)
            return Response({'zdjecia': photo_json}, status=200)
        return Response({'error': 'Wrong Token.'}, status=400)


class AddPhotoApiView(APIView):
    @swagger_auto_schema(
        operation_description="Dodaj zdjęcie (tylko dla montażysty lub admina)",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'image'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'image': openapi.Schema(type=openapi.TYPE_FILE, description='Plik zdjęcia'),
                'klient': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID klienta'),
                'instalacja_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID instalacji'),
                'montaz_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID montażu'),
                'serwis_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID serwisu'),
                'inspekcja': openapi.Schema(type=openapi.TYPE_STRING, description='Czy zdjęcie jest inspekcją (true/false)'),
            }
        ),
        responses={
            201: openapi.Response('Zdjęcie utworzone'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        print("=== ADD PHOTO API VIEW ===")
        print("Request data:", request.data)
        print("Request files:", request.FILES)
        print("Content type:", request.content_type)

        token = request.data.get('token')

        # Sprawdź czy plik image jest w request.FILES
        if 'image' not in request.FILES:
            print("ERROR: No 'image' file in request.FILES")
            return Response({'error': 'No image file provided'}, status=400)

        image_file = request.FILES['image']
        print(
            f"Image file info: name={image_file.name}, size={image_file.size}, content_type={image_file.content_type}")

        ac_user = get_cached_user(token)
        if not ac_user:
            print("ERROR: User not found with provided token")
            return Response({'error': 'Invalid token'}, status=400)

        print(f"User found: {ac_user.email}")

        if ac_user.check_token(token):
            if ac_user.is_monter() or ac_user.is_admin():
                # Przygotuj dane dla serializera
                data = {
                    'owner': ac_user.id,
                    'image': image_file,  # Użyj pliku z request.FILES
                }

                klient_id = request.data.get('klient')
                if klient_id not in [None, '', 'null', 'undefined']:
                    data['klient'] = klient_id

                # Obsługa powiązania ze specyficznymi elementami
                if request.data.get('instalacja_id'):
                    data['instalacja'] = request.data.get('instalacja_id')

                if request.data.get('montaz_id'):
                    data['montaz'] = request.data.get('montaz_id')

                if request.data.get('serwis_id'):
                    data['serwis'] = request.data.get('serwis_id')

                if request.data.get('inspekcja') == 'true' and request.data.get('instalacja_id'):
                    # Znajdź inspekcję dla tej instalacji, jeśli nie istnieje - utwórz ją
                    try:
                        instalacja = Instalacja.objects.get(
                            id=request.data.get('instalacja_id'))
                        inspekcja = instalacja.inspekcje.first()  # Pierwsza inspekcja dla instalacji
                        if not inspekcja:
                            # Utwórz nową inspekcję dla tej instalacji
                            inspekcja = Inspekcja.objects.create(
                                instalacja=instalacja)
                            print(
                                f"Created new inspekcja for installation {instalacja.id}")

                        # Użyj ID inspekcji zamiast obiektu
                        data['inspekcja'] = inspekcja.id
                        print(
                            f"Photo will be linked to inspekcja ID: {inspekcja.id}")
                    except Instalacja.DoesNotExist:
                        print(
                            f"Installation with ID {request.data.get('instalacja_id')} not found")

                print("Data for serializer:", {
                      k: v if k != 'image' else f'<File: {v.name}>' for k, v in data.items()})

                serializer = PhotoSerializer(data=data)
                if serializer.is_valid():
                    photo = serializer.save()
                    print("Photo saved successfully with image path:",
                          photo.image.url)
                    return Response({'status': 'Photo created', 'image_url': photo.image.url, 'photo_id': photo.id}, status=201)

                print("Serializer errors:", serializer.errors)
                return Response(serializer.errors, status=400)
            return Response({'error': 'User is not monter or admin'}, status=400)
        return Response({'error': 'Wrong Token.'}, status=400)


class EditPhotoApiView(APIView):
    @swagger_auto_schema(
        operation_description="Edytuj zdjęcie (tylko dla montażysty lub admina)",
        request_body=PhotoSerializer,
        responses={
            201: openapi.Response('Zdjęcie zaktualizowane'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user or not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)
        if ac_user.is_monter() or ac_user.is_admin():
            photo_id = request.data.get('photo_id')
            photo = Photo.objects.get(id=photo_id)
            serializer = PhotoSerializer(
                photo, data=request.data, partial=True)
            if serializer.is_valid():
                serializer.save()
                return Response({'status': 'Photo updated'}, status=201)
            return Response(serializer.errors, status=400)
        return Response({'error': 'User is not monter or admin'}, status=400)


class PhotoDeleteApiView(APIView):
    @swagger_auto_schema(
        operation_description="Usuń zdjęcie (tylko dla montażysty lub admina)",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'photo_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'photo_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID zdjęcia'),
            }
        ),
        responses={
            200: openapi.Response('Zdjęcie usunięte'),
            400: openapi.Response('Błąd walidacji'),
            403: openapi.Response('Brak uprawnień'),
            404: openapi.Response('Zdjęcie nie znalezione'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')
        photo_id = request.data.get('photo_id')

        if not photo_id:
            return Response({'error': 'Photo ID is required'}, status=400)

        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'Wrong Token.'}, status=400)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        if not (ac_user.is_monter() or ac_user.is_admin()):
            return Response({'error': 'User is not monter or admin'}, status=403)

        try:
            photo = Photo.objects.get(id=photo_id)
        except Photo.DoesNotExist:
            return Response({'error': 'Photo not found'}, status=404)

        if ac_user.is_monter() and photo.owner_id != ac_user.id:
            return Response({'error': 'User is not owner of photo'}, status=403)

        photo.delete()
        return Response({'status': 'Photo deleted'}, status=200)


class AddTagApiView(APIView):
    @swagger_auto_schema(
        operation_description="Dodaj tag",
        request_body=TagSerializer,
        responses={
            201: openapi.Response('Tag utworzony'),
            400: openapi.Response('Błąd walidacji lub tag już istnieje'),
        }
    )
    def post(self, request):
        print("=== ADD TAG API DEBUG ===")
        print(f"Request data: {request.data}")
        print(f"Request data type: {type(request.data)}")
        print(
            f"Request data keys: {list(request.data.keys()) if hasattr(request.data, 'keys') else 'No keys'}")

        token = request.data.get('token')
        print(f"Token: {token}")

        name = request.data.get('name')
        print(f"Name field: {name}")
        print(f"Name field type: {type(name)}")
        print(f"Name field empty: {not name}")
        print(f"Name field stripped: {name.strip() if name else 'None'}")

        ac_user = get_cached_user(token)
        if not ac_user:
            print("User not found")
            return Response({'error': 'User not found'}, status=400)

        print(f"User found: {ac_user}")

        if not ac_user.check_token(token):
            print("Token is invalid")
            return Response({'error': 'Wrong Token.'}, status=400)

        print("Token is valid")

        if ac_user.is_klient():
            print("User is klient - returning error")
            return Response({'error': 'User is klient'}, status=400)

        print("Creating serializer with data:", request.data)
        serializer = TagSerializer(data=request.data)
        print(f"Serializer is valid: {serializer.is_valid()}")

        if not serializer.is_valid():
            print(f"Serializer errors: {serializer.errors}")
            return Response(serializer.errors, status=400)

        if Tag.objects.filter(name=request.data.get('name')).exists():
            print("Tag already exists")
            return Response({'error': 'This token exists'}, status=400)

        print("Saving tag...")
        serializer.save()
        print("Tag saved successfully")
        return Response({'status': 'Tag created'}, status=201)


class TagListApiView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz listę wszystkich tagów",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
            }
        ),
        responses={
            200: openapi.Response('Lista tagów'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user or not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)
        # Optymalizacja: użyj many=True zamiast pętli
        tags = Tag.objects.all()
        serializer = TagSerializer(tags, many=True)
        return Response({'tag_list': serializer.data}, status=200)

###############################


class GroupsByOwnerAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz listę grup użytkownika z użytkownikami w każdej grupie",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
            }
        ),
        responses={
            200: openapi.Response('Lista grup'),
            404: openapi.Response('Użytkownik nie znaleziony'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')

        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)

        print("User: ", ac_user.id)

        groups = Group.objects.filter(owner=int(ac_user.id))
        result = []

        for group in groups:
            users_in_group = ACUser.objects.filter(group=group)
            user_ids = users_in_group.values_list('id', flat=True)
            result.append({
                'id': group.id,
                'nazwa': group.nazwa,
                'user_ids': list(user_ids)
            })

        print("Ekipy: ", result)

        return Response(result)


class GroupEditAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Edytuj grupę - zmień nazwę i przypisanych użytkowników",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'group_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'group_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID grupy'),
                'nazwa': openapi.Schema(type=openapi.TYPE_STRING, description='Nowa nazwa grupy'),
                'user_ids': openapi.Schema(
                    type=openapi.TYPE_ARRAY,
                    items=openapi.Schema(type=openapi.TYPE_INTEGER),
                    description='Lista ID użytkowników w grupie'
                ),
            }
        ),
        responses={
            200: openapi.Response('Grupa zaktualizowana'),
            400: openapi.Response('Błąd walidacji'),
            404: openapi.Response('Grupa nie znaleziona'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')

        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)
        group = get_object_or_404(Group, id=request.data.get('group_id'))

        group_name = request.data.get('nazwa')
        user_ids = request.data.get('user_ids', [])

        if group_name:
            group.nazwa = group_name
            group.save()

        # Usunięcie przynależności do grupy dla użytkowników, którzy już nie należą do tej grupy
        ACUser.objects.filter(group=group).exclude(
            id__in=user_ids).update(group=None)

        # Dodanie nowych użytkowników do grupy
        ACUser.objects.filter(id__in=user_ids).update(group=group)

        return Response({'message': 'Group updated successfully'}, status=200)


class AddGroupApiView(APIView):
    @swagger_auto_schema(
        operation_description="Dodaj nową grupę (tylko dla admina)",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'nazwa'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'nazwa': openapi.Schema(type=openapi.TYPE_STRING, description='Nazwa grupy'),
            }
        ),
        responses={
            200: openapi.Response('Grupa dodana'),
            400: openapi.Response('Błąd walidacji lub grupa już istnieje'),
        }
    )
    def post(self, request):
        pprint(request.data)
        print("Dodajemy grupe!!!!")
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'Wrong Token.'}, status=400)
        print('przed check_token')
        if ac_user.check_token(token):
            print('po check_token')
            if ac_user.is_admin():
                print('is admin')
                if Group.objects.filter(nazwa=request.data.get('nazwa')).exists():
                    print('group exists')
                    return Response({'error': 'Group exists'}, status=400)
                group = Group(nazwa=request.data.get(
                    'nazwa'), owner=ac_user.id)
                group.save()
                print('group saved')
                return Response({'status': 'Group added'}, status=200)
            return Response({'error': 'User is not Admin'}, status=400)
        return Response({'error': 'Wrong Token.'}, status=400)


class AddToGroupApiView(APIView):
    @swagger_auto_schema(
        operation_description="Dodaj montażystę do grupy (tylko dla admina)",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'id_monter', 'nazwa'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'id_monter': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID montażysty'),
                'nazwa': openapi.Schema(type=openapi.TYPE_STRING, description='Nazwa grupy'),
            }
        ),
        responses={
            200: openapi.Response('Montażysta dodany do grupy'),
            400: openapi.Response('Błąd walidacji lub grupa nie istnieje'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user or not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)
        if ac_user.is_admin():
            monter = ACUser.objects.get(id=request.data.get('id_monter'))
            if ac_user.get_children().filter(id=monter.id).exists():
                try:
                    group = Group.objects.get(
                        nazwa=request.data.get('nazwa'), owner=ac_user.id)
                    monter.group = group
                    monter.save()
                    return Response({'status': 'Monter added to group'}, status=200)
                except Group.DoesNotExist:
                    return Response({'error': 'Group not exist'}, status=400)
            return Response({'error': 'This id of monter not exist'}, status=400)
        return Response({'error': 'User is not Admin'}, status=400)


class RemoveGroupApiView(APIView):
    @swagger_auto_schema(
        operation_description="Usuń grupę (tylko dla admina)",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'nazwa'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'nazwa': openapi.Schema(type=openapi.TYPE_STRING, description='Nazwa grupy do usunięcia'),
            }
        ),
        responses={
            200: openapi.Response('Grupa usunięta'),
            400: openapi.Response('Błąd walidacji lub grupa nie istnieje'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user or not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)
        if ac_user.is_admin():
            try:
                group = Group.objects.get(
                    nazwa=request.data.get('nazwa'), owner=ac_user.id)
                group.delete()
                return Response({'status': 'Group deleted'}, status=200)
            except Group.DoesNotExist:
                return Response({'error': 'Group not exist'}, status=400)
        return Response({'error': 'User is not Admin'}, status=400)


class RemoveFromGroupApiView(APIView):
    @swagger_auto_schema(
        operation_description="Usuń montażystę z grupy (tylko dla admina)",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'id_monter'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'id_monter': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID montażysty'),
            }
        ),
        responses={
            200: openapi.Response('Montażysta usunięty z grupy'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user or not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)
        if ac_user.is_admin():
            monter = ACUser.objects.get(id=request.data.get('id_monter'))
            if ac_user.get_children().filter(id=monter.id).exists():
                monter.group = None
                monter.save()
                return Response({'status': 'Monter removed from group'}, status=200)
            return Response({'error': 'This id of monter not exist'}, status=400)
        return Response({'error': 'User is not Admin'}, status=400)


class InstallationDataApiView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz dane instalacji wraz ze zdjęciami inspekcji",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'instalacja_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'instalacja_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID instalacji'),
            }
        ),
        responses={
            200: openapi.Response('Dane instalacji'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user or not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)
        if ac_user.is_klient():
            return Response({'error': 'User is klient'}, status=400)

        instalacja = Instalacja.objects.get(
            id=request.data.get('instalacja_id'))
        serializer = InstalacjaSerializer(
            instalacja, context={'request': request})

        # Dodaj zdjęcia przypisane do inspekcji tej instalacji
        response_data = serializer.data

        # Znajdź inspekcję dla tej instalacji, jeśli nie istnieje - utwórz ją
        inspekcja = instalacja.inspekcje.first()
        if not inspekcja:
            # Utwórz nową inspekcję dla tej instalacji
            inspekcja = Inspekcja.objects.create(instalacja=instalacja)
            print(f"Created new inspekcja for installation {instalacja.id}")

        # Pobierz zdjęcia przypisane do tej inspekcji za pomocą related_name
        inspection_photos = inspekcja.inspection_photos.all()
        photos_data = []
        for photo in inspection_photos:
            photo_serializer = PhotoSerializer(
                photo, context={'request': request})
            photos_data.append(photo_serializer.data)
        response_data['photos'] = photos_data
        print(
            f"Found {len(photos_data)} photos for inspekcja ID {inspekcja.id}")

        # Dodaj dane inspekcji do odpowiedzi
        inspekcja_serializer = InspekcjaSerializer(
            inspekcja, context={'request': request})
        response_data['inspekcja'] = [inspekcja_serializer.data]

        return Response(response_data, status=200)


class InstallationEditApiView(APIView):
    @swagger_auto_schema(
        operation_description="Edytuj instalację",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'installation_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'installation_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID instalacji'),
                'name': openapi.Schema(type=openapi.TYPE_STRING, description='Nazwa instalacji'),
                'ulica': openapi.Schema(type=openapi.TYPE_STRING, description='Ulica'),
                'numer_domu': openapi.Schema(type=openapi.TYPE_STRING, description='Numer domu'),
                'mieszkanie': openapi.Schema(type=openapi.TYPE_STRING, description='Mieszkanie'),
                'kod_pocztowy': openapi.Schema(type=openapi.TYPE_STRING, description='Kod pocztowy'),
                'miasto': openapi.Schema(type=openapi.TYPE_STRING, description='Miasto'),
            }
        ),
        responses={
            200: openapi.Response('Instalacja zaktualizowana'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')
        installation_id = request.data.get('installation_id')

        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'Invalid token'}, status=400)

        if ac_user.check_token(token):
            try:
                instalacja = Instalacja.objects.get(id=installation_id)

                # Aktualizacja nazwy
                if 'name' in request.data:
                    instalacja.name = request.data.get('name')

                # Aktualizacja pól adresowych
                instalacja.ulica = request.data.get('ulica') or None
                instalacja.numer_domu = request.data.get('numer_domu') or None
                instalacja.mieszkanie = request.data.get('mieszkanie') or None
                instalacja.kod_pocztowy = request.data.get(
                    'kod_pocztowy') or None
                instalacja.miasto = request.data.get('miasto') or None

                instalacja.save()
                return Response({'status': 'Installation updated'}, status=200)
            except Instalacja.DoesNotExist:
                return Response({'error': 'Installation not found'}, status=400)
        return Response({'error': 'Wrong Token'}, status=400)


class InstallationCreateApiView(APIView):
    @swagger_auto_schema(
        operation_description="Utwórz nową instalację",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'klient_id', 'name'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'klient_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID klienta'),
                'name': openapi.Schema(type=openapi.TYPE_STRING, description='Nazwa instalacji'),
            }
        ),
        responses={
            200: openapi.Response('Instalacja utworzona'),
            400: openapi.Response('Błąd walidacji'),
            500: openapi.Response('Błąd serwera'),
        }
    )
    def post(self, request):
        try:
            print('=== InstallationCreateApiView START ===')
            print('Request data:', request.data)

            token = request.data.get('token')
            klient_id = request.data.get('klient_id')
            name = request.data.get('name')

            print(f'token: {token}')
            print(f'klient_id: {klient_id} (type: {type(klient_id)})')
            print(f'name: {name}')

            if not token:
                print('ERROR: No token provided')
                return Response({'error': 'Token required'}, status=400)

            if not klient_id:
                print('ERROR: No klient_id provided')
                return Response({'error': 'Client ID required'}, status=400)

            if not name:
                print('ERROR: No name provided')
                return Response({'error': 'Installation name required'}, status=400)

            owner = get_cached_user(token)
            if owner:
                print(f'Owner found: {owner.email} (id: {owner.id})')
            else:
                print('ERROR: Owner not found with token:', token)
                return Response({'error': 'Invalid token'}, status=400)

            try:
                klient = ACUser.objects.get(id=klient_id)
                print(
                    f'Client found: {klient.email} (id: {klient.id}, type: {klient.user_type})')
            except ACUser.DoesNotExist:
                print(f'ERROR: Client not found with id: {klient_id}')
                # Sprawdźmy dostępnych klientów
                all_clients = ACUser.objects.filter(user_type='klient')
                print(
                    f'Available clients: {[(c.id, c.email) for c in all_clients]}')
                return Response({'error': 'Client not found'}, status=400)

            if not owner.check_token(token):
                print('ERROR: Token validation failed')
                return Response({'error': 'Invalid token'}, status=400)

            print('Creating installation...')
            instalacja = Instalacja.objects.create(
                owner=owner,
                klient=klient,
                name=name,
            )
            print(f'Installation created: {instalacja.id}')

            print('Creating related objects...')
            Inspekcja.objects.create(instalacja=instalacja)
            Montaz.objects.create(instalacja=instalacja)
            # Nie tworzymy automatycznie Serwis - przeglądy będą tworzone ręcznie przez użytkownika

            print('=== InstallationCreateApiView SUCCESS ===')
            return Response({'status': 'Installation created'}, status=200)

        except Exception as e:
            print(f'=== InstallationCreateApiView ERROR: {str(e)} ===')
            import traceback
            print(traceback.format_exc())
            return Response({'error': 'Internal server error'}, status=500)


class InstallationDeleteApiView(APIView):
    @swagger_auto_schema(
        operation_description="Usuń instalację",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'installation_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'installation_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID instalacji'),
            }
        ),
        responses={
            200: openapi.Response('Instalacja usunięta'),
            400: openapi.Response('Błąd walidacji lub instalacja nie znaleziona'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')
        installation_id = request.data.get('installation_id')

        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'Invalid token'}, status=400)

        if ac_user.check_token(token):
            try:
                instalacja = Instalacja.objects.get(id=installation_id)
                instalacja.delete()
                return Response({'status': 'Installation deleted'}, status=200)
            except Instalacja.DoesNotExist:
                return Response({'error': 'Installation not found'}, status=400)
        return Response({'error': 'Wrong Token'}, status=400)


class InstallationListApiView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz listę instalacji dla klienta",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'klient_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'klient_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID klienta'),
            }
        ),
        responses={
            200: openapi.Response('Lista instalacji'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')
        klient_id = request.data.get('klient_id')

        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'Invalid token'}, status=400)

        if ac_user.check_token(token):
            installation_list_json = []
            # Optymalizacja: użyj select_related dla owner i klient
            installations = Instalacja.objects.filter(
                klient_id=klient_id).select_related('owner', 'klient')
            for installation in installations:
                tmp = {}
                tmp['id'] = installation.id
                tmp['owner'] = installation.owner.id
                tmp['klient_id'] = installation.klient_id
                tmp['created_date'] = installation.created_date
                tmp['name'] = installation.name
                tmp['ulica'] = installation.ulica
                tmp['numer_domu'] = installation.numer_domu
                tmp['mieszkanie'] = installation.mieszkanie
                tmp['kod_pocztowy'] = installation.kod_pocztowy
                tmp['miasto'] = installation.miasto
                installation_list_json.append(tmp)
            return Response({'installation_list': installation_list_json}, status=200)
        return Response({'error': 'Wrong Token'}, status=400)


class OfertaDataApiView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz dane oferty",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'oferta_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'oferta_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID oferty'),
            }
        ),
        responses={
            200: openapi.Response('Dane oferty'),
            400: openapi.Response('Błąd walidacji'),
            404: openapi.Response('Oferta nie znaleziona'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'Wrong Token.'}, status=400)
        oferta_id = request.data.get('oferta_id')
        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        try:
            # Optymalizacja: użyj select_related aby uniknąć dodatkowych zapytań
            oferta = Oferta.objects.select_related(
                'instalacja', 'instalacja__klient').get(id=oferta_id)
        except Oferta.DoesNotExist:
            return Response({'error': 'Oferta does not exist'}, status=404)

        serializer = OfertaReadSerializer(oferta)
        response_data = serializer.data

        # Dodaj informacje o kliencie i uprawnieniach
        if oferta.instalacja and oferta.instalacja.klient:
            client = oferta.instalacja.klient
            # Sprawdź i zaktualizuj has_account dla istniejących użytkowników
            client.check_if_has_account()

            response_data['client_id'] = client.id
            response_data['client_has_account'] = client.has_account
            response_data['is_current_user_client'] = (ac_user.id == client.id)
        else:
            response_data['client_id'] = None
            response_data['client_has_account'] = False
            response_data['is_current_user_client'] = False

        return Response(response_data, status=200)


class OfertaCreateApiView(APIView):
    @swagger_auto_schema(
        operation_description="Utwórz nową ofertę",
        request_body=OfertaSerializer,
        responses={
            201: openapi.Response('Oferta utworzona'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'Wrong Token.'}, status=400)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)
        if ac_user.is_klient():
            return Response({'error': 'User is klient'}, status=400)

        data = request.data.copy()  # Tworzenie kopii danych żądania
        data['creator'] = ac_user.id

        # Czyszczenie list z wartości None
        if 'narzut' in data:
            data['narzut'] = [x for x in data['narzut'] if x is not None]
        if 'rabat' in data:
            data['rabat'] = [x for x in data['rabat'] if x is not None]
        if 'devices_split' in data:
            data['devices_split'] = [
                x for x in data['devices_split'] if x is not None]
        if 'devices_multi_split' in data:
            data['devices_multi_split'] = [
                x for x in data['devices_multi_split'] if x is not None]

        serializer = OfertaSerializer(data=data)
        if serializer.is_valid():
            oferta = serializer.save()

            # Sprawdź czy oferta ma powiązaną instalację i klienta
            if oferta.instalacja and oferta.instalacja.klient:
                client = oferta.instalacja.klient
                sender = ac_user

                # Sprawdź i zaktualizuj has_account dla istniejących użytkowników
                client.check_if_has_account()

                # Wyślij powiadomienie push do klienta (jeśli ma konto)
                if client.has_account:
                    try:
                        from .utils.notification_service import \
                            NotificationService

                        # Pobierz nazwę oferty
                        offer_name = oferta.nazwa_oferty or f"Oferta #{oferta.id}"

                        NotificationService.send_notification(
                            user=client,
                            notification_type='offer_new',
                            title='Nowa oferta',
                            message=f'Utworzono nową ofertę: {offer_name}',
                            related_object_type='oferta',
                            related_object_id=oferta.id
                        )
                    except Exception as e:
                        print(
                            f"Failed to send push notification to client: {e}")

                # Pobierz email klienta - sprawdź czy nie jest tymczasowy
                client_email = client.email

                # Pomiń wysyłanie emaila jeśli email jest tymczasowy (@temp.local)
                if client_email and client_email.endswith('@temp.local'):
                    return Response(serializer.data, status=201)

                # Jeśli klient nie ma konta - wyślij zaproszenie z informacją o ofercie
                if not client.has_account:
                    # Sprawdź czy zaproszenie dla tego emaila już istnieje i jest aktywne
                    existing_invitation = Invitation.objects.filter(
                        email=client_email,
                        client=client,
                        used=False,
                        expires_at__gt=timezone.now()
                    ).first()

                    if not existing_invitation:
                        # Utwórz zaproszenie
                        invitation = Invitation(
                            email=client_email,
                            client=client,
                            created_by=sender,
                            expires_at=timezone.now() + timedelta(days=7)
                        )
                        invitation.generate_token()
                        invitation.save()
                        invitation_token = invitation.token
                    else:
                        invitation_token = existing_invitation.token

                    # Wygeneruj link zaproszenia
                    protocol = 'https' if not settings.DEBUG else 'http'
                    host = request.get_host()
                    base_url = f"{protocol}://{host}"
                    invitation_url = f"{base_url}/api/invite/?token={invitation_token}&email={client_email}"

                    # Wyślij email z zaproszeniem i informacją o ofercie asynchronicznie
                    @run_async
                    def send_invitation_email_with_offer():
                        try:
                            from django.conf import settings
                            from django.core.mail import send_mail

                            subject = 'Zaproszenie do aplikacji AC Manager - Nowa oferta'
                            message = f'''Witaj {client.first_name} {client.last_name}!

Utworzyliśmy dla Ciebie nową ofertę w aplikacji AC Manager.

Aby zobaczyć szczegóły oferty i zarządzać nią, zarejestruj się w naszej aplikacji.

Kliknij w poniższy link, aby się zarejestrować:
{invitation_url}

Link jest ważny przez 7 dni.

Po rejestracji będziesz mógł:
- Przeglądać szczegóły oferty
- Akceptować lub modyfikować ofertę
- Śledzić status realizacji

Pozdrawiamy,
{sender.first_name} {sender.last_name}
Zespół AC Manager'''

                            send_mail(
                                subject=subject,
                                message=message,
                                from_email=getattr(
                                    settings, 'DEFAULT_FROM_EMAIL', 'noreply@acmanager.pl'),
                                recipient_list=[client_email],
                                fail_silently=False,
                            )
                        except Exception as e:
                            print(
                                f"Błąd podczas wysyłania emaila z zaproszeniem: {str(e)}")

                    send_invitation_email_with_offer()

                # Jeśli klient ma konto - wyślij informację o ofercie asynchronicznie
                else:
                    @run_async
                    def send_offer_notification_email():
                        try:
                            from django.conf import settings
                            from django.core.mail import send_mail

                            subject = 'Nowa oferta w aplikacji AC Manager'
                            message = f'''Witaj {client.first_name} {client.last_name}!

Utworzyliśmy dla Ciebie nową ofertę w aplikacji AC Manager.

Zaloguj się do aplikacji, aby zobaczyć szczegóły oferty i zarządzać nią.

Pozdrawiamy,
{sender.first_name} {sender.last_name}
Zespół AC Manager'''

                            send_mail(
                                subject=subject,
                                message=message,
                                from_email=getattr(
                                    settings, 'DEFAULT_FROM_EMAIL', 'noreply@acmanager.pl'),
                                recipient_list=[client_email],
                                fail_silently=False,
                            )
                        except Exception as e:
                            print(
                                f"Błąd podczas wysyłania emaila z informacją o ofercie: {str(e)}")

                    send_offer_notification_email()

            return Response(serializer.data, status=201)
        print("Validation errors:", serializer.errors)
        return Response(serializer.errors, status=400)


class OfertaAcceptApiView(APIView):
    @swagger_auto_schema(
        operation_description="Akceptuj lub odrzuć ofertę",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'oferta_id', 'is_accepted'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'oferta_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID oferty'),
                'is_accepted': openapi.Schema(type=openapi.TYPE_BOOLEAN, description='Czy oferta jest zaakceptowana'),
                'selected_device_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID wybranego urządzenia (opcjonalne)'),
            }
        ),
        responses={
            200: openapi.Response('Oferta zaktualizowana'),
            400: openapi.Response('Błąd walidacji'),
            404: openapi.Response('Oferta nie znaleziona'),
        }
    )
    def post(self, request):
        print("=== OFERTA ACCEPT API DEBUG ===")
        print("Request data:", request.data)

        # Pobranie użytkownika na podstawie tokenu
        token = request.data.get('token')
        oferta_id = request.data.get('oferta_id')
        selected_device_id = request.data.get('selected_device_id')
        is_accepted = request.data.get('is_accepted')

        print(f"Token: {token}")
        print(f"Oferta ID: {oferta_id} (type: {type(oferta_id)})")
        print(
            f"Selected device ID: {selected_device_id} (type: {type(selected_device_id)})")
        print(f"Is accepted: {is_accepted} (type: {type(is_accepted)})")

        ac_user = get_cached_user(token)
        if not ac_user:
            print("ERROR: User not found")
            return Response({'error': 'Invalid Token.'}, status=400)

        print(f"User found: {ac_user}")

        if not ac_user.check_token(token):
            print("ERROR: Token check failed")
            return Response({'error': 'Wrong Token.'}, status=400)

        # Sprawdź czy oferta istnieje
        print(f"Looking for oferta with ID: {oferta_id}")
        try:
            oferta = Oferta.objects.select_related(
                'creator', 'instalacja', 'instalacja__klient').get(id=oferta_id)
            print(f"Oferta found: {oferta}")
            print(f"Oferta current is_accepted: {oferta.is_accepted}")
            print(
                f"Oferta current selected_device_id: {oferta.selected_device_id}")
        except Oferta.DoesNotExist:
            print(f"ERROR: Oferta with ID {oferta_id} not found")
            # Sprawdź jakie oferty istnieją
            all_ofertas = Oferta.objects.all()
            print(f"Available ofertas: {[o.id for o in all_ofertas]}")
            return Response({'error': 'Oferta not found'}, status=404)

        # Aktualizacja danych oferty
        print("Updating oferta with data:", request.data)
        was_accepted_before = oferta.is_accepted
        serializer = OfertaSerializer(oferta, data=request.data, partial=True)
        if serializer.is_valid():
            print("Serializer is valid, saving...")
            updated_oferta = serializer.save()
            print(f"Oferta updated successfully: {updated_oferta}")
            print(f"Updated is_accepted: {updated_oferta.is_accepted}")
            print(
                f"Updated selected_device_id: {updated_oferta.selected_device_id}")

            # Wyślij powiadomienie do twórcy oferty, jeśli oferta została właśnie zaakceptowana
            if updated_oferta.is_accepted and not was_accepted_before and updated_oferta.creator:
                try:
                    from .utils.notification_service import NotificationService

                    # Sprawdź czy twórca to monter/admin
                    creator = updated_oferta.creator
                    if creator.is_admin() or creator.is_monter():
                        # Informacje o kliencie
                        client_name = "Nieznany klient"
                        if updated_oferta.instalacja and updated_oferta.instalacja.klient:
                            klient = updated_oferta.instalacja.klient
                            try:
                                user_data = UserData.objects.get(
                                    ac_user=klient)
                                client_name = user_data.nazwa_firmy or f"{klient.first_name} {klient.last_name}"
                            except UserData.DoesNotExist:
                                client_name = f"{klient.first_name} {klient.last_name}"

                        # Informacje o ofercie
                        oferta_title = f"Oferta #{updated_oferta.id}"
                        if updated_oferta.instalacja:
                            oferta_title = f"Oferta dla {client_name}"

                        NotificationService.send_notification(
                            user=creator,
                            notification_type='offer_accepted',
                            title='Oferta zaakceptowana',
                            message=f'{client_name} zaakceptował ofertę: {oferta_title}',
                            related_object_type='oferta',
                            related_object_id=updated_oferta.id
                        )
                except Exception as e:
                    print(
                        f"Failed to send push notification to offer creator: {e}")

            return Response(serializer.data, status=200)
        else:
            print("ERROR: Serializer validation failed")
            print("Serializer errors:", serializer.errors)
            return Response(serializer.errors, status=400)


class OfertaSendEmailApiView(APIView):
    @swagger_auto_schema(
        operation_description="Wyślij ofertę emailem do klienta (tylko dla admina lub montażysty)",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'oferta_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'oferta_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID oferty'),
            }
        ),
        responses={
            200: openapi.Response('Email wysłany'),
            400: openapi.Response('Błąd walidacji'),
            403: openapi.Response('Brak uprawnień'),
            404: openapi.Response('Oferta nie znaleziona'),
        }
    )
    def post(self, request):
        """Wysyła ofertę emailem do klienta"""
        token = request.data.get('token')
        oferta_id = request.data.get('oferta_id')

        # Weryfikacja użytkownika
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'Invalid Token.'}, status=400)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        # Sprawdź czy użytkownik to monter/admin
        if not (ac_user.is_admin() or ac_user.is_monter()):
            return Response({'error': 'Unauthorized. Only admin or monter can send offers.'}, status=403)

        # Pobierz ofertę
        try:
            oferta = Oferta.objects.select_related(
                'instalacja', 'instalacja__klient', 'creator').get(id=oferta_id)
        except Oferta.DoesNotExist:
            return Response({'error': 'Oferta not found'}, status=404)

        # Sprawdź czy oferta ma przypisaną instalację i klienta
        if not oferta.instalacja or not oferta.instalacja.klient:
            return Response({'error': 'Oferta must have an installation and client'}, status=400)

        klient = oferta.instalacja.klient

        # Sprawdź czy klient ma email
        if not klient.email:
            return Response({'error': 'Client does not have an email address'}, status=400)

        # Pobierz urządzenia z oferty
        if oferta.offer_type == 'split':
            devices = list(oferta.devices_split.all())
        else:
            devices = list(oferta.devices_multi_split.all())

        if not devices:
            return Response({'error': 'Oferta has no devices'}, status=400)

        # Pobierz rabaty dla oferty
        rabaty = oferta.rabat.all()
        rabat_dict = {r.producent: r.value for r in rabaty}

        # Pobierz narzuty dla oferty
        narzuty = oferta.narzut.all()
        surcharges_list = [{'name': n.name, 'value': n.value} for n in narzuty]

        # Oblicz ceny finalne dla urządzeń
        for device in devices:
            catalog_price = float(device.cena_katalogowa_netto)
            discount_value = rabat_dict.get(device.producent, 0)

            # Zastosuj rabat
            price = catalog_price
            if discount_value:
                price -= price * (discount_value / 100)

            # Dodaj narzuty
            total_surcharge = sum(s['value'] for s in surcharges_list)
            price += total_surcharge

            device.final_price = price

        # Pogrupuj urządzenia po producentach
        grouped_devices = {}
        for device in devices:
            if device.producent not in grouped_devices:
                grouped_devices[device.producent] = []
            grouped_devices[device.producent].append(device)

        # Pobierz dane firmy z UserData twórcy oferty
        try:
            creator_data = UserData.objects.get(ac_user=oferta.creator)
            company_name = creator_data.nazwa_firmy or f"{oferta.creator.first_name} {oferta.creator.last_name}"
            company_phone = creator_data.numer_telefonu or ''
        except UserData.DoesNotExist:
            company_name = f"{oferta.creator.first_name} {oferta.creator.last_name}"
            company_phone = ''

        # Przygotuj kontekst dla szablonu
        context = {
            'company_name': company_name,
            'company_email': oferta.creator.email,
            'company_phone': company_phone,
            'contact_person': f"{oferta.creator.first_name} {oferta.creator.last_name}",
            'contact_email': oferta.creator.email,
            'contact_phone': company_phone,
            'grouped_devices': grouped_devices,
            'surcharges': surcharges_list if surcharges_list else None,
            'app_link': f'ac-manager://offer/{oferta_id}',
        }

        # Renderuj szablon HTML
        html_content = render_to_string('offer_email.html', context)

        # Wyślij email
        try:
            from django.core.mail import EmailMessage

            subject = f'Oferta klimatyzacji - {company_name}'
            email_message = EmailMessage(
                subject=subject,
                body=html_content,
                from_email=settings.DEFAULT_FROM_EMAIL,
                to=[klient.email],
            )
            email_message.content_subtype = 'html'
            email_message.send()

            return Response({
                'success': True,
                'message': f'Email sent successfully to {klient.email}'
            }, status=200)

        except Exception as e:
            return Response({
                'error': f'Failed to send email: {str(e)}'
            }, status=500)


class AvailableMontazDatesApiView(APIView):
    @swagger_auto_schema(
        operation_description="Zwraca dostępne terminy montażu (dni robocze bez zaplanowanych zadań)",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'start_date': openapi.Schema(type=openapi.TYPE_STRING, description='Data początkowa (YYYY-MM-DD)', format='date'),
                'end_date': openapi.Schema(type=openapi.TYPE_STRING, description='Data końcowa (YYYY-MM-DD), domyślnie +30 dni', format='date'),
            }
        ),
        responses={
            200: openapi.Response('Lista dostępnych dat'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        """Zwraca dostępne terminy montażu (dni robocze bez zaplanowanych zadań)"""
        token = request.data.get('token')
        start_date_str = request.data.get('start_date')
        end_date_str = request.data.get('end_date')

        # Weryfikacja użytkownika
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'Invalid Token.'}, status=400)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        # Parsowanie dat
        try:
            start_date = datetime.strptime(
                start_date_str, '%Y-%m-%d').date() if start_date_str else datetime.now().date()
        except ValueError:
            return Response({'error': 'Invalid start_date format. Use YYYY-MM-DD'}, status=400)

        # Jeśli nie podano end_date, ustaw na +30 dni
        if end_date_str:
            try:
                end_date = datetime.strptime(end_date_str, '%Y-%m-%d').date()
            except ValueError:
                return Response({'error': 'Invalid end_date format. Use YYYY-MM-DD'}, status=400)
        else:
            end_date = start_date + timedelta(days=30)

        # Pobierz zadania w zakresie dat dla danego użytkownika (rodzica lub grupy)
        # Dla admina/montera - zadania które sam przypisał
        # Dla klienta - zadania powiązane z jego instalacjami
        if ac_user.is_admin() or ac_user.is_monter():
            zadania = Zadanie.objects.filter(
                rodzic=ac_user,
                start_date__date__range=[start_date, end_date]
            ).values_list('start_date', 'end_date')
        else:
            # Klient nie powinien mieć dostępu do tego endpointu w normalnym przypadku,
            # ale jeśli ma, pokaż zadania związane z jego instalacjami
            instalacje_ids = Instalacja.objects.filter(
                klient=ac_user).values_list('id', flat=True)
            zadania = Zadanie.objects.filter(
                instalacja_id__in=instalacje_ids,
                start_date__date__range=[start_date, end_date]
            ).values_list('start_date', 'end_date')

        # Stwórz zbiór zajętych dni
        occupied_dates = set()
        for start, end in zadania:
            current = start.date() if isinstance(start, datetime) else start
            end_dt = end.date() if isinstance(end, datetime) else end

            while current <= end_dt:
                occupied_dates.add(current)
                current += timedelta(days=1)

        # Generuj listę dostępnych dni roboczych
        available_dates = []
        current_date = start_date

        polish_days = {
            0: 'Poniedziałek',
            1: 'Wtorek',
            2: 'Środa',
            3: 'Czwartek',
            4: 'Piątek',
            5: 'Sobota',
            6: 'Niedziela'
        }

        while current_date <= end_date:
            # Sprawdź czy to dzień roboczy (0=pon, 4=pt)
            weekday = current_date.weekday()
            is_workday = weekday < 5  # Poniedziałek-Piątek

            # Sprawdź czy dzień jest dostępny
            is_available = current_date not in occupied_dates and is_workday

            if is_available:
                available_dates.append({
                    'date': current_date.strftime('%Y-%m-%d'),
                    'day_name': polish_days[weekday],
                    'is_available': True
                })

            current_date += timedelta(days=1)

        return Response({
            'available_dates': available_dates,
            'start_date': start_date.strftime('%Y-%m-%d'),
            'end_date': end_date.strftime('%Y-%m-%d')
        }, status=200)


class ProposeMontazDateApiView(APIView):
    @swagger_auto_schema(
        operation_description="Zaproponuj termin montażu (tylko dla klienta)",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'oferta_id', 'proposed_date'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'oferta_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID oferty'),
                'proposed_date': openapi.Schema(type=openapi.TYPE_STRING, description='Proponowana data (YYYY-MM-DD)', format='date'),
                'proposed_time': openapi.Schema(type=openapi.TYPE_STRING, description='Proponowana godzina (HH:MM)', format='time'),
            }
        ),
        responses={
            200: openapi.Response('Termin zaproponowany'),
            400: openapi.Response('Błąd walidacji'),
            403: openapi.Response('Brak uprawnień'),
            404: openapi.Response('Oferta nie znaleziona'),
        }
    )
    def post(self, request):
        """Pozwala klientowi zaproponować termin montażu"""
        token = request.data.get('token')
        oferta_id = request.data.get('oferta_id')
        proposed_date_str = request.data.get('proposed_date')
        proposed_time_str = request.data.get('proposed_time')

        # Weryfikacja użytkownika
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'Invalid Token.'}, status=400)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        # Pobierz ofertę
        try:
            oferta = Oferta.objects.select_related(
                'instalacja', 'instalacja__klient', 'creator').get(id=oferta_id)
        except Oferta.DoesNotExist:
            return Response({'error': 'Oferta not found'}, status=404)

        # Sprawdź czy oferta jest zaakceptowana
        if not oferta.is_accepted:
            return Response({'error': 'Oferta must be accepted before proposing a montaz date'}, status=400)

        # Sprawdź czy użytkownik to klient powiązany z ofertą
        if oferta.instalacja and oferta.instalacja.klient:
            if ac_user.id != oferta.instalacja.klient.id and not (ac_user.is_admin() or ac_user.is_monter()):
                return Response({'error': 'Unauthorized. Only the client can propose a date.'}, status=403)

        # Parsowanie daty
        try:
            proposed_date = datetime.strptime(
                proposed_date_str, '%Y-%m-%d').date()
        except (ValueError, TypeError):
            return Response({'error': 'Invalid proposed_date format. Use YYYY-MM-DD'}, status=400)

        # Sprawdź czy data to dzień roboczy (pn-pt)
        if proposed_date.weekday() >= 5:
            return Response({'error': 'Proposed date must be a workday (Monday-Friday)'}, status=400)

        # Parsowanie godziny (opcjonalnie)
        proposed_time = None
        if proposed_time_str:
            try:
                proposed_time = datetime.strptime(
                    proposed_time_str, '%H:%M').time()
            except (ValueError, TypeError):
                return Response({'error': 'Invalid proposed_time format. Use HH:MM'}, status=400)

        # Aktualizuj ofertę
        oferta.proposed_montaz_date = proposed_date
        oferta.proposed_montaz_time = proposed_time
        oferta.montaz_status = 'pending'
        oferta.save()

        # Wyślij powiadomienie do twórcy oferty o nowej propozycji
        if oferta.creator:
            try:
                from .utils.notification_service import NotificationService

                # Sprawdź czy twórca to monter/admin
                creator = oferta.creator
                if creator.is_admin() or creator.is_monter():
                    # Informacje o kliencie
                    client_name = "Nieznany klient"
                    if oferta.instalacja and oferta.instalacja.klient:
                        klient = oferta.instalacja.klient
                        try:
                            user_data = UserData.objects.get(ac_user=klient)
                            client_name = user_data.nazwa_firmy or f"{klient.first_name} {klient.last_name}"
                        except UserData.DoesNotExist:
                            client_name = f"{klient.first_name} {klient.last_name}"

                    NotificationService.send_notification(
                        user=creator,
                        notification_type='montaz_proposed',
                        title='Nowa propozycja terminu montażu',
                        message=f'{client_name} zaproponował termin montażu: {proposed_date.strftime("%d.%m.%Y")}',
                        related_object_type='oferta',
                        related_object_id=oferta.id
                    )
            except Exception as e:
                print(
                    f"Failed to send push notification to offer creator: {e}")

        return Response({
            'success': True,
            'message': 'Montaz date proposed successfully',
            'oferta_id': oferta.id,
            'proposed_date': proposed_date.strftime('%Y-%m-%d'),
            'proposed_time': proposed_time.strftime('%H:%M') if proposed_time else None,
            'montaz_status': oferta.montaz_status
        }, status=200)


class ConfirmMontazDateApiView(APIView):
    @swagger_auto_schema(
        operation_description="Zaakceptuj zaproponowany termin montażu (tylko dla montażysty lub admina)",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'oferta_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'oferta_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID oferty'),
            }
        ),
        responses={
            200: openapi.Response('Termin potwierdzony i zadanie utworzone'),
            400: openapi.Response('Błąd walidacji'),
            403: openapi.Response('Brak uprawnień'),
            404: openapi.Response('Oferta nie znaleziona'),
            500: openapi.Response('Błąd serwera'),
        }
    )
    def post(self, request):
        """Pozwala monterowi/adminowi zaakceptować zaproponowany termin montażu"""
        token = request.data.get('token')
        oferta_id = request.data.get('oferta_id')

        # Weryfikacja użytkownika
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'Invalid Token.'}, status=400)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        # Sprawdź czy użytkownik to monter/admin
        if not (ac_user.is_admin() or ac_user.is_monter()):
            return Response({'error': 'Unauthorized. Only admin or monter can confirm dates.'}, status=403)

        # Pobierz ofertę
        try:
            oferta = Oferta.objects.select_related(
                'instalacja', 'instalacja__klient').get(id=oferta_id)
        except Oferta.DoesNotExist:
            return Response({'error': 'Oferta not found'}, status=404)

        # Sprawdź czy oferta ma zaproponowany termin
        if oferta.montaz_status != 'pending':
            return Response({'error': 'No pending montaz proposal for this offer'}, status=400)

        if not oferta.proposed_montaz_date:
            return Response({'error': 'No proposed date found'}, status=400)

        # Utwórz zadanie montażu w kalendarzu
        try:
            # Przygotuj datę i czas rozpoczęcia
            start_datetime = datetime.combine(
                oferta.proposed_montaz_date,
                oferta.proposed_montaz_time or datetime.min.time()
            )

            # Ustaw czas zakończenia na koniec dnia
            end_datetime = datetime.combine(
                oferta.proposed_montaz_date,
                datetime.max.time().replace(microsecond=0)
            )

            # Pobierz nazwę klienta
            if oferta.instalacja and oferta.instalacja.klient:
                klient = oferta.instalacja.klient
                try:
                    user_data = UserData.objects.get(ac_user=klient)
                    client_name = user_data.nazwa_firmy or f"{klient.first_name} {klient.last_name}"
                except UserData.DoesNotExist:
                    client_name = f"{klient.first_name} {klient.last_name}"
            else:
                client_name = "Nieznany klient"

            # Utwórz zadanie
            zadanie = Zadanie.objects.create(
                rodzic=ac_user,
                instalacja=oferta.instalacja,
                typ='montaż',
                status='Zaplanowane',
                start_date=start_datetime,
                end_date=end_datetime,
                nazwa=f"Montaż - {client_name}",
                czy_oferta=True,
                notatki=f"Automatycznie utworzone z oferty #{oferta.id}"
            )

            # Powiąż zadanie z ofertą
            oferta.montaz_zadanie = zadanie
            oferta.montaz_status = 'confirmed'
            oferta.save()

            # Opcjonalnie: Wyślij email potwierdzający do klienta
            if oferta.instalacja and oferta.instalacja.klient and oferta.instalacja.klient.email:
                try:
                    from django.core.mail import send_mail

                    subject = f'Termin montażu potwierdzony - {oferta.proposed_montaz_date.strftime("%d.%m.%Y")}'
                    message = f"""
Dzień dobry,

Potwierdzamy termin montażu klimatyzacji:

Data: {oferta.proposed_montaz_date.strftime('%d.%m.%Y')} ({['Poniedziałek', 'Wtorek', 'Środa', 'Czwartek', 'Piątek', 'Sobota', 'Niedziela'][oferta.proposed_montaz_date.weekday()]})
{f"Godzina: {oferta.proposed_montaz_time.strftime('%H:%M')}" if oferta.proposed_montaz_time else ""}

W razie pytań prosimy o kontakt.

Pozdrawiamy,
{ac_user.first_name} {ac_user.last_name}
                    """

                    send_mail(
                        subject=subject,
                        message=message,
                        from_email=settings.DEFAULT_FROM_EMAIL,
                        recipient_list=[oferta.instalacja.klient.email],
                        fail_silently=True,
                    )
                except Exception as e:
                    print(f"Failed to send confirmation email: {e}")

            # Wyślij powiadomienie push do klienta
            if oferta.instalacja and oferta.instalacja.klient:
                try:
                    from .utils.notification_service import NotificationService
                    NotificationService.send_notification(
                        user=oferta.instalacja.klient,
                        notification_type='montaz_confirmed',
                        title='Termin montażu potwierdzony',
                        message=f'Termin montażu został potwierdzony na {oferta.proposed_montaz_date.strftime("%d.%m.%Y")}',
                        related_object_type='oferta',
                        related_object_id=oferta.id
                    )
                except Exception as e:
                    print(f"Failed to send push notification: {e}")

            return Response({
                'success': True,
                'message': 'Montaz date confirmed and task created',
                'zadanie_id': zadanie.id,
                'oferta_id': oferta.id,
                'montaz_status': oferta.montaz_status
            }, status=200)

        except Exception as e:
            return Response({
                'error': f'Failed to create task: {str(e)}'
            }, status=500)


class RejectMontazDateApiView(APIView):
    @swagger_auto_schema(
        operation_description="Odrzuć zaproponowany termin montażu (tylko dla montażysty lub admina)",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'oferta_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'oferta_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID oferty'),
                'rejection_reason': openapi.Schema(type=openapi.TYPE_STRING, description='Powód odrzucenia'),
            }
        ),
        responses={
            200: openapi.Response('Termin odrzucony'),
            400: openapi.Response('Błąd walidacji'),
            403: openapi.Response('Brak uprawnień'),
            404: openapi.Response('Oferta nie znaleziona'),
        }
    )
    def post(self, request):
        """Pozwala monterowi/adminowi odrzucić zaproponowany termin montażu"""
        token = request.data.get('token')
        oferta_id = request.data.get('oferta_id')
        rejection_reason = request.data.get('rejection_reason', '')

        # Weryfikacja użytkownika
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'Invalid Token.'}, status=400)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        # Sprawdź czy użytkownik to monter/admin
        if not (ac_user.is_admin() or ac_user.is_monter()):
            return Response({'error': 'Unauthorized. Only admin or monter can reject dates.'}, status=403)

        # Pobierz ofertę
        try:
            oferta = Oferta.objects.select_related(
                'instalacja', 'instalacja__klient').get(id=oferta_id)
        except Oferta.DoesNotExist:
            return Response({'error': 'Oferta not found'}, status=404)

        # Sprawdź czy oferta ma zaproponowany termin
        if oferta.montaz_status != 'pending':
            return Response({'error': 'No pending montaz proposal for this offer'}, status=400)

        # Odrzuć termin
        oferta.montaz_status = 'rejected'
        oferta.rejection_reason = rejection_reason
        oferta.save()

        # Opcjonalnie: Wyślij powiadomienie do klienta
        if oferta.instalacja and oferta.instalacja.klient and oferta.instalacja.klient.email:
            try:
                from django.core.mail import send_mail

                subject = 'Termin montażu wymaga zmiany'
                message = f"""
Dzień dobry,

Niestety zaproponowany termin montażu ({oferta.proposed_montaz_date.strftime('%d.%m.%Y')}) nie jest dostępny.

{f"Powód: {rejection_reason}" if rejection_reason else ""}

Prosimy o zaproponowanie innego terminu w aplikacji.

Pozdrawiamy,
{ac_user.first_name} {ac_user.last_name}
                """

                send_mail(
                    subject=subject,
                    message=message,
                    from_email=settings.DEFAULT_FROM_EMAIL,
                    recipient_list=[oferta.instalacja.klient.email],
                    fail_silently=True,
                )
            except Exception as e:
                print(f"Failed to send rejection email: {e}")

        # Wyślij powiadomienie push do klienta
        if oferta.instalacja and oferta.instalacja.klient:
            try:
                from .utils.notification_service import NotificationService
                NotificationService.send_notification(
                    user=oferta.instalacja.klient,
                    notification_type='montaz_rejected',
                    title='Termin montażu odrzucony',
                    message=f'Termin montażu został odrzucony. {rejection_reason or "Proszę zaproponować inny termin."}',
                    related_object_type='oferta',
                    related_object_id=oferta.id
                )
            except Exception as e:
                print(f"Failed to send push notification: {e}")

        return Response({
            'success': True,
            'message': 'Montaz date rejected',
            'oferta_id': oferta.id,
            'montaz_status': oferta.montaz_status,
            'rejection_reason': rejection_reason
        }, status=200)


class PendingMontazProposalsApiView(APIView):
    @swagger_auto_schema(
        operation_description="Zwraca listę ofert z oczekującymi propozycjami terminów montażu",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
            }
        ),
        responses={
            200: openapi.Response('Lista ofert z oczekującymi propozycjami'),
            400: openapi.Response('Błąd walidacji'),
            403: openapi.Response('Brak uprawnień'),
        }
    )
    def post(self, request):
        """Zwraca listę ofert z oczekującymi propozycjami terminów montażu"""
        token = request.data.get('token')

        # Weryfikacja użytkownika
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'Invalid Token.'}, status=400)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        # Sprawdź czy użytkownik to monter/admin
        if not (ac_user.is_admin() or ac_user.is_monter()):
            return Response({'error': 'Unauthorized. Only admin or monter can view proposals.'}, status=403)

        # Pobierz oferty z oczekującymi propozycjami
        pending_ofertas = Oferta.objects.filter(
            creator=ac_user,
            montaz_status='pending'
        ).select_related('instalacja', 'instalacja__klient').order_by('proposed_montaz_date')

        # Przygotuj dane do zwrócenia
        proposals = []
        for oferta in pending_ofertas:
            klient_data = {}
            if oferta.instalacja and oferta.instalacja.klient:
                klient = oferta.instalacja.klient
                try:
                    user_data = UserData.objects.get(ac_user=klient)
                    klient_data = {
                        'id': klient.id,
                        'first_name': klient.first_name,
                        'last_name': klient.last_name,
                        'email': klient.email,
                        'nazwa_firmy': user_data.nazwa_firmy,
                        'numer_telefonu': user_data.numer_telefonu,
                        'miasto': user_data.miasto,
                        'ulica': user_data.ulica,
                        'numer_domu': user_data.numer_domu,
                    }
                except UserData.DoesNotExist:
                    klient_data = {
                        'id': klient.id,
                        'first_name': klient.first_name,
                        'last_name': klient.last_name,
                        'email': klient.email,
                    }

            proposals.append({
                'oferta_id': oferta.id,
                'nazwa_oferty': oferta.nazwa_oferty,
                'proposed_date': oferta.proposed_montaz_date.strftime('%Y-%m-%d') if oferta.proposed_montaz_date else None,
                'proposed_time': oferta.proposed_montaz_time.strftime('%H:%M') if oferta.proposed_montaz_time else None,
                'klient': klient_data,
                'instalacja_id': oferta.instalacja.id if oferta.instalacja else None,
                'created_date': oferta.created_date.strftime('%Y-%m-%d %H:%M:%S'),
            })

        return Response({
            'proposals': proposals,
            'count': len(proposals)
        }, status=200)


class OfertaListApiView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz listę ofert użytkownika",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
            }
        ),
        responses={
            200: openapi.Response('Lista ofert'),
            400: openapi.Response('Błąd walidacji'),
            403: openapi.Response('Brak uprawnień'),
        }
    )
    def post(self, request):
        pprint(request.data)
        # Pobranie użytkownika na podstawie tokenu
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'Invalid Token.'}, status=400)

        if ac_user.is_admin():
            # Zwróć wszystkie oferty użytkownika (z klientami i bez klientów)
            # Optymalizacja: użyj select_related dla instalacja i klient
            oferty = Oferta.objects.filter(creator=ac_user).select_related(
                'instalacja', 'instalacja__klient')
        elif ac_user.is_monter():
            # Monter widzi oferty utworzone przez siebie
            oferty = Oferta.objects.filter(creator=ac_user).select_related(
                'instalacja', 'instalacja__klient')
        elif ac_user.is_klient():
            # Optymalizacja: użyj select_related i prefetch_related aby uniknąć problemu N+1
            instalacje = Instalacja.objects.filter(klient_id=ac_user.id)
            instalacja_ids = list(instalacje.values_list('id', flat=True))
            # Pobierz wszystkie oferty dla instalacji w jednym zapytaniu
            # Tylko oferty nie będące szablonami
            oferty = Oferta.objects.filter(
                instalacja_id__in=instalacja_ids,
                is_template=False
            ).select_related('instalacja', 'instalacja__klient')
        else:
            return Response({'error': 'Unauthorized.'}, status=403)

        serializer = OfertaReadSerializer(oferty, many=True)
        return Response(serializer.data, status=200)


class OfertaDeleteApiView(APIView):
    @swagger_auto_schema(
        operation_description="Usuń ofertę (tylko dla admina)",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'oferta_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'oferta_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID oferty'),
            }
        ),
        responses={
            200: openapi.Response('Oferta usunięta'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'Wrong Token.'}, status=400)
        oferta_id = request.data.get('oferta_id')

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)
        if not ac_user.is_admin():
            return Response({'error': 'User is not admin'}, status=400)

        oferta = Oferta.objects.get(id=oferta_id)
        if not oferta:
            return Response({'error': 'Wrong id installation'}, status=400)
        oferta.delete()
        return Response({'status': 'Oferta deleted'}, status=200)


class InspekcjaEditApiView(APIView):
    @swagger_auto_schema(
        operation_description="Edytuj inspekcję",
        request_body=InspekcjaSerializer,
        responses={
            201: openapi.Response('Inspekcja zaktualizowana'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user or not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)
        if ac_user.is_klient():
            return Response({'error': 'User is klient'}, status=400)
        # TODO sprawdzenie czy oferta nalezy do klienta ktory jest klientem admina lub montera
        # TODO sprawdzenie czy oferta_id jest podane
        instalacja_id = request.data.get('instalacja_id')

        # Sprawdź czy inspekcja istnieje, jeśli nie - utwórz ją
        try:
            inspekcja = Inspekcja.objects.get(instalacja_id=instalacja_id)
        except Inspekcja.DoesNotExist:
            # Utwórz nową inspekcję dla tej instalacji
            instalacja = Instalacja.objects.get(id=instalacja_id)
            inspekcja = Inspekcja.objects.create(instalacja=instalacja)
            print(f"Created new inspekcja for installation {instalacja_id}")

        serializer = InspekcjaSerializer(
            inspekcja, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response({'status': 'Inspekcja updated'}, status=201)
        print(f"Serializer errors: {serializer.errors}")
        return Response(serializer.errors, status=400)


class MontazEditApiView(APIView):
    @swagger_auto_schema(
        operation_description="Edytuj montaż",
        request_body=MontazSerializer,
        responses={
            201: openapi.Response('Montaż zaktualizowany'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user or not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)
        if ac_user.is_klient():
            return Response({'error': 'User is klient'}, status=400)
        # TODO sprawdzenie czy instalacja nalezy do klienta ktory jest klientem admina lub montera
        # TODO sprawdzenie czy inspekcja_id jest podane
        instalacja_id = request.data.get('instalacja_id')
        montaz = Montaz.objects.get(instalacja_id=instalacja_id)
        serializer = MontazSerializer(montaz, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response({'status': 'Montaz updated'}, status=201)
        return Response(serializer.errors, status=400)


class MontazListApiView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz listę montaży dla instalacji",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'instalacja_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'instalacja_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID instalacji'),
            }
        ),
        responses={
            200: openapi.Response('Lista montaży'),
            400: openapi.Response('Błąd walidacji'),
            404: openapi.Response('Użytkownik nie znaleziony'),
        }
    )
    def post(self, request):
        token = request.data.get('token')
        instalacja_id = request.data.get('instalacja_id')

        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        if ac_user.is_klient():
            return Response({'error': 'User is klient'}, status=400)

        try:
            montaze = Montaz.objects.filter(
                instalacja_id=instalacja_id)
            serializer = MontazSerializer(montaze, many=True)
            return Response(serializer.data, status=200)
        except Exception as e:
            return Response({'error': str(e)}, status=400)


class MontazDataApiView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz dane montażu",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'montaz_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'montaz_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID montażu'),
            }
        ),
        responses={
            200: openapi.Response('Dane montażu'),
            400: openapi.Response('Błąd walidacji'),
            404: openapi.Response('Montaż nie znaleziony'),
        }
    )
    def post(self, request):
        token = request.data.get('token')
        montaz_id = request.data.get('montaz_id')

        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        if ac_user.is_klient():
            return Response({'error': 'User is klient'}, status=400)

        try:
            montaz = Montaz.objects.get(id=montaz_id)
            serializer = MontazSerializer(montaz)
            return Response(serializer.data, status=200)
        except Montaz.DoesNotExist:
            return Response({'error': 'Montaz not found'}, status=404)


class MontazCreateApiView(APIView):
    @swagger_auto_schema(
        operation_description="Utwórz nowy montaż",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'instalacja_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'instalacja_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID instalacji'),
                'cisnienie': openapi.Schema(type=openapi.TYPE_NUMBER, description='Ciśnienie'),
                'data_montazu': openapi.Schema(type=openapi.TYPE_STRING, description='Data montażu'),
                'split_multisplit': openapi.Schema(type=openapi.TYPE_STRING, description='Typ (split/multisplit)'),
                'gaz': openapi.Schema(type=openapi.TYPE_STRING, description='Gaz'),
                'gaz_ilos': openapi.Schema(type=openapi.TYPE_NUMBER, description='Ilość gazu'),
                'gaz_ilosc_dodana': openapi.Schema(type=openapi.TYPE_NUMBER, description='Ilość gazu dodana'),
                'gwarancja': openapi.Schema(type=openapi.TYPE_INTEGER, description='Gwarancja'),
                'liczba_przegladow': openapi.Schema(type=openapi.TYPE_INTEGER, description='Liczba przeglądów'),
                'miejsce_montazu_jedn_wew': openapi.Schema(type=openapi.TYPE_STRING, description='Miejsce montażu jednostki wewnętrznej'),
                'miejsce_montazu_jedn_zew': openapi.Schema(type=openapi.TYPE_STRING, description='Miejsce montażu jednostki zewnętrznej'),
                'miejsce_podlaczenia_elektryki': openapi.Schema(type=openapi.TYPE_STRING, description='Miejsce podłączenia elektryki'),
                'miejsce_skroplin': openapi.Schema(type=openapi.TYPE_STRING, description='Miejsce skroplin'),
                'nr_seryjny_jedn_wew': openapi.Schema(type=openapi.TYPE_STRING, description='Nr seryjny jednostki wewnętrznej'),
                'nr_seryjny_jedn_zew': openapi.Schema(type=openapi.TYPE_STRING, description='Nr seryjny jednostki zewnętrznej'),
                'przegrzanie': openapi.Schema(type=openapi.TYPE_NUMBER, description='Przegrzanie'),
                'sposob_skroplin': openapi.Schema(type=openapi.TYPE_STRING, description='Sposób skroplin'),
                'temp_chlodzenia': openapi.Schema(type=openapi.TYPE_NUMBER, description='Temperatura chłodzenia'),
                'temp_grzania': openapi.Schema(type=openapi.TYPE_NUMBER, description='Temperatura grzania'),
                'temp_wew_montazu': openapi.Schema(type=openapi.TYPE_NUMBER, description='Temperatura wewnętrzna podczas montażu'),
                'temp_zew_montazu': openapi.Schema(type=openapi.TYPE_NUMBER, description='Temperatura zewnętrzna podczas montażu'),
                'uwagi': openapi.Schema(type=openapi.TYPE_STRING, description='Uwagi'),
                'miejsce_i_sposob_montazu_jedn_zew': openapi.Schema(type=openapi.TYPE_STRING, description='Miejsce i sposób montażu jednostki zewnętrznej'),
                'dlugosc_instalacji': openapi.Schema(type=openapi.TYPE_NUMBER, description='Długość instalacji'),
            }
        ),
        responses={
            201: openapi.Response('Montaż utworzony'),
            400: openapi.Response('Błąd walidacji'),
            404: openapi.Response('Użytkownik nie znaleziony'),
        }
    )
    def post(self, request):
        token = request.data.get('token')

        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        if ac_user.is_klient():
            return Response({'error': 'User is klient'}, status=400)

        print('before mapping data', request.data)
        try:
            instalacja = Instalacja.objects.get(
                id=request.data.get('instalacja_id'))
            data = {
                'cisnienie': request.data.get('cisnienie'),
                'data_montazu': request.data.get('data_montazu'),
                'split_multisplit': request.data.get('split_multisplit'),
                'gaz': request.data.get('gaz'),
                'gaz_ilos': float(request.data.get('gaz_ilos')) if request.data.get('gaz_ilos') else None,
                'gaz_ilosc_dodana': float(request.data.get('gaz_ilosc_dodana')) if request.data.get('gaz_ilosc_dodana') else None,
                'gwarancja': int(request.data.get('gwarancja')) if request.data.get('gwarancja') else None,
                'liczba_przegladow': int(request.data.get('liczba_przegladow')) if request.data.get('liczba_przegladow') else None,
                'miejsce_montazu_jedn_wew': request.data.get('miejsce_montazu_jedn_wew'),
                'miejsce_montazu_jedn_zew': request.data.get('miejsce_montazu_jedn_zew'),
                'miejsce_podlaczenia_elektryki': request.data.get('miejsce_podlaczenia_elektryki'),
                'miejsce_skroplin': request.data.get('miejsce_skroplin'),
                'nr_seryjny_jedn_wew': request.data.get('nr_seryjny_jedn_wew'),
                'nr_seryjny_jedn_zew': request.data.get('nr_seryjny_jedn_zew'),
                'przegrzanie': float(request.data.get('przegrzanie')) if request.data.get('przegrzanie') else None,
                'sposob_skroplin': request.data.get('sposob_skroplin'),
                'temp_chlodzenia': float(request.data.get('temp_chlodzenia')) if request.data.get('temp_chlodzenia') else None,
                'temp_grzania': float(request.data.get('temp_grzania')) if request.data.get('temp_grzania') else None,
                'temp_wew_montazu': float(request.data.get('temp_wew_montazu')) if request.data.get('temp_wew_montazu') else None,
                'temp_zew_montazu': float(request.data.get('temp_zew_montazu')) if request.data.get('temp_zew_montazu') else None,
                'uwagi': request.data.get('uwagi'),
                'miejsce_i_sposob_montazu_jedn_zew': request.data.get('miejsce_i_sposob_montazu_jedn_zew'),
                'dlugosc_instalacji': float(request.data.get('dlugosc_instalacji')) if request.data.get('dlugosc_instalacji') else None,
                'devicePower': request.data.get('devicePower'),
                'gwarancja_photo': int(request.data.get('gwarancja_photo')) if request.data.get('gwarancja_photo') else None,
                'instalacja': instalacja.id,
            }
        except Instalacja.DoesNotExist:
            return Response({'error': 'Installation not found'}, status=404)

        print('before serializer', data)
        serializer = MontazSerializer(data=data)
        print('after serializer and before is_valid')
        if serializer.is_valid():
            print('before save')
            montaz = serializer.save()
            return Response({'status': 'Montaz created', 'montaz_id': montaz.id}, status=201)
        else:
            return Response({'error': serializer.errors}, status=400)
        return Response(serializer.errors, status=400)


class MontazDeleteApiView(APIView):
    @swagger_auto_schema(
        operation_description="Usuń montaż",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'montaz_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'montaz_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID montażu'),
            }
        ),
        responses={
            200: openapi.Response('Montaż usunięty'),
            400: openapi.Response('Błąd walidacji'),
            404: openapi.Response('Montaż nie znaleziony'),
        }
    )
    def post(self, request):
        token = request.data.get('token')
        montaz_id = request.data.get('montaz_id')

        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        if ac_user.is_klient():
            return Response({'error': 'User is klient'}, status=400)

        try:
            montaz = Montaz.objects.get(id=montaz_id)
            montaz.delete()
            return Response({'status': 'Montaz deleted'}, status=200)
        except Montaz.DoesNotExist:
            return Response({'error': 'Montaz not found'}, status=404)


class SerwisEditApiView(APIView):
    @swagger_auto_schema(
        operation_description="Edytuj serwis",
        request_body=SerwisSerializer,
        responses={
            201: openapi.Response('Serwis zaktualizowany'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user or not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)
        if ac_user.is_klient():
            return Response({'error': 'User is klient'}, status=400)

        # Sprawdzenie czy to przegląd cykliczny (powiązany z montażem) czy indywidualny serwis
        montaz_id = request.data.get('montaz_id')
        instalacja_id = request.data.get('instalacja_id')

        if montaz_id:
            # To jest przegląd cykliczny powiązany z montażem
            try:
                montaz = Montaz.objects.get(id=montaz_id)
                serwis_id = request.data.get('serwis_id')

                if serwis_id:
                    # Edycja istniejącego przeglądu
                    przeglad = Serwis.objects.get(
                        id=serwis_id, montaz=montaz, typ='przeglad')
                else:
                    # Tworzenie nowego przeglądu - wymagana jest data_przegladu
                    data_przegladu = request.data.get('data_przegladu')
                    if not data_przegladu:
                        return Response({'error': 'data_przegladu is required for new review'}, status=400)

                    # Sprawdź czy już istnieje przegląd z tą datą
                    existing_review = Serwis.objects.filter(
                        montaz=montaz,
                        typ='przeglad',
                        data_przegladu=data_przegladu
                    ).first()

                    if existing_review:
                        przeglad = existing_review
                    else:
                        przeglad = Serwis.objects.create(
                            instalacja=montaz.instalacja,
                            montaz=montaz,
                            typ='przeglad',
                            data_przegladu=data_przegladu,
                            numer_przegladu=1
                        )

                serializer = SerwisSerializer(
                    przeglad, data=request.data, partial=True)
                if serializer.is_valid():
                    serializer.save()
                    return Response({'status': 'Przegląd updated', 'serwis_id': przeglad.id}, status=201)
                return Response(serializer.errors, status=400)
            except Montaz.DoesNotExist:
                return Response({'error': 'Montaz not found'}, status=404)
            except Serwis.DoesNotExist:
                return Response({'error': 'Przegląd not found'}, status=404)

        elif instalacja_id:
            # To może być indywidualny serwis lub przegląd powiązany z instalacją
            try:
                instalacja = Instalacja.objects.get(id=instalacja_id)
                serwis_id = request.data.get('serwis_id')
                # Domyślnie 'serwis', ale może być 'przeglad'
                typ = request.data.get('typ', 'serwis')

                if serwis_id:
                    # Edycja istniejącego serwisu/przeglądu
                    serwis = Serwis.objects.get(
                        id=serwis_id, instalacja=instalacja)
                else:
                    # Tworzenie nowego serwisu/przeglądu
                    if typ == 'przeglad':
                        # Tworzenie nowego przeglądu dla instalacji
                        # Sprawdź czy już istnieje przegląd z tą samą datą (jeśli data jest podana)
                        data_przegladu = request.data.get('data_przegladu')
                        existing_review = None
                        if data_przegladu:
                            # Sprawdź czy istnieje przegląd z tą samą datą dla tej instalacji
                            existing_review = Serwis.objects.filter(
                                instalacja=instalacja,
                                typ='przeglad',
                                data_przegladu=data_przegladu
                            ).first()

                        if existing_review:
                            # Użyj istniejącego przeglądu zamiast tworzyć nowy
                            serwis = existing_review
                        else:
                            # Sprawdź czy istnieje montaż dla tej instalacji
                            montaz = instalacja.montaze.first()
                            if montaz:
                                # Jeśli istnieje montaż, powiąż przegląd z montażem
                                serwis = Serwis.objects.create(
                                    instalacja=instalacja,
                                    montaz=montaz,
                                    typ='przeglad',
                                    data_przegladu=data_przegladu
                                )
                            else:
                                # Jeśli nie ma montażu, utwórz przegląd bez powiązania z montażem
                                serwis = Serwis.objects.create(
                                    instalacja=instalacja,
                                    typ='przeglad',
                                    data_przegladu=data_przegladu
                                )
                    else:
                        # Tworzenie nowego indywidualnego serwisu
                        serwis = Serwis.objects.create(
                            instalacja=instalacja,
                            typ='serwis',
                            termin_serwisu=request.data.get('termin_serwisu')
                        )

                serializer = SerwisSerializer(
                    serwis, data=request.data, partial=True)
                if serializer.is_valid():
                    serializer.save()
                    status_message = 'Przegląd updated' if typ == 'przeglad' else 'Serwis updated'
                    return Response({'status': status_message, 'serwis_id': serwis.id}, status=201)
                return Response(serializer.errors, status=400)
            except Instalacja.DoesNotExist:
                return Response({'error': 'Instalacja not found'}, status=404)
            except Serwis.DoesNotExist:
                return Response({'error': 'Serwis not found'}, status=404)

        else:
            return Response({'error': 'montaz_id or instalacja_id required'}, status=400)


class RabatAddApiView(APIView):
    @swagger_auto_schema(
        operation_description="Dodaj rabat (tylko dla admina)",
        request_body=RabatSerializer,
        responses={
            201: openapi.Response('Rabat utworzony'),
            400: openapi.Response('Błąd walidacji'),
            404: openapi.Response('Użytkownik nie znaleziony'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')

        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)
        if not ac_user.is_admin():
            return Response({'error': 'User is not admin'}, status=400)

        data = request.data.copy()
        data['owner'] = ac_user.id

        serializer = RabatSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=201)
        print("RabatAddApiView validation errors:", serializer.errors)
        return Response(serializer.errors, status=400)


class RabatListApiView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz listę rabatów (tylko dla admina)",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'rabaty_id': openapi.Schema(
                    type=openapi.TYPE_ARRAY,
                    items=openapi.Schema(type=openapi.TYPE_INTEGER),
                    description='Lista ID rabatów do pobrania (opcjonalne)'
                ),
            }
        ),
        responses={
            200: openapi.Response('Lista rabatów'),
            400: openapi.Response('Błąd walidacji'),
            404: openapi.Response('Użytkownik nie znaleziony'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')

        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        if not ac_user.is_admin():
            return Response({'error': 'User is not admin'}, status=400)

        # Pobieranie rabaty_id z danych żądania
        rabaty_id = request.data.get('rabaty_id', None)

        if rabaty_id is not None:
            # Sprawdzanie, czy rabaty_id zostało wysłane
            if not isinstance(rabaty_id, list):
                # Sprawdzanie, czy rabaty_id jest listą
                return Response({'error': 'rabaty_id should be a list.'}, status=400)
            try:
                # Filtracja rabatów na podstawie rabaty_id
                rabaty = Rabat.objects.filter(owner=ac_user, id__in=rabaty_id)
            except ValueError:
                # Zwracanie błędu, jeśli rabaty_id nie jest listą poprawnych ID
                return Response({'error': 'Invalid rabaty_id.'}, status=400)
        else:
            rabaty = Rabat.objects.filter(owner=ac_user)

        serializer = RabatSerializer(rabaty, many=True)
        return Response(serializer.data, status=200)


class RabatEditApiView(APIView):
    @swagger_auto_schema(
        operation_description="Edytuj rabat (tylko dla admina)",
        request_body=RabatSerializer,
        responses={
            201: openapi.Response('Rabat zaktualizowany'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')
        rabat_id = request.data.get('rabat_id')
        ac_user = get_cached_user(token)
        if not ac_user or not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)
        if not ac_user.is_admin():
            return Response({'error': 'User is nor admin'}, status=400)

        rabat = Rabat.objects.get(id=rabat_id)
        serializer = RabatSerializer(rabat, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response({'status': 'Rabat updated'}, status=201)
        return Response(serializer.errors, status=400)


class RabatDeleteApiView(APIView):
    @swagger_auto_schema(
        operation_description="Usuń rabat (tylko dla admina)",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'rabat_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'rabat_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID rabatu'),
            }
        ),
        responses={
            200: openapi.Response('Rabat usunięty'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')
        rabat_id = request.data.get('rabat_id')
        ac_user = get_cached_user(token)
        if not ac_user or not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)
        if not ac_user.is_admin():
            return Response({'error': 'User is nor admin'}, status=400)

        rabat = Rabat.objects.get(id=rabat_id)
        rabat.delete()
        return Response({'status': 'Rabat deleted'}, status=200)


class RabatValueApiView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz wartość rabatu",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'rabat_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'rabat_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID rabatu'),
            }
        ),
        responses={
            200: openapi.Response('Wartość rabatu'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')
        rabat_id = request.data.get('rabat_id')
        ac_user = get_cached_user(token)
        if not ac_user or not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)
        rabat = Rabat.objects.get(id=rabat_id)
        return Response({'value': rabat.value}, status=200)


class NarzutAddApiView(APIView):
    @swagger_auto_schema(
        operation_description="Dodaj narzut (tylko dla admina)",
        request_body=NarzutSerializer,
        responses={
            201: openapi.Response('Narzut utworzony'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user or not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)
        if not ac_user.is_admin():
            return Response({'error': 'User is nor admin'}, status=400)

        data = request.data.copy()
        data['owner'] = ac_user.id

        serializer = NarzutSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=201)
        return Response(serializer.errors, status=400)


class NarzutListApiView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz listę narzutów (tylko dla admina)",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'narzuty_id': openapi.Schema(
                    type=openapi.TYPE_ARRAY,
                    items=openapi.Schema(type=openapi.TYPE_INTEGER),
                    description='Lista ID narzutów do pobrania (opcjonalne)'
                ),
            }
        ),
        responses={
            200: openapi.Response('Lista narzutów'),
            400: openapi.Response('Błąd walidacji'),
            404: openapi.Response('Użytkownik nie znaleziony'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')

        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        if not ac_user.is_admin():
            return Response({'error': 'User is not admin'}, status=400)

        # Pobieranie rabaty_id z danych żądania
        narzuty_id = request.data.get('narzuty_id', None)

        if narzuty_id is not None:
            # Sprawdzanie, czy rabaty_id zostało wysłane
            if not isinstance(narzuty_id, list):
                # Sprawdzanie, czy rabaty_id jest listą
                return Response({'error': 'narzuty_id should be a list.'}, status=400)
            try:
                # Filtracja rabatów na podstawie rabaty_id
                narzuty = Narzut.objects.filter(
                    owner=ac_user, id__in=narzuty_id)
            except ValueError:
                # Zwracanie błędu, jeśli rabaty_id nie jest listą poprawnych ID
                return Response({'error': 'Invalid narzuty_id.'}, status=400)
        else:
            narzuty = Narzut.objects.filter(owner=ac_user)

        serializer = NarzutSerializer(narzuty, many=True)
        return Response(serializer.data, status=200)


class NarzutEditApiView(APIView):
    @swagger_auto_schema(
        operation_description="Edytuj narzut (tylko dla admina)",
        request_body=NarzutSerializer,
        responses={
            201: openapi.Response('Narzut zaktualizowany'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')
        narzut_id = request.data.get('narzut_id')
        ac_user = get_cached_user(token)
        if not ac_user or not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)
        if not ac_user.is_admin():
            return Response({'error': 'User is nor admin'}, status=400)

        narzut = Narzut.objects.get(id=narzut_id)
        serializer = NarzutSerializer(narzut, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response({'status': 'Narzut updated'}, status=201)
        return Response(serializer.errors, status=400)


class NarzutDeleteApiView(APIView):
    @swagger_auto_schema(
        operation_description="Usuń narzut (tylko dla admina)",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'narzut_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'narzut_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID narzutu'),
            }
        ),
        responses={
            200: openapi.Response('Narzut usunięty'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')
        narzut_id = request.data.get('narzut_id')
        ac_user = get_cached_user(token)
        if not ac_user or not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)
        if not ac_user.is_admin():
            return Response({'error': 'User is nor admin'}, status=400)

        narzut = Narzut.objects.get(id=narzut_id)
        narzut.delete()
        return Response({'status': 'Narzut deleted'}, status=200)


class NarzutValueApiView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz wartość narzutu",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'narzut_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'narzut_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID narzutu'),
            }
        ),
        responses={
            200: openapi.Response('Wartość narzutu'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')
        narzut_id = request.data.get('narzut_id')
        ac_user = get_cached_user(token)
        if not ac_user or not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)
        narzut = Narzut.objects.get(id=narzut_id)
        return Response({'value': narzut.value}, status=200)


class DevicesSplitApiView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz listę urządzeń split z opcjonalnymi filtrami",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'filters': openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    description='Filtry wyszukiwania',
                    properties={
                        'manufacturer': openapi.Schema(type=openapi.TYPE_STRING, description='Producent (może być lista)'),
                        'type': openapi.Schema(type=openapi.TYPE_STRING, description='Typ urządzenia'),
                        'volume': openapi.Schema(type=openapi.TYPE_STRING, description='Głośność'),
                        'color': openapi.Schema(type=openapi.TYPE_STRING, description='Kolor'),
                        'heatPowerFrom': openapi.Schema(type=openapi.TYPE_NUMBER, description='Moc grzewcza od'),
                        'heatPowerTo': openapi.Schema(type=openapi.TYPE_NUMBER, description='Moc grzewcza do'),
                        'coolPowerFrom': openapi.Schema(type=openapi.TYPE_NUMBER, description='Moc chłodnicza od'),
                        'coolPowerTo': openapi.Schema(type=openapi.TYPE_NUMBER, description='Moc chłodnicza do'),
                        'size': openapi.Schema(type=openapi.TYPE_NUMBER, description='Wielkość jednostki wewnętrznej'),
                        'wifi': openapi.Schema(type=openapi.TYPE_BOOLEAN, description='Sterowanie WiFi'),
                    }
                ),
            }
        ),
        responses={
            200: openapi.Response('Lista urządzeń split'),
            400: openapi.Response('Błąd walidacji'),
            404: openapi.Response('Użytkownik nie znaleziony'),
        }
    )
    def post(self, request):
        token = request.data.get('token')
        filters = request.data.get('filters', {})  # Pobierz filtry z żądania

        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        # Filtracja urządzeń na podstawie przekazanych filtrów
        devices = DeviceSplit.objects.all()

        if 'manufacturer' in filters and filters['manufacturer'] is not None:
            manufacturer_filter = filters['manufacturer']
            if isinstance(manufacturer_filter, list):
                # Jeśli to lista producentów, użyj __in
                devices = devices.filter(producent__in=manufacturer_filter)
            else:
                # Jeśli to pojedynczy producent, użyj standardowego filtra
                devices = devices.filter(producent=manufacturer_filter)
        # Zmieniono z 'rodzaj' na 'typ'
        if 'type' in filters and filters['type'] is not None:
            devices = devices.filter(typ=filters['type'])
        if 'volume' in filters and filters['volume'] is not None:
            devices = devices.filter(glosnosc=filters['volume'])
        if 'color' in filters and filters['color'] is not None:
            devices = devices.filter(kolor=filters['color'])

        # Filtrowanie po mocy grzewczej
        if 'heatPowerFrom' in filters and filters['heatPowerFrom'] is not None and filters['heatPowerFrom'] != '':
            try:
                heat_power_from = float(filters['heatPowerFrom'])
                devices = devices.filter(moc_grzewcza__gte=heat_power_from)
            except (ValueError, TypeError):
                pass  # Ignoruj nieprawidłowe wartości

        if 'heatPowerTo' in filters and filters['heatPowerTo'] is not None and filters['heatPowerTo'] != '':
            try:
                heat_power_to = float(filters['heatPowerTo'])
                devices = devices.filter(moc_grzewcza__lte=heat_power_to)
            except (ValueError, TypeError):
                pass  # Ignoruj nieprawidłowe wartości

        # Filtrowanie po mocy chłodniczej
        if 'coolPowerFrom' in filters and filters['coolPowerFrom'] is not None and filters['coolPowerFrom'] != '':
            try:
                cool_power_from = float(filters['coolPowerFrom'])
                devices = devices.filter(moc_chlodnicza__gte=cool_power_from)
            except (ValueError, TypeError):
                pass

        if 'coolPowerTo' in filters and filters['coolPowerTo'] is not None and filters['coolPowerTo'] != '':
            try:
                cool_power_to = float(filters['coolPowerTo'])
                devices = devices.filter(moc_chlodnicza__lte=cool_power_to)
            except (ValueError, TypeError):
                pass

        # Filtrowanie po wielkości jednostki wewnętrznej
        if 'size' in filters and filters['size'] is not None and filters['size'] != '':
            try:
                size_value = float(filters['size'])
                devices = devices.filter(wielkosc_wew=size_value)
            except (ValueError, TypeError):
                pass  # Ignoruj nieprawidłowe wartości

        # Filtrowanie po sterowaniu wifi
        if 'wifi' in filters and filters['wifi'] is not None:
            devices = devices.filter(sterowanie_wifi=bool(filters['wifi']))

        devices_json = [DeviceSplitSerializer(
            instance=device).data for device in devices]
        return Response({'DevicesSplit': devices_json}, status=200)


class DevicesMultiSplitApiView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz listę urządzeń multisplit",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'devices_id': openapi.Schema(
                    type=openapi.TYPE_ARRAY,
                    items=openapi.Schema(type=openapi.TYPE_INTEGER),
                    description='Lista ID urządzeń do pobrania (opcjonalne)'
                ),
            }
        ),
        responses={
            200: openapi.Response('Lista urządzeń multisplit'),
            400: openapi.Response('Błąd walidacji'),
            404: openapi.Response('Użytkownik nie znaleziony'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')

        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        # Pobieranie devices_id z danych żądania
        devices_id = request.data.get('devices_id', None)
        if devices_id is not None:
            # Sprawdzanie, czy devices_id zostało wysłane
            # Sprawdzanie, czy devices_id jest listą
            if not isinstance(devices_id, list):
                return Response({'error': 'devices_id should be a list.'}, status=400)
            try:
                # Filtracja urządzeń na podstawie devices_id
                devices = DeviceMultiSplit.objects.filter(id__in=devices_id)
            except ValueError:
                # Zwracanie błędu, jeśli devices_id nie jest listą poprawnych ID
                return Response({'error': 'Invalid devices_id.'}, status=400)
        else:
            devices = DeviceMultiSplit.objects.all()

        devices_json = [DeviceMultiSplitSerializer(
            instance=device).data for device in devices]

        return Response({'DevicesMultiSplit': devices_json}, status=200)


class ListAllProducersAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz listę wszystkich producentów urządzeń",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            properties={}
        ),
        responses={
            200: openapi.Response('Lista producentów'),
        }
    )
    def post(self, request):
        # Pobranie unikalnych nazw producentów z DeviceSplit
        producers_split = DeviceSplit.objects.values_list(
            'producent', flat=True).distinct()

        # Pobranie unikalnych nazw producentów z DeviceMultiSplit
        producers_multisplit = DeviceMultiSplit.objects.values_list(
            'producent', flat=True).distinct()

        # Połączenie i filtrowanie list
        combined_producers = set(producers_split) | set(producers_multisplit)
        combined_producers = [prod for prod in combined_producers if prod]

        return Response({'producers': list(combined_producers)})


class SzablonCreateApiView(APIView):
    @swagger_auto_schema(
        operation_description="Utwórz szablon (tylko dla admina)",
        request_body=SzablonSerializer,
        responses={
            201: openapi.Response('Szablon utworzony'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')

        ac_user = get_cached_user(token)
        if not ac_user or not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)
        if not ac_user.is_admin():
            return Response({'error': 'User is not admin'}, status=400)

        # Clean the data
        data = request.data.copy()
        data['owner'] = ac_user.id

        # Remove None values from lists
        if 'narzuty' in data:
            data['narzuty'] = [x for x in data['narzuty'] if x is not None]
        if 'devices_split' in data:
            data['devices_split'] = [
                x for x in data['devices_split'] if x is not None]
        if 'devices_multisplit' in data:
            data['devices_multisplit'] = [
                x for x in data['devices_multisplit'] if x is not None]

        serializer = SzablonSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=201)
        else:
            print("Validation errors:", serializer.errors)
            return Response(serializer.errors, status=400)


class SzablonListApiView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz listę szablonów",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'szablony_id': openapi.Schema(
                    type=openapi.TYPE_ARRAY,
                    items=openapi.Schema(type=openapi.TYPE_INTEGER),
                    description='Lista ID szablonów do pobrania (opcjonalne)'
                ),
            }
        ),
        responses={
            200: openapi.Response('Lista szablonów'),
            400: openapi.Response('Błąd walidacji'),
            404: openapi.Response('Użytkownik nie znaleziony'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')

        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        szablony_id = request.data.get('szablony_id', None)

        if szablony_id is not None:
            if not isinstance(szablony_id, list):
                return Response({'error': 'szablony_id should be a list.'}, status=400)
            try:
                szablony = Szablon.objects.filter(
                    owner=ac_user, id__in=szablony_id)
            except ValueError:
                return Response({'error': 'Invalid szablony_id.'}, status=400)
        else:
            szablony = Szablon.objects.filter(owner=ac_user)

        serializer = SzablonSerializer(szablony, many=True)
        return Response(serializer.data, status=200)


class SzablonDataApiView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz dane szablonu",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'szablon_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'szablon_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID szablonu'),
            }
        ),
        responses={
            200: openapi.Response('Dane szablonu'),
            400: openapi.Response('Błąd walidacji'),
            404: openapi.Response('Szablon nie znaleziony'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'Wrong Token.'}, status=400)
        szablon_id = request.data.get('szablon_id')
        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        try:
            szablon = Szablon.objects.get(id=szablon_id)
        except Szablon.DoesNotExist:
            return Response({'error': 'Szablon does not exist'}, status=404)

        serializer = SzablonReadSerializer(szablon)
        return Response(serializer.data, status=200)


class SzablonDeleteApiView(APIView):
    @swagger_auto_schema(
        operation_description="Usuń szablon (tylko dla admina)",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'szablon_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'szablon_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID szablonu'),
            }
        ),
        responses={
            200: openapi.Response('Szablon usunięty'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')
        szablon_id = request.data.get('szablon_id')
        ac_user = get_cached_user(token)
        if not ac_user or not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)
        if not ac_user.is_admin():
            return Response({'error': 'User is nor admin'}, status=400)

        szablon = Szablon.objects.get(id=szablon_id)
        szablon.delete()
        return Response({'status': 'Szablon deleted'}, status=200)


class ZadanieCreateApiView(APIView):
    """
    Widok do tworzenia nowego zadania.
    """
    @swagger_auto_schema(
        operation_description="Utwórz nowe zadanie",
        request_body=ZadanieSerializer,
        responses={
            201: openapi.Response('Zadanie utworzone'),
            400: openapi.Response('Błąd walidacji'),
            404: openapi.Response('Użytkownik nie znaleziony'),
        }
    )
    def post(self, request):
        pprint(request.data)  # Wyświetla przychodzące dane żądania
        token = request.data.get('token')

        # Weryfikacja użytkownika za pomocą tokenu
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        data = request.data
        data['rodzic'] = ac_user.pk

        # Utworzenie zadania
        serializer = ZadanieSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=201)
        else:
            print("Serializer errors:", serializer.errors)  # Debug print
            return Response(serializer.errors, status=400)


class ZadanieListApiView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz listę zadań użytkownika",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
            }
        ),
        responses={
            200: openapi.Response('Lista zadań'),
            400: openapi.Response('Błąd walidacji'),
            404: openapi.Response('Użytkownik nie znaleziony'),
        }
    )
    def post(self, request):
        pprint(request.data)  # Wyświetla przychodzące dane żądania
        token = request.data.get('token')

        # Weryfikacja użytkownika za pomocą tokenu
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)

        # Jeśli użytkownik zostanie znaleziony, pobieramy jego zadania
        zadania = Zadanie.objects.filter(rodzic=ac_user)

        serializer = ZadanieSerializer(zadania, many=True)

        return Response(serializer.data, status=200)


class ZadanieDeleteApiView(APIView):
    @swagger_auto_schema(
        operation_description="Usuń zadanie",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'zadanie_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'zadanie_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID zadania'),
            }
        ),
        responses={
            200: openapi.Response('Zadanie usunięte'),
            400: openapi.Response('Błąd walidacji'),
            404: openapi.Response('Zadanie nie znalezione'),
        }
    )
    def post(self, request):
        # Wyświetla przychodzące dane żądania
        pprint(request.data)
        token = request.data.get('token')
        zadanie_id = request.data.get('zadanie_id')  # ID zadania do usunięcia

        if zadanie_id is None:
            return Response({'error': 'Task ID is required.'}, status=400)

        # Weryfikacja użytkownika za pomocą tokenu
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)

        # Sprawdzanie, czy zadanie istnieje i czy należy do tego użytkownika
        try:
            zadanie = Zadanie.objects.get(id=zadanie_id, rodzic=ac_user)
        except Zadanie.DoesNotExist:
            return Response({'error': 'Task not found.'}, status=404)

        # Usunięcie zadania
        zadanie.delete()
        return Response({'success': 'Task deleted successfully.'}, status=200)


class ZadanieEditApiView(APIView):
    @swagger_auto_schema(
        operation_description="Edytuj zadanie",
        request_body=ZadanieSerializer,
        responses={
            200: openapi.Response('Zadanie zaktualizowane'),
            400: openapi.Response('Błąd walidacji'),
            404: openapi.Response('Zadanie nie znalezione'),
        }
    )
    def post(self, request):
        # Wyświetla przychodzące dane żądania
        pprint(request.data)
        token = request.data.get('token')
        zadanie_id = request.data.get('zadanie_id')  # ID zadania do edycji

        if zadanie_id is None:
            return Response({'error': 'Task ID is required.'}, status=400)

        # Weryfikacja użytkownika za pomocą tokenu
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)

        # Sprawdzanie, czy zadanie istnieje i czy należy do tego użytkownika
        try:
            zadanie = Zadanie.objects.get(id=zadanie_id, rodzic=ac_user)
        except Zadanie.DoesNotExist:
            return Response({'error': 'Task not found.'}, status=404)

        # Teraz edytujemy zadanie za pomocą danych przesłanych przez użytkownika.
        serializer = ZadanieSerializer(
            zadanie, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=200)
        else:
            return Response(serializer.errors, status=400)


class InvoiceSettingsListAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz ustawienia faktury (tylko dla admina)",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
            }
        ),
        responses={
            200: openapi.Response('Ustawienia faktury'),
            404: openapi.Response('Użytkownik nie znaleziony lub brak uprawnień'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)

        if not ac_user.is_admin():
            return Response({'error': 'User not admin.'}, status=404)

        # Pobieranie ustawień faktury dla danego użytkownika
        invoice_settings, created = InvoiceSettings.objects.get_or_create(
            ac_user=ac_user)

        # Serializowanie danych
        serializer = InvoiceSettingsSerializer(invoice_settings)

        return Response(serializer.data, status=200)


class InvoiceSettingsCreateUpdateAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Utwórz lub zaktualizuj ustawienia faktury",
        request_body=InvoiceSettingsSerializer,
        responses={
            200: openapi.Response('Ustawienia zaktualizowane'),
            202: openapi.Response('Ustawienia utworzone'),
            400: openapi.Response('Błąd walidacji'),
            404: openapi.Response('Użytkownik nie znaleziony'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')

        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)

        # Pobieranie lub tworzenie ustawień faktury dla danego użytkownika
        invoice_settings, created = InvoiceSettings.objects.get_or_create(
            ac_user=ac_user)

        # Aktualizacja istniejących ustawień
        serializer = InvoiceSettingsSerializer(
            invoice_settings, data=request.data, partial=True)
        if serializer.is_valid():
            with transaction.atomic():
                serializer.save()
            return Response(serializer.data, status=200 if created else 202)

        return Response(serializer.errors, status=400)


class InvoiceAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Utwórz fakturę w systemie Fakturownia (tylko dla admina)",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'type', 'number', 'positions'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'type': openapi.Schema(type=openapi.TYPE_STRING, description='Typ faktury'),
                'number': openapi.Schema(type=openapi.TYPE_STRING, description='Numer faktury'),
                'sellDate': openapi.Schema(type=openapi.TYPE_STRING, description='Data sprzedaży'),
                'issueDate': openapi.Schema(type=openapi.TYPE_STRING, description='Data wystawienia'),
                'paymentDate': openapi.Schema(type=openapi.TYPE_INTEGER, description='Liczba dni do zapłaty', default=7),
                'sellerName': openapi.Schema(type=openapi.TYPE_STRING, description='Nazwa sprzedawcy'),
                'sellerNip': openapi.Schema(type=openapi.TYPE_STRING, description='NIP sprzedawcy'),
                'buyerName': openapi.Schema(type=openapi.TYPE_STRING, description='Nazwa nabywcy'),
                'buyerNip': openapi.Schema(type=openapi.TYPE_STRING, description='NIP nabywcy'),
                'buyerEmail': openapi.Schema(type=openapi.TYPE_STRING, description='Email nabywcy'),
                'client': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID klienta'),
                'installationId': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID instalacji'),
                'status': openapi.Schema(type=openapi.TYPE_STRING, description='Status faktury'),
                'paymentMethod': openapi.Schema(type=openapi.TYPE_STRING, description='Metoda płatności'),
                'positions': openapi.Schema(
                    type=openapi.TYPE_ARRAY,
                    items=openapi.Schema(
                        type=openapi.TYPE_OBJECT,
                        properties={
                            'productName': openapi.Schema(type=openapi.TYPE_STRING),
                            'vat': openapi.Schema(type=openapi.TYPE_INTEGER),
                            'productBrutto': openapi.Schema(type=openapi.TYPE_NUMBER),
                            'productQuantity': openapi.Schema(type=openapi.TYPE_INTEGER),
                        }
                    ),
                    description='Pozycje faktury'
                ),
            }
        ),
        responses={
            201: openapi.Response('Faktura utworzona pomyślnie'),
            400: openapi.Response('Błąd walidacji'),
            404: openapi.Response('Użytkownik nie znaleziony'),
        }
    )
    def post(self, request):
        print('request.data', request.data)
        data = request.data
        token = data.get('token')

        def safe(val):
            return val if val is not None else ""

        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)
        if not ac_user.is_admin():
            return Response({'error': 'User not admin.'}, status=404)

        payment_days = int(data.get("paymentDate", 7))
        payment_to = (
            timezone.now() + timezone.timedelta(days=payment_days)).strftime("%Y-%m-%d")

        positions = []
        for pos in data.get("positions", []):
            positions.append({
                "name": safe(pos.get("productName")),
                "tax": int(pos.get("vat", 0)),
                "total_price_gross": float(pos.get("productBrutto", 0)),
                "quantity": int(pos.get("productQuantity", 1)),
            })

        invoice_data = {
            "api_token": settings.FAKTUROWNIA_API_TOKEN,
            "invoice": {
                "kind": safe(data.get("type")),
                "number": safe(data.get("number")),
                "sell_date": safe(data.get("sellDate", "")).split("T")[0],
                "issue_date": safe(data.get("issueDate", "")).split("T")[0],
                "payment_to": payment_to,
                "seller_name": safe(data.get("sellerName")),
                "seller_tax_no": safe(data.get("sellerNip")),
                "buyer_name": safe(data.get("buyerName")),
                "buyer_tax_no": safe(data.get("buyerNip")),
                "buyer_email": safe(data.get("buyerEmail")),
                "positions": positions,
            }
        }
        print('invoice_data', invoice_data)
        response = requests.post(
            'https://acmanager.fakturownia.pl/invoices.json?api_token=T9KJ0u2F3_vY_JAocTvd',
            json=invoice_data
        )

        print('response.json()', response.json())
        print('create faktura')

        # Sprawdź odpowiedź z API
        response_data = response.json()
        if 'id' in response_data and response_data['id'] is not None:
            # Faktura utworzona pomyślnie
            faktura = Faktury.objects.create(
                ac_user=ac_user,
                client_id=data.get('client'),
                instalacja_id=data.get('installationId') if data.get(
                    'installationId') else None,
                status=data.get('status'),
                issue_date=safe(data.get("issueDate", "")).split("T")[0],
                order=data.get('paymentMethod'),
                id_fakturowni=response_data['id'],
                numer_faktury=safe(data.get("number"))
            )
            return Response({'message': 'Faktura utworzona pomyślnie', 'faktura_id': faktura.id}, status=201)
        else:
            # Błąd podczas tworzenia faktury
            error_message = response_data.get('message', 'Nieznany błąd')
            return Response({'error': f'Błąd podczas tworzenia faktury: {error_message}'}, status=400)


class FakturyListView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz listę faktur użytkownika",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
            }
        ),
        responses={
            200: openapi.Response('Lista faktur'),
            403: openapi.Response('Brak uprawnień'),
            404: openapi.Response('Użytkownik nie znaleziony'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')

        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)

        # Admin/Monter: zwróć faktury wystawione przez tego użytkownika
        if ac_user.is_admin() or ac_user.is_monter():
            faktury = Faktury.objects.filter(ac_user=ac_user)
        # Klient: zwróć faktury wystawione na tego klienta
        elif ac_user.is_klient():
            faktury = Faktury.objects.filter(client=ac_user)
        else:
            return Response({'error': 'Unauthorized.'}, status=403)

        serializer = FakturySerializer(faktury, many=True)

        return Response(serializer.data, status=200)


class FakturyDataView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz dane faktury",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'invoice_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'invoice_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID faktury'),
            }
        ),
        responses={
            200: openapi.Response('Dane faktury'),
            400: openapi.Response('Błąd walidacji'),
            403: openapi.Response('Brak uprawnień'),
            404: openapi.Response('Faktura nie znaleziona'),
        }
    )
    def post(self, request):
        token = request.data.get('token')
        faktura_id = request.data.get('invoice_id')

        print('=== FAKTURA_DATA DEBUG ===')
        print('Request data:', request.data)
        print('Token:', token)
        print('Faktura ID:', faktura_id)
        print('==========================')

        ac_user = get_cached_user(token)
        if not ac_user:
            print('ERROR: User not found for token:', token)
            return Response({'error': 'User not found.'}, status=404)

        print('User found:', ac_user.email, 'ID:', ac_user.id)

        if not ac_user.check_token(token):
            print('ERROR: Invalid token for user:', ac_user.email)
            return Response({'error': 'Wrong Token.'}, status=400)

        try:
            # Admin/Monter: pobierz faktury wystawione przez tego użytkownika
            if ac_user.is_admin() or ac_user.is_monter():
                faktura = Faktury.objects.get(id=faktura_id, ac_user=ac_user)
            # Klient: pobierz fakturę wystawioną na tego klienta
            elif ac_user.is_klient():
                faktura = Faktury.objects.get(id=faktura_id, client=ac_user)
            else:
                print('ERROR: Unauthorized user type')
                return Response({'error': 'Unauthorized.'}, status=403)

            print('Faktura found:', faktura.id,
                  'External ID:', faktura.id_fakturowni)
        except Faktury.DoesNotExist:
            print('ERROR: Faktura not found or access denied for ID:',
                  faktura_id, 'and user ID:', ac_user.id)
            return Response({'error': 'Faktura not found or access denied.'}, status=404)

        if faktura.id_fakturowni:
            print('Fetching data from external API for faktura ID:',
                  faktura.id_fakturowni)
            response = requests.get(
                f'https://acmanager.fakturownia.pl/invoices/{faktura.id_fakturowni}.json',
                params={'api_token': 'T9KJ0u2F3_vY_JAocTvd'}
            )
            print('External API response status:', response.status_code)
            if response.status_code == 200:
                invoice_api_response = response.json()
                print('External API response data:', invoice_api_response)
                if 'id' in invoice_api_response:
                    filtered_data = {
                        k: v for k, v in invoice_api_response.items() if v is not None}
                    return Response(filtered_data)
                else:
                    print('ERROR: No ID in external API response')
                    return Response({'error': 'Faktura data not found in external API.'}, status=404)
            else:
                print('ERROR: External API returned status:',
                      response.status_code)
                return Response({'error': 'Error fetching faktura data from external API.'}, status=response.status_code)
        else:
            print('ERROR: No external ID for faktura:', faktura.id)
            return Response({'error': 'No external ID for this faktura.'}, status=404)


class FakturyDeleteAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Usuń fakturę",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'faktura_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'faktura_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID faktury'),
            }
        ),
        responses={
            200: openapi.Response('Faktura usunięta'),
            400: openapi.Response('Błąd walidacji'),
            404: openapi.Response('Faktura nie znaleziona'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')
        invoice_id = request.data.get('invoice_id')

        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)
        if not ac_user.is_admin():
            return Response({'error': 'User not admin.'}, status=404)

        try:
            faktura = Faktury.objects.get(id=invoice_id, ac_user=ac_user)
        except Faktury.DoesNotExist:
            return Response({'error': 'Invoice not found.'}, status=404)

        id_fakturowni = faktura.id_fakturowni
        response = requests.delete(
            f'https://acmanager.fakturownia.pl/invoices/{id_fakturowni}.json',
            params={'api_token': settings.FAKTUROWNIA_API_TOKEN}
        )
        pprint(response.json())
        if response.status_code == 200:
            faktura.delete()
            return Response({'message': 'Invoice deleted successfully.'}, status=200)
        else:
            # Obsługa błędów związanych z API Fakturowni
            return Response({'error': 'Failed to delete invoice from Fakturownia.'}, status=response.status_code)


class PrzegladDataApiView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz dane przeglądu",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'serwis_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'serwis_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID serwisu/przeglądu'),
            }
        ),
        responses={
            200: openapi.Response('Dane przeglądu'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        token = request.data.get('token')
        serwis_id = request.data.get('serwis_id')

        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        if ac_user.is_klient():
            return Response({'error': 'User is klient'}, status=400)

        try:
            serwis = Serwis.objects.get(id=serwis_id, typ='przeglad')
            serializer = SerwisSerializer(serwis)
            data = serializer.data

            # Pobierz dane urządzenia z powiązanego Montaz
            device_data = None
            if serwis.montaz:
                montaz = serwis.montaz
                if montaz.devices_split.exists():
                    devices = montaz.devices_split.all()
                    if devices:
                        device = devices.first()
                        from .serializers import DeviceSplitSerializer
                        device_serializer = DeviceSplitSerializer(device)
                        device_data = device_serializer.data
                elif montaz.devices_multi_split.exists():
                    devices = montaz.devices_multi_split.all()
                    if devices:
                        device = devices.first()
                        from .serializers import DeviceMultiSplitSerializer
                        device_serializer = DeviceMultiSplitSerializer(device)
                        device_data = device_serializer.data

            # Pobierz zdjęcia powiązane z przeglądem
            photos = Photo.objects.filter(serwis=serwis_id)
            from .serializers import PhotoSerializer
            photo_serializer = PhotoSerializer(
                photos, many=True, context={'request': request})
            photos_data = photo_serializer.data

            return Response({
                'serwis': data,
                'device': device_data,
                'photos': photos_data
            }, status=200)
        except Serwis.DoesNotExist:
            return Response({'error': 'Przegląd not found'}, status=404)
        except Exception as e:
            return Response({'error': str(e)}, status=400)


class PrzegladListApiView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz listę przeglądów dla montażu",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'montaz_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'montaz_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID montażu'),
            }
        ),
        responses={
            200: openapi.Response('Lista przeglądów'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        token = request.data.get('token')
        montaz_id = request.data.get('montaz_id')
        instalacja_id = request.data.get('instalacja_id')

        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        if ac_user.is_klient():
            return Response({'error': 'User is klient'}, status=400)

        try:
            if montaz_id:
                # Filtruj tylko przeglądy które mają datę przeglądu (prawdziwe przeglądy)
                przeglady = Serwis.objects.filter(
                    montaz_id=montaz_id,
                    typ='przeglad',
                    data_przegladu__isnull=False
                ).order_by('numer_przegladu')
            elif instalacja_id:
                # Filtruj tylko przeglądy które mają datę przeglądu (prawdziwe przeglądy)
                # Wykluczamy stare rekordy Serwis które mają domyślny typ='przeglad' ale nie są prawdziwymi przeglądami
                przeglady = Serwis.objects.filter(
                    instalacja_id=instalacja_id,
                    typ='przeglad',
                    data_przegladu__isnull=False
                ).order_by('-data_przegladu', '-created_date')
            else:
                return Response({'error': 'montaz_id or instalacja_id required'}, status=400)

            serializer = SerwisSerializer(przeglady, many=True)
            przeglady_data = serializer.data

            # Dodaj adres instalacji i status dla każdego przeglądu
            result = []
            for przeglad_data in przeglady_data:
                przeglad_obj = Serwis.objects.get(id=przeglad_data['id'])
                instalacja = przeglad_obj.instalacja

                # Adres instalacji
                address_parts = []
                if instalacja.ulica:
                    address_parts.append(instalacja.ulica)
                if instalacja.numer_domu:
                    address_parts.append(instalacja.numer_domu)
                if instalacja.mieszkanie:
                    address_parts.append(instalacja.mieszkanie)
                address_line1 = ', '.join(
                    address_parts) if address_parts else ''

                address_line2_parts = []
                if instalacja.kod_pocztowy:
                    address_line2_parts.append(instalacja.kod_pocztowy)
                if instalacja.miasto:
                    address_line2_parts.append(instalacja.miasto)
                address_line2 = ', '.join(
                    address_line2_parts) if address_line2_parts else ''

                # Status przeglądu (wyliczany z data_przegladu)
                status = 'Zaplanowane'
                if przeglad_obj.data_przegladu:
                    if przeglad_obj.data_przegladu <= timezone.now():
                        status = 'Wykonane'
                    else:
                        status = 'Zaplanowane'
                else:
                    status = 'Zaplanowane'

                # Informacje o ekipie (jeśli powiązane z Task)
                ekipa = None
                ekipa_id = None
                # Można dodać logikę do pobierania ekipy z powiązanego Task jeśli istnieje

                przeglad_data['address'] = {
                    'line1': address_line1,
                    'line2': address_line2,
                    'ulica': instalacja.ulica or '',
                    'numer_domu': instalacja.numer_domu or '',
                    'mieszkanie': instalacja.mieszkanie or '',
                    'kod_pocztowy': instalacja.kod_pocztowy or '',
                    'miasto': instalacja.miasto or '',
                }
                przeglad_data['status'] = status
                przeglad_data['ekipa'] = ekipa
                przeglad_data['ekipa_id'] = ekipa_id

                result.append(przeglad_data)

            return Response({'przeglady': result}, status=200)
        except Exception as e:
            return Response({'error': str(e)}, status=400)


class SerwisListApiView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz listę serwisów dla instalacji",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'instalacja_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'instalacja_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID instalacji'),
            }
        ),
        responses={
            200: openapi.Response('Lista serwisów'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        token = request.data.get('token')
        instalacja_id = request.data.get('instalacja_id')

        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        if ac_user.is_klient():
            return Response({'error': 'User is klient'}, status=400)

        try:
            serwisy = Serwis.objects.filter(
                instalacja_id=instalacja_id, typ='serwis').order_by('-termin_serwisu')
            serializer = SerwisSerializer(serwisy, many=True)
            return Response({'serwisy': serializer.data}, status=200)
        except Exception as e:
            return Response({'error': str(e)}, status=400)


class GeneratePDFAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Generuj PDF protokołu przeglądu lub serwisu",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'type', 'serwis_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'type': openapi.Schema(type=openapi.TYPE_STRING, description='Typ dokumentu (przeglad/serwis/generic)', enum=['przeglad', 'serwis', 'generic']),
                'serwis_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID serwisu/przeglądu'),
            }
        ),
        responses={
            200: openapi.Response('HTML dokumentu do wydruku'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        token = request.data.get('token')
        # 'przeglad', 'serwis', 'generic'
        doc_type = request.data.get('type', 'generic')
        serwis_id = request.data.get('serwis_id')

        ac_user = get_cached_user(token)
        if not ac_user or not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        if ac_user.is_klient():
            return Response({'error': 'User is klient'}, status=400)

        # Jeśli to przegląd, pobierz dane z bazy
        if doc_type == 'przeglad' and serwis_id:
            try:
                serwis = Serwis.objects.get(id=serwis_id, typ='przeglad')
                serializer = SerwisSerializer(serwis)
                data = serializer.data

                # Pobierz dane urządzenia i instalacji
                device_data = None
                if serwis.montaz:
                    montaz = serwis.montaz
                    if montaz.devices_split.exists():
                        devices = montaz.devices_split.all()
                        if devices:
                            device = devices.first()
                            from .serializers import DeviceSplitSerializer
                            device_serializer = DeviceSplitSerializer(device)
                            device_data = device_serializer.data
                    elif montaz.devices_multi_split.exists():
                        devices = montaz.devices_multi_split.all()
                        if devices:
                            device = devices.first()
                            from .serializers import DeviceMultiSplitSerializer
                            device_serializer = DeviceMultiSplitSerializer(
                                device)
                            device_data = device_serializer.data

                instalacja = serwis.instalacja
                data['instalacja'] = {
                    'name': instalacja.name or '',
                    'ulica': instalacja.ulica or '',
                    'numer_domu': instalacja.numer_domu or '',
                    'mieszkanie': instalacja.mieszkanie or '',
                    'kod_pocztowy': instalacja.kod_pocztowy or '',
                    'miasto': instalacja.miasto or '',
                }
                data['device'] = device_data

                # Opcja 1: Zwróć HTML który frontend może wydrukować jako PDF
                html_content = f"""
                <!DOCTYPE html>
                <html>
                <head>
                    <meta charset="utf-8">
                    <title>Protokół przeglądu</title>
                    <style>
                        body {{ font-family: Arial, sans-serif; margin: 20px; }}
                        .header {{ text-align: center; margin-bottom: 30px; }}
                        .content {{ margin: 20px 0; }}
                        .section {{ margin-bottom: 20px; }}
                        .field {{ margin-bottom: 10px; }}
                        .label {{ font-weight: bold; }}
                    </style>
                </head>
                <body>
                    <div class="header">
                        <h1>Protokół przeglądu</h1>
                        <p>Data generowania: {timezone.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
                    </div>
                    <div class="content">
                        <div class="section">
                            <h2>Dane instalacji</h2>
                            <p><span class="label">Nazwa:</span> {data['instalacja']['name']}</p>
                            <p><span class="label">Adres:</span> {data['instalacja']['ulica']} {data['instalacja']['numer_domu']}, {data['instalacja']['kod_pocztowy']} {data['instalacja']['miasto']}</p>
                        </div>
                        <div class="section">
                            <h2>Dane przeglądu</h2>
                            <p><span class="label">Data przeglądu:</span> {data.get('data_przegladu', 'Nie podano')}</p>
                            <p><span class="label">Uwagi:</span> {data.get('uwagi', 'Brak')}</p>
                        </div>
                    </div>
                </body>
                </html>
                """
            except Serwis.DoesNotExist:
                return Response({'error': 'Przegląd not found'}, status=404)
        else:
            # Dla innych typów dokumentów lub gdy nie podano serwis_id
            data = request.data
            html_content = f"""
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="utf-8">
                <title>PDF Document</title>
                <style>
                    body {{ font-family: Arial, sans-serif; margin: 20px; }}
                    .header {{ text-align: center; margin-bottom: 30px; }}
                    .content {{ margin: 20px 0; }}
                </style>
            </head>
            <body>
                <div class="header">
                    <h1>PDF wygenerowany</h1>
                </div>
                <div class="content">
                    <p>Dane: {data}</p>
                    <p>Data generowania: {timezone.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
                </div>
            </body>
            </html>
            """

        # Opcja 2: Zwróć dane do dalszego przetwarzania przez frontend
        response_data = {
            'success': True,
            'message': 'PDF content prepared',
            'html_content': html_content,
            'data': data,
            'timestamp': timezone.now().isoformat()
        }

        return Response(response_data, status=status.HTTP_200_OK)


class OfertaTemplateCreateApiView(APIView):
    @swagger_auto_schema(
        operation_description="Utwórz szablon oferty",
        request_body=OfertaSerializer,
        responses={
            201: openapi.Response('Szablon oferty utworzony'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        pprint(request.data)
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'Wrong Token.'}, status=400)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)
        if ac_user.is_klient():
            return Response({'error': 'User is klient'}, status=400)

        data = request.data.copy()
        data['creator'] = ac_user.id
        data['is_template'] = True
        data['instalacja'] = None  # Szablony nie są powiązane z instalacją

        # Czyszczenie list z wartości None
        if 'narzut' in data:
            data['narzut'] = [x for x in data['narzut'] if x is not None]
        if 'rabat' in data:
            data['rabat'] = [x for x in data['rabat'] if x is not None]
        if 'devices_split' in data:
            data['devices_split'] = [
                x for x in data['devices_split'] if x is not None]
        if 'devices_multi_split' in data:
            data['devices_multi_split'] = [
                x for x in data['devices_multi_split'] if x is not None]

        serializer = OfertaSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=201)
        print("Validation errors:", serializer.errors)
        return Response(serializer.errors, status=400)


class OfertaTemplateListApiView(APIView):
    @swagger_auto_schema(
        operation_description="Pobierz listę szablonów ofert",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'szablony_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID szablonu (opcjonalne)'),
            }
        ),
        responses={
            200: openapi.Response('Lista szablonów ofert'),
            400: openapi.Response('Błąd walidacji'),
            404: openapi.Response('Użytkownik nie znaleziony'),
        }
    )
    def post(self, request):
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'User not found.'}, status=404)

        if not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)

        szablony_id = request.data.get('szablony_id', None)

        if szablony_id is not None:
            if not isinstance(szablony_id, list):
                return Response({'error': 'szablony_id should be a list.'}, status=400)
            try:
                szablony = Szablon.objects.filter(
                    owner=ac_user, id__in=szablony_id)
            except ValueError:
                return Response({'error': 'Invalid szablony_id.'}, status=400)
        else:
            szablony = Szablon.objects.filter(owner=ac_user)

        serializer = SzablonSerializer(szablony, many=True)
        return Response(serializer.data, status=200)


class FakturaCreateAPIView(APIView):
    @swagger_auto_schema(
        operation_description="Utwórz fakturę w systemie Fakturownia (tylko dla admina lub montażysty)",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'type', 'number', 'positions'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'type': openapi.Schema(type=openapi.TYPE_STRING, description='Typ faktury'),
                'number': openapi.Schema(type=openapi.TYPE_STRING, description='Numer faktury'),
                'sellDate': openapi.Schema(type=openapi.TYPE_STRING, description='Data sprzedaży'),
                'issueDate': openapi.Schema(type=openapi.TYPE_STRING, description='Data wystawienia'),
                'issuePlace': openapi.Schema(type=openapi.TYPE_STRING, description='Miejsce wystawienia'),
                'paymentDate': openapi.Schema(type=openapi.TYPE_INTEGER, description='Liczba dni do zapłaty', default=7),
                'sellerName': openapi.Schema(type=openapi.TYPE_STRING, description='Nazwa sprzedawcy'),
                'sellerNip': openapi.Schema(type=openapi.TYPE_STRING, description='NIP sprzedawcy'),
                'sellerAddress': openapi.Schema(type=openapi.TYPE_STRING, description='Adres sprzedawcy'),
                'sellerCode': openapi.Schema(type=openapi.TYPE_STRING, description='Kod pocztowy sprzedawcy'),
                'sellerCity': openapi.Schema(type=openapi.TYPE_STRING, description='Miasto sprzedawcy'),
                'sellerAccount': openapi.Schema(type=openapi.TYPE_STRING, description='Konto bankowe sprzedawcy'),
                'paymentMethod': openapi.Schema(type=openapi.TYPE_STRING, description='Metoda płatności'),
                'status': openapi.Schema(type=openapi.TYPE_STRING, description='Status faktury'),
                'prepaid': openapi.Schema(type=openapi.TYPE_NUMBER, description='Zaliczka'),
                'client_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID klienta'),
                'installation_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID instalacji'),
                'positions': openapi.Schema(
                    type=openapi.TYPE_ARRAY,
                    items=openapi.Schema(
                        type=openapi.TYPE_OBJECT,
                        properties={
                            'productName': openapi.Schema(type=openapi.TYPE_STRING),
                            'vat': openapi.Schema(type=openapi.TYPE_INTEGER),
                            'productBrutto': openapi.Schema(type=openapi.TYPE_NUMBER),
                            'productQuantity': openapi.Schema(type=openapi.TYPE_INTEGER),
                        }
                    ),
                    description='Pozycje faktury'
                ),
            }
        ),
        responses={
            201: openapi.Response('Faktura utworzona pomyślnie'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user or not ac_user.check_token(token):
            return Response({'error': 'Wrong Token.'}, status=400)
        if ac_user.is_admin() or ac_user.is_monter():
            # Pobierz dane z request
            sell_date = request.data.get('sellDate')
            issue_date = request.data.get('issueDate')
            type_invoice = request.data.get('type')
            issue_place = request.data.get('issuePlace')
            number = request.data.get('number')
            seller_name = request.data.get('sellerName')
            seller_nip = request.data.get('sellerNip')
            seller_address = request.data.get('sellerAddress')
            seller_code = request.data.get('sellerCode')
            seller_city = request.data.get('sellerCity')
            seller_account = request.data.get('sellerAccount')
            positions = request.data.get('positions')
            payment_method = request.data.get('paymentMethod')
            payment_date = request.data.get('paymentDate')
            status = request.data.get('status')
            prepaid = request.data.get('prepaid')
            issued_by = request.data.get('issuedBy')
            received_by = request.data.get('receivedBy')
            currency = request.data.get('currency')
            client_id = request.data.get('client')
            buyer = request.data.get('buyer')
            buyer_name = request.data.get('buyerName')
            buyer_nip = request.data.get('buyerNip')
            buyer_street = request.data.get('buyerStreet')
            buyer_code = request.data.get('buyerCode')
            buyer_city = request.data.get('buyerCity')
            installation_id = request.data.get('installationId')

            # Konwersja daty
            sell_date_obj = datetime.strptime(
                sell_date, "%Y-%m-%dT%H:%M:%S.%fZ")
            issue_date_obj = datetime.strptime(
                issue_date, "%Y-%m-%dT%H:%M:%S.%fZ")
            payment_to = (
                sell_date_obj + timedelta(days=int(payment_date))).strftime('%Y-%m-%d')
            sell_date = sell_date_obj.strftime('%Y-%m-%d')
            issue_date = issue_date_obj.strftime('%Y-%m-%d')

            # Przygotowanie pozycji faktury
            invoice_positions = []
            for pos in positions:
                invoice_positions.append({
                    'name': pos.get('productName'),
                    'tax': int(pos.get('vat')),
                    'total_price_gross': float(pos.get('productBrutto')),
                    'quantity': int(pos.get('productQuantity')),
                })

            # Przygotowanie danych do API Fakturownia
            invoice_data = {
                'api_token': 'T9KJ0u2F3_vY_JAocTvd',
                'invoice': {
                    'kind': type_invoice,
                    'number': number,
                    'sell_date': sell_date,
                    'issue_date': issue_date,
                    'payment_to': payment_to,
                    'seller_name': seller_name,
                    'seller_tax_no': seller_nip,
                    'buyer_name': buyer_name,
                    'buyer_tax_no': buyer_nip,
                    'buyer_email': '',
                    'positions': invoice_positions
                }
            }

            print('request.data', request.data)
            print('invoice_data', invoice_data)

            # Wyślij żądanie do API Fakturownia
            response = requests.post(
                'https://acmanager.fakturownia.pl/invoices.json?api_token=T9KJ0u2F3_vY_JAocTvd',
                json=invoice_data
            )

            print('response.json()', response.json())
            print('create faktura')

            # Sprawdź odpowiedź z API
            response_data = response.json()
            if 'id' in response_data and response_data['id'] is not None:
                # Faktura utworzona pomyślnie
                faktura = Faktury.objects.create(
                    ac_user=ac_user,
                    client_id=client_id,
                    instalacja_id=installation_id if installation_id else None,
                    status=status,
                    issue_date=issue_date,
                    order=payment_method,
                    id_fakturowni=response_data['id'],
                    numer_faktury=number
                )
                return Response({'message': 'Faktura utworzona pomyślnie', 'faktura_id': faktura.id}, status=201)
            else:
                # Błąd podczas tworzenia faktury
                error_message = response_data.get(
                    'message', 'Nieznany błąd')
                return Response({'error': f'Błąd podczas tworzenia faktury: {error_message}'}, status=400)
        return Response({'error': 'User is not Admin or Monter'}, status=400)


# ==================== CHAT API VIEWS ====================

class ConversationsListView(APIView):
    """Lista konwersacji dla zalogowanego użytkownika"""
    @swagger_auto_schema(
        operation_description="Pobierz listę konwersacji użytkownika",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
            }
        ),
        responses={
            200: openapi.Response('Lista konwersacji'),
            400: openapi.Response('Błąd walidacji'),
            401: openapi.Response('Nieprawidłowy token'),
        }
    )
    def post(self, request):
        token = request.data.get('token')
        if not token:
            return Response({'error': 'Token is required'}, status=400)

        user = ACUser.objects.filter(hash_value=token).first()
        if not user or not user.check_token(token):
            return Response({'error': 'Invalid token'}, status=401)

        # Pobierz wszystkie konwersacje użytkownika
        conversations = Conversation.objects.filter(
            models.Q(participant_1=user) | models.Q(participant_2=user)
        ).order_by('-updated_at')

        # Ustaw request.user dla serializera
        request.user = user

        serializer = ConversationSerializer(
            conversations, many=True, context={'request': request})
        return Response(serializer.data, status=200)


class ConversationMessagesView(APIView):
    """Lista wiadomości w konwersacji"""
    @swagger_auto_schema(
        operation_description="Pobierz wiadomości z konwersacji z paginacją",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'limit': openapi.Schema(type=openapi.TYPE_INTEGER, description='Liczba wiadomości do pobrania', default=25),
                'offset': openapi.Schema(type=openapi.TYPE_INTEGER, description='Offset paginacji', default=0),
            }
        ),
        responses={
            200: openapi.Response('Lista wiadomości'),
            400: openapi.Response('Błąd walidacji'),
            401: openapi.Response('Nieprawidłowy token'),
            403: openapi.Response('Brak dostępu do konwersacji'),
            404: openapi.Response('Konwersacja nie znaleziona'),
        }
    )
    def post(self, request, conversation_id):
        token = request.data.get('token')
        if not token:
            return Response({'error': 'Token is required'}, status=400)

        user = ACUser.objects.filter(hash_value=token).first()
        if not user or not user.check_token(token):
            return Response({'error': 'Invalid token'}, status=401)

        # Sprawdź czy konwersacja istnieje i użytkownik ma do niej dostęp
        conversation = get_object_or_404(Conversation, id=conversation_id)
        if conversation.participant_1 != user and conversation.participant_2 != user:
            return Response({'error': 'Access denied'}, status=403)

        # Pobierz wiadomości z paginacją
        limit = int(request.data.get('limit', 25))
        offset = int(request.data.get('offset', 0))

        # Pobierz wiadomości od najnowszych (DESC), następnie odwróć w froncie
        # Dla offset=0 pobieramy 25 najnowszych, dla offset=25 pobieramy kolejne 25 starszych itd.
        messages = conversation.messages.order_by(
            '-created_at')[offset:offset + limit]

        # Odwróć kolejność dla poprawnego wyświetlenia (od najstarszej do najnowszej w ramach strony)
        messages_list = list(messages)
        messages_list.reverse()

        serializer = MessageSerializer(messages_list, many=True)

        return Response({
            'messages': serializer.data,
            'total': conversation.messages.count(),
            'has_more': (offset + limit) < conversation.messages.count()
        }, status=200)


class SendMessageView(APIView):
    """Wysłanie wiadomości (fallback dla REST)"""
    @swagger_auto_schema(
        operation_description="Wyślij wiadomość w konwersacji",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'content'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'content': openapi.Schema(type=openapi.TYPE_STRING, description='Treść wiadomości'),
            }
        ),
        responses={
            201: openapi.Response('Wiadomość wysłana'),
            400: openapi.Response('Błąd walidacji'),
            401: openapi.Response('Nieprawidłowy token'),
            403: openapi.Response('Brak dostępu do konwersacji'),
            404: openapi.Response('Konwersacja nie znaleziona'),
        }
    )
    def post(self, request, conversation_id):
        token = request.data.get('token')
        content = request.data.get('content', '').strip()

        if not token:
            return Response({'error': 'Token is required'}, status=400)

        if not content:
            return Response({'error': 'Content is required'}, status=400)

        user = ACUser.objects.filter(hash_value=token).first()
        if not user or not user.check_token(token):
            return Response({'error': 'Invalid token'}, status=401)

        # Sprawdź czy konwersacja istnieje i użytkownik ma do niej dostęp
        conversation = get_object_or_404(Conversation, id=conversation_id)
        if conversation.participant_1 != user and conversation.participant_2 != user:
            return Response({'error': 'Access denied'}, status=403)

        # Utwórz wiadomość
        message = Message.objects.create(
            conversation=conversation,
            sender=user,
            content=content,
            is_read=False
        )

        serializer = MessageSerializer(message)
        return Response(serializer.data, status=201)


class MarkMessagesAsReadView(APIView):
    """Oznaczenie wiadomości jako przeczytane"""
    @swagger_auto_schema(
        operation_description="Oznacz wiadomości w konwersacji jako przeczytane",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
            }
        ),
        responses={
            200: openapi.Response('Wiadomości oznaczone jako przeczytane'),
            400: openapi.Response('Błąd walidacji'),
            401: openapi.Response('Nieprawidłowy token'),
            403: openapi.Response('Brak dostępu do konwersacji'),
            404: openapi.Response('Konwersacja nie znaleziona'),
        }
    )
    def post(self, request, conversation_id):
        token = request.data.get('token')
        if not token:
            return Response({'error': 'Token is required'}, status=400)

        user = ACUser.objects.filter(hash_value=token).first()
        if not user or not user.check_token(token):
            return Response({'error': 'Invalid token'}, status=401)

        # Sprawdź czy konwersacja istnieje i użytkownik ma do niej dostęp
        conversation = get_object_or_404(Conversation, id=conversation_id)
        if conversation.participant_1 != user and conversation.participant_2 != user:
            return Response({'error': 'Access denied'}, status=403)

        # Oznacz wiadomości jako przeczytane (tylko te NIE wysłane przez użytkownika)
        messages = conversation.messages.exclude(
            sender=user).filter(is_read=False)
        count = messages.update(is_read=True, read_at=timezone.now())

        return Response({'marked_as_read': count}, status=200)


class UnreadCountView(APIView):
    """Liczba wszystkich nieprzeczytanych wiadomości"""
    @swagger_auto_schema(
        operation_description="Pobierz liczbę nieprzeczytanych wiadomości użytkownika",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
            }
        ),
        responses={
            200: openapi.Response('Liczba nieprzeczytanych wiadomości'),
            400: openapi.Response('Błąd walidacji'),
            401: openapi.Response('Nieprawidłowy token'),
        }
    )
    def post(self, request):
        token = request.data.get('token')
        if not token:
            return Response({'error': 'Token is required'}, status=400)

        user = ACUser.objects.filter(hash_value=token).first()
        if not user or not user.check_token(token):
            return Response({'error': 'Invalid token'}, status=401)

        # Policz nieprzeczytane wiadomości we wszystkich konwersacjach użytkownika
        conversations = Conversation.objects.filter(
            models.Q(participant_1=user) | models.Q(participant_2=user)
        )

        unread_count = 0
        for conversation in conversations:
            unread_count += conversation.messages.exclude(
                sender=user).filter(is_read=False).count()

        return Response({'unread_count': unread_count}, status=200)


class StartConversationView(APIView):
    """Rozpoczęcie nowej konwersacji z klientem"""
    @swagger_auto_schema(
        operation_description="Rozpocznij nową konwersację z klientem (tylko dla admina lub montażysty)",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'client_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'client_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID klienta'),
            }
        ),
        responses={
            200: openapi.Response('Konwersacja utworzona lub istniejąca'),
            201: openapi.Response('Nowa konwersacja utworzona'),
            400: openapi.Response('Błąd walidacji'),
            401: openapi.Response('Nieprawidłowy token'),
            403: openapi.Response('Brak uprawnień'),
            404: openapi.Response('Klient nie znaleziony'),
        }
    )
    def post(self, request):
        token = request.data.get('token')
        client_id = request.data.get('client_id')

        if not token:
            return Response({'error': 'Token is required'}, status=400)

        if not client_id:
            return Response({'error': 'Client ID is required'}, status=400)

        user = ACUser.objects.filter(hash_value=token).first()
        if not user or not user.check_token(token):
            return Response({'error': 'Invalid token'}, status=401)

        # Sprawdź czy użytkownik to Admin lub Monter
        if user.user_type not in ['admin', 'monter']:
            return Response({'error': 'Only Admin or Monter can start conversations'}, status=403)

        # Pobierz klienta
        client = get_object_or_404(ACUser, id=client_id)

        # Sprawdź czy klient należy do tego użytkownika (dla Montera)
        if user.user_type == 'monter':
            if client not in user.clients.all():
                return Response({'error': 'Client does not belong to this monter'}, status=403)

        # Sprawdź czy konwersacja już istnieje
        conversation = Conversation.objects.filter(
            models.Q(participant_1=user, participant_2=client) |
            models.Q(participant_1=client, participant_2=user)
        ).first()

        # Ustaw request.user dla serializera
        request.user = user

        if conversation:
            # Konwersacja już istnieje
            serializer = ConversationSerializer(
                conversation, context={'request': request})
            return Response(serializer.data, status=200)

        # Utwórz nową konwersację
        conversation = Conversation.objects.create(
            participant_1=user,
            participant_2=client
        )

        serializer = ConversationSerializer(
            conversation, context={'request': request})
        return Response(serializer.data, status=201)


# ========================================
# Notifications API Views
# ========================================

class RegisterPushTokenApiView(APIView):
    """Rejestruje Expo push token użytkownika"""
    @swagger_auto_schema(
        operation_description="Zarejestruj token push notifications dla użytkownika",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika (może być w body lub Authorization header)'),
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Expo push token'),
                'device_name': openapi.Schema(type=openapi.TYPE_STRING, description='Nazwa urządzenia'),
            }
        ),
        responses={
            200: openapi.Response('Token zarejestrowany'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        token_value = request.data.get('token')
        device_name = request.data.get('device_name', '')

        # Weryfikacja użytkownika
        user_token = request.data.get('token') if not token_value else request.headers.get(
            'Authorization', '').replace('Bearer ', '')
        ac_user = get_cached_user(user_token)
        if not ac_user:
            return Response({'error': 'Invalid Token.'}, status=400)

        if not token_value:
            return Response({'error': 'Push token is required'}, status=400)

        # Utwórz lub zaktualizuj token
        from .models import PushNotificationToken
        push_token, created = PushNotificationToken.objects.update_or_create(
            user=ac_user,
            token=token_value,
            defaults={'device_name': device_name, 'is_active': True}
        )

        return Response({'success': True, 'created': created})


class NotificationsListApiView(APIView):
    """Pobiera listę powiadomień użytkownika"""
    @swagger_auto_schema(
        operation_description="Pobierz listę powiadomień użytkownika",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
            }
        ),
        manual_parameters=[
            openapi.Parameter('unread', openapi.IN_QUERY,
                              description='Filtruj tylko nieprzeczytane (true/false)', type=openapi.TYPE_BOOLEAN),
        ],
        responses={
            200: openapi.Response('Lista powiadomień'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        # Weryfikacja użytkownika
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'Invalid Token.'}, status=400)

        from .models import Notification
        notifications = Notification.objects.filter(
            user=ac_user,
            is_deleted=False
        )

        # Opcjonalnie filtruj tylko nieprzeczytane
        only_unread = request.query_params.get(
            'unread', 'false').lower() == 'true'
        if only_unread:
            notifications = notifications.filter(is_read=False)

        data = [{
            'id': n.id,
            'type': n.type,
            'title': n.title,
            'message': n.message,
            'is_read': n.is_read,
            'created_at': n.created_at.isoformat(),
            'related_object_type': n.related_object_type,
            'related_object_id': n.related_object_id,
            'data': n.data,
        } for n in notifications[:100]]  # Limit do 100 najnowszych

        return Response({
            'notifications': data,
            'unread_count': notifications.filter(is_read=False).count()
        })


class MarkNotificationReadApiView(APIView):
    """Oznacza powiadomienie jako przeczytane"""
    @swagger_auto_schema(
        operation_description="Oznacz powiadomienie jako przeczytane",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'notification_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'notification_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID powiadomienia'),
            }
        ),
        responses={
            200: openapi.Response('Powiadomienie oznaczone jako przeczytane'),
            400: openapi.Response('Błąd walidacji'),
            404: openapi.Response('Powiadomienie nie znalezione'),
        }
    )
    def post(self, request):
        # Weryfikacja użytkownika
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'Invalid Token.'}, status=400)

        notification_id = request.data.get('notification_id')

        from .models import Notification
        try:
            notification = Notification.objects.get(
                id=notification_id,
                user=ac_user
            )
            notification.is_read = True
            notification.read_at = timezone.now()
            notification.save()

            return Response({'success': True})
        except Notification.DoesNotExist:
            return Response({'error': 'Notification not found'}, status=404)


class DeleteNotificationApiView(APIView):
    """Usuwa powiadomienie (soft delete)"""
    @swagger_auto_schema(
        operation_description="Usuń powiadomienie (soft delete)",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'notification_id'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'notification_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID powiadomienia'),
            }
        ),
        responses={
            200: openapi.Response('Powiadomienie usunięte'),
            400: openapi.Response('Błąd walidacji'),
            404: openapi.Response('Powiadomienie nie znalezione'),
        }
    )
    def post(self, request):
        # Weryfikacja użytkownika
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'Invalid Token.'}, status=400)

        notification_id = request.data.get('notification_id')

        from .models import Notification
        try:
            notification = Notification.objects.get(
                id=notification_id,
                user=ac_user
            )
            notification.is_deleted = True
            notification.save()

            return Response({'success': True})
        except Notification.DoesNotExist:
            return Response({'error': 'Notification not found'}, status=404)


class MarkAllNotificationsReadApiView(APIView):
    """Oznacza wszystkie powiadomienia jako przeczytane"""
    @swagger_auto_schema(
        operation_description="Oznacz wszystkie powiadomienia użytkownika jako przeczytane",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
            }
        ),
        responses={
            200: openapi.Response('Wszystkie powiadomienia oznaczone jako przeczytane'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        # Weryfikacja użytkownika
        token = request.data.get('token')
        ac_user = get_cached_user(token)
        if not ac_user:
            return Response({'error': 'Invalid Token.'}, status=400)

        from .models import Notification
        Notification.objects.filter(
            user=ac_user,
            is_read=False
        ).update(is_read=True, read_at=timezone.now())

        return Response({'success': True})


class SyncPullAPIView(APIView):
    """
    Endpoint do pobierania zmian z serwera (pull synchronization)
    Zwraca wszystkie rekordy zmodyfikowane po last_synced_at
    """
    @swagger_auto_schema(
        operation_description="Pobierz zmiany z serwera (pull synchronization)",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'last_synced_at': openapi.Schema(type=openapi.TYPE_STRING, description='Data ostatniej synchronizacji (ISO format)', format='date-time'),
            }
        ),
        responses={
            200: openapi.Response('Zmiany z serwera'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        token = request.data.get('token')
        last_synced_at = request.data.get('last_synced_at')

        ac_user = get_cached_user(token)
        if not ac_user or not ac_user.check_token(token):
            return Response({'error': 'Invalid Token.'}, status=400)

        if not last_synced_at:
            last_synced_at = '1970-01-01T00:00:00Z'

        try:
            last_sync = datetime.fromisoformat(
                last_synced_at.replace('Z', '+00:00'))
        except:
            last_sync = datetime(1970, 1, 1, tzinfo=timezone.utc)

        changes = {}

        # Pobierz zmiany dla każdej tabeli
        # Clients (ACUser) - tylko klienci użytkownika
        clients = ACUser.objects.filter(
            Q(parent=ac_user) | Q(monter=ac_user) | Q(id=ac_user.id)
        ).distinct()

        # Jeśli model ma updated_at, filtruj po nim (dodaj pole updated_at do modelu jeśli nie ma)
        # Na razie pobieramy wszystkich klientów użytkownika

        changes['clients'] = [{
            'id': c.id,
            'first_name': c.first_name,
            'last_name': c.last_name,
            'email': c.email,
            'url': c.url,
            'user_type': c.user_type,
            'parent_id': c.parent_id if c.parent else None,
            'group_id': c.group_id if c.group else None,
            'map_list_id': c.map_list_id if c.map_list_id else None,
            'has_account': c.has_account,
            'updated_at': c.updated_at.isoformat() if hasattr(c, 'updated_at') else timezone.now().isoformat(),
        } for c in clients]

        # UserData
        user_data_list = UserData.objects.filter(
            ac_user__in=clients
        )
        changes['user_data'] = [{
            'id': ud.id,
            'ac_user_id': ud.ac_user_id,
            'rodzaj_klienta': ud.rodzaj_klienta,
            'nazwa_firmy': ud.nazwa_firmy,
            'nip': ud.nip,
            'typ_klienta': ud.typ_klienta,
            'ulica': ud.ulica,
            'mieszkanie': ud.mieszkanie,
            'kod_pocztowy': ud.kod_pocztowy,
            'numer_domu': ud.numer_domu,
            'miasto': ud.miasto,
            'numer_telefonu': ud.numer_telefonu,
            'longitude': float(ud.longitude) if ud.longitude else None,
            'latitude': float(ud.latitude) if ud.latitude else None,
            'client_status': ud.client_status,
            'lista_klientow': ud.lista_klientow,
        } for ud in user_data_list]

        # Installations
        installations = Instalacja.objects.filter(
            models.Q(owner=ac_user) | models.Q(klient__in=clients)
        )
        if hasattr(Instalacja, 'updated_at'):
            installations = installations.filter(updated_at__gt=last_sync)
        changes['installations'] = [{
            'id': inst.id,
            'owner_id': inst.owner_id,
            'klient_id': inst.klient_id,
            'name': inst.name,
            'created_date': inst.created_date.isoformat() if inst.created_date else None,
        } for inst in installations]

        # Offers
        offers = Oferta.objects.filter(
            creator=ac_user
        )
        if hasattr(Oferta, 'updated_date'):
            offers = offers.filter(updated_date__gt=last_sync)
        changes['offers'] = [{
            'id': o.id,
            'instalacja_id': o.instalacja_id,
            'creator_id': o.creator_id,
            'is_accepted': o.is_accepted,
            'is_template': o.is_template,
            'offer_type': o.offer_type,
            'nazwa_oferty': o.nazwa_oferty,
            'wersja': o.wersja,
            'created_date': o.created_date.isoformat() if o.created_date else None,
            'updated_date': o.updated_date.isoformat() if o.updated_date else None,
            'selected_device_id': o.selected_device_id,
            'proposed_montaz_date': o.proposed_montaz_date.isoformat() if o.proposed_montaz_date else None,
            'proposed_montaz_time': str(o.proposed_montaz_time) if o.proposed_montaz_time else None,
            'montaz_status': o.montaz_status,
            'montaz_zadanie_id': o.montaz_zadanie_id,
            'rejection_reason': o.rejection_reason,
        } for o in offers]

        # Tasks (Zadanie)
        tasks = Zadanie.objects.filter(
            rodzic=ac_user
        )
        if hasattr(Zadanie, 'updated_at'):
            tasks = tasks.filter(updated_at__gt=last_sync)
        changes['tasks'] = [{
            'id': t.id,
            'rodzic_id': t.rodzic_id,
            'grupa': t.grupa,
            'instalacja_id': t.instalacja_id,
            'status': t.status,
            'nazwa': t.nazwa,
            'start_date': t.start_date.isoformat() if t.start_date else None,
            'end_date': t.end_date.isoformat() if t.end_date else None,
            'czy_oferta': t.czy_oferta,
            'czy_faktura': t.czy_faktura,
            'notatki': t.notatki,
            'typ': t.typ,
        } for t in tasks]

        # Montaz
        montaze = Montaz.objects.filter(
            instalacja__in=installations
        )
        if hasattr(Montaz, 'updated_at'):
            montaze = montaze.filter(updated_at__gt=last_sync)
        changes['montaz'] = [{
            'id': m.id,
            'instalacja_id': m.instalacja_id,
            'created_date': m.created_date.isoformat() if m.created_date else None,
            'data_montazu': m.data_montazu.isoformat() if m.data_montazu else None,
            'gwarancja': m.gwarancja,
            'liczba_przegladow': m.liczba_przegladow,
            'split_multisplit': m.split_multisplit,
            'nr_seryjny_jedn_zew': m.nr_seryjny_jedn_zew,
            'nr_seryjny_jedn_zew_photo': m.nr_seryjny_jedn_zew_photo,
            'nr_seryjny_jedn_wew': m.nr_seryjny_jedn_wew,
            'nr_seryjny_jedn_wew_photo': m.nr_seryjny_jedn_wew_photo,
            'miejsce_montazu_jedn_zew': m.miejsce_montazu_jedn_zew,
            'miejsce_montazu_jedn_zew_photo': m.miejsce_montazu_jedn_zew_photo,
            'miejsce_montazu_jedn_wew': m.miejsce_montazu_jedn_wew,
            'miejsce_montazu_jedn_wew_photo': m.miejsce_montazu_jedn_wew_photo,
            'sposob_skroplin': m.sposob_skroplin,
            'miejsce_skroplin': m.miejsce_skroplin,
            'miejsce_i_sposob_montazu_jedn_zew': m.miejsce_i_sposob_montazu_jedn_zew,
            'miejsce_i_sposob_montazu_jedn_zew_photo': m.miejsce_i_sposob_montazu_jedn_zew_photo,
            'miejsce_podlaczenia_elektryki': m.miejsce_podlaczenia_elektryki,
            'gaz': m.gaz,
            'gaz_ilosc_dodana': float(m.gaz_ilosc_dodana) if m.gaz_ilosc_dodana else None,
            'gaz_ilos': float(m.gaz_ilos) if m.gaz_ilos else None,
            'temp_zew_montazu': float(m.temp_zew_montazu) if m.temp_zew_montazu else None,
            'temp_wew_montazu': float(m.temp_wew_montazu) if m.temp_wew_montazu else None,
            'cisnienie': float(m.cisnienie) if m.cisnienie else None,
            'przegrzanie': float(m.przegrzanie) if m.przegrzanie else None,
            'temp_chlodzenia': float(m.temp_chlodzenia) if m.temp_chlodzenia else None,
            'temp_grzania': float(m.temp_grzania) if m.temp_grzania else None,
            'uwagi': m.uwagi,
            'kontrola_stanu_technicznego_jedn_wew': m.kontrola_stanu_technicznego_jedn_wew,
            'kontrola_stanu_technicznego_jedn_zew': m.kontrola_stanu_technicznego_jedn_zew,
            'kontrola_stanu_mocowania_agregatu': m.kontrola_stanu_mocowania_agregatu,
            'czyszczenie_filtrow_jedn_wew': m.czyszczenie_filtrow_jedn_wew,
            'czyszczenie_wymiennika_ciepla_jedn_wew': m.czyszczenie_wymiennika_ciepla_jedn_wew,
            'czyszczenie_obudowy_jedn_wew': m.czyszczenie_obudowy_jedn_wew,
            'czyszczenie_tacy_skroplin': m.czyszczenie_tacy_skroplin,
            'kontrola_droznosci_odplywu_skroplin': m.kontrola_droznosci_odplywu_skroplin,
            'czyszczenie_obudowy_jedn_zew': m.czyszczenie_obudowy_jedn_zew,
            'czyszczenie_wymiennika_ciepla_jedn_zew': m.czyszczenie_wymiennika_ciepla_jedn_zew,
            'kontrola_szczelnosci_instalacji': m.kontrola_szczelnosci_instalacji,
            'kontrola_poprawnosci_dzialania': m.kontrola_poprawnosci_dzialania,
            'kontrola_temperatury_nawiewu': m.kontrola_temperatury_nawiewu,
            'diagnostyka_awarii_urzadzen': m.diagnostyka_awarii_urzadzen,
        } for m in montaze]

        # Photos
        photos = Photo.objects.filter(
            owner=ac_user
        )
        if hasattr(Photo, 'updated_at'):
            photos = photos.filter(updated_at__gt=last_sync)
        changes['photos'] = [{
            'id': p.id,
            'owner_id': p.owner_id,
            'klient_id': p.klient_id,
            'instalacja_id': p.instalacja,
            'serwis_id': p.serwis,
            'montaz_id': p.montaz,
            'inspekcja_id': p.inspekcja_id if p.inspekcja else None,
            'image_url': request.build_absolute_uri(p.image.url) if p.image else None,
        } for p in photos]

        # Messages
        conversations = Conversation.objects.filter(
            Q(participant_1=ac_user) | Q(participant_2=ac_user)
        )
        messages = Message.objects.filter(
            conversation__in=conversations
        )
        if hasattr(Message, 'updated_at'):
            messages = messages.filter(updated_at__gt=last_sync)
        changes['messages'] = [{
            'id': msg.id,
            'conversation_id': msg.conversation_id,
            'sender_id': msg.sender_id,
            'content': msg.content,
            'created_at': msg.created_at.isoformat() if msg.created_at else None,
            'is_read': msg.is_read,
            'read_at': msg.read_at.isoformat() if msg.read_at else None,
        } for msg in messages]

        return Response({
            'changes': changes,
            'sync_timestamp': timezone.now().isoformat(),
        })


class SyncPushAPIView(APIView):
    """
    Endpoint do wysyłania zmian z klienta (push synchronization)
    Przyjmuje zmiany i zapisuje je na serwerze
    """
    @swagger_auto_schema(
        operation_description="Wyślij zmiany z klienta na serwer (push synchronization)",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['token', 'table', 'changes'],
            properties={
                'token': openapi.Schema(type=openapi.TYPE_STRING, description='Token użytkownika'),
                'table': openapi.Schema(type=openapi.TYPE_STRING, description='Nazwa tabeli'),
                'changes': openapi.Schema(
                    type=openapi.TYPE_ARRAY,
                    items=openapi.Schema(type=openapi.TYPE_OBJECT),
                    description='Lista zmian do synchronizacji'
                ),
            }
        ),
        responses={
            200: openapi.Response('Zmiany zsynchronizowane'),
            400: openapi.Response('Błąd walidacji'),
        }
    )
    def post(self, request):
        token = request.data.get('token')
        table = request.data.get('table')
        changes = request.data.get('changes', [])

        ac_user = get_cached_user(token)
        if not ac_user or not ac_user.check_token(token):
            return Response({'error': 'Invalid Token.'}, status=400)

        if not table or not changes:
            return Response({'error': 'Table and changes are required.'}, status=400)

        processed = []

        try:
            with transaction.atomic():
                for change in changes:
                    operation = change.get('operation')
                    local_id = change.get('local_id')
                    data = change.get('data', {})

                    try:
                        if operation == 'create':
                            result = self._create_record(table, data, ac_user)
                            processed.append({
                                'local_id': local_id,
                                'server_id': result.get('id'),
                                'success': True,
                            })
                        elif operation == 'update':
                            result = self._update_record(table, data, ac_user)
                            processed.append({
                                'local_id': local_id,
                                'server_id': result.get('id'),
                                'success': True,
                            })
                        elif operation == 'delete':
                            self._delete_record(table, data, ac_user)
                            processed.append({
                                'local_id': local_id,
                                'success': True,
                            })
                    except Exception as e:
                        processed.append({
                            'local_id': local_id,
                            'success': False,
                            'error': str(e),
                        })
        except Exception as e:
            return Response({'error': str(e)}, status=500)

        return Response({
            'processed': processed,
            'success': True,
        })

    def _create_record(self, table, data, ac_user):
        """Tworzy nowy rekord"""
        if table == 'clients':
            # Clients są tworzone przez admina/montera, więc pomijamy
            return {'id': None}
        elif table == 'offers':
            offer = Oferta.objects.create(
                instalacja_id=data.get('instalacja_id'),
                creator=ac_user,
                is_accepted=data.get('is_accepted', False),
                is_template=data.get('is_template', False),
                offer_type=data.get('offer_type'),
                nazwa_oferty=data.get('nazwa_oferty'),
                wersja=data.get('wersja', 1),
                selected_device_id=data.get('selected_device_id'),
                proposed_montaz_date=data.get('proposed_montaz_date'),
                proposed_montaz_time=data.get('proposed_montaz_time'),
                montaz_status=data.get('montaz_status', 'none'),
                rejection_reason=data.get('rejection_reason'),
            )
            return {'id': offer.id}
        elif table == 'tasks':
            task = Zadanie.objects.create(
                rodzic=ac_user,
                grupa=data.get('grupa'),
                instalacja_id=data.get('instalacja_id'),
                status=data.get('status', 'niewykonane'),
                nazwa=data.get('nazwa'),
                start_date=data.get('start_date'),
                end_date=data.get('end_date'),
                czy_oferta=data.get('czy_oferta', False),
                czy_faktura=data.get('czy_faktura', False),
                notatki=data.get('notatki'),
                typ=data.get('typ', 'montaż'),
            )
            return {'id': task.id}
        # Dodaj więcej tabel według potrzeb
        return {'id': None}

    def _update_record(self, table, data, ac_user):
        """Aktualizuje istniejący rekord"""
        record_id = data.get('id')
        if not record_id:
            raise ValueError('Record ID is required for update')

        if table == 'offers':
            offer = Oferta.objects.get(id=record_id, creator=ac_user)
            for key, value in data.items():
                if key != 'id' and hasattr(offer, key):
                    setattr(offer, key, value)
            offer.save()
            return {'id': offer.id}
        elif table == 'tasks':
            task = Zadanie.objects.get(id=record_id, rodzic=ac_user)
            for key, value in data.items():
                if key != 'id' and hasattr(task, key):
                    setattr(task, key, value)
            task.save()
            return {'id': task.id}
        # Dodaj więcej tabel według potrzeb
        return {'id': record_id}

    def _delete_record(self, table, data, ac_user):
        """Usuwa rekord"""
        record_id = data.get('id')
        if not record_id:
            raise ValueError('Record ID is required for delete')

        if table == 'offers':
            Oferta.objects.filter(id=record_id, creator=ac_user).delete()
        elif table == 'tasks':
            Zadanie.objects.filter(id=record_id, rodzic=ac_user).delete()
        # Dodaj więcej tabel według potrzeb        # Dodaj więcej tabel według potrzeb
