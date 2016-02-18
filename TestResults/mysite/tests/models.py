from django.db import models

# Create your models here.
class test_cases(models.Model):
    test_case = models.TextField(null=False)
    test_threshold = models.TextField(default='', null=True)
    test_threshold_value = models.IntegerField(default=-1, null=True)

class test_threshold(models.Model):
    test_case_id = models.IntegerField(null=False)
    test_branch = models.TextField(default='', null=True)
    test_display_order = models.IntegerField(default=0, null=True)
    test_method_name = models.TextField(default='', null=True)
    test_threshold_name = models.TextField(default='', null=True)
    test_threshold_value = models.IntegerField(default=-1, null=True)

class test_results(models.Model):
    test_case_id = models.IntegerField(null=False)
    test_time_id = models.IntegerField(null=False)
    test_result = models.TextField(null=False)
    test_extra_msgs = models.TextField(default='', null=True)
	
class test_extra_messages(models.Model):
    test_case_id = models.IntegerField(null=False)
    test_time_id = models.IntegerField(null=False)
    test_method_name = models.TextField(default='', null=True)
    test_message_name = models.TextField(default='', null=False)
    test_message_value = models.IntegerField(default=-1, null=False)
    test_message_extra_messages = models.TextField(default='', null=False)
    
class test_times(models.Model):
    test_time = models.TextField(null=False)
    test_done = models.TextField(null=False, default='False')
    test_branch = models.TextField(default='', null=True)
    test_git_log_id = models.IntegerField(null=False, default=-1)
    test_device_info_id = models.IntegerField(null=False, default=-1)
    number_of_test_time = models.IntegerField(null=False, default=1)
    
class test_versions(models.Model):
    test_time_id = models.IntegerField(null=False)
    test_version = models.TextField(null=False)
	
class test_tags(models.Model):
    test_time_id = models.IntegerField(null=False)
    test_tag = models.TextField(null=False)
	
class test_git_log(models.Model):
    git_subject = models.TextField(null=False)
    git_author_name = models.TextField(null=False)
    git_author_email = models.TextField(null=False)
    git_hash_code = models.TextField(null=False)
    git_tested = models.TextField(null=False, default='False')
    git_branch = models.TextField(default='', null=True)

class test_device_info(models.Model):
    version_sdk = models.TextField(null=False)
    version_incremental = models.TextField(null=False)
    product = models.TextField(null=False)
    csc_version = models.TextField(null=False)
    characristics = models.TextField(null=False)
    sku = models.TextField(null=False)
    device_id = models.TextField(null=False)