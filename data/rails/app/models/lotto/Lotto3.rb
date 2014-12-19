require 'open-uri'
require_relative 'LOTTO'
require_relative 'Bean'
require_relative 'DataProvider'
require_relative 'Updater'

class Lotto3 < LOTTO
private 
    @@DIM = 3;
    @@TREND50_SITE = "http://www.9800.com.tw/lotto3/trend50.html"
    @@TREND20_SITE = "http://www.9800.com.tw/lotto3/trend.html"
    @@TREND10_SITE = "http://www.9800.com.tw/lotto3/trend10.html"

	

    #--------------------------------------------------------------//
public  
    def initialize
		@is_connect_success = false	
		@long_term_acc = []
		@medium_term_acc = []
		@short_term_acc = []
        @last_epi_of_3th_server = "000000"
        @recent_2year_games = []
		
=begin        
		begin
			puts "Parsing #{@@TREND50_SITE}"
			f = open(@@TREND50_SITE)
			src_code = f.readlines
			@long_term_acc = parse_html(src_code)
            @last_epi_of_3th_server = parse_last_epi(src_code)
			
			puts "Parsing #{@@TREND20_SITE}"
			f = open(@@TREND20_SITE)
			src_code = f.readlines
			@medium_term_acc = parse_html(src_code)
			
			puts "Parsing #{@@TREND10_SITE}"
			f = open(@@TREND10_SITE)
			src_code = f.readlines
			@short_term_acc = parse_html(src_code)

			@is_connect_success = true
		rescue OpenURI::HTTPError => e
			puts "Connect #{url} fail, msg:#{e.message}"
			#puts "raise OpenURI::HTTPError"
			#raise e
		rescue Exception => e
			puts "raise Exception: #{e.message}"
			#raise e
		ensure
			#puts "ensure-clause"
		end
=end
		
		@data = DataProvider.new("data" +  File::SEPARATOR + "3star.txt").get_data
		@curr_data = @data
    end
    
    def curr_data
        return @curr_data
    end
    
    attr_accessor :long_term_acc, :medium_term_acc, :short_term_acc
    
    def get_recent_2year_games
        tag1 = "onmouseout=\"this.style.backgroundColor=''\">"
        tag2 = "<TD align=center>"
        tag3 = "<TD align=center><font color=\"#FF0000\"><b>"
        @recent_2year_games.clear
        f = open(get_history_url)
        src_code = f.readlines
        0.upto(src_code.length-1) do |i|
            line = src_code[i]
            if line.include? (tag1)
                line1 = src_code[i+1]
                line3 = src_code[i+3]
                epi = line1[tag2.length, 6]
                draws = line3[tag3.length, 5].split(/ /).collect{|v| v.to_i}
                @recent_2year_games.push(Bean.new(epi, draws, -1))
            end
        end
        return @recent_2year_games
    end
    
    # ==================================================
    # Purpose:      取得三個位數最常出現的號碼(短/中/長期)
    # Parameters:   
    # Return: 
    # Remark:
    # Author:          
    # ==================================================
    def get_longterm_max_acc_number
        return get_max_acc_number(@long_term_acc)
    end
    def get_mediumterm_max_acc_number
        return get_max_acc_number(@medium_term_acc)
    end
    def get_shortterm_max_acc_number
        return get_max_acc_number(@short_term_acc)
    end
    
    def report
        puts "3-star report:"
        puts "long-term max-acc-number: #{get_longterm_max_acc_number}"
        puts "medium-term max-acc-number: #{get_mediumterm_max_acc_number}"
        puts "short-term max-acc-number: #{get_shortterm_max_acc_number}"
        puts "last_epi_of_3th_server: #{@last_epi_of_3th_server}"
        puts "history_url: #{get_history_url}"
    end
    
private
    def get_max_acc_number(acc_3d_array)
        rslt = []
        0.upto(acc_3d_array.length-1) do |i|
            # i=0:digit in hundreds (百位數)
            # i=1:digit in tens (拾位數)
            # i=2:digit in ones (個位數)
            sort_arr = acc_3d_array[i].each_with_index.to_a.sort_by{|v| -v[0]}
            num = sort_arr[0][1]
            rslt.push(num)
        end
        return rslt
    end
    # ==================================================
    # Purpose:  parse html code, and get array[0..30] 
    #           ,where array[0],array[10],array[20] means the acc-value of #0
    #           ex: [3, 7, 5, 6, 4, 7, 2, 9, 4, 3] means #0 with 3-counts, #1 with 7-counts, ... etc
    # Parameters:   src_code: html-src-code
    # Return:       2d-array: [[<1st-number>],[<2nd-number>],[3th-number]]  
    # Remark:
    # Author:
    # ==================================================
	def parse_html(src_code)
		tag = "<TD bgColor=#ffffff id=bt>"
		num_acc = []
		src_code.each do |line|
			if line.include?(tag)
				idx1 = tag.length
				idx2 = line.index("<BR>")
				cnt = line[idx1...idx2].to_i
				num_acc.push(cnt)
			end
		end
		# [1,2,3,4,5,6] -> [[1,2],[3,4],[5,6]]
		return num_acc.each_slice(10).to_a 
	end
    
	def parse_last_epi(src_code)
		tag = "name=p2>"
		last_epi = nil
		src_code.each do |line|
			if line.include?(tag)
				idx1 = line.index("value=")
                last_epi = line[(idx1+6), 6]
			end
		end
		return last_epi
	end
    
    def get_history_url
        last = @last_epi_of_3th_server.to_i
        start = (last - 2000).to_s # about 600 games
        return sprintf("http://www.9800.com.tw/trend.asp?p1=%s&p2=%s&l=0&type=3", start, last)
    end
	
    
	
	
	
end

=begin
lotto3 = Lotto3.new
p lotto3.long_term_acc
p lotto3.medium_term_acc
p lotto3.short_term_acc
lotto3.report
#p lotto3.get_recent_2year_games
=end
