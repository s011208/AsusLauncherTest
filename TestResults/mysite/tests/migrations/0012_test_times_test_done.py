# -*- coding: utf-8 -*-
# Generated by Django 1.9.1 on 2016-02-02 02:25
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('tests', '0011_test_times_test_git_log_id'),
    ]

    operations = [
        migrations.AddField(
            model_name='test_times',
            name='test_done',
            field=models.TextField(default='False'),
        ),
    ]