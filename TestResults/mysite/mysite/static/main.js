$(document).ready(function() {
    var collapse_height=70;
    var expand_height=300;
    var expand_delta=expand_height-collapse_height;
    var expand_animate_time=400;
	$("tr.content_column").click(function () {
		$(this).find(".content_failure").each(function() {
			if($(this).height() == collapse_height) {
                $(this).animate({height:expand_delta},expand_animate_time);
			} else {
				$(this).animate({height:collapse_height},expand_animate_time);
			}
		});
		$(this).find("td.column div.column").each(function() {
			if($(this).height() == collapse_height) {
                $(this).animate({height:expand_delta},expand_animate_time);
			} else {
                $(this).animate({height:collapse_height},expand_animate_time);
			}
		});
	});
});
