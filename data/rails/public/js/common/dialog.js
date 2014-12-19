
function blockUI() {
	$.blockUI({
		message : $("<h5 style=\"text-align:center\"><img src=\"/puppy/img/loading.gif\" /></h5>"),
		css : {
			top : ($(window).height() - 40) / 2 + "px",
			left : ($(window).width() - 40) / 2 + "px",
			width : "60px",
			color : "#fff",
			background : "none",
			border : "0px",
			opacity : .7
		}
	});
}

function unblockUI() {
	$.unblockUI({
		fadeOut : 500
	});
}

function yAlert(msg) {
	alert(msg);
}

function cuttingAlert(msg) {
	var $alert = $(".cuttingAlert");
	$(".alertMsg", $alert).text(msg || "");
	if($alert.bPopup) {
		$alert.bPopup({
			onOpen: function() {
				$(".btnCyanAlert", $alert).click(function() { // ok button
					$alert.bPopup().close();
				});
			}
		});
	} else {
		alert(msg);
	}
}

(function() {
	var elem = 
	'<div class="cuttingAlert" style="display:none;">' +
		'<div class="bgColor">' +
			'<p class="alertMsg"></p>' +
	    	'<p class="btnCyanAlert"><a href="javascript:void(0)">確定</a></p>' +
	    '</div>' +
	'</div>';
	$("body").append(elem);
})();
