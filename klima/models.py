from datetime import datetime, timedelta

import jwt
from django.contrib.auth.hashers import check_password, make_password
from django.db import models
from django.dispatch import receiver
from django.utils import timezone
from rest_framework.authtoken.models import Token

SECRET_KEY = 'Twój Tajny Klucz'


class Group(models.Model):
    nazwa = models.CharField(max_length=255)
    owner = models.PositiveIntegerField(null=True)
    # TODO zrobić ze jesli sie usuwa AC Usera to usuwają sie jego grupy


class ACUser(models.Model):

    ADMIN = 'admin'
    MONTER = 'monter'
    KLIENT = 'klient'
    USER_TYPE_CHOICES = (
        (ADMIN, 'Admin'),
        (MONTER, 'Monter'),
        (KLIENT, 'Klient'),
    )

    first_name = models.CharField(max_length=255)
    last_name = models.CharField(max_length=255)
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=128)
    url = models.URLField(
        default='http://51.68.143.33/static/default_user.png', null=False)
    parent = models.ForeignKey(
        'self', on_delete=models.CASCADE, null=True, blank=True, related_name='children')
    monter = models.ManyToManyField(
        'self', symmetrical=False, related_name='clients', blank=True)
    user_type = models.CharField(
        max_length=10, choices=USER_TYPE_CHOICES, default=KLIENT)
    hash_value = models.CharField(max_length=128, db_index=True)
    group = models.ForeignKey(
        Group, on_delete=models.SET_NULL, null=True, blank=True)
    map_list_id = models.ForeignKey(
        'ListyKlientow', on_delete=models.SET_NULL, null=True, blank=True)
    has_account = models.BooleanField(
        default=False, verbose_name="Czy ma konto w aplikacji")

    class Meta:
        indexes = [
            models.Index(fields=['hash_value'], name='acuser_hash_value_idx'),
            models.Index(fields=['email'], name='acuser_email_idx'),
        ]

    def __str__(self):
        return self.email

    def is_admin(self):
        return self.user_type == self.ADMIN

    def is_monter(self):
        return self.user_type == self.MONTER

    def is_klient(self):
        return self.user_type == self.KLIENT

    def get_children(self):
        return self.children.all()

    def get_clients(self):
        return self.clients.all()

    def set_password(self, password):
        self.password = make_password(password)

    def check_password(self, password):
        return check_password(password, self.password)

    def check_if_has_account(self):
        """
        Sprawdza czy użytkownik ma konto w aplikacji.
        Jeśli has_account nie jest ustawione, sprawdza czy hasło jest różne od domyślnego "aaa"
        """
        if self.has_account:
            return True

        # Sprawdź czy hasło jest różne od domyślnego "aaa"
        # Domyślne hasło dla nowych klientów to "aaa"
        try:
            if not check_password('aaa', self.password):
                # Hasło jest różne od domyślnego, więc użytkownik ma konto
                self.has_account = True
                self.save(update_fields=['has_account'])
                return True
        except:
            # Jeśli sprawdzenie hasła się nie powiodło, załóżmy że użytkownik nie ma konta
            pass

        return False

    def save(self, *args, **kwargs):
        super().save(*args, **kwargs)

    @staticmethod
    def verify_user(email, password):
        try:
            user = ACUser.objects.get(email=email)
            if user.check_password(password):
                return user
        except ACUser.DoesNotExist:
            pass

        return None

    def generate_token(self):
        payload = {
            'user_id': self.id,
            'exp': datetime.utcnow() + timedelta(days=7)  # Token będzie ważny przez 7 dni
        }
        self.hash_value = jwt.encode(payload, SECRET_KEY, algorithm='HS256')
        super().save()
        return self.hash_value

    def is_token_valid(self, token):
        try:
            payload = jwt.decode(token, 'Twój Tajny Klucz',
                                 algorithms=['HS256'])
            exp_timestamp = payload['exp']
            current_timestamp = datetime.timestamp(datetime.now())
            if current_timestamp < exp_timestamp:
                return True
        except jwt.ExpiredSignatureError:
            pass
        except jwt.InvalidTokenError:
            pass
        return False

    def check_token(self, token):
        if self.is_token_valid(token):
            if token == self.hash_value:
                return True
        return False


