# -*- coding: utf-8 -*-
# Generated by Django 1.9.1 on 2016-02-03 06:04
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('tests', '0014_test_device_info'),
    ]

    operations = [
        migrations.AddField(
            model_name='test_results',
            name='test_extra_msgs',
            field=models.TextField(default=''),
        ),
    ]
