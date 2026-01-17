from django.contrib import admin
from django.urls import path

from .views import *
from .views import UpdateEmployeeTeamAPIView

urlpatterns = [

    path('update_employee_team/', UpdateEmployeeTeamAPIView.as_view(),
         name='update_employee_team'),

        path('invite/', invite_redirect, name='invite_redirect'),
path('privacy/', privacy, name='privacy'),

    path('register/', RegistrationAPIView.as_view(), name='register'),
    path('login/', LoginAPIView.as_view(), name='login'),
    path('send_invitation/', SendInvitationAPIView.as_view(), name='send_invitation'),
    path('invitation_data/', InvitationDataAPIView.as_view(), name='invitation_data'),
    path('data/', DataAPIView.as_view(), name='data'),
    path('monter_list/', MonterListAPIView.as_view(), name='monter_list'),
    path('group_list/', GroupListAPIView.as_view(), name='group_list'),
    path('create_monter/', CreateMonterAPIView.as_view(), name='create_monter'),
    path('remove_user/', RemoveUserAPIView.as_view(), name='remove_user'),
    path('reset/', ResetAPIView.as_view(), name='reset'),

    path('change_own_data/', ChangeOwnDataAPIView.as_view(), name='change_own_data'),
    path('change_child_data/', ChangeChildDataAPIView.as_view(),
         name='change_child_data'),

    path('klient_list/', KlientListAPIView.as_view(), name='klient_list'),
    path('data_child/', DataChildAPIView.as_view(), name='data_child'),
    path('check_email/', CheckEmailAPIView.as_view(), name='check_email'),
    path('create_klient/', CreateKlientAPIView.as_view(), name='create_klient'),
    path('addchildren/', AddChildren.as_view(), name='addchildren'),
    path('remove_klient/', RemoveKlientAPIVIew.as_view(), name='remove_klient'),

    path('listy_klientow/', ListyKlientowAPIView.as_view(), name='listy_klientow'),
    path('listy_klientow_add/', ListyKlientowAddAPIView.as_view(),
         name='listy_klientow_add'),
    path('listy_klientow_add_klient_to_lista/', ListyKlientowAddKlientToListaAPIView.as_view(),
         name='listy_klientow_add_klient_to_lista'),
    path('listy_klientow_remove_klient_from_lista/', ListyKlientowRemoveKlientFromListaAPIView.as_view(),
         name='listy_klientow_remove_klient_from_lista'),

    path('add_task/', CreateTaskAPIView.as_view(), name='add_task'),
    path('task_list/', TasksAPIView.as_view(), name='task_list'),

    path('certyfikat_add/', CertyfikatAddAPIView.as_view(), name='certyfikat_add'),
    path('certyfikat_list/', CertyfikatListAPIView.as_view(), name='certyfikat_list'),
    path('certyfikat_delete/', CertyfikatDeleteAPIView.as_view(),
         name='certyfikat_delete'),

    path('szkolenie_add/', SzkolenieAddAPIView.as_view(), name='szkolenie_add'),
    path('szkolenie_list/', SzkolenieListAPIView.as_view(), name='szkolenie_list'),
    path('szkolenie_delete/', SzkolenieDeleteAPIView.as_view(),
         name='szkolenie_delete'),

    path('katalog_add/', KatalogAddAPIView.as_view(), name='katalog_addd'),
    path('katalog_list/', KatalogListAPIView.as_view(), name='katalog_list'),
    path('katalog_delete/', KatalogDeleteAPIView.as_view(), name='katalog_delete'),

    path('cennik_add/', CennikAddAPIView.as_view(), name='cennik_add'),
    path('cennik_list/', CennikListAPIView.as_view(), name='cennik_list'),
    path('cennik_delete/', CennikDeleteAPIView.as_view(), name='cennik_delete'),

    path('ulotka_add/', UlotkaAddAPIView.as_view(), name='ulotka_add'),
    path('ulotka_list/', UlotkaListAPIView.as_view(), name='ulotka_list'),
    path('ulotka_delete/', UlotkaDeleteAPIView.as_view(), name='ulotka_delete'),

    path('photo_list/', PhotoListApiView.as_view(), name='photo_list'),
    path('add_photo/', AddPhotoApiView.as_view(), name='add_photo'),
    path('edit_photo/', EditPhotoApiView.as_view(), name='edit_photo'),
    path('photo_delete/', PhotoDeleteApiView.as_view(), name='photo_delete'),

    path('add_tag/', AddTagApiView.as_view(), name='add_photo'),
    path('tag_list/', TagListApiView.as_view(), name='tag_list'),

    path('group_list_new/', GroupsByOwnerAPIView.as_view(), name='group_list_new'),
    path('group_edit/', GroupEditAPIView.as_view(), name='group_edit'),
    path('add_group/', AddGroupApiView.as_view(), name='add_group'),
    path('add_to_group/', AddToGroupApiView.as_view(), name='add_to_group'),
    path('remove_group/', RemoveGroupApiView.as_view(), name='remove_group'),
    path('remove_from_group/', RemoveFromGroupApiView.as_view(),
         name='remove_from_group'),

    path('installation_data/', InstallationDataApiView.as_view(),
         name='installation_data'),
    path('installation_create/', InstallationCreateApiView.as_view(),
         name='installation_create'),
    path('installation_delete/', InstallationDeleteApiView.as_view(),
         name='installation_delete'),
    path('installation_edit/', InstallationEditApiView.as_view(),
         name='installation_edit'),
    path('installation_list/', InstallationListApiView.as_view(),
         name='installation_list'),

    path('montaz_list/', MontazListApiView.as_view(), name='montaz_list'),
    path('montaz_data/', MontazDataApiView.as_view(), name='montaz_data'),
    path('montaz_create/', MontazCreateApiView.as_view(), name='montaz_create'),
    path('montaz_delete/', MontazDeleteApiView.as_view(), name='montaz_delete'),
    path('montaz_edit/', MontazEditApiView.as_view(), name='montaz_edit'),

    path('oferta_data/', OfertaDataApiView.as_view(), name='oferta_data'),
    path('oferta_create/', OfertaCreateApiView.as_view(), name='oferta_create'),
    path('oferta_accept/', OfertaAcceptApiView.as_view(), name='oferta_accept'),
    path('oferta_list/', OfertaListApiView.as_view(), name='oferta_list'),
    path('oferta_delete/', OfertaDeleteApiView.as_view(), name='oferta_delete'),
    path('oferta_template_create/', OfertaTemplateCreateApiView.as_view(),
         name='oferta_template_create'),
    path('oferta_template_list/', OfertaTemplateListApiView.as_view(),
         name='oferta_template_list'),
    
    # Montaz booking system endpoints
    path('oferta_send_email/', OfertaSendEmailApiView.as_view(), name='oferta_send_email'),
    path('available_montaz_dates/', AvailableMontazDatesApiView.as_view(), name='available_montaz_dates'),
    path('propose_montaz_date/', ProposeMontazDateApiView.as_view(), name='propose_montaz_date'),
    path('confirm_montaz_date/', ConfirmMontazDateApiView.as_view(), name='confirm_montaz_date'),
    path('reject_montaz_date/', RejectMontazDateApiView.as_view(), name='reject_montaz_date'),
    path('pending_montaz_proposals/', PendingMontazProposalsApiView.as_view(), name='pending_montaz_proposals'),

    path('inspekcja_edit/', InspekcjaEditApiView.as_view(), name='inspekcja_edit'),
    path('serwis_edit/', SerwisEditApiView.as_view(), name='serwis_edit'),
    path('przeglad_data/', PrzegladDataApiView.as_view(), name='przeglad_data'),
    path('przeglad_list/', PrzegladListApiView.as_view(), name='przeglad_list'),
    path('serwis_list/', SerwisListApiView.as_view(), name='serwis_list'),

    path('rabat_add/', RabatAddApiView.as_view(), name='rabat_add'),
    path('rabat_list/', RabatListApiView.as_view(), name='rabat_list'),
    path('rabat_edit/', RabatEditApiView.as_view(), name='rabat_edit'),
    path('rabat_delete/', RabatDeleteApiView.as_view(), name='rabat_delete'),
    path('rabat_value/', RabatValueApiView.as_view(), name='rabat_value'),
    path('narzut_add/', NarzutAddApiView.as_view(), name='narzut_add'),
    path('narzut_list/', NarzutListApiView.as_view(), name='narzut_list'),
    path('narzut_edit/', NarzutEditApiView.as_view(), name='narzut_edit'),
    path('narzut_delete/', NarzutDeleteApiView.as_view(), name='narzut_delete'),
    path('narzut_value/', NarzutValueApiView.as_view(), name='narzut_value'),

    path('devices_split/', DevicesSplitApiView.as_view(), name='devices_split'),
    path('devices_multisplit/', DevicesMultiSplitApiView.as_view(),
         name='devices_multisplit'),
    path('producenci_list/', ListAllProducersAPIView.as_view(),
         name='producenci_list'),

    path('szablon_create/', SzablonCreateApiView.as_view(), name='szablon_create'),
    path('szablon_list/', SzablonListApiView.as_view(), name='szablon_list'),
    path('szablon_data/', SzablonDataApiView.as_view(), name='szablon_data'),
    path('szablon_delete/', SzablonDeleteApiView.as_view(), name='szablon_delete'),

    path('zadanie_create/', ZadanieCreateApiView.as_view(), name='zadanie_create'),
    path('zadanie_list/', ZadanieListApiView.as_view(), name='zadanie_list'),
    path('zadanie_delete/', ZadanieDeleteApiView.as_view(), name='zadanie_delete'),
    path('zadanie_edit/', ZadanieEditApiView.as_view(), name='zadanie_edit'),

    path('invoice_settings_list/', InvoiceSettingsListAPIView.as_view(),
         name='invoice_settings_list'),
    path('invoice_settings_edit/', InvoiceSettingsCreateUpdateAPIView.as_view(),
         name='invoice_settings_edit'),
    path('faktura_create/', InvoiceAPIView.as_view(), name='faktura_create'),
    path('faktura_list/', FakturyListView.as_view(), name='faktura_list'),
    path('faktura_delete/', FakturyDeleteAPIView.as_view(), name='faktura_delete'),
    path('faktura_data/', FakturyDataView.as_view(), name='faktura_data'),

    path('generate_pdf/', GeneratePDFAPIView.as_view(), name='generate_pdf'),

    # Chat endpoints
    path('conversations/', ConversationsListView.as_view(), name='conversations_list'),
    path('conversations/<int:conversation_id>/messages/', ConversationMessagesView.as_view(), name='conversation_messages'),
    path('conversations/<int:conversation_id>/send/', SendMessageView.as_view(), name='send_message'),
    path('conversations/<int:conversation_id>/mark-read/', MarkMessagesAsReadView.as_view(), name='mark_messages_read'),
    path('conversations/unread-count/', UnreadCountView.as_view(), name='unread_count'),
    path('conversations/start/', StartConversationView.as_view(), name='start_conversation'),

    # Notifications System endpoints
    path('register_push_token/', RegisterPushTokenApiView.as_view(), name='register_push_token'),
    path('notifications/', NotificationsListApiView.as_view(), name='notifications_list'),
    path('notification_mark_read/', MarkNotificationReadApiView.as_view(), name='notification_mark_read'),
    path('notification_delete/', DeleteNotificationApiView.as_view(), name='notification_delete'),
    path('notifications_mark_all_read/', MarkAllNotificationsReadApiView.as_view(), name='notifications_mark_all_read'),

    # Sync endpoints
    path('sync/pull/', SyncPullAPIView.as_view(), name='sync_pull'),
    path('sync/push/', SyncPushAPIView.as_view(), name='sync_push'),

]
