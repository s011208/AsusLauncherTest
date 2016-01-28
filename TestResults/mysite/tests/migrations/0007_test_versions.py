# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('tests', '0006_auto_20160127_0725'),
    ]

    operations = [
        migrations.CreateModel(
            name='test_versions',
            fields=[
                ('id', models.AutoField(serialize=False, verbose_name='ID', auto_created=True, primary_key=True)),
                ('test_time_id', models.IntegerField()),
                ('test_version', models.TextField()),
            ],
        ),
    ]
