from django.http import HttpResponse, JsonResponse
from django.utils.deprecation import MiddlewareMixin
from django.core.cache import cache


class CORSMiddleware(MiddlewareMixin):
    """
    Simple CORS middleware to allow React Native app and admin panel to access API
    """

    def process_request(self, request):
        # Handle preflight OPTIONS requests for CORS
        if request.method == 'OPTIONS' and (request.path.startswith('/api/') or request.path.startswith('/documents/')):
            response = HttpResponse()
            response["Access-Control-Allow-Origin"] = "*"
            response["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS, PATCH"
            response["Access-Control-Allow-Headers"] = "Content-Type, Authorization, X-Requested-With"
            response["Access-Control-Max-Age"] = "3600"
            return response
        return None

    def process_response(self, request, response):
        # Add CORS headers for media files (images)
        if request.path.startswith('/documents/'):
            response["Access-Control-Allow-Origin"] = "*"
            response["Access-Control-Allow-Methods"] = "GET, OPTIONS"
            response["Access-Control-Allow-Headers"] = "Content-Type, Authorization"
        
        # Add CORS headers for API endpoints (dla panelu admina i aplikacji mobilnej)
        if request.path.startswith('/api/'):
            response["Access-Control-Allow-Origin"] = "*"
            response["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS, PATCH"
            response["Access-Control-Allow-Headers"] = "Content-Type, Authorization, X-Requested-With"
            response["Access-Control-Max-Age"] = "3600"

        return response


class RateLimitMiddleware(MiddlewareMixin):
    """
    Rate limiting middleware używający Django cache.
    Ogranicza liczbę requestów na IP i token.
    """
    
    # Limit requestów na minutę
    RATE_LIMIT_PER_MINUTE = 500
    RATE_LIMIT_PER_HOUR = 5000
    
    def process_request(self, request):
        # Pomiń rate limiting dla statycznych plików
        if request.path.startswith('/static/') or request.path.startswith('/documents/'):
            return None
        
        try:
            # Pobierz IP klienta
            ip = self.get_client_ip(request)
            
            # Rate limiting per IP
            ip_cache_key = f'rate_limit_ip_{ip}'
            try:
                ip_requests = cache.get(ip_cache_key, 0)
            except Exception:
                # Jeśli cache nie działa, pomiń rate limiting
                return None
            
            if ip_requests >= self.RATE_LIMIT_PER_MINUTE:
                return JsonResponse(
                    {
                        'error': 'Too many requests. Please try again later.',
                        'retry_after': 60
                    },
                    status=429
                )
            
            # Zwiększ licznik
            try:
                cache.set(ip_cache_key, ip_requests + 1, 60)  # 60 sekund
            except Exception:
                # Jeśli cache nie działa, pomiń rate limiting
                pass
            
            # Rate limiting per token - tylko dla requestów z tokenem w query params lub headers
            # NIE odczytujemy body tutaj, ponieważ może to powodować problemy z parsowaniem
            # Token rate limiting będzie obsługiwany w widokach, jeśli będzie potrzebny
        except Exception:
            # Jeśli wystąpi jakikolwiek błąd, pomiń rate limiting aby nie blokować requestów
            pass
        
        return None
    
    def get_client_ip(self, request):
        """Pobiera IP klienta z nagłówków"""
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            ip = x_forwarded_for.split(',')[0].strip()
        else:
            ip = request.META.get('REMOTE_ADDR')
        return ip
