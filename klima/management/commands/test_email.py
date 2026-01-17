from django.conf import settings
from django.core.mail import send_mail
from django.core.management.base import BaseCommand


class Command(BaseCommand):
    help = 'Wysyła testowy email na podany adres (domyślnie: jakub.stawski@interactive.net.pl)'

    def add_arguments(self, parser):
        parser.add_argument(
            '--email',
            type=str,
            default='jakub.stawski@interactive.net.pl',
            help='Adres email, na który wysłać testowy email (domyślnie: jakub.stawski@interactive.net.pl)',
        )
        parser.add_argument(
            '--subject',
            type=str,
            default='Test email z AC Manager',
            help='Temat wiadomości email',
        )

    def handle(self, *args, **options):
        email = options['email']
        subject = options['subject']

        # Wyświetl informacje diagnostyczne przed wysłaniem
        self.stdout.write('\n=== Konfiguracja SMTP ===')
        self.stdout.write(
            f'EMAIL_HOST: {getattr(settings, "EMAIL_HOST", "Nie ustawione")}')
        self.stdout.write(
            f'EMAIL_PORT: {getattr(settings, "EMAIL_PORT", "Nie ustawione")}')
        self.stdout.write(
            f'EMAIL_USE_TLS: {getattr(settings, "EMAIL_USE_TLS", "Nie ustawione")}')
        self.stdout.write(
            f'EMAIL_HOST_USER: {getattr(settings, "EMAIL_HOST_USER", "Nie ustawione")}')
        self.stdout.write(
            f'EMAIL_HOST_PASSWORD: {"***" if getattr(settings, "EMAIL_HOST_PASSWORD", None) else "Nie ustawione"}')
        self.stdout.write(
            f'DEFAULT_FROM_EMAIL: {getattr(settings, "DEFAULT_FROM_EMAIL", "Nie ustawione")}')
        self.stdout.write(f'\nPróba wysłania emaila na: {email}')
        self.stdout.write('')

        message = f'''To jest testowy email z aplikacji AC Manager.

Ten email został wysłany w celu przetestowania mechanizmu wysyłania maili.

Konfiguracja email:
- EMAIL_BACKEND: {getattr(settings, 'EMAIL_BACKEND', 'Nie ustawione')}
- EMAIL_HOST: {getattr(settings, 'EMAIL_HOST', 'Nie ustawione')}
- EMAIL_PORT: {getattr(settings, 'EMAIL_PORT', 'Nie ustawione')}
- EMAIL_USE_TLS: {getattr(settings, 'EMAIL_USE_TLS', 'Nie ustawione')}
- EMAIL_HOST_USER: {getattr(settings, 'EMAIL_HOST_USER', 'Nie ustawione')}
- DEFAULT_FROM_EMAIL: {getattr(settings, 'DEFAULT_FROM_EMAIL', 'Nie ustawione')}

Jeśli otrzymałeś ten email, oznacza to, że mechanizm wysyłania maili działa poprawnie.

Pozdrawiamy,
Zespół AC Manager'''

        try:
            send_mail(
                subject=subject,
                message=message,
                from_email=getattr(
                    settings, 'DEFAULT_FROM_EMAIL', 'noreply@acmanager.pl'),
                recipient_list=[email],
                fail_silently=False,
            )
            self.stdout.write(
                self.style.SUCCESS(
                    f'✓ Testowy email został pomyślnie wysłany na adres: {email}'
                )
            )
        except Exception as e:
            self.stdout.write(
                self.style.ERROR(
                    f'✗ Błąd podczas wysyłania emaila: {str(e)}'
                )
            )
            raise
