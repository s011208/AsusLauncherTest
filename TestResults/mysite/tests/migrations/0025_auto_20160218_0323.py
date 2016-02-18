# -*- coding: utf-8 -*-
# Generated by Django 1.9.1 on 2016-02-18 03:23
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('tests', '0024_test_results_number_of_test_time'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='test_results',
            name='number_of_test_time',
        ),
        migrations.AddField(
            model_name='test_times',
            name='number_of_test_time',
            field=models.IntegerField(default=1),
        ),
    ]
