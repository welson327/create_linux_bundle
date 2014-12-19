require 'open-uri'
require_relative 'LOTTO'
require_relative 'Bean'
require_relative 'DataProvider'

class Updater
private 
    @@DIM = 6;
    @@WEBSITE = "http://www.taiwanlottery.com.tw/Lotto/Lotto649/history.aspx"
	@@tag_epi = "_L649_DrawTerm"
    @@tag_draw = ["_No1", "_No2", "_No3", "_No4", "_No5", "_No6"]
    @@tag_draw_span_id = "Lotto649Control_history_dlQuery_No"
    @@tag_sp = "Lotto649Control_history_dlQuery_SNo_"

    #--------------------------------------------------------------//
public    
    def initialize(sType)
        @sType = sType
        
        @is_connect_success = false
        @latest_10s = []
		@src_code = []
        
        case (sType)
            when "649"
                @url = "http://www.taiwanlottery.com.tw/Lotto/Lotto649/history.aspx"
            else
                @url = "http://www.taiwanlottery.com.tw/Lotto/Lotto649/history.aspx"
        end

		begin
			puts "Connect #{@url} ..."
			f = open(@url)
			@src_code = f.readlines
			@is_connect_success = true
		rescue OpenURI::HTTPError => e
			puts "Connect #{url} fail, msg:#{e.message}"
			#puts "raise OpenURI::HTTPError"
			#raise e
			@is_connect_success = false
		rescue Exception => e
			puts "raise Exception: #{e.message}"
			#raise e
			@is_connect_success = false
		ensure
			#puts "ensure-clause"
			puts "is_connect_success = #{@is_connect_success}"
		end
    end

    def get_connection_status
        return @is_connect_success
    end

    def get_latest
        start = 0
        stop = 0
        is_6_num_done = false #因為識別字一樣
        tmp = nil;
        is_access_done = true
        if(@is_connect_success)
            case(@sType)
                when "649"
                    @src_code.each { |tmpstr|
                        if(tmp == nil)
                            tmp = Bean.new
                            is_access_done = false
                        end
                        
                        if (tmpstr.include?(@@tag_epi))
                            start = tmpstr.index(@@tag_epi) + @@tag_epi.length + 4
                            stop = start + 9
                            #puts "epi_num: #{tmpstr.slice(start, stop)}"
                            tmp.setEpi(tmpstr.slice(start, 9))
                            next
                        elsif (tmpstr.include?(@@tag_sp)  &&  is_6_num_done)
                            start = tmpstr.index(@@tag_sp) + @@tag_sp.length + 3
                            stop = start + 2
                            #System.out.println("special: " + tmpstr.substring(start, stop));
                            tmp.setSpecialNum(tmpstr.slice(start, stop).to_i)

                            # Complete 1 data.
                            is_6_num_done = false
                            @latest_10s.insert(0, tmp) #v.add(0, tmp);
                            tmp = nil
                            is_access_done = true
                            next
                        else
                            if (tmpstr.include?(@@tag_draw_span_id)) 
                                for i in 0...@@DIM
                                    if (tmpstr.include?(@@tag_draw[i]))
                                        start = tmpstr.index(@@tag_draw[i]) + @@tag_draw[i].length + 4
                                        stop = start + 2
                                        # System.out.printf("號碼[%d]: %s\n", i, tmpstr.substring(start, stop));
                                        tmp.setDrawNum(i, tmpstr.slice(start, stop).to_i)
                                        
                                        is_6_num_done = true if (i == @@DIM-1)
                                        
                                        break
                                    end
                                end
                            end
                        end
                    }
                    puts "latest_10s=#{@latest_10s}"
                else
                    put "#{@sType} not valid"
            end
        else
            puts "#{@url} not valid"
        end
        
        return @latest_10s
    end
    
end

## debug
#u = Updater.new("649")
#u.get_latest
