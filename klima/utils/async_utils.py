"""
Utility functions for asynchronous task processing.
Uses Python's built-in threading module.
"""
import threading
from functools import wraps
from django.core.cache import cache


def run_async(func):
    """
    Decorator do uruchamiania funkcji w osobnym wątku.
    Używa wbudowanego threading.
    
    Usage:
        @run_async
        def my_long_task():
            # długie zadanie
            pass
    """
    @wraps(func)
    def wrapper(*args, **kwargs):
        thread = threading.Thread(target=func, args=args, kwargs=kwargs)
        thread.daemon = True
        thread.start()
        return thread
    return wrapper


def async_task(task_id, func, *args, **kwargs):
    """
    Uruchamia zadanie asynchronicznie i zapisuje status w cache.
    
    Args:
        task_id: Unikalne ID zadania
        func: Funkcja do wykonania
        *args, **kwargs: Argumenty dla funkcji
    
    Returns:
        task_id: ID zadania do śledzenia statusu
    
    Example:
        task_id = str(uuid.uuid4())
        async_task(task_id, process_report, user_id)
        # Sprawdź status: get_task_status(task_id)
    """
    def task_wrapper():
        try:
            # Ustaw status: running
            cache.set(f'task_status_{task_id}', {'status': 'running'}, 3600)
            
            # Wykonaj zadanie
            result = func(*args, **kwargs)
            
            # Ustaw status: completed
            cache.set(f'task_status_{task_id}', {
                'status': 'completed',
                'result': result
            }, 3600)
        except Exception as e:
            # Ustaw status: error
            cache.set(f'task_status_{task_id}', {
                'status': 'error',
                'error': str(e)
            }, 3600)
    
    thread = threading.Thread(target=task_wrapper)
    thread.daemon = True
    thread.start()
    return task_id


def get_task_status(task_id):
    """
    Pobiera status zadania asynchronicznego.
    
    Args:
        task_id: ID zadania
    
    Returns:
        Dict z statusem: {'status': 'running'|'completed'|'error', ...}
        lub None jeśli zadanie nie istnieje
    """
    return cache.get(f'task_status_{task_id}')

