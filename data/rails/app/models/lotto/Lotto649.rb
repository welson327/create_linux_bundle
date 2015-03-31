require 'open-uri'
require_relative 'LOTTO'
require_relative 'Bean'
require_relative 'DataProvider'
require_relative 'Updater'

class Lotto649 < LOTTO
    private 
    @@DIM = 6;
    @@WEBSITE = "http://www.taiwanlottery.com.tw/Lotto/Lotto649/history.aspx"
	@@id_epi = "_L649_DrawTerm"
    @@id_draw = ["_No1", "_No2", "_No3", "_No4", "_No5", "_No6"]
    @@id_sp = "_No"
    @@is_update_success = false;

    #--------------------------------------------------------------//
    public  
    @@SERVER_DATA_NUM = 10;
    @@latest_10s = [];

    def self.SERVER_DATA_NUM
        return @@SERVER_DATA_NUM
    end
    def self.latest_10s
        return @@latest_10s
    end


    #~ public
    #~ def get_web_code(url)
        #~ #f = open(url)
        #~ #@web_code = f.readlines
        #~ 
		#~ @web_code = []
		#~ rslt = false
#~ 
		#~ begin
			#~ f = open(url)
			#~ @web_code = f.readlines
			#~ rslt = true
		#~ rescue OpenURI::HTTPError => e
			#~ puts "Connect #{url} fail, msg:#{e.message}"
			#~ #puts "raise OpenURI::HTTPError"
			#~ #raise e
			#~ rslt = false
		#~ rescue Exception => e
			#~ #puts "raise Exception"
			#~ #raise e
			#~ rslt = false
		#~ ensure
			#~ #puts "ensure-clause"
		#~ end
		#~ 
		#~ return rslt
    #~ end
    
    
    private 
    def self.combine_data
        idx = 0  # web db latest index
        new_len = @@data.length
        tmp = @@latest_10s[-1]
        web_epi = ""
        
        # find new db len
        for i in 0...@@SERVER_DATA_NUM
            tmp = @@latest_10s[i]
            web_epi = LOTTO._EPI_NUM(tmp.getEpi)
            if(web_epi > @@data[-1].getEpi)
                new_len += (@@SERVER_DATA_NUM - i)
                idx = i
                break
            end
        end

        puts "[#{@name}] before update: curr_data.length = #{@@curr_data.length}"
        if(new_len == @@data.length)
            @@curr_data = @@data
            return
        else
            @@curr_data = []
            #@@curr_data.clear
        
            # def db
            for i in 0...@@data.length
                @@curr_data[i] = @@data[i]
            end

            # web db
            for j in 0...@@SERVER_DATA_NUM-idx
                @@curr_data[@@data.length + j] = @@latest_10s[idx + j]
            end
        end
        puts "[#{@name}] after update: curr_data.length = #{@@curr_data.length}"
    end  
    
    public 
    def self.get_update_status
        return @@is_update_success
    end
    
    
    # implements
    public 
    def update
        @name = "649"

        updater = Updater.new("649")
        @@latest_10s = updater.get_latest

=begin
        v = @@latest_10s
        tmpstr = ""

        # open stream
        @@is_update_success = get_web_code(@@WEBSITE)
        
        # parse
        start = 0
        stop = 0
        is_6_num_done = false; #因為識別字一樣
        tmp = nil;
        is_access_done = true;
        
        #while((tmpstr=br.readLine()) != null)
        @web_code.each do |tmpstr|
        
            if(tmp == nil)
                tmp = Bean.new
                is_access_done = false
            end
            
            if (tmpstr.include?(@@id_epi))
                start = tmpstr.index(@@id_epi.to_s) + @@id_epi.to_s.length + 2
                stop = start + 9
                #puts "epi_num: #{tmpstr.slice(start, stop)}"
                tmp.setEpi(tmpstr.slice(start, 9))
                next
            elsif (tmpstr.include?(@@id_sp)  &&  is_6_num_done)
                start = tmpstr.index(@@id_sp.to_s) + @@id_sp.to_s.length + 2
                stop = start + 2
                #System.out.println("special: " + tmpstr.substring(start, stop));
                tmp.setSpecialNum(tmpstr.slice(start, stop).to_i)

                # Complete 1 data.
                is_6_num_done = false
                v.insert(0, tmp) #v.add(0, tmp);
                tmp = nil
                is_access_done = true
                next
            else
                for i in 0...@@DIM
                    if (tmpstr.include?(@@id_draw[i]))
                        start = tmpstr.index(@@id_draw[i].to_s) + @@id_draw[i].to_s.length + 2
                        stop = start + 2
                        # System.out.printf("號碼[%d]: %s\n", i, tmpstr.substring(start, stop));
                        tmp.setDrawNum(i, tmpstr.slice(start, stop).to_i)
                        
                        is_6_num_done = true if (i == @@DIM-1)
                        
                        break
                    end
                end
            end
        end
=end        
        
        @@is_update_success = updater.get_connection_status

        if(@@is_update_success == true)
            Lotto649.combine_data
            return 1
        else
            @@curr_data = @@data
            return 0
        end
    end 
    
    # default db version
    public 
    def self.def_db_version
        return @@data[-1].getEpi()
    end
    
    public 
    def self.curr_db_version
        if (@@is_update_success)
            return @@curr_data[-1].getEpi
        else
            return def_db_version
        end
    end  
    
    
    public
    @@data = DataProvider.new("#{Rails.root}/app/models/lotto/data" +  File::SEPARATOR + "649.txt").get_data
    @@curr_data = @@data 
    
    def self.curr_data
        return @@curr_data
    end
end