class UserData(models.Model):
    KLIENCI_CHOICES = [
        ('firma', 'Firma'),
        ('osoba_prywatna', 'Osoba prywatna'),
    ]

    TYP_KLIENTA_CHOICES = [
        ('0', 'Aktywny'),
        ('1', 'Nieaktywny'),
    ]

    ac_user = models.OneToOneField(ACUser, on_delete=models.CASCADE)
    rodzaj_klienta = models.CharField(
        max_length=20, choices=KLIENCI_CHOICES, default='firma')
    nazwa_firmy = models.CharField(max_length=100, blank=True, null=True)
    nip = models.CharField(max_length=15, blank=True, null=True)
    typ_klienta = models.CharField(
        max_length=20, choices=TYP_KLIENTA_CHOICES, default='aktualny')
    ulica = models.CharField(max_length=100, blank=True, null=True)
    mieszkanie = models.CharField(max_length=100, blank=True, null=True)
    kod_pocztowy = models.CharField(max_length=10, blank=True, null=True)
    numer_domu = models.CharField(max_length=10, blank=True, null=True)
    miasto = models.CharField(max_length=100, blank=True, null=True)
    numer_telefonu = models.CharField(max_length=20, blank=True, null=True)
    longitude = models.FloatField(blank=True, null=True)
    latitude = models.FloatField(blank=True, null=True)
    client_status = models.CharField(
        max_length=20, choices=TYP_KLIENTA_CHOICES, default='0')
    lista_klientow = models.IntegerField(null=True, blank=True)

    def __str__(self):
        return f"Ustawienia użytkownika: {self.acuser.username}"


class Task(models.Model):
    TASK_TYPE_CHOICES = [
        ('serwis', 'Serwis'),
        ('montaż', 'Montaż'),
        ('audyt', 'Audyt'),
    ]

    STATUS_CHOICES = [
        ('wykonane', 'Wykonane'),
        ('nie_wykonane', 'Nie wykonane'),
    ]

    start_date = models.DateTimeField()
    end_date = models.DateTimeField()
    name = models.CharField(max_length=100, blank=True)
    task_type = models.CharField(
        max_length=20, choices=TASK_TYPE_CHOICES, default="montaż")
    status = models.CharField(
        max_length=20, choices=STATUS_CHOICES, default="wykonane")
    assigned_monter = models.ForeignKey(
        ACUser, on_delete=models.CASCADE, null=True, blank=True)
    assigned_group = models.IntegerField(null=True, blank=True)


def get_certificate_upload_to(instance, filename):
    return f'documents/certificates/{instance.ac_user.id}/{filename}'


def get_szkolenie_upload_to(instance, filename):
    return f'documents/szkolenia/{instance.ac_user.id}/{filename}'


def get_katalog_upload_to(instance, filename):
    return f'documents/katalogi/{instance.ac_user.id}/{filename}'


def get_cennik_upload_to(instance, filename):
    return f'documents/cenniki/{instance.ac_user.id}/{filename}'


def get_ulotka_upload_to(instance, filename):
    return f'documents/ulotka/{instance.ac_user.id}/{filename}'


class Certificate(models.Model):
    ac_user = models.ForeignKey(ACUser, on_delete=models.CASCADE)
    name = models.CharField(max_length=100, blank=True)
    file = models.FileField(upload_to=get_certificate_upload_to, blank=True)
    created_date = models.DateTimeField(auto_now_add=True)
    set_date = models.DateTimeField()


class Szkolenie(models.Model):
    ac_user = models.ForeignKey(ACUser, on_delete=models.CASCADE)
    name = models.CharField(max_length=100, blank=True)
    file = models.FileField(upload_to=get_szkolenie_upload_to, blank=True)
    created_date = models.DateTimeField(auto_now_add=True)
    set_date = models.DateTimeField()


class Katalog(models.Model):
    ac_user = models.ForeignKey(ACUser, on_delete=models.CASCADE)
    name = models.CharField(max_length=100, blank=True)
    file = models.FileField(upload_to=get_katalog_upload_to, blank=True)
    created_date = models.DateTimeField(auto_now_add=True)
    is_active = models.BooleanField(default=True)


class Cennik(models.Model):
    ac_user = models.ForeignKey(ACUser, on_delete=models.CASCADE)
    name = models.CharField(max_length=100, blank=True)
    file = models.FileField(upload_to=get_cennik_upload_to, blank=True)
    created_date = models.DateTimeField(auto_now_add=True)
    is_active = models.BooleanField(default=True)


class Ulotka(models.Model):
    ac_user = models.ForeignKey(ACUser, on_delete=models.CASCADE)
    name = models.CharField(max_length=100, blank=True)
    file = models.FileField(upload_to=get_ulotka_upload_to, blank=True)
    created_date = models.DateTimeField(auto_now_add=True)
    is_active = models.BooleanField(default=True)
###################################################################################


class DeviceSplit(models.Model):
    data = models.DateTimeField(blank=True, null=True)
    producent = models.CharField(max_length=255, blank=True, null=True)
    typ = models.CharField(max_length=255, blank=True, null=True)
    moc_chlodnicza = models.DecimalField(
        max_digits=8, decimal_places=2, blank=True, null=True)
    moc_grzewcza = models.DecimalField(
        max_digits=8, decimal_places=2, blank=True, null=True)
    nazwa_modelu = models.CharField(max_length=255, blank=True, null=True)
    nazwa_modelu_producenta = models.CharField(
        max_length=255, blank=True, null=True)
    nazwa_jedn_wew = models.CharField(max_length=255, blank=True, null=True)
    nazwa_jedn_zew = models.CharField(max_length=255, blank=True, null=True)
    cena_katalogowa_netto = models.DecimalField(
        max_digits=8, decimal_places=2, blank=True, default=0.0, null=True)
    kolor = models.CharField(max_length=255, blank=True, null=True)
    glosnosc = models.DecimalField(
        max_digits=8, decimal_places=2, blank=True, null=True)
    wielkosc_wew = models.DecimalField(
        max_digits=8, decimal_places=2, blank=True, null=True)
    wielkosc_zew = models.DecimalField(
        max_digits=8, decimal_places=2, blank=True, null=True)
    klasa_energetyczna_chlodzenie = models.CharField(
        max_length=255, blank=True, null=True)
    klasa_energetyczna_grzanie = models.CharField(
        max_length=255, blank=True, null=True)
    sterowanie_wifi = models.BooleanField(default=False)


