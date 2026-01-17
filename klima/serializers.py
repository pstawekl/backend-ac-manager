from rest_framework import serializers

from .models import *


class ACUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = ACUser
        exclude = ('password', 'hash_value', 'monter', 'parent', 'user_type')


class UserDataSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserData
        exclude = ('id',)


class TaskSerializer(serializers.ModelSerializer):
    class Meta:
        model = Task
        fields = '__all__'


class CertificateSerializer(serializers.ModelSerializer):
    file_url = serializers.SerializerMethodField()

    class Meta:
        model = Certificate
        fields = '__all__'

    def get_file_url(self, obj):
        if obj.file:
            # Zwróć pełny URL zamiast względnej ścieżki
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.file.url)
            # Fallback jeśli nie ma request w kontekście
            return obj.file.url
        return None

    def to_representation(self, instance):
        data = super().to_representation(instance)
        # Nadpisz pole 'file' pełnym URL
        data['file'] = self.get_file_url(instance)
        return data


class SzkolenieSerializer(serializers.ModelSerializer):
    file_url = serializers.SerializerMethodField()

    class Meta:
        model = Szkolenie
        fields = '__all__'

    def get_file_url(self, obj):
        if obj.file:
            # Zwróć pełny URL zamiast względnej ścieżki
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.file.url)
            # Fallback jeśli nie ma request w kontekście
            return obj.file.url
        return None

    def to_representation(self, instance):
        data = super().to_representation(instance)
        # Nadpisz pole 'file' pełnym URL
        data['file'] = self.get_file_url(instance)
        return data


class KatalogSerializer(serializers.ModelSerializer):
    file_url = serializers.SerializerMethodField()

    class Meta:
        model = Katalog
        fields = '__all__'

    def get_file_url(self, obj):
        if obj.file:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.file.url)
            return obj.file.url
        return None

    def to_representation(self, instance):
        data = super().to_representation(instance)
        data['file'] = self.get_file_url(instance)
        return data


class CennikSerializer(serializers.ModelSerializer):
    file_url = serializers.SerializerMethodField()

    class Meta:
        model = Cennik
        fields = '__all__'

    def get_file_url(self, obj):
        if obj.file:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.file.url)
            return obj.file.url
        return None

    def to_representation(self, instance):
        data = super().to_representation(instance)
        data['file'] = self.get_file_url(instance)
        return data


class UlotkaSerializer(serializers.ModelSerializer):
    file_url = serializers.SerializerMethodField()

    class Meta:
        model = Ulotka
        fields = '__all__'

    def get_file_url(self, obj):
        if obj.file:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.file.url)
            return obj.file.url
        return None

    def to_representation(self, instance):
        data = super().to_representation(instance)
        data['file'] = self.get_file_url(instance)
        return data


class PhotoSerializer(serializers.ModelSerializer):
    image_url = serializers.SerializerMethodField()

    class Meta:
        model = Photo
        fields = '__all__'
        extra_kwargs = {
            'klient': {'required': False, 'allow_null': True},
        }

    def create(self, validated_data):
        # Obsługa pola inspekcja - może być przekazane jako ID lub obiekt
        if 'inspekcja' in validated_data and isinstance(validated_data['inspekcja'], int):
            # Jeśli inspekcja jest przekazana jako ID, to jest OK
            pass
        return super().create(validated_data)

    def get_image_url(self, obj):
        if obj.image:
            # Zwróć pełny URL zamiast względnej ścieżki
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.image.url)
            # Fallback jeśli nie ma request w kontekście
            return obj.image.url
        return None

    def to_representation(self, instance):
        data = super().to_representation(instance)
        # Dodaj image_url do odpowiedzi, ale zachowaj też oryginalne pole image
        data['image'] = self.get_image_url(instance)
        return data


class TagSerializer(serializers.ModelSerializer):
    class Meta:
        model = Tag
        fields = '__all__'


class InspekcjaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Inspekcja
        fields = '__all__'

    def to_internal_value(self, data):
        # Konwertuj pola numeryczne z stringów na liczby
        numeric_fields = ['rooms', 'rooms_m2', 'device_amount',
                          'power_amount', 'dlugosc_instalacji', 'obnizenie']

        for field in numeric_fields:
            if field in data and data[field] is not None and data[field] != '':
                try:
                    if field in ['rooms', 'device_amount']:
                        # Pola integer
                        data[field] = int(float(data[field]))
                    else:
                        # Pola float
                        data[field] = float(data[field])
                except (ValueError, TypeError):
                    # Jeśli konwersja się nie powiedzie, usuń pole
                    data[field] = None

        return super().to_internal_value(data)


