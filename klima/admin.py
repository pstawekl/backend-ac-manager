from django.contrib import admin

from .models import Invitation

# Register your models here.


@admin.register(Invitation)
class InvitationAdmin(admin.ModelAdmin):
    list_display = ('email', 'client', 'created_by',
                    'created_at', 'expires_at', 'used', 'used_at')
    list_filter = ('used', 'created_at', 'expires_at')
    search_fields = ('email', 'token')
    readonly_fields = ('token', 'created_at', 'used_at')
