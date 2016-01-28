from django.shortcuts import render
from datetime import datetime
from django.http import HttpResponse
from tests.models import *
from tests.models import test_results as models_test_results

def test_results(request):
    return render(request, 'test_results.html', {
        'all_test_cases' : getAllTestCases(), 'all_test_times' : getAllTestTimes(),
        'all_test_results' : getAllResults()
    })

def getAllTestCases():
    return test_cases.objects.all().order_by('id').values()

def getAllTestTimes():
    return test_times.objects.all().order_by('-id').values()

def getAllResults():
    return models_test_results.objects.order_by('-test_time_id').all().values()
