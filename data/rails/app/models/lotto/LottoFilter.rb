require 'set'
require_relative 'LOTTO'
require_relative 'LottoUtil'
require_relative 'LottoStatistics'

# ========================================================
# Purpose:		Filter不用管什麼號碼該濾、什麼號碼該包含...，只管濾的規則介面
#               剩下的交給LottoStatistics
# Parameter:    
# Return:      
# Remark:       
# Revision:
# ========================================================
class LottoFilter
protected 
    @@FILTER_RATE = 88;      # 參考 check_is_prev_train_or_again()函數
    @@FILTER_DIM = 16;
    @@SERVER_DATA_NUM = 10;
    @@NEAR_DATA_DIM = 24;
    
    @@GH_GAMES_OUT = 5;      # GH = Gail Howard
    
public    
    def initialize(stat)
        @statistics = stat
        @lotto = LOTTO.new
        
        reset(@statistics)      
    end
    
    def DBG(msg)
		puts "[#{__FILE__}][#{__LINE__}] #{msg}"
    end
    
    def reset(stat)
		@statistics = stat
        
        h = @statistics.get_statistics
        @filtered_data          = h[:filtered_data]
        @near_data              = h[:near_data]
        @skip_acc               = h[:skip_acc]
        @skip_numbers_eq_1      = h[:skip_numbers_eq_1]
        @skip_numbers_eq_2      = h[:skip_numbers_eq_2]
        @skip_numbers_btw_1_4   = h[:skip_numbers_btw_1_4]
        @skip_numbers_btw_5_10  = h[:skip_numbers_btw_5_10]
        @skip_numbers_gt        = h[:skip_numbers_gt]
        @skip_numbers_gt_4      = h[:skip_numbers_gt_4]
        @skip_numbers_gt_14     = h[:skip_numbers_gt_14]
        @skip_numbers_le        = h[:skip_numbers_le]
        @minus_data             = h[:minus_data]
        
        @latest_10s_data        = h[:latest_10s]
    end
    # ========================================================
    # Purpose:      
    # Parameter:   int[] selected_num, int len
    # Return:      double
    # Remark:      
    # Revision:
    # ========================================================    
    def pass_rate(selected_num, len)
        # to be overrided
    end
    
    # ========================================================
    # Purpose:      
    # Parameter:   int[] selected_num, int len
    # Return:      double
    # Remark:      
    # Revision:
    # ========================================================    
    def is_logical(selected_num, len)
        # to be overrided
    end

    # ========================================================
    # Purpose:	   近 N 期內，出現cnt次的號碼
    # Parameter:   is_permit_again=true時: 允許連莊
    # Return:      
    # Remark:      
    # Revision:
    # ======================================================== 
    def get_numbers_of_arising_in_N_run(n_run, cnt, is_permit_again)
        draws = []
        output = []

        total = @curr_data.length - _get_drop_number()
        start = (total - n_run + 1)>=0 ? (total - n_run + 1) : 0
        stop = total
        data = @curr_data # website data for default DB
        
        if !is_permit_again
			stop = stop - 1
		end
        for j in start...stop
			draws += data[j].getDrawNum
            #puts "222>> [#{data[j].getEpi}] #{data[j].getDrawNum}"
        end
        
        draws.each {|v| 
			output << v if draws.count(v) == cnt - 1
		}
		output.sort!.uniq!
		
		puts "get_numbers_of_arising_in_#{n_run}_run(#{cnt},#{is_permit_again}) = #{output}"
        return output
    end



    # ========================================================
    # Purpose:		確認result[]中，在 N 期內是否重複 M 碼
    # Parameter:    int[] result, int N_run, int M_num
    # Return:       1 if yes, otherwise 0
    # Remark:      
    # Revision:
    # ========================================================
    def check_is_N_run_M_num(result, n_run, m_num)
        
        return 0 if result == nil
		
        # if(n_run > SERVER_DATA_NUM) { # check_history() use it!
			# return 0;
		# }

        rpt_cnt = 0
        total = @curr_data.length - _get_drop_number()
        start = (total - n_run)>=0 ? (total - n_run) : 0
        stop = total
        data = @curr_data # website data for default DB

        for j in start...stop
            #~ for i in 0...@lotto.dim
                #~ for k in 0...@lotto.dim
                    #~ if(result[k] == data[j].getDrawNum(i))
                        #~ rpt_cnt += 1
                        #~ break
                    #~ end
                #~ end
            #~ end
            rpt_cnt = (result & data[j].getDrawNum()).size
            
            if(rpt_cnt >= m_num)
                if(false)
                    puts ">>> #{n_run} run repeats #{m_num} num."
                    p result
                    p @latest_10s_data
                end
                return 1
            else
                rpt_cnt = 0
            end
        end
            
        return 0
    end

    # ========================================================
    # Purpose:		確認result[]是否和歷史重複
    # Parameter:    int result[]
    # Return:       1 if yes, otherwise 0
    # Remark:       是「在 N 期內是否重複 M 碼」的特例
    # Revision:
    # ========================================================
    def check_is_history(result)
        return 0 if(result == nil)
        
        total = @curr_data.length - _get_drop_number()
        if(check_is_N_run_M_num(result, total, @lotto.dim - 1) == 1)
            return 1
        else
            return 0
        end
    end
    
    # ========================================================
    # Purpose:		遺漏次數>10者，至少要含一碼(89%)
    #              遺漏次數<=5者，至少要含二碼()
    # Parameter:   int result[]
    # Return:      boolean
    # Remark:      
    # Revision:
    # ========================================================
    def check_include_skip_number(result)
        has_gt_skip = false
        has_le_skip = false
        
        return false if(result == nil)
        
        if(LottoUtil.check_repeats(@skip_numbers_gt, result) > 0)
            has_gt_skip = true
        end
        if(LottoUtil.check_repeats(@skip_numbers_le, result) >= 3)
            has_le_skip = true
        end

        return has_gt_skip && has_le_skip
    end
        
    # ========================================================
    # Purpose:		上期特別號不再開出(機率90%)
    # Parameter:   
    # Return:      1: is repeated
    # Remark:      only for 649
    # Revision:
    # ========================================================
    def check_include_prev_special(result)
        # 上期特別號
        prev = @latest_10s_data[@@SERVER_DATA_NUM - 1]
        special = prev.getSpecialNum
                    
        if(LottoUtil.check_is_repeat(result, special) == 1)
            return 1
        else
            return 0
        end
    end


    # ========================================================
    # Purpose:		上期連號or四期內連莊, 則下期不可再開出
    # Parameter:   rate: 100代表100%回報，82代表82%回報 
    # Return:      1: is repeated
    # Remark:      因為加了一些規則，會有機率考慮(若只是單純比較是否有重複，rate=100)
    #              (1) 上期連號，這期又開出其中之一的機率約18% (099-100期統計)
    #              (2) 四期內曾經連莊，且四期內又再開出的機率約14%(不是連三莊)(100011-100088)
    #              (3) 綜合上述，機率約12%，即rate = 88
    # Revision:
    # ========================================================
    # old version
    def check_is_prev_train_or_again(value, rate)
        filter = @filtered_data
        return LottoUtil.check_is_repeat(filter, @@FILTER_DIM, value)
    end
    # new version
    def check_is_prev_train_or_again_by_array(result, rate)
        is_repeat = 0
        filter = @filtered_data
            
        for i in 0...@lotto.dim
            is_repeat = LottoUtil.check_is_repeat(filter, result[i])
            
            if(is_repeat == 1)
                break
            end
        end

        return is_repeat;
    end

    # ========================================================
    # Purpose:     確認間距
    # Parameter:   for [10,15,21,28,36,45]
    #                return 10 if is_consider_side = ture  
    #                return  9 if is_consider_side = false
    # Return:      
    # Remark:      
    # Revision:
    # ========================================================
    def check_max_interval(arr, is_consider_side)
        # to be override
        return 1
    end
    
    # ========================================================
    # Purpose:		以BW=5的方式, 確認arr[]中是否在上期開獎號的附近的次數
    # Parameter:   len: length of arr
    # Return:      BW區內附近次數 
    # Remark:      會使用此函數代表 check_near_num() == 0 時
    # Revision:
    # ========================================================
    def check_near_num_in_bw5(arr, len)
        return 0 if arr == nil
        return (arr & @near_data_in_bw5).size
    end

    # ========================================================
    # Purpose:		確認arr[]中，否在上期開獎號隔壁的次數
    # Parameter:   
    # Return:      BW區內附近次數 
    # Remark:      
    # Revision:
    # ========================================================
    def check_near_num(arr, len_of_arr)
        return 0 if arr == nil
        return (arr & @near_data).size
    end

    # ========================================================
    # Purpose:		確認result[]和上期號碼重複數
    # Parameter:    int[] result
    # Return:      重複碼數
    # Remark:      
    # Revision:
    # ========================================================
    def check_repeat_by_prev(result)
        return 0 if result == nil

		prev_num = @latest_10s_data[@@SERVER_DATA_NUM-1].getDrawNum();
        return (result & prev_num).size
    end

    # ========================================================
    # Purpose:     確認歷史中，N期內重複M碼的次數 (ex: 歷史中,4期內曾開出3碼相同的次數)
    # Parameter:   
    # Return:       int
    # Remark:      歷史資料數自動默認
    #              ex: 上期開 [1,2,3,4,5,6], 四期內開出三碼重複, 
    #                  如[1,2,3,41,45,46], [11,22,33,4,5,6], ..., etc.
    #              Welson觀察: 
    #                  4期內重複開出一模一樣的3碼，幾乎很低!
    #                  此預測和 "不可與歷史開出相同號碼" 的概念很像                
    # Revision:
    # ========================================================
    def check_history_N_run_M_num_cnt(n_run, m_num)
        total = @curr_data.length - _get_drop_number()
        start_index = n_run
        cnt = 0
 
        for i in start_index...total    #確認歷史之中
            for j in 1...n_run          #n_run期內 (含第i期本身)
                #~ for n in 0...@lotto.dim        #重複m_num
                    #~ for m in 0...@lotto.dim
                        #~ if(@curr_data[i].getDrawNum(m) == @curr_data[i-j].getDrawNum(n))
                            #~ tmp_cnt += 1
                            #~ break;
                        #~ end
                    #~ end
                #~ end
                
                if((@curr_data[i].getDrawNum() & @curr_data[i-j].getDrawNum()).size >= m_num)
                    cnt += 1
                    break
                end
            end
        end
            
        return cnt
    end

    # ========================================================
    # Purpose:     確認N期內連號的次數
    # Parameter:   
    # Return:
    # Remark:      
    # Revision:
    # ========================================================
    def check_N_run_serial_cnt(n_run)
        total = @curr_data.length - _get_drop_number()
        start_index = (total - n_run)>=0 ? (total - n_run) : 0
        cnt = 0

        for i in start_index...total    #確認N期內
            if(LottoUtil.check_is_train(@curr_data[i].getDrawNum()) == 1)
                cnt += 1
            end
        end
            
        return cnt
    end
    
