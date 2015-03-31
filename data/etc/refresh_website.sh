#!/bin/bash

source "/yiabi/path.sh"
	
refresh_website() {
	# update homepage.json, category.json
	homepageJsonRslt="$(${PROJ_ETC_DIR}/gen_homepage_json.sh)"
	echo "$homepageJsonRslt"
	sleep 3

	# update book-statistics cache
	cacheRslt="$(${PROJ_CRONJOB_DIR}/calc_book_statistics.sh)"
	echo "$cacheRslt"
	sleep 3
	
	# gen homepage booklist page
	#rslt="$(${PROJ_CRONJOB_DIR}/gen_homepage_booklist_page.sh)"
	#echo "$rslt"
}

refresh_website
