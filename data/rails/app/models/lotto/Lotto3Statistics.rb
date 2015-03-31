require_relative 'LOTTO'
require_relative 'Bean'
require_relative 'LottoUtil'
#require_relative 'Lotto649'
#require_relative 'Lotto539'
require_relative 'Lotto3'

# ========================================================
# Purpose:	    很多資料與函數很難分類，設計如下:
#               (1) 現有資料經統計與分析後的東西都放此類別
#               (2) 和drop_number有關的API也放此類別
# Parameter:   
# Return:      
# Remark:      
# Revision:
# ========================================================
class Lotto3Statistics
    @@SERVER_DATA_NUM = 10
    @@NEAR_DATA_DIM = 16
    
    @@L649 = LOTTO.new
        @@L649.name = "649"
        @@L649.dim = 6
        @@L649.range = 49
    @@L539 = LOTTO.new
        @@L539.name = "539"
        @@L539.dim = 5
        @@L539.range = 39
    @@L3 = LOTTO.new
        @@L3.name = "3"
        @@L3.dim = 3
        @@L3.range = 9
    
    def initialize(db_data, base_n, lotto_name)
        @drop_number = 0
        @base_n = base_n            #100
        
        @skip_avg = 11
        @curr_data = db_data        # ex: Lotto649.curr_data
        
        
        case lotto_name
            when "649"
                @lotto = @@L649
            when "539"
                @lotto = @@L539
            when "3"
                @lotto = @@L3
        end


        @acc_data = []
        #@acc_data_of_next = Hash.new(0)
        @acc_from_to = {}           # hash: [:from=>"102001", :to=>"102101"]
        @acc_halfvalue = []
        
        #~ @filtered_data = [];        # 濾掉的數字
		#~ @near_data = [];            # 上期號碼的附近，經常在下期出現
		#~ @near_data_in_bw5 = [];
		@skip_acc = [];
		#~ @skip_numbers_eq_1 = [];    # eq = equal
		#~ @skip_numbers_eq_2 = [];        
		#~ @skip_numbers_btw_1_4 = []; # btw = between   
		#~ @skip_numbers_btw_5_10 = [];
		#~ @skip_numbers_gt = [];      # 遺漏 > skip_avg 的號碼(gt = greater than)
		#~ @skip_numbers_gt_4 = [];
		#~ @skip_numbers_gt_14 = [];
		#~ @skip_numbers_le = [];      # Gail Howard's 'Games Out', le = less than or equal
        #~ @minus_data = [];           # 近幾期內，每個號碼減去最小號的值

        # rate 
        
        
        @latest_10s_data = []
        
        calc(@drop_number)
    end
    
    def calc(drop_number)
        @drop_number = drop_number
        calc_rate
        calc_latest_detail
    end
    
    def calc_rate
    end
    
    def calc_latest_detail
        start = (@curr_data.length - @@SERVER_DATA_NUM) - get_drop_number()
        for i in 0...@@SERVER_DATA_NUM
            @latest_10s_data[i] = @curr_data[start + i]
        end

        get_acc_data
        query_skip_data
    end     
    
    def report
        report_rate
        report_latest_detail
    end
    
    def report_rate
        #printf("[%s] 4_run_repeat_1_num rate = %.2f\n", @lotto.name, @rate_of_4_run_repeat_1_num);
    end

    def report_latest_detail
        puts "[3star]"
		puts "acc from #{@acc_from_to[:from]} to #{@acc_from_to[:to]}, base=#{@base_n}:"
            p @acc_data
        puts "acc.max = #{@acc_data.collect{|v| v.max}}"
        puts "half of acc.max = #{@acc_halfvalue}"
        puts "skip_acc = #{@skip_acc}"
    end
    
    # ========================================================
    # Purpose:		設定捨棄目前資料最後num筆
    # Parameter:    int num
    # Return:      
    # Remark:      Should call reset_filter() again
    # Revision:
    # ========================================================    
    def set_drop_number(val)
        @drop_number = val
    end
    def get_drop_number
        @drop_number
    end
    
    def get_statistics
        h = {}
        h[:acc_data] = @acc_data
        h[:acc_from] = @acc_from_to[:from]
        h[:acc_to] = @acc_from_to[:to]
        h[:acc_len] = @acc_from_to[:len]
        h[:acc_halfvalue] = @acc_halfvalue

        h[:skip_acc] = @skip_acc
        
        h[:latest_10s] = @latest_10s_data
        
        return h
    end
    
    # ========================================================
    # Purpose:		
    # Parameter:   prev_step=0 means last game of DB
    # Return:      Bean
    # Remark:      
    # Revision:
    # ========================================================    
    def get_prev_game(prev_step)
        index = @curr_data.length - 1 - prev_step - get_drop_number
        
        if(index >= 0)
            return @curr_data[index]
        else
            return nil
        end
    end
    
    # ========================================================
    # Purpose:		
    # Parameter:   
    # Return:      Bean
    # Remark:      
    # Revision:
    # ========================================================     
    def get_last_game
        index = @curr_data.length - 1 - get_drop_number
        
        if(index >= 0)
            return @curr_data[index]
        else
            return nil
        end
    end    
    