class DeviceMultiSplit(models.Model):
    data = models.DateTimeField(blank=True, null=True)
    producent = models.CharField(max_length=255, blank=True, null=True)
    rodzaj = models.CharField(max_length=255, blank=True, null=True)
    maks_ilosc_jedn_wew = models.IntegerField(blank=True, null=True)
    typ_jedn_zew = models.CharField(max_length=255, blank=True, null=True)
    typ_jedn_wew = models.CharField(max_length=255, blank=True, null=True)
    moc_chlodnicza = models.DecimalField(
        max_digits=8, decimal_places=2, blank=True, null=True)
    moc_grzewcza = models.DecimalField(
        max_digits=8, decimal_places=2, blank=True, null=True)
    model_nazwa = models.CharField(max_length=255, blank=True, null=True)
    nazwa_modelu_producenta = models.CharField(
        max_length=255, blank=True, null=True)
    nazwa_jedn_wew = models.CharField(max_length=255, blank=True, null=True)
    nazwa_jedn_zew = models.CharField(max_length=255, blank=True, null=True)
    cena_katalogowa_netto = models.DecimalField(
        max_digits=8, decimal_places=2, blank=True, default=0.0, null=True)
    kolor = models.CharField(max_length=255, blank=True, null=True)
    glosnosc = models.DecimalField(
        max_digits=8, decimal_places=2, blank=True, null=True)
    wielkosc_wew = models.DecimalField(
        max_digits=8, decimal_places=2, blank=True, null=True)
    wielkosc_zew = models.DecimalField(
        max_digits=8, decimal_places=2, blank=True, null=True)
    klasa_energetyczna_chlodzenie = models.CharField(
        max_length=255, blank=True, null=True)
    klasa_energetyczna_grzanie = models.CharField(
        max_length=255, blank=True, null=True)
    sterowanie_wifi = models.BooleanField(default=False)


class Narzut(models.Model):
    owner = models.ForeignKey(ACUser, on_delete=models.CASCADE)
    name = models.CharField(max_length=255)
    value = models.FloatField()
    created_date = models.DateTimeField(auto_now_add=True)
    order = models.PositiveIntegerField()  # Dodaj pole order

    class Meta:
        ordering = ['owner', 'order']


class Rabat(models.Model):
    owner = models.ForeignKey(ACUser, on_delete=models.CASCADE)
    producent = models.CharField(max_length=255)
    value = models.FloatField()
    created_date = models.DateTimeField(auto_now_add=True)


class Tag(models.Model):
    name = models.CharField(max_length=50)
    created_date = models.DateTimeField(auto_now_add=True)


class Photo(models.Model):
    owner = models.ForeignKey(
        ACUser, on_delete=models.CASCADE, related_name='owner_photo')
    klient = models.ForeignKey(
        ACUser, on_delete=models.CASCADE, related_name='klient_photo', null=True, blank=True)
    instalacja = models.PositiveIntegerField(null=True)
    serwis = models.PositiveIntegerField(null=True)
    montaz = models.PositiveIntegerField(null=True)
    inspekcja = models.ForeignKey(
        'Inspekcja', on_delete=models.CASCADE, null=True, blank=True, related_name='inspection_photos')
    image = models.ImageField(upload_to='documents/photos/')
    tags = models.ManyToManyField(Tag, blank=True)


class Instalacja(models.Model):
    owner = models.ForeignKey(
        ACUser, on_delete=models.CASCADE, related_name='owner_instalation')
    klient = models.ForeignKey(
        ACUser, on_delete=models.CASCADE, related_name='klient_instalation', db_index=True)
    name = models.CharField(max_length=255, blank=True, null=True)
    created_date = models.DateTimeField(auto_now_add=True)
    # Pola adresowe instalacji
    ulica = models.CharField(max_length=255, blank=True, null=True)
    numer_domu = models.CharField(max_length=50, blank=True, null=True)
    mieszkanie = models.CharField(max_length=50, blank=True, null=True)
    kod_pocztowy = models.CharField(max_length=20, blank=True, null=True)
    miasto = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        indexes = [
            models.Index(fields=['klient'], name='instalacja_klient_idx'),
            models.Index(fields=['owner'], name='instalacja_owner_idx'),
        ]


