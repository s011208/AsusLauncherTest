from django.db import models

# Create your models here.
class test_cases(models.Model):
    test_case = models.TextField(null=False)

class test_results(models.Model):
    test_case_id = models.IntegerField(null=False)
    test_time_id = models.IntegerField(null=False)
    test_result = models.TextField(null=False)
    
class test_times(models.Model):
    test_time = models.TextField(null=False)
    
class test_versions(models.Model):
    test_time_id = models.IntegerField(null=False)
    test_version = models.TextField(null=False)
	
class test_tags(models.Model):
    test_time_id = models.IntegerField(null=False)
    test_tag = models.TextField(null=False)