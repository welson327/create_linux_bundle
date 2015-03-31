var PATHNAME = window.location.pathname;
var SITE = PATHNAME.substring(0, PATHNAME.indexOf("/", 1));
var SITENAME = "/puppy";
var PORT = window.location.port;
var HOSTNAME = "http://" + window.location.hostname + ":" + PORT;

var RESTFULNAME = "/pus"; // donot forget 'ebook.url.object.js'
var RESTFUL_HOSTSITE = HOSTNAME + RESTFULNAME;

// constant
var USERNAME_LEN_MAX = 200;
var USERPASSWORD_LEN_MIN = 6;
var USERPASSWORD_LEN_MAX = 12;

// tag
var TAG_UID = "ownerUid";