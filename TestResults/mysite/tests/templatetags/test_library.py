from django import template

register = template.Library()

def remove_pkg(string):
    return string.replace("com.asus.launcher.", "")
    
def get_test_result(test_results, test_case_id, test_time_id):
    #return test_results
    for result in test_results:
        #return result
        #return result.get('test_case_id')
        if int(result.get('test_case_id')) == int(test_case_id):
            if int(result.get('test_time_id')) == int(test_time_id):
                return result.get('test_result')
    return "N/A"
    
register.simple_tag(remove_pkg)
register.simple_tag(get_test_result)