class Inspekcja(models.Model):
    instalacja = models.ForeignKey(
        Instalacja, on_delete=models.CASCADE, related_name='inspekcje')
    created_date = models.DateTimeField(auto_now_add=True)
    miejsce_agregatu = models.TextField(null=True, blank=True)
    podlaczenie_elektryki = models.TextField(null=True, blank=True)
    miejsce_urzadzen_wew = models.TextField(null=True, blank=True)
    sposob_montazu = models.TextField(null=True, blank=True)
    uwagi_agregat = models.TextField(null=True, blank=True)
    uwagi_instalacja = models.TextField(null=True, blank=True)
    uwagi_elektryka = models.TextField(null=True, blank=True)
    uwagi_ogolne = models.TextField(null=True, blank=True)
    # Legacy fields - keeping for backward compatibility but not used in new UI
    rooms = models.IntegerField(null=True, blank=True)
    rooms_m2 = models.FloatField(null=True, blank=True)
    device_amount = models.IntegerField(null=True, blank=True)
    power_amount = models.FloatField(null=True, blank=True)
    dlugosc_instalacji = models.FloatField(null=True, blank=True)
    prowadzenie_instalacji = models.CharField(
        max_length=100, null=True, blank=True)
    prowadzenie_skroplin = models.CharField(
        max_length=100, null=True, blank=True)
    obnizenie = models.FloatField(null=True, blank=True)
    uwagi = models.TextField(null=True, blank=True)
    # Nowe pola z formularza
    typ_urzadzenia_wewnetrznego = models.CharField(
        max_length=100, null=True, blank=True)
    miejsce_montazu = models.CharField(
        max_length=100, null=True, blank=True)
    # photos field removed - now using ForeignKey from Photo model with related_name='inspection_photos'


class Montaz(models.Model):
    instalacja = models.ForeignKey(
        Instalacja, on_delete=models.CASCADE, related_name='montaze')
    created_date = models.DateTimeField(auto_now_add=True)
    data_montazu = models.DateTimeField(null=True, blank=True)
    gwarancja = models.IntegerField(null=True, blank=True)
    liczba_przegladow = models.IntegerField(null=True, blank=True)
    split_multisplit = models.BooleanField(null=True, blank=True)
    devices_split = models.ManyToManyField(DeviceSplit, blank=True)
    devices_multi_split = models.ManyToManyField(DeviceMultiSplit, blank=True)
    nr_seryjny_jedn_zew = models.CharField(
        null=True, max_length=100, blank=True)
    nr_seryjny_jedn_zew_photo = models.CharField(
        null=True, max_length=100, blank=True)
    nr_seryjny_jedn_wew = models.CharField(
        null=True, max_length=100, blank=True)
    nr_seryjny_jedn_wew_photo = models.CharField(
        null=True, max_length=100, blank=True)
    miejsce_montazu_jedn_zew = models.CharField(
        null=True, max_length=100, blank=True)
    miejsce_montazu_jedn_zew_photo = models.PositiveIntegerField(
        null=True, blank=True)
    miejsce_montazu_jedn_wew = models.CharField(
        null=True, max_length=100, blank=True)
    miejsce_montazu_jedn_wew_photo = models.PositiveIntegerField(null=True)
    sposob_skroplin = models.CharField(null=True, max_length=100, blank=True)
    miejsce_skroplin = models.CharField(null=True, max_length=100, blank=True)
    miejsce_i_sposob_montazu_jedn_zew = models.CharField(
        null=True, max_length=100, blank=True)
    miejsce_i_sposob_montazu_jedn_zew_photo = models.PositiveIntegerField(
        null=True)
    miejsce_podlaczenia_elektryki = models.CharField(
        null=True, max_length=100, blank=True)
    gaz = models.CharField(null=True, max_length=100, blank=True)
    gaz_ilosc_dodana = models.FloatField(null=True, blank=True)
    gaz_ilos = models.FloatField(null=True, blank=True)
    temp_zew_montazu = models.FloatField(null=True, blank=True)
    temp_wew_montazu = models.FloatField(null=True, blank=True)
    cisnienie = models.FloatField(null=True, blank=True)
    przegrzanie = models.FloatField(null=True, blank=True)
    temp_chlodzenia = models.FloatField(null=True, blank=True)
    temp_grzania = models.FloatField(null=True, blank=True)
    uwagi = models.TextField(null=True, blank=True)
    dlugosc_instalacji = models.FloatField(null=True, blank=True)
    gwarancja_photo = models.PositiveIntegerField(null=True, blank=True)
    devicePower = models.CharField(max_length=100, null=True, blank=True)

    # Nowe pola - Przeprowadzone czynności
    kontrola_stanu_technicznego_jedn_wew = models.CharField(
        max_length=100, null=True, blank=True)
    kontrola_stanu_technicznego_jedn_zew = models.CharField(
        max_length=100, null=True, blank=True)
    kontrola_stanu_mocowania_agregatu = models.CharField(
        max_length=100, null=True, blank=True)
    czyszczenie_filtrow_jedn_wew = models.CharField(
        max_length=100, null=True, blank=True)
    czyszczenie_wymiennika_ciepla_jedn_wew = models.CharField(
        max_length=100, null=True, blank=True)
    czyszczenie_obudowy_jedn_wew = models.CharField(
        max_length=100, null=True, blank=True)
    czyszczenie_tacy_skroplin = models.CharField(
        max_length=100, null=True, blank=True)
    kontrola_droznosci_odplywu_skroplin = models.CharField(
        max_length=100, null=True, blank=True)
    czyszczenie_obudowy_jedn_zew = models.CharField(
        max_length=100, null=True, blank=True)
    czyszczenie_wymiennika_ciepla_jedn_zew = models.CharField(
        max_length=100, null=True, blank=True)
    kontrola_szczelnosci_instalacji = models.CharField(
        max_length=100, null=True, blank=True)
    kontrola_poprawnosci_dzialania = models.CharField(
        max_length=100, null=True, blank=True)

    # Dodatkowe pola
    kontrola_temperatury_nawiewu = models.CharField(
        max_length=100, null=True, blank=True)
    diagnostyka_awarii_urzadzen = models.CharField(
        max_length=100, null=True, blank=True)