private
    ##----------------------------------------------------------------------##


    def get_acc_data
        #base = 99;#民國99年
        data_num = 0;
        stop = @curr_data.length - get_drop_number
        start = stop - @base_n

        @acc_from_to[:from] = @curr_data[start].getEpi
        @acc_from_to[:to] = @curr_data[stop-1].getEpi
        @acc_data = Array.new(@lotto.dim) { Array.new(10, 0) }
        
        for k in start...stop
            for i in 0...@lotto.dim
                num = @curr_data[k].getDrawNum(i)
                if(num >= 0)
                    @acc_data[i][num] += 1
                end
            end
            data_num += 1
        end
        @acc_from_to[:len] = data_num
        
        0.upto(@lotto.dim-1) do |i|
            @acc_halfvalue.push(@acc_data[i].max / 2.to_f)
        end
    end
    
    # ========================================================
    # Purpose:     被濾掉的number: 4期內的連莊 & 上期的連號
    # Parameter:   
    # Return:
    # Remark:
    # Revision:
    # ========================================================
    def query_filtered_data
        #~ int i, j, k;
        #~ int m;
        #~ int start, len;
        #~ int total;
        
        #LottoUtil.init_array(@filtered_data, @@FILTER_DIM)
        @filtered_data.clear
        
        #------------------------------------------------------
        total = @@SERVER_DATA_NUM
        start = total - 4
        m = 0

        for i in start...total-1          # 四期內, total-1 是因為每次比較兩期
            # 尋找兩期重複號(要比對dim*dim次)
            #~ for j in 0...@lotto.dim
                #~ for k in 0...@lotto.dim
                    #~ if(latest_10s_data[i].getDrawNum(j) == latest_10s_data[i+1].getDrawNum(k))
                        #~ @@filtered_data[m] = latest_10s_data[i].getDrawNum(j);
                        #~ m += 1
                    #~ end
                #~ end
            #~ end
            (@latest_10s_data[i].getDrawNum() & @latest_10s_data[i+1].getDrawNum()).each {|x| @filtered_data << x}
        end
        m = @filtered_data.length
        #puts "[#{@lotto.name}] repeat number in 4 games: #{@filtered_data[0...m]}"
        
        
        #最近一期出現連續的號碼
        start = total - 1;
        for i in start...total
            for j in 0...@lotto.dim-1
                if(@latest_10s_data[i].getDrawNum(j) == @latest_10s_data[i].getDrawNum(j+1) - 1)
                    @filtered_data << @latest_10s_data[i].getDrawNum(j)
                    @filtered_data << @latest_10s_data[i].getDrawNum(j+1)
                    #~ filtered_data[m] = latest_10s_data[i].getDrawNum(j);
                    #~ m += 1
                    #~ filtered_data[m] = latest_10s_data[i].getDrawNum(j+1)
                    #~ m += 1
                    #~ j += 1
                end
            end
        end
        
        @filtered_data.uniq!
        #puts "[#{@lotto.name}] serial number in prev games: #{@filtered_data[m..-1]}"
    end

    def query_skip_data
        cnt = 0
        end_index = @curr_data.length - get_drop_number() - 1
        is_found = false;
        
        @skip_acc.clear
        
        for i in 0...@lotto.dim
            arr = []
            0.upto(@lotto.range) do |num|
                while(cnt < end_index)
                    if(num == @curr_data[end_index-cnt].getDrawNum(i))
                        arr.push(cnt)
                        cnt = 0
                        break
                    else
                        cnt += 1
                    end
                end
            end
            @skip_acc.push(arr)
        end
    end
    

    
  
end

## debug
=begin
lotto3 = Lotto3.new
stat = Lotto3Statistics.new(lotto3.curr_data, 100, "3")
stat.report
=end
