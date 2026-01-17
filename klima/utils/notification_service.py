import requests
from typing import Optional, Dict, Any
from ..models import Notification, PushNotificationToken, ACUser


class NotificationService:
    """Serwis do wysyłania powiadomień in-app i push"""
    
    EXPO_PUSH_URL = 'https://exp.host/--/api/v2/push/send'
    
    @staticmethod
    def create_notification(
        user: ACUser,
        notification_type: str,
        title: str,
        message: str,
        related_object_type: Optional[str] = None,
        related_object_id: Optional[int] = None,
        data: Optional[Dict[str, Any]] = None
    ) -> Notification:
        """Tworzy powiadomienie w bazie danych"""
        notification = Notification.objects.create(
            user=user,
            type=notification_type,
            title=title,
            message=message,
            related_object_type=related_object_type,
            related_object_id=related_object_id,
            data=data or {}
        )
        return notification
    
    @staticmethod
    def send_push_notification(
        user: ACUser,
        title: str,
        body: str,
        data: Optional[Dict[str, Any]] = None
    ) -> bool:
        """Wysyła push notification przez Expo"""
        # Pobierz aktywne tokeny użytkownika
        tokens = PushNotificationToken.objects.filter(
            user=user,
            is_active=True
        ).values_list('token', flat=True)
        
        if not tokens:
            return False
        
        messages = []
        for token in tokens:
            message = {
                'to': token,
                'sound': 'default',
                'title': title,
                'body': body,
                'data': data or {},
            }
            messages.append(message)
        
        try:
            response = requests.post(
                NotificationService.EXPO_PUSH_URL,
                json=messages,
                headers={
                    'Accept': 'application/json',
                    'Content-Type': 'application/json',
                }
            )
            return response.status_code == 200
        except Exception as e:
            print(f"Error sending push notification: {e}")
            return False
    
    @staticmethod
    def send_notification(
        user: ACUser,
        notification_type: str,
        title: str,
        message: str,
        related_object_type: Optional[str] = None,
        related_object_id: Optional[int] = None,
        data: Optional[Dict[str, Any]] = None,
        send_push: bool = True
    ) -> Notification:
        """Tworzy powiadomienie i opcjonalnie wysyła push"""
        # Utwórz powiadomienie w bazie
        notification = NotificationService.create_notification(
            user=user,
            notification_type=notification_type,
            title=title,
            message=message,
            related_object_type=related_object_type,
            related_object_id=related_object_id,
            data=data
        )
        
        # Wyślij push notification
        if send_push:
            NotificationService.send_push_notification(
                user=user,
                title=title,
                body=message,
                data={
                    'notification_id': notification.id,
                    'type': notification_type,
                    'related_object_type': related_object_type,
                    'related_object_id': related_object_id,
                    **(data or {})
                }
            )
        
        return notification