class Serwis(models.Model):
    instalacja = models.ForeignKey(
        Instalacja, on_delete=models.CASCADE, related_name='serwisy')
    montaz = models.ForeignKey(
        'Montaz', on_delete=models.CASCADE, related_name='przeglady', null=True, blank=True)
    created_date = models.DateTimeField(auto_now_add=True)

    # Pole do rozróżnienia typu: przegląd cykliczny czy indywidualny serwis
    TYP_CHOICES = [
        ('przeglad', 'Przegląd cykliczny'),
        ('serwis', 'Serwis indywidualny'),
    ]
    typ = models.CharField(
        max_length=20, choices=TYP_CHOICES, default='przeglad')

    # Dla przeglądów cyklicznych - numer przeglądu w serii
    numer_przegladu = models.IntegerField(null=True, blank=True)

    # Dla serwisów indywidualnych - konkretny termin
    termin_serwisu = models.DateTimeField(null=True, blank=True)

    data_montazu = models.DateTimeField(null=True, blank=True)
    dlugosc_gwarancji = models.IntegerField(null=True, blank=True)
    liczba_przegladow_rok = models.IntegerField(null=True, blank=True)
    data_przegladu = models.DateTimeField(null=True, blank=True)
    kontrola_stanu_jedn_wew = models.CharField(max_length=100, null=True, blank=True)
    kontrola_stanu_jedn_zew = models.CharField(max_length=100, null=True, blank=True)
    kontrola_stanu_mocowania_agregatu = models.CharField(max_length=100, null=True, blank=True)
    czyszczenie_filtrow_jedn_wew = models.CharField(max_length=100, null=True, blank=True)
    czyszczenie_wymiennika_ciepla_wew = models.CharField(max_length=100, null=True, blank=True)
    czyszczenie_obudowy_jedn_wew = models.CharField(max_length=100, null=True, blank=True)
    czyszczenie_tacy_skroplin = models.CharField(max_length=100, null=True, blank=True)
    kontrola_droznosci_skroplin = models.CharField(max_length=100, null=True, blank=True)
    czyszczenie_obudowy_jedn_zew = models.CharField(max_length=100, null=True, blank=True)
    czyszczenie_wymiennika_ciepla_zew = models.CharField(max_length=100, null=True, blank=True)
    kontrola_szczelnosci = models.CharField(max_length=100, null=True, blank=True)
    kontrola_poprawnosci_dzialania = models.CharField(max_length=100, null=True, blank=True)
    kontrola_temperatury_nawiewu_wew = models.CharField(max_length=100, null=True, blank=True)
    diagnostyka_awari = models.CharField(max_length=100, null=True, blank=True)
    uwagi = models.TextField(null=True, blank=True)
    # TODO dane urzadzenia z oferty zaakceptowanej


