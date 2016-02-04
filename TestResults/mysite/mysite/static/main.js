$(document).ready(function() {
	$("#device_list_title").click(function() {
		$("#devices_list_table_div").slideToggle( "fast", function() {
			if ( $("#devices_list_table_div").css('display') == 'none' ){
				$("#device_list_title").text("click to show device list");
			} else {
				$("#device_list_title").text("Device list");
			}
		});
	});
	
    var collapse_height=70;
    var expand_height=380;
    var expand_delta=expand_height-collapse_height;
    var expand_animate_time=200;
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
	
	var _showTab = 0;
	var $defaultLi = $('ul.branch_nav li').eq(_showTab).addClass('active');
	$($defaultLi.find('a').attr('href')).siblings().hide();
	$('ul.branch_nav li').click(function() {
		var $this = $(this),
			_clickTab = $this.find('a').attr('href');
		$this.addClass('active').siblings('.active').removeClass('active');
		$(_clickTab).stop(false, true).fadeIn().siblings().hide();
		return false;
	}).find('a').focus(function(){
		this.blur();
	});
});