class MontazSerializer(serializers.ModelSerializer):
    class Meta:
        model = Montaz
        fields = '__all__'

    def to_internal_value(self, data):
        # Mapowanie skróconych nazw pól na pełne nazwy
        field_mapping = {
            'kontrola_stanu_jedn_wew': 'kontrola_stanu_technicznego_jedn_wew',
            'kontrola_stanu_jedn_zew': 'kontrola_stanu_technicznego_jedn_zew',
            'czyszczenie_wymiennika_ciepla_wew': 'czyszczenie_wymiennika_ciepla_jedn_wew',
            'czyszczenie_wymiennika_ciepla_zew': 'czyszczenie_wymiennika_ciepla_jedn_zew',
            'kontrola_droznosci_skroplin': 'kontrola_droznosci_odplywu_skroplin',
            'kontrola_szczelnosci': 'kontrola_szczelnosci_instalacji',
            'kontrola_temperatury_nawiewu_wew': 'kontrola_temperatury_nawiewu',
            'diagnostyka_awari': 'diagnostyka_awarii_urzadzen',
        }

        # Przekształć dane używając mapowania
        mapped_data = {}
        for key, value in data.items():
            if key in field_mapping:
                mapped_data[field_mapping[key]] = value
            else:
                mapped_data[key] = value

        return super().to_internal_value(mapped_data)


class SerwisSerializer(serializers.ModelSerializer):
    class Meta:
        model = Serwis
        fields = '__all__'


class InstalacjaSerializer(serializers.ModelSerializer):
    inspekcja = InspekcjaSerializer(
        many=True, read_only=True, source='inspekcje')
    montaz = MontazSerializer(many=True, read_only=True, source='montaze')
    serwis = SerwisSerializer(many=True, read_only=True, source='serwisy')

    class Meta:
        model = Instalacja
        fields = '__all__'


class DeviceSplitSerializer(serializers.ModelSerializer):
    class Meta:
        model = DeviceSplit
        fields = '__all__'


class DeviceMultiSplitSerializer(serializers.ModelSerializer):
    # Dodaj pole nazwa_modelu jako alias dla model_nazwa (dla kompatybilności z frontendem)
    # Użyj nazwa_modelu_producenta jako fallback, gdy model_nazwa jest puste
    nazwa_modelu = serializers.SerializerMethodField()
    # Dodaj pole typ jako alias dla typ_jedn_wew (dla kompatybilności z frontendem)
    typ = serializers.CharField(
        source='typ_jedn_wew', read_only=True, allow_null=True
    )

    def get_nazwa_modelu(self, obj):
        # Jeśli model_nazwa jest puste, użyj nazwa_modelu_producenta
        return obj.model_nazwa if obj.model_nazwa and obj.model_nazwa.strip() else obj.nazwa_modelu_producenta

    class Meta:
        model = DeviceMultiSplit
        fields = '__all__'


class RabatSerializer(serializers.ModelSerializer):
    class Meta:
        model = Rabat
        fields = '__all__'


class NarzutSerializer(serializers.ModelSerializer):
    class Meta:
        model = Narzut
        fields = '__all__'


class ResetPasswordSerializer(serializers.Serializer):
    email = serializers.EmailField()


class CheckEmailSerializer(serializers.Serializer):
    token = serializers.CharField()
    email = serializers.EmailField()
    exclude_user_id = serializers.IntegerField(required=False, allow_null=True)


