# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('tests', '0002_test_cases1'),
    ]

    operations = [
        migrations.DeleteModel(
            name='test_cases',
        ),
        migrations.DeleteModel(
            name='test_cases1',
        ),
    ]
