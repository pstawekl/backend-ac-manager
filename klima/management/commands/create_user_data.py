from django.core.management.base import BaseCommand
from klima.models import UserData, ACUser

class Command(BaseCommand):
    help = 'Create UserData objects for existing ACUser instances'

    def handle(self, *args, **options):
        ac_users = ACUser.objects.all()

        for ac_user in ac_users:
            if not UserData.objects.filter(ac_user=ac_user).exists():
                user_data = UserData.objects.create(ac_user=ac_user)
                user_data.save()

        self.stdout.write(self.style.SUCCESS('Successfully created UserData objects for existing ACUser instances.'))