class Oferta(models.Model):
    instalacja = models.ForeignKey(
        Instalacja, on_delete=models.CASCADE, null=True, blank=True, db_index=True)
    creator = models.ForeignKey(
        ACUser, on_delete=models.CASCADE, db_index=True)
    is_accepted = models.BooleanField(default=False)
    is_template = models.BooleanField(
        default=False, help_text="Czy oferta jest szablonem", db_index=True)
    devices_split = models.ManyToManyField(DeviceSplit, blank=True)
    devices_multi_split = models.ManyToManyField(DeviceMultiSplit, blank=True)
    rabat = models.ManyToManyField(Rabat, blank=True)
    narzut = models.ManyToManyField(Narzut, blank=True)
    offer_type = models.CharField(max_length=255, choices=[(
        'split', 'Split'), ('multi_split', 'Multi Split')])
    # New fields for offer grouping and versioning
    nazwa_oferty = models.CharField(
        max_length=255, null=True, blank=True, help_text="Nazwa grupy ofert")
    wersja = models.IntegerField(default=1, help_text="Numer wersji oferty")
    created_date = models.DateTimeField(auto_now_add=True)
    updated_date = models.DateTimeField(auto_now=True)
    # Pole do przechowywania wybranego urządzenia z oferty
    selected_device_id = models.IntegerField(
        null=True, blank=True, help_text="ID wybranego urządzenia z oferty")
    
    # Pola dla systemu rezerwacji terminów montażu
    proposed_montaz_date = models.DateField(
        null=True, blank=True, 
        help_text="Data montażu zaproponowana przez klienta")
    proposed_montaz_time = models.TimeField(
        null=True, blank=True,
        help_text="Godzina montażu zaproponowana przez klienta")
    montaz_status = models.CharField(
        max_length=20,
        choices=[
            ('none', 'Brak propozycji'),
            ('pending', 'Oczekuje na akceptację'),
            ('confirmed', 'Zatwierdzony'),
            ('rejected', 'Odrzucony'),
        ],
        default='none',
        help_text="Status rezerwacji terminu montażu")
    montaz_zadanie = models.ForeignKey(
        'Zadanie', on_delete=models.SET_NULL, 
        null=True, blank=True,
        related_name='oferta_montaz',
        help_text="Powiązane zadanie montażu w kalendarzu")
    rejection_reason = models.TextField(
        null=True, blank=True,
        help_text="Powód odrzucenia terminu przez montera")

    class Meta:
        ordering = ['nazwa_oferty', '-wersja']
        indexes = [
            models.Index(fields=['instalacja'], name='oferta_instalacja_idx'),
            models.Index(fields=['creator'], name='oferta_creator_idx'),
            models.Index(fields=['is_template'],
                         name='oferta_is_template_idx'),
            models.Index(fields=['instalacja', 'is_template'],
                         name='oferta_instalacja_template_idx'),
        ]

    def __str__(self):
        if self.nazwa_oferty:
            return f"{self.nazwa_oferty} v{self.wersja}"
        return f"Oferta {self.id} v{self.wersja}"


class Szablon(models.Model):
    nazwa = models.CharField(max_length=255)
    owner = models.ForeignKey(ACUser, on_delete=models.CASCADE)
    narzuty = models.ManyToManyField(Narzut, blank=True)  # Add blank=True here
    devices_split = models.ManyToManyField(
        DeviceSplit, related_name='devices_split', blank=True)
    devices_multisplit = models.ManyToManyField(
        DeviceMultiSplit, related_name='devices_multisplit', blank=True)
    TYP_CHOICES = (
        ('split', 'Split'),
        ('multisplit', 'Multisplit'),
    )
    typ = models.CharField(max_length=10, choices=TYP_CHOICES)

    def __str__(self):
        return self.nazwa


class Zadanie(models.Model):
    rodzic = models.ForeignKey(
        ACUser,
        on_delete=models.CASCADE,
        related_name='zadania'
    )

    grupa = models.IntegerField(
        null=True,
        blank=True,
    )

    instalacja = models.ForeignKey(
        Instalacja,
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name='zadania'
    )

    STATUS_CHOICES = (
        ('wykonane', 'Wykonane'),
        ('niewykonane', 'Niewykonane'),
        ('Zaplanowane', 'Zaplanowane'),
    )
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='niewykonane'
    )

    nazwa = models.CharField(max_length=255, null=True, blank=True)
    start_date = models.DateTimeField(null=False, blank=False)
    end_date = models.DateTimeField(null=False, blank=False)
    czy_oferta = models.BooleanField(default=False)
    czy_faktura = models.BooleanField(default=False)
    notatki = models.TextField(null=True, blank=True)

    TYP_CHOICES = (
        ('montaż', 'Montaż'),
        ('oględziny', 'Oględziny'),
        ('serwis', 'Serwis'),
        ('szkolenie', 'Szkolenie'),
    )
    typ = models.CharField(
        max_length=20,
        choices=TYP_CHOICES,
        default='montaż'
    )

    def __str__(self):
        return f"{self.typ} - {self.status}"


