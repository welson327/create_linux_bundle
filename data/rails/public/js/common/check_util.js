
function getCookie(c_name){
	var c_value = document.cookie;
	var c_start = c_value.indexOf(" " + c_name + "=");
	if (c_start == -1) {
		c_start = c_value.indexOf(c_name + "=");
	}
	if (c_start == -1) {
		c_value = null;
	}
	else {
		c_start = c_value.indexOf("=", c_start) + 1;
		var c_end = c_value.indexOf(";", c_start);
		if (c_end == -1) {
			c_end = c_value.length;
		}
		c_value = unescape(c_value.substring(c_start,c_end));
	}
	return c_value;
}

function gotoLoginPageIfAccountCookieNotFound(pathname_before_login) {
	if(getCookie('yiabi_account_name') == null) {
		if(pathname_before_login)
			window.location.href = "/member_system/login.html?from=" + encodeURIComponent(pathname_before_login);
		else
			window.location.href = "/member_system/login.html";
		return true;
	}
	return false;
}
