from django.shortcuts import render
from datetime import datetime
from django.http import HttpResponse
from tests.models import *
from tests.models import test_results as models_test_results

def test_results(request):
    return render(request, 'test_results.html', {
        'all_test_cases' : getAllTestCases(), 'all_test_times' : getAllTestTimes(),
        'play_test_times' : getBranchPlayTestTimes(), 'beta_test_times' : getBranchBetaTestTimes(), 'dev_test_times' : getBranchDevTestTimes(), 
        'all_test_results' : getAllResults(), 'all_versions' : getAllVersions(),
		'all_test_tags' : getAllLauncherTags(), 'all_git_tags' : getAllGitLogs(),
		'all_device_infos' : getAllDeviceInfos(), 'all_test_thresholds' : getAllTestThresholds()
    })

def getAllTestCases():
    return test_cases.objects.all().order_by('id').values()

def getAllTestTimes():
    return test_times.objects.all().order_by('-id').values()

def getBranchPlayTestTimes():
    return test_times.objects.filter(test_branch="AsusLauncher_1.4_play").order_by('-id').values()

def getBranchBetaTestTimes():
    return test_times.objects.filter(test_branch="AsusLauncher_1.4_beta").order_by('-id').values()

def getBranchDevTestTimes():
    return test_times.objects.filter(test_branch="AsusLauncher_1.4_dev").order_by('-id').values()

def getAllResults():
    return models_test_results.objects.order_by('-test_time_id').all().values()

def getAllVersions():
    return test_versions.objects.all().values()
	
def getAllLauncherTags():
    return test_tags.objects.all().values()
	
def getAllGitLogs():
    return test_git_log.objects.all().values()

def getAllDeviceInfos():
    return test_device_info.objects.all().values()

def getAllTestThresholds():
    return test_threshold.objects.all().order_by('test_display_order').values()