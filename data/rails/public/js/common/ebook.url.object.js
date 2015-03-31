/* =====================================================
 * Purpose:		for basic object
 * Parameter:
 * Return:
 * Remark:		
 * Author: welson
 * ===================================================== */ 
var ebookUrlObject = {
		HOSTNAME: "http://" + window.location.hostname + ":" + window.location.port,
		SITENAME: "/puppy",
		RESTFUL_HOSTSITE: this.HOSTNAME + "/pus",
		BEAGLE_HOSTSITE: this.HOSTNAME + "/pus", //"http://www.beagle.com:80"

		getHomePage: function() {
			//return this.HOSTNAME + this.SITENAME + "/index.html";
			return this.HOSTNAME;
		},
		getHomePagePath: function() {
			return "/";
		},
		
		// cs
		getCustomerServicePage: function(anchorName) {
			if(anchorName  &&  anchorName!="")
				return this.HOSTNAME + this.SITENAME + "/pages/cs/frequently_asked_questions_page.html#" + anchorName;
			else
				return this.HOSTNAME + this.SITENAME + "/pages/cs/frequently_asked_questions_page.html";
		},
		getFrequentlyQuestionsPage: function() {
			return this.getCustomerServicePage(null);
		},
		getContactUsPage: function() {
			return this.HOSTNAME + this.SITENAME + "/pages/cs/contact_us_page.html";
		},
		getClausePage: function() {
			return this.HOSTNAME + this.SITENAME + "/pages/cs/clause_page.html";
		},
		getCopyrightPage: function() {
			return this.HOSTNAME + this.SITENAME + "/pages/cs/copyright_protection_page.html";
		},
		
		
		getMyBooksPage: function() {
			return this.HOSTNAME + this.SITENAME + "/pages/user_mybooks_page.html";
		},
		getMyBookStorePage: function() {
			return this.HOSTNAME + this.SITENAME + "/pages/user_bookstore_page.html";
		},
		getBuyProcessPage: function() {
			return "javascript:void(0)";
		},
		getAppDownloadPage: function() {
			return "javascript:void(0)";
		},
		
		getProductPage: function(bookId) {
			//return this.HOSTNAME + this.SITENAME + "/pages/product_info_page.html?bookId=" + bookId;
			return this.getProductC2cPage(bookId);
		},
		getProductC2cPage: function(bookId) {
			//return this.HOSTNAME + this.SITENAME + "/pages/product_info_c2c_page.html?bookId=" + bookId + "&p=1";
			return RESTFUL_HOSTSITE + "/pages/product_info_c2c_page.jsp?bookId=" + bookId + "&p=1";
		},
		getRatingPage: function(bookId) {
			return this.HOSTNAME + this.SITENAME + "/pages/rating_page.html?bookId=" + bookId;
		},
		getEditPage: function(bookId) {
			return this.HOSTNAME + this.SITENAME + "/pages/complete_upload_page.html?bookId=" + bookId + "&action=edit";
		},
		
		// category, sub-category
		getCategoryPage: function(level, categoryId) { 
			return this.HOSTNAME + this.SITENAME + "/pages/category_level" + level + "_page.html?categoryId=" + categoryId;
		},
		getCategoryQueryPage: function(level, querystr) { 
			return this.HOSTNAME + this.SITENAME + "/pages/category_level" + level + "_page.html?" + querystr;
		},
		
		getDefaultCoverImage: function() {
			return (this.SITENAME + "/img/cover.jpg");
		},
		getPreparationImage: function() {
			return (this.SITENAME + "/img/coverPreparation.gif");
		},
		getCoverUrl: function(json) {
			/*
			var txtPath = json.txtPath;
			var ext = txtPath.substring(txtPath.lastIndexOf("."));
			var img = null;
			if(json.thumbnailImage || ext==".txt") {
				img = this.getThumbnail(json);
			} else {
				var convStatus = json.convStatus;
				if(bookConvStatusChecker.isCoverReady(convStatus)) {
					img = this.getThumbnail2(json);
				} else {
					img = this.getPreparationImage();
				}
			}
			return img;
			*/
			
			// new version
			if(json.cover) {
				return this.HOSTNAME + json.cover;
			} else {
				var bookId = json.bookId ? json.bookId : json._id.$oid;//txtPath.substring(0, txtPath.lastIndexOf("."));
				var filename = json.thumbnailImage;
				var convStatus = json.convStatus ? json.convStatus : 0;
				return (this.RESTFUL_HOSTSITE + "/dfs/cover?bookId=" + bookId + "&filename=" + filename + "&convStatus=" + convStatus);
			}
		},
		getUploadUrl: function (account, ext) {
			return (this.RESTFUL_HOSTSITE + "/services/upload?account=" + account + "&ext=" + ext);
		},
		getBrowsingCntUrl: function () {
			return (this.BEAGLE_HOSTSITE + "/browsingCount");
		}
};