class InvoiceSettings(models.Model):
    ac_user = models.OneToOneField(ACUser, on_delete=models.CASCADE)

    footer = models.TextField(null=True, verbose_name="Stopka do faktury")
    place_of_issue = models.CharField(
        null=True, max_length=255, verbose_name="Miejsce wystawienia faktury")
    issuer_name = models.CharField(
        null=True, max_length=255, verbose_name="Imię i nazwisko osoby wystawiającej")

    standard_payment_term = models.IntegerField(
        null=True, verbose_name="Standardowy termin płatności w dniach")

    iban = models.CharField(max_length=28, null=True,
                            blank=True, verbose_name="IBAN")

    prefix = models.CharField(max_length=10, null=True,
                              blank=True, verbose_name="Prefix")
    suffix = models.CharField(max_length=10, null=True,
                              blank=True, verbose_name="Sufiks")

    NUMBERING_TYPE_CHOICES = [
        ('yearly', 'Od początku roku'),
        ('monthly', 'Od początku miesiąca'),
        ('daily', 'Liczone w danym dniu'),
    ]
    numbering_type = models.CharField(
        max_length=10, null=True, choices=NUMBERING_TYPE_CHOICES, verbose_name="Rodzaj numeracji")

    YEAR_FORMAT_CHOICES = [
        ('YYYY', 'Czterocyfrowy'),
        ('YY', 'Dwucyfrowy'),
    ]
    year_format = models.CharField(
        max_length=4, null=True, choices=YEAR_FORMAT_CHOICES, verbose_name="Format roku")

    MONTH_FORMAT_CHOICES = [
        ('numeric', 'Liczbowy'),
        ('short_name', 'Skrócona nazwa'),
        ('full_name', 'Pełna nazwa'),
    ]
    month_format = models.CharField(
        max_length=10, null=True, choices=MONTH_FORMAT_CHOICES, verbose_name="Format miesiąca")

    DAY_FORMAT_CHOICES = [
        ('numeric', 'Liczbowy'),
        ('two_digit', 'Zawsze dwucyfrowy'),
    ]
    day_format = models.CharField(
        max_length=10, null=True, choices=DAY_FORMAT_CHOICES, verbose_name="Format dnia")

    def __str__(self):
        return f"Ustawienia faktury użytkownika {self.user.username}"


class Faktury(models.Model):
    ac_user = models.ForeignKey(ACUser, related_name='ac_user',
                                on_delete=models.CASCADE, verbose_name="Użytkownik wystawiający")
    client = models.ForeignKey(
        ACUser, related_name='client', on_delete=models.CASCADE, verbose_name="Klient")
    issue_date = models.DateField(verbose_name="Data wystawienia")
    order = models.IntegerField(verbose_name="Kolejność")
    instalacja = models.ForeignKey(
        Instalacja, null=True, on_delete=models.CASCADE, related_name='id_instalacji_dla_faktury')
    id_fakturowni = models.CharField(
        max_length=100, verbose_name="ID Faktury w Fakturowni", null=True, blank=True)
    numer_faktury = models.CharField(
        max_length=100, verbose_name="Numer faktury", null=True, blank=True)
    status = models.CharField(
        max_length=100, verbose_name="Status", null=True, blank=True)

    def save(self, *args, **kwargs):
        if not self.pk:  # Sprawdzanie, czy faktura jest nowa
            last_order = Faktury.objects.filter(
                ac_user=self.ac_user).order_by('order').last()
            self.order = (last_order.order + 1) if last_order else 1
        super(Faktury, self).save(*args, **kwargs)


class ListyKlientow(models.Model):
    ac_user = models.ForeignKey(
        ACUser, on_delete=models.CASCADE, verbose_name="Użytkownik tworzący")
    nazwa = models.CharField(
        max_length=100, verbose_name="Nazwa listy")
    created_date = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.nazwa

    def save(self, *args, **kwargs):
        if not self.pk:
            self.ac_user = self.ac_user
        super(ListyKlientow, self).save(*args, **kwargs)


class Invitation(models.Model):
    email = models.EmailField(verbose_name="Email zaproszonego")
    token = models.CharField(max_length=255, unique=True,
                             verbose_name="Token zaproszenia")
    client = models.ForeignKey(
        ACUser, on_delete=models.CASCADE, related_name='invitations',
        verbose_name="Klient powiązany z zaproszeniem")
    created_by = models.ForeignKey(
        ACUser, on_delete=models.CASCADE, related_name='sent_invitations',
        verbose_name="Użytkownik wysyłający zaproszenie")
    created_at = models.DateTimeField(
        auto_now_add=True, verbose_name="Data utworzenia")
    expires_at = models.DateTimeField(verbose_name="Data wygaśnięcia")
    used = models.BooleanField(default=False, verbose_name="Czy użyte")
    used_at = models.DateTimeField(
        null=True, blank=True, verbose_name="Data użycia")

    def __str__(self):
        return f"Zaproszenie dla {self.email} - {'Użyte' if self.used else 'Aktywne'}"

    def is_valid(self):
        from django.utils import timezone
        return not self.used and timezone.now() < self.expires_at

    def generate_token(self):
        import secrets
        self.token = secrets.token_urlsafe(32)
        return self.token

    class Meta:
        verbose_name = "Zaproszenie"
        verbose_name_plural = "Zaproszenia"


