"""
Utility functions for caching user tokens and API responses.
Uses Django's built-in cache framework.
"""
from django.core.cache import cache
from django.core.exceptions import ObjectDoesNotExist

from ..models import ACUser

# Cache timeout dla użytkowników (5 minut)
USER_CACHE_TIMEOUT = 300


def get_cached_user(token):
    """
    Pobiera użytkownika z cache lub bazy danych.
    Używa Django cache framework (wbudowany).

    Args:
        token: Token użytkownika (hash_value)

    Returns:
        ACUser instance lub None jeśli nie znaleziono lub token nieprawidłowy
    """
    if not token:
        return None

    cache_key = f'user_token_{token}'

    # Spróbuj pobrać z cache
    try:
        cached_user = cache.get(cache_key)
        if cached_user is not None:
            # None może być cache'owane jako negatywny wynik
            if cached_user == 'None':
                return None
            return cached_user
    except Exception:
        # Jeśli cache nie działa, po prostu pobierz z bazy danych
        pass

    # Jeśli nie ma w cache, pobierz z bazy danych
    try:
        user = ACUser.objects.select_related('group').get(hash_value=token)

        # Sprawdź czy token jest poprawny przed cache'owaniem
        if user.check_token(token):
            # Cache'uj użytkownika na 5 minut
            try:
                cache.set(cache_key, user, USER_CACHE_TIMEOUT)
            except Exception:
                # Jeśli cache nie działa, zwróć użytkownika bez cache'owania
                pass
            return user
        else:
            # Cache'uj negatywny wynik na krócej (1 minuta)
            try:
                cache.set(cache_key, 'None', 60)
            except Exception:
                pass
            return None
    except ACUser.DoesNotExist:
        # Cache'uj negatywny wynik
        try:
            cache.set(cache_key, 'None', 60)
        except Exception:
            pass
        return None


def invalidate_user_cache(token=None, user_id=None):
    """
    Unieważnia cache użytkownika.

    Args:
        token: Token użytkownika do unieważnienia
        user_id: ID użytkownika (opcjonalne, dla przyszłych rozszerzeń)
    """
    if token:
        cache.delete(f'user_token_{token}')

    # Można rozszerzyć o unieważnianie wszystkich tokenów użytkownika
    # jeśli będzie potrzebne


def cache_response(key, data, timeout=300):
    """
    Helper do cache'owania odpowiedzi API.

    Args:
        key: Klucz cache
        data: Dane do cache'owania
        timeout: Czas wygaśnięcia w sekundach (domyślnie 5 minut)
    """
    cache.set(key, data, timeout)


def get_cached_response(key):
    """
    Helper do pobierania cache'owanej odpowiedzi.

    Args:
        key: Klucz cache

    Returns:
        Cache'owane dane lub None
    """
    return cache.get(key)
