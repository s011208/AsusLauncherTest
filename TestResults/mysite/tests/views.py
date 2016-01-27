from django.shortcuts import render
from datetime import datetime
from django.http import HttpResponse
from tests.models import test_cases


def hello_world(request):
    return render(request, 'hello_world.html', {
        'current_time': datetime.now(), 'insert_time' : addTestCase(), 'all_tests' : getAllTestCases()
    })
    
def addTestCase():
    current_time = datetime.now()
    #test_cases.objects.create(test_case=current_time)
    return current_time
    
def getAllTestCases():
    return test_cases.objects.all().values()