=begin
    def get_query_data
        h = {}
        h[:filtered_data] = @filtered_data
        h[:near_data] = @near_data
        h[:skip_acc] = @skip_acc
        h[:skip_numbers_eq_1] = @skip_numbers_eq_1
        h[:skip_numbers_eq_2] = @skip_numbers_eq_2
        h[:skip_numbers_btw_1_4] = @skip_numbers_btw_1_4
        h[:skip_numbers_btw_5_10] = @skip_numbers_btw_5_10
        h[:skip_numbers_gt] = @skip_numbers_gt
        h[:skip_numbers_gt_4] = @skip_numbers_gt_4
        h[:skip_numbers_gt_14] = @skip_numbers_gt_14
        h[:skip_numbers_le] = @skip_numbers_le
        h[:minus_data] = @minus_data
        return h
    end

    # ========================================================
    # Purpose:     被濾掉的number: 4期內的連莊 & 上期的連號
    # Parameter:   
    # Return:
    # Remark:
    # Revision:
    # ========================================================
    
    def query_filter_data
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
        puts "[#{@lotto.name}] repeat number in 4 games: #{@filtered_data[0...m]}"
        
        
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
        puts "[#{@lotto.name}] serial number in prev games: #{@filtered_data[m..-1]}"
    end

    # ========================================================
    # Purpose:     bw=3 時，找左右距離為1的；bw=5時，找左右距離為2的, 結果存於arr
    # Parameter:   
    # Return:
    # Remark:
    # Revision:
    # ========================================================
    public 
    def query_near_data_at_dist(bw, arr, len_of_arr)
        #~ int index = 0;
        #~ int dist;
        #~ int left, right;
        #~ int draw = 0;
        #~ int i, k;
        
        return if arr == nil
        bw = 3 if( !(bw == 3  ||  bw == 5) ) # not 3 or 5

        
        arr.clear #LottoUtil.init_array(arr, len_of_arr);
        dist = (bw-1)/2;

        index = @@SERVER_DATA_NUM - 1;
        
        #k = 0;
        lotto_range = 1..@lotto.range
        
        for i in 0...@lotto.dim
            draw = @latest_10s_data[index].getDrawNum(i);
            left = draw - dist;
            right = draw + dist;
            
            #if(left>=1  &&  left<=@lotto.range)
            if lotto_range === left
                if(LottoUtil.check_is_repeat(arr, left) == 0)
                    arr << left
                end
            end
            if lotto_range === right
                if(LottoUtil.check_is_repeat(arr, right) == 0)
                    arr << right
                end
            end
        end
    end

    # ========================================================
    # Purpose:     Gail Howard: 下期至少有1~2碼是上期的鄰號
    # Parameter:   
    # Return:
    # Remark:
    # Revision:
    # ========================================================
    public 
    def query_near_data
        bw = 3
        query_near_data_at_dist(bw, @near_data, @@NEAR_DATA_DIM)

        bw = 5
        query_near_data_at_dist(bw, @near_data_in_bw5, @@NEAR_DATA_DIM)

        #check
        if(true)
            puts "[#{@lotto.name}] near data: #{@near_data}"
        end
    end
    
    # ========================================================
    # Purpose:     找出遺漏> 10的號碼
    # Parameter:   
    # Return:
    # Remark:
    # Revision:
    # ========================================================
    public 
    def query_skip_data
        cnt = 0
        len = 0
        end_index = @curr_data.length - _get_drop_number() - 1
        is_found = false;
        
        for i in 1..@lotto.range
            while(cnt < end_index)
                for k in 0...@lotto.dim
                    if(i == @curr_data[end_index-cnt].getDrawNum(k))
                        is_found = true
                        break
                    end
                end
                
                if(is_found)
                    len += 1
                    @skip_acc[i-1] = cnt
                    cnt = 0
                    is_found = false
                    break
                else
                    cnt += 1
                end
            end
        end
        
        
        # skip numbers
        @skip_numbers_eq_1.clear
        @skip_numbers_eq_2.clear
        @skip_numbers_btw_1_4.clear
        @skip_numbers_btw_5_10.clear
        @skip_numbers_gt.clear
        @skip_numbers_gt_4.clear
        @skip_numbers_gt_14.clear
        @skip_numbers_le.clear
        for i in 0...@lotto.range
            # my variant base on Gail Howard
            if(@skip_acc[i] <= 2)
                @skip_numbers_le << i+1
            end
            
            # Welson
            if(@skip_acc[i] == 1)
                @skip_numbers_eq_1 << i+1
            end
            if(@skip_acc[i] == 2)
                @skip_numbers_eq_2 << i+1
            end
            if (1..4) === @skip_acc[i]
                @skip_numbers_btw_1_4 << i+1
            end
            if (5..10) === @skip_acc[i]
                @skip_numbers_btw_5_10 << i+1
            end
            if(@skip_acc[i] > 14)
                @skip_numbers_gt_14 << i+1
            end
            if(@skip_acc[i] > @skip_avg)
                @skip_numbers_gt << i+1
            end
            if(@skip_acc[i] > 4)
                @skip_numbers_gt_4 << i+1
            end
        end


        # check
        if(true)
            #printf("[#{@lotto.name}] skip data: ")
            #@skip_acc.each_with_index{|v,i|
            #    printf("##{i+1}(#{v}) ")
            #}
            #printf("\n")
            
            printf("[#{@lotto.name}] skip number(sorting): ")
            skip_sorting = @skip_acc.each_with_index.sort_by{|v| -v[0]}
            skip_sorting.each{|v,i|
                printf("##{i+1}(#{v}) ")
            }
            printf("\n")            
            
            printf("[#{@lotto.name}] skip number(<=2): ")
            p @skip_numbers_le
            
            printf("[#{@lotto.name}] skip number(1~4): ")
            p @skip_numbers_btw_1_4
            
            printf("[#{@lotto.name}] skip number(5~10): ")
            p @skip_numbers_btw_5_10
            
            printf("[#{@lotto.name}] skip number(>#{@skip_avg}): ")
            p @skip_numbers_gt
            
            #printf("[#{@lotto.name}] skip number(>4): ")
            #p @skip_numbers_gt_4
            
            printf("[#{@lotto.name}] skip number(>14): ")
            p @skip_numbers_gt_14
        end
    end
    
    def query_minus_data
        n = 7
        h = {}
        draws = nil
        
        for i in 0...n
            draws = (@latest_10s_data[-i-1].getDrawNum + 
                    [@latest_10s_data[-i-1].getSpecialNum]).sort
            for j in 1...draws.size
                v = draws[j] - draws[0]
                h[v] = v
            end
        end
        
        @minus_data.clear
        h.values.each{|elem| @minus_data << elem}
        @minus_data.sort!
        
        printf("[#{@lotto.name}] minus data(within #{n} games): ")
        p @minus_data
    end
    
    


    def reset_filter()
        @curr_data = Lotto649.curr_data # maybe new another memory
        start = (@curr_data.length - @@SERVER_DATA_NUM) - _get_drop_number()
        for i in 0...@@SERVER_DATA_NUM
            @latest_10s_data[i] = @curr_data[start + i]
        end
        
        query_filter_data()
        query_near_data()
        query_skip_data()
        #query_minus_data()
    end
=end

private
	def _get_drop_number
		@statistics.get_drop_number
	end

    
    
end