class CreateKlientSerializer(serializers.Serializer):
    token = serializers.CharField()
    email = serializers.EmailField(
        required=False, allow_null=True, allow_blank=True)
    first_name = serializers.CharField()
    last_name = serializers.CharField()
    rodzaj_klienta = serializers.CharField()
    ulica = serializers.CharField(
        required=False, allow_null=True, allow_blank=True)
    miasto = serializers.CharField(
        required=False, allow_null=True, allow_blank=True)
    mieszkanie = serializers.CharField(
        required=False, allow_null=True, allow_blank=True)
    kod_pocztowy = serializers.CharField(
        required=False, allow_null=True, allow_blank=True)
    numer_telefonu = serializers.CharField(
        required=False, allow_null=True, allow_blank=True)
    longitude = serializers.FloatField(required=False, allow_null=True)
    latitude = serializers.FloatField(required=False, allow_null=True)
    nazwa_firmy = serializers.CharField(
        required=False, allow_null=True, allow_blank=True)
    nip = serializers.CharField(
        required=False, allow_null=True, allow_blank=True)
    numer_domu = serializers.CharField(
        required=False, allow_null=True, allow_blank=True)
    typ_klienta = serializers.CharField(
        required=False, allow_null=True, allow_blank=True)
    client_status = serializers.CharField(
        required=False, allow_null=True, allow_blank=True)
    url = serializers.CharField(
        required=False, allow_null=True, allow_blank=True)
    # Dodatkowe pole dla kompatybilności
    house_number = serializers.CharField(
        required=False, allow_null=True, allow_blank=True)

    def validate(self, data):
        """Custom validation: email jest wymagany tylko dla firm"""
        rodzaj_klienta = data.get('rodzaj_klienta')
        email = data.get('email')

        if rodzaj_klienta == 'firma' and not email:
            raise serializers.ValidationError({
                'email': 'Email jest wymagany dla firm'
            })

        return data


class OfertaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Oferta
        fields = '__all__'
        extra_kwargs = {
            'instalacja': {'required': False},
            'devices_split': {'required': False},
            'devices_multi_split': {'required': False},
            'rabat': {'required': False},
            'narzut': {'required': False},
        }

    def validate_narzut(self, value):
        if value is None:
            return []
        return [item for item in value if item is not None]

    def validate_rabat(self, value):
        if value is None:
            return []
        return [item for item in value if item is not None]

    def validate_devices_split(self, value):
        if value is None:
            return []
        return [item for item in value if item is not None]

    def validate_devices_multi_split(self, value):
        if value is None:
            return []
        return [item for item in value if item is not None]


class OfertaReadSerializer(serializers.ModelSerializer):
    devices_split = DeviceSplitSerializer(many=True, read_only=True)
    devices_multi_split = DeviceMultiSplitSerializer(many=True, read_only=True)
    rabat = RabatSerializer(many=True, read_only=True)
    narzut = NarzutSerializer(many=True, read_only=True)

    class Meta:
        model = Oferta
        fields = '__all__'


class SzablonSerializer(serializers.ModelSerializer):
    class Meta:
        model = Szablon
        fields = '__all__'
        extra_kwargs = {
            'narzuty': {'required': False},
            'devices_split': {'required': False},
            'devices_multisplit': {'required': False},
        }

    def validate_narzuty(self, value):
        if value is None:
            return []
        return [item for item in value if item is not None]

    def validate_devices_split(self, value):
        if value is None:
            return []
        return [item for item in value if item is not None]

    def validate_devices_multisplit(self, value):
        if value is None:
            return []
        return [item for item in value if item is not None]


class SzablonReadSerializer(serializers.ModelSerializer):
    devices_split = DeviceSplitSerializer(many=True, read_only=True)
    devices_multisplit = DeviceMultiSplitSerializer(many=True, read_only=True)
    narzuty = NarzutSerializer(many=True, read_only=True)

    class Meta:
        model = Szablon
        fields = '__all__'


class ZadanieSerializer(serializers.ModelSerializer):
    instalacja_info = serializers.SerializerMethodField()

    class Meta:
        model = Zadanie
        fields = ['id', 'start_date', 'end_date', 'typ', 'rodzic',
                  'status', 'grupa', 'nazwa', 'notatki', 'instalacja', 'instalacja_info']
        extra_kwargs = {
            'nazwa': {'required': True},
            'start_date': {'required': True},
            'end_date': {'required': True},
            'typ': {'required': True},
            'id': {'read_only': True},
        }

    def get_instalacja_info(self, obj):
        if obj.instalacja:
            klient = obj.instalacja.klient
            try:
                user_data = klient.userdata
            except:
                user_data = None

            return {
                'id': obj.instalacja.id,
                'name': obj.instalacja.name,
                'klient_id': klient.id,
                'first_name': klient.first_name,
                'last_name': klient.last_name,
                'email': klient.email,
                'nazwa_firmy': user_data.nazwa_firmy if user_data else None,
                'nip': user_data.nip if user_data else None,
                'rodzaj_klienta': user_data.rodzaj_klienta if user_data else None,
                'ulica': user_data.ulica if user_data else None,
                'numer_domu': user_data.numer_domu if user_data else None,
                'mieszkanie': user_data.mieszkanie if user_data else None,
                'kod_pocztowy': user_data.kod_pocztowy if user_data else None,
                'miasto': user_data.miasto if user_data else None,
                'numer_telefonu': user_data.numer_telefonu if user_data else None,
            }
        return None


