# -*- coding: utf-8 -*-
# Generated by Django 1.9.1 on 2016-02-04 09:20
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('tests', '0018_auto_20160204_0815'),
    ]

    operations = [
        migrations.AddField(
            model_name='test_git_log',
            name='git_branch',
            field=models.TextField(default='', null=True),
        ),
    ]
