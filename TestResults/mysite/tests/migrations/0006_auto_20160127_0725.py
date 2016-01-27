# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('tests', '0005_auto_20160127_0719'),
    ]

    operations = [
        migrations.CreateModel(
            name='test_results',
            fields=[
                ('id', models.AutoField(serialize=False, verbose_name='ID', auto_created=True, primary_key=True)),
                ('test_case_id', models.IntegerField()),
                ('test_time_id', models.IntegerField()),
                ('test_result', models.TextField()),
            ],
        ),
        migrations.CreateModel(
            name='test_times',
            fields=[
                ('id', models.AutoField(serialize=False, verbose_name='ID', auto_created=True, primary_key=True)),
                ('test_time', models.TextField()),
            ],
        ),
        migrations.DeleteModel(
            name='Test',
        ),
        migrations.AlterField(
            model_name='test_cases',
            name='test_case',
            field=models.TextField(),
        ),
    ]
