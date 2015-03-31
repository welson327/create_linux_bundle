
$(function(){

	$.fn.extend({
		setCookie: function(key, value, expiryInMinutes) {
			var expiryTime = new Date();
			expiryTime.setTime(expiryDate.getTime() + (expiryInMinutes * 60 * 1000));
			$.cookie(key, value, { path:'/', expires: expiryTime });
		},
		getCookie: function(key) {
			return $.cookie(key);
		}	
	});

});

var bookStatusChecker = {
		ST_BOOK: 						0,
		ST_DRAFT: 						(1 << 1),
		ST_REMOVED_BY_USER: 			(1 << 4),
		ST_REMOVED_BY_PLATFORM: 		(1 << 5),
		ST_POST_BY_PUBLISHING_COMPANY: 	(1 << 8),
		
		isBook: function(status) {
			//return (0<=status  &&  status<=99);
			return ((status & 1) == this.ST_BOOK);
		},
		isRemoved: function(status) {
			return ((status & this.ST_REMOVED_BY_USER) == this.ST_REMOVED_BY_USER);
		},
		isRemovedByPlatform: function(status) {
			return ((status & this.ST_REMOVED_BY_PLATFORM) == this.ST_REMOVED_BY_PLATFORM);
		},
		isPostedByPublishingCompany: function(status) {
			return ((status & this.ST_POST_BY_PUBLISHING_COMPANY) == this.ST_POST_BY_PUBLISHING_COMPANY);
		},
		isDraft: function(status) {
			return ((status & this.ST_DRAFT) == this.ST_DRAFT);
		},
		canEdit: function(status) {
			return (this.isBook(status) | this.isDraft(status));
		}
};

var bookConvStatusChecker = {
	CONVERSION_SUPPORTED: 		(1 << 0),
	CONVERSION_COVER_READY: 	(1 << 5),
	CONVERSION_HTML_READY: 		(1 << 8),
	CONVERSION_PROCESS_DONE: 	(1 << 15),

	isSupported: function(status) {
		return ((status & this.CONVERSION_SUPPORTED) == this.CONVERSION_SUPPORTED);
	},
	isCoverReady: function(status) {
		return ((status & this.CONVERSION_COVER_READY) == this.CONVERSION_COVER_READY);
	},
	isProcessDone: function(status) {
		return ((status & this.CONVERSION_PROCESS_DONE) == this.CONVERSION_PROCESS_DONE);
	}
};

/*
var DateUtil = {
	d: new Date(),
	
	zeroPadding: function(num) {
		return (num < 10) ? ("0" + num) : num;
	},
	getFormatDate: function(y, m, d) {
		return this.zeroPadding(y) + "-" + this.zeroPadding(m) + "-" + this.zeroPadding(d);
	},

	year: this.d.getFullYear(),
	month: this.d.getMonth() + 1,
	day: this.d.getDate(),
	hours: this.d.getHours(),
	minutes: this.d.getMinutes(),
	seconds: this.d.getSeconds(),
	
	today: function() {
		return this.getFormatDate(this.year, this.month, this.day);
	},
	nextMonth: function() {
		var nextMonth = Number(this.month);
		var date = new Date(this.year, nextMonth, this.day);
		var y = date.getFullYear();
		var m = date.getMonth() + 1;
		var d = date.getDate();
		return this.getFormatDate(y, m, d);
	}
};*/

function joinAutoLogout() {
	/* Boss reject!!!!!!!!!!!!!!!!!!!!!!!
	//$.log("$(this)=" + $(this));

	var idleTime = 0;
	var step = 60; // check per seconds
	
	var timeoutId = setInterval(checkIdle, step*1000);

	$(this).mousemove(function (e) {
        idleTime = 0;
    });
    $(this).keypress(function (e) {
        idleTime = 0;
    });

	function checkIdle() {
	    idleTime = idleTime + step;
	    
	    //$.log("idleTime=" + idleTime);
	    
	    if (idleTime > 179) { // 3-hours = 180minutes  
	    	clearLoginInfo();
	    	clearInterval(timeoutId);
	    	window.location.reload(); // redirect by login_if.js
	    }
	}
	
	function clearLoginInfo() {
		$.cookie('yiabi_account_name', null, {path: '/'});
		$.cookie('yiabi_account_nickname', null, {path: '/'});
		$.cookie('yiabi_account_token', null, {path: '/'});
	}
	*/
}

//scroll to bottom
function scroll2Bottom() {
	$("html, body").animate({ 
		scrollTop: $(document).height() - $(window).height() 
	});
}
function scroll2Top() {
	/*
	$("html, body").animate({ 
		scrollTop: 0
	});*/
	if(window) {
		window.scrollTo(0, 0);
	}
}

function sleep(milliseconds) {
	var start = new Date().getTime();
	for (var i = 0; i < 1e7; i++) {
		if ((new Date().getTime() - start) > milliseconds) {
			break;
		}
	}
}

function trimEmail(str) {
	var emailReg = /^([\w-_\.]+@([\w-_]+\.)+[\w-]{2,})?$/; // must sync 'member_system'
	if(!emailReg.test(str))
		return str;
	else
		return str.substring(0, str.indexOf("@"));
}

function getUrlFileName(_location) {
	// ~/index.html ------------> return 'index'
	// ~/index.jsp -------------> return 'index'
	// ~/index.html?key=value --> return 'index'
	if(_location != null) {
		var path = _location.pathname;
		return path.substring(path.lastIndexOf('/')+1, path.indexOf('.'));
	} else
		return "";
}

function checkAccountNaming(str) {
	if(str != null) {
		var reg = new RegExp(/^[a-zA-Z]+[a-zA-Z0-9_.]*/);
		return (reg.exec(str) == str);
	} else
		return false;
};

function redirectIfAuthFail() {
	$(location).attr('href', "/");
};

function ajaxUpdateCategory(accessToken, callback) {
	$.ajax({
		type: "GET",
		url: RESTFUL_HOSTSITE + "/services/getCategory",
		contentType: "application/json",
		dataType: "json",
		//data: JSON.stringify(postData),
		success: function(data) {  
			if(callback) {
				callback(data.Data);
			}
		},
	    error:function() {
	    },
	    complete:function(){
		}    				
	});
}

function service_debug(msg) {
	if(window.console)
		console.log(msg);
}

function getParentCategoryId(subcategory) {
	return Math.floor(subcategory/100000000)*100000000;
}

function isParentCategoryId(id) {
	return (getParentCategoryId(id) == id);
}

function htmlEscape(str) {
	// http://php.net/htmlspecialchars
	// http://stackoverflow.com/questions/1219860/html-encoding-in-javascript-jquery
    return String(str)
            .replace(/&/g, '&amp;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;');
}

function randomString(bytes) {
	var chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz";
	var string_length = bytes ? bytes : 8;
	var randomstring = '';
	for (var i=0; i<string_length; i++) {
		var rnum = Math.floor(Math.random() * chars.length);
		randomstring += chars.substring(rnum,rnum+1);
	}
	return randomstring;
}