class Conversation(models.Model):
    """
    Model reprezentujący konwersację między dwoma użytkownikami.
    participant_1 - zwykle Admin lub Monter
    participant_2 - zwykle Klient
    """
    participant_1 = models.ForeignKey(
        ACUser, on_delete=models.CASCADE, related_name='conversations_as_p1',
        verbose_name="Uczestnik 1 (Admin/Monter)")
    participant_2 = models.ForeignKey(
        ACUser, on_delete=models.CASCADE, related_name='conversations_as_p2',
        verbose_name="Uczestnik 2 (Klient)")
    created_at = models.DateTimeField(auto_now_add=True, verbose_name="Data utworzenia")
    updated_at = models.DateTimeField(auto_now=True, verbose_name="Ostatnia aktualizacja")

    class Meta:
        verbose_name = "Konwersacja"
        verbose_name_plural = "Konwersacje"
        unique_together = [['participant_1', 'participant_2']]
        indexes = [
            models.Index(fields=['participant_1', 'participant_2'], name='conv_participants_idx'),
            models.Index(fields=['-updated_at'], name='conv_updated_idx'),
        ]
        ordering = ['-updated_at']

    def __str__(self):
        return f"Konwersacja: {self.participant_1.email} <-> {self.participant_2.email}"

    def get_other_participant(self, user):
        """Zwraca drugiego uczestnika konwersacji"""
        if self.participant_1 == user:
            return self.participant_2
        return self.participant_1


class Message(models.Model):
    """
    Model reprezentujący pojedynczą wiadomość w konwersacji.
    """
    conversation = models.ForeignKey(
        Conversation, on_delete=models.CASCADE, related_name='messages',
        verbose_name="Konwersacja")
    sender = models.ForeignKey(
        ACUser, on_delete=models.CASCADE, related_name='sent_messages',
        verbose_name="Nadawca")
    content = models.TextField(verbose_name="Treść wiadomości")
    created_at = models.DateTimeField(auto_now_add=True, verbose_name="Data wysłania", db_index=True)
    is_read = models.BooleanField(default=False, verbose_name="Czy przeczytana", db_index=True)
    read_at = models.DateTimeField(null=True, blank=True, verbose_name="Data przeczytania")

    class Meta:
        verbose_name = "Wiadomość"
        verbose_name_plural = "Wiadomości"
        indexes = [
            models.Index(fields=['conversation', '-created_at'], name='msg_conv_created_idx'),
            models.Index(fields=['conversation', 'is_read'], name='msg_conv_read_idx'),
        ]
        ordering = ['created_at']

    def __str__(self):
        return f"Wiadomość od {self.sender.email} ({self.created_at.strftime('%Y-%m-%d %H:%M')})"

    def mark_as_read(self):
        """Oznacz wiadomość jako przeczytaną"""
        if not self.is_read:
            from django.utils import timezone
            self.is_read = True
            self.read_at = timezone.now()
            self.save(update_fields=['is_read', 'read_at'])


class PushNotificationToken(models.Model):
    """Przechowuje Expo push tokeny użytkowników"""
    user = models.ForeignKey(ACUser, on_delete=models.CASCADE, related_name='push_tokens')
    token = models.CharField(max_length=255, unique=True)
    device_name = models.CharField(max_length=255, blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = 'push_notification_tokens'
        unique_together = ('user', 'token')
        verbose_name = 'Push Token'
        verbose_name_plural = 'Push Tokens'
    
    def __str__(self):
        return f"{self.user.email} - {self.device_name or 'Unknown Device'}"


class Notification(models.Model):
    """Model przechowujący powiadomienia użytkowników"""
    
    NOTIFICATION_TYPES = (
        ('montaz_confirmed', 'Termin montażu potwierdzony'),
        ('montaz_rejected', 'Termin montażu odrzucony'),
        ('montaz_proposed', 'Nowa propozycja terminu montażu'),
        ('offer_new', 'Nowa oferta'),
        ('offer_accepted', 'Oferta zaakceptowana'),
        ('task_new', 'Nowe zadanie'),
        ('task_status_changed', 'Zmiana statusu zadania'),
        ('invoice_new', 'Nowa faktura'),
        ('chat_message', 'Nowa wiadomość'),
    )
    
    user = models.ForeignKey(ACUser, on_delete=models.CASCADE, related_name='notifications')
    type = models.CharField(max_length=50, choices=NOTIFICATION_TYPES)
    title = models.CharField(max_length=255)
    message = models.TextField()
    
    # Dane kontekstowe do nawigacji
    related_object_type = models.CharField(max_length=50, blank=True, null=True)  # 'oferta', 'zadanie', etc.
    related_object_id = models.IntegerField(blank=True, null=True)
    
    # Metadata
    data = models.JSONField(default=dict, blank=True)  # Dodatkowe dane w formacie JSON
    
    # Status
    is_read = models.BooleanField(default=False)
    is_deleted = models.BooleanField(default=False)
    
    # Daty
    created_at = models.DateTimeField(auto_now_add=True)
    read_at = models.DateTimeField(blank=True, null=True)
    
    class Meta:
        db_table = 'notifications'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user', '-created_at']),
            models.Index(fields=['user', 'is_read']),
        ]
        verbose_name = 'Powiadomienie'
        verbose_name_plural = 'Powiadomienia'
    
    def __str__(self):
        status = "✓" if self.is_read else "●"
        return f"{status} {self.title} - {self.user.email}"