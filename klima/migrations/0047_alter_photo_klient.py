from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('klima', '0046_oferta_selected_device_id'),
    ]

    operations = [
        migrations.AlterField(
            model_name='photo',
            name='klient',
            field=models.ForeignKey(
                blank=True,
                null=True,
                on_delete=models.CASCADE,
                related_name='klient_photo',
                to='klima.acuser',
            ),
        ),
    ]