class InvoiceSettingsSerializer(serializers.ModelSerializer):
    class Meta:
        model = InvoiceSettings
        fields = '__all__'
        extra_kwargs = {field.name: {'required': False}
                        for field in model._meta.get_fields()}


class FakturySerializer(serializers.ModelSerializer):
    client_name = serializers.SerializerMethodField()

    class Meta:
        model = Faktury
        fields = ('id', 'ac_user', 'status', 'client_name', 'issue_date', 'order', 'instalacja',
                  # Wylistuj wszystkie pola, które chcesz uwzględnić
                  'id_fakturowni', 'numer_faktury')

    def get_client_name(self, obj):
        return f"{obj.client.first_name} {obj.client.last_name}"


class ListyKlientowSerializer(serializers.ModelSerializer):
    class Meta:
        model = ListyKlientow
        fields = ['id', 'ac_user', 'nazwa']


class MessageSerializer(serializers.ModelSerializer):
    sender_name = serializers.SerializerMethodField()
    sender_email = serializers.CharField(source='sender.email', read_only=True)
    sender_avatar = serializers.CharField(source='sender.url', read_only=True)

    class Meta:
        model = Message
        fields = ['id', 'conversation', 'sender', 'sender_name', 'sender_email', 
                  'sender_avatar', 'content', 'created_at', 'is_read', 'read_at']
        read_only_fields = ['id', 'created_at', 'sender_name', 'sender_email', 'sender_avatar']

    def get_sender_name(self, obj):
        return f"{obj.sender.first_name} {obj.sender.last_name}"


class ConversationSerializer(serializers.ModelSerializer):
    participant_1_name = serializers.SerializerMethodField()
    participant_2_name = serializers.SerializerMethodField()
    participant_1_email = serializers.CharField(source='participant_1.email', read_only=True)
    participant_2_email = serializers.CharField(source='participant_2.email', read_only=True)
    participant_1_avatar = serializers.CharField(source='participant_1.url', read_only=True)
    participant_2_avatar = serializers.CharField(source='participant_2.url', read_only=True)
    participant_1_type = serializers.CharField(source='participant_1.user_type', read_only=True)
    participant_2_type = serializers.CharField(source='participant_2.user_type', read_only=True)
    last_message = serializers.SerializerMethodField()
    unread_count = serializers.SerializerMethodField()

    class Meta:
        model = Conversation
        fields = ['id', 'participant_1', 'participant_2', 
                  'participant_1_name', 'participant_2_name',
                  'participant_1_email', 'participant_2_email',
                  'participant_1_avatar', 'participant_2_avatar',
                  'participant_1_type', 'participant_2_type',
                  'created_at', 'updated_at', 'last_message', 'unread_count']
        read_only_fields = ['id', 'created_at', 'updated_at']

    def get_participant_1_name(self, obj):
        return f"{obj.participant_1.first_name} {obj.participant_1.last_name}"

    def get_participant_2_name(self, obj):
        return f"{obj.participant_2.first_name} {obj.participant_2.last_name}"

    def get_last_message(self, obj):
        last_msg = obj.messages.order_by('-created_at').first()
        if last_msg:
            return {
                'id': last_msg.id,
                'content': last_msg.content,
                'created_at': last_msg.created_at,
                'sender_id': last_msg.sender.id,
                'is_read': last_msg.is_read,
            }
        return None

    def get_unread_count(self, obj):
        # Get current user from context
        request = self.context.get('request')
        # Check if user exists and is not AnonymousUser (has id attribute)
        if request and request.user and hasattr(request.user, 'id'):
            # Count messages not sent by current user and not read
            return obj.messages.exclude(sender=request.user).filter(is_read=False).count()
        return 0


class UnreadCountSerializer(serializers.Serializer):
    """Serializer dla liczby nieprzeczytanych wiadomości"""
    unread_count = serializers.IntegerField()
