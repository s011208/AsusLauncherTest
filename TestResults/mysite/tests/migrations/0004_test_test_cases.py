# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('tests', '0003_auto_20160127_0717'),
    ]

    operations = [
        migrations.CreateModel(
            name='Test',
            fields=[
                ('id', models.AutoField(auto_created=True, verbose_name='ID', primary_key=True, serialize=False)),
                ('charNull', models.CharField(max_length=10, null=True)),
                ('charBlank', models.CharField(blank=True, max_length=10)),
                ('charNullBlank', models.CharField(max_length=10, blank=True, null=True)),
                ('intNull', models.IntegerField(null=True)),
                ('intBlank', models.IntegerField(blank=True)),
                ('intNullBlank', models.IntegerField(blank=True, null=True)),
                ('dateNull', models.DateTimeField(null=True)),
                ('dateBlank', models.DateTimeField(blank=True)),
                ('dateNullBlank', models.DateTimeField(blank=True, null=True)),
            ],
        ),
        migrations.CreateModel(
            name='test_cases',
            fields=[
                ('id', models.AutoField(auto_created=True, verbose_name='ID', primary_key=True, serialize=False)),
                ('test_case', models.TextField(blank=True)),
            ],
        ),
    ]
