# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('tests', '0004_test_test_cases'),
    ]

    operations = [
        migrations.AlterField(
            model_name='test_cases',
            name='test_case',
            field=models.TextField(blank=True, null=True),
        ),
    ]
