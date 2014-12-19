require_relative 'LOTTO'
require_relative 'Bean'
require_relative 'LottoUtil'
require_relative 'Lotto649'
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
class LottoStatistics
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
        #@lotto.def_db_ver = Lotto649.def_db_version()
        #@lotto.curr_db_ver = Lotto649.curr_db_version()
    
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


        @acc_data = Array.new(@lotto.range, 0)
        @acc_data_of_next = Hash.new(0)
        @acc_from_to = {}           # hash: [:from=>"102001", :to=>"102101"]
        @acc_halfvalue = 0.0
        
        @filtered_data = [];        # 濾掉的數字
		@near_data = [];            # 上期號碼的附近，經常在下期出現
		@near_data_in_bw5 = [];
		@skip_acc = [];
		@skip_numbers_eq_1 = [];    # eq = equal
		@skip_numbers_eq_2 = [];        
		@skip_numbers_btw_1_4 = []; # btw = between   
		@skip_numbers_btw_5_10 = [];
		@skip_numbers_gt = [];      # 遺漏 > skip_avg 的號碼(gt = greater than)
		@skip_numbers_gt_4 = [];
		@skip_numbers_gt_14 = [];
		@skip_numbers_le = [];      # Gail Howard's 'Games Out', le = less than or equal
        @minus_data = [];           # 近幾期內，每個號碼減去最小號的值



        # rate of N_run_repeat_M_num
        @rate_of_4_run_repeat_1_num = 0.0
        @rate_of_5_run_repeat_1_num = 0.0
        @rate_of_4_run_repeat_2_num = 0.0
        @rate_of_5_run_repeat_2_num = 0.0
        @rate_of_6_run_repeat_2_num = 0.0
        @rate_of_4_run_repeat_3_num = 0.0
        @rate_of_5_run_repeat_3_num = 0.0
        
        @rate_of_serial = 0.0
        @rate_of_7_array = 0.0
        @rate_of_tail_intersection = 0.0
        
        @rate_of_neighbors_of_1th_of_prev_appears_in_next = 0.0
        @rate_of_neighbors_of_2th_of_prev_appears_in_next = 0.0
        @rate_of_neighbors_of_3th_of_prev_appears_in_next = 0.0
        @rate_of_neighbors_of_4th_of_prev_appears_in_next = 0.0
        @rate_of_neighbors_of_5th_of_prev_appears_in_next = 0.0
        @rate_of_neighbors_of_6th_of_prev_appears_in_next = 0.0
        
        # {二合}: 第一區|第二區連續開出任2碼，之後的第四期又開出同一區有2碼的機率
        @rate_of_SuccessAttack_for_repeated_nthOf7Area_after3games = []
        
        # rate of Data-Independency
        @rate_of_DI = 0.0
        @distribution_of_7areas = []
        @rate_of_empty_of_7areas = 0.0
        @rate_of_empty_of_6areas = 0.0
        @rate_of_gte2draws_insameof7areas_in2games = 0.0 # 上期在7分區中的某區開出2碼，這期又再同區開出的機率
        
        @latest_10s_data = []
        
        calc(@drop_number)
    end
    
    def calc(drop_number)
        @drop_number = drop_number
        calc_rate
        calc_latest_detail
    end
    
    def calc_rate
        # rate of N_run_repeat_M_num
        history_cnt = check_history_N_run_M_num_cnt(4, 1)
        @rate_of_4_run_repeat_1_num = history_cnt.to_f/(@curr_data.length - get_drop_number())
        history_cnt = check_history_N_run_M_num_cnt(5, 1)
        @rate_of_5_run_repeat_1_num = history_cnt.to_f/(@curr_data.length - get_drop_number())
        history_cnt = check_history_N_run_M_num_cnt(4, 2)
        @rate_of_4_run_repeat_2_num = history_cnt.to_f/(@curr_data.length - get_drop_number())
        history_cnt = check_history_N_run_M_num_cnt(5, 2)
        @rate_of_5_run_repeat_2_num = history_cnt.to_f/(@curr_data.length - get_drop_number())
        history_cnt = check_history_N_run_M_num_cnt(6, 2)
        @rate_of_6_run_repeat_2_num = history_cnt.to_f/(@curr_data.length - get_drop_number())
        history_cnt = check_history_N_run_M_num_cnt(4, 3)
        @rate_of_4_run_repeat_3_num = history_cnt.to_f/(@curr_data.length - get_drop_number())
        history_cnt = check_history_N_run_M_num_cnt(5, 3)
        @rate_of_5_run_repeat_3_num = history_cnt.to_f/(@curr_data.length - get_drop_number())
        
        history_cnt = check_N_run_serial_cnt(@base_n) #100期內的連號期數
        @rate_of_serial = history_cnt.to_f/@base_n
        history_cnt = check_N_run_7_array_cnt(@base_n)
        @rate_of_7_array = history_cnt.to_f/@base_n
        @rate_of_tail_intersection = rate_of_tail_intersection()
        
        @rate_of_neighbors_of_1th_of_prev_appears_in_next = rate_of_neighbors_of_nth_of_prev_appears_in_next(1)
        @rate_of_neighbors_of_2th_of_prev_appears_in_next = rate_of_neighbors_of_nth_of_prev_appears_in_next(2)
        @rate_of_neighbors_of_3th_of_prev_appears_in_next = rate_of_neighbors_of_nth_of_prev_appears_in_next(3)
        @rate_of_neighbors_of_4th_of_prev_appears_in_next = rate_of_neighbors_of_nth_of_prev_appears_in_next(4)
        @rate_of_neighbors_of_5th_of_prev_appears_in_next = rate_of_neighbors_of_nth_of_prev_appears_in_next(5)
        @rate_of_neighbors_of_6th_of_prev_appears_in_next = rate_of_neighbors_of_nth_of_prev_appears_in_next(6)
        
        @rate_of_SuccessAttack_for_repeated_nthOf7Area_after3games, 
        @attack_cnt_for_repeated_nthOf7Area_after3games =
        rate_of_SuccessAttack_for_repeated_nthOf7Area_after3games(800)
        
        # rate of Data-Independency
        #@rate_of_DI = check_rate_of_di()
        @rate_of_2empty_of_7areas = check_N_run_2empty_of_n_sections(@base_n, 2, 7).to_f/@base_n
        @rate_of_2empty_of_6areas = check_N_run_2empty_of_n_sections(@base_n, 2, 6).to_f/@base_n
        
        @rate_of_gte2draws_insameof7areas_in2games = check_N_run_gte2draws_insameof7areas_in2games(@base_n).to_f/@base_n
    end
    
    def calc_latest_detail
        start = (@curr_data.length - @@SERVER_DATA_NUM) - get_drop_number()
        for i in 0...@@SERVER_DATA_NUM
            @latest_10s_data[i] = @curr_data[start + i]
        end
        
        get_acc_data
        get_acc_data_of_next
        
        query_filtered_data
        query_near_data
        query_skip_data
        #query_minus_data
        query_7areas_distribution
    end     
    
    def report
        report_rate
        report_latest_detail
    end
    
    def report_rate
        printf("[%s] 4_run_repeat_1_num rate = %.2f\n", @lotto.name, @rate_of_4_run_repeat_1_num);
        printf("[%s] 5_run_repeat_1_num rate = %.2f\n", @lotto.name, @rate_of_5_run_repeat_1_num);
        printf("[%s] 4_run_repeat_2_num rate = %.2f\n", @lotto.name, @rate_of_4_run_repeat_2_num);
        printf("[%s] 5_run_repeat_2_num rate = %.2f\n", @lotto.name, @rate_of_5_run_repeat_2_num);
        printf("[%s] 6_run_repeat_2_num rate = %.2f\n", @lotto.name, @rate_of_6_run_repeat_2_num);
        printf("[%s] 4_run_repeat_3_num rate = %.2f\n", @lotto.name, @rate_of_4_run_repeat_3_num);
        printf("[%s] 5_run_repeat_3_num rate = %.2f\n", @lotto.name, @rate_of_5_run_repeat_3_num);
        printf("[%s] rate_of_serial = %.2f\n", @lotto.name, @rate_of_serial);
        printf("[%s] rate_of_7_array = %.2f\n", @lotto.name, @rate_of_7_array);
        printf("[%s] rate_of_tail_intersection = %.2f\n", @lotto.name, @rate_of_tail_intersection);
        printf("[%s] rate_of_neighbors_of_1th_of_prev_appears_in_next = %.2f\n", @lotto.name, @rate_of_neighbors_of_1th_of_prev_appears_in_next);
        printf("[%s] rate_of_neighbors_of_2th_of_prev_appears_in_next = %.2f\n", @lotto.name, @rate_of_neighbors_of_2th_of_prev_appears_in_next);
        printf("[%s] rate_of_neighbors_of_3th_of_prev_appears_in_next = %.2f\n", @lotto.name, @rate_of_neighbors_of_3th_of_prev_appears_in_next);
        printf("[%s] rate_of_neighbors_of_4th_of_prev_appears_in_next = %.2f\n", @lotto.name, @rate_of_neighbors_of_4th_of_prev_appears_in_next);
        printf("[%s] rate_of_neighbors_of_5th_of_prev_appears_in_next = %.2f\n", @lotto.name, @rate_of_neighbors_of_5th_of_prev_appears_in_next);
        printf("[%s] rate_of_neighbors_of_6th_of_prev_appears_in_next = %.2f\n", @lotto.name, @rate_of_neighbors_of_6th_of_prev_appears_in_next);
        puts "[#{@lotto.name}] rate_of_SuccessAttack_for_repeated_nthOf7Area_after3games = #{@rate_of_SuccessAttack_for_repeated_nthOf7Area_after3games}"
        puts "[#{@lotto.name}] attack_cnt_for_repeated_nthOf7Area_after3games = #{@attack_cnt_for_repeated_nthOf7Area_after3games}"
        #printf("[%s] rate_of_DI = %.2f\n", @lotto.name, @rate_of_DI);
        printf("[%s] rate_of_2empty_of_7areas = %.2f\n", @lotto.name, @rate_of_2empty_of_7areas);
        printf("[%s] rate_of_2empty_of_6areas = %.2f\n", @lotto.name, @rate_of_2empty_of_6areas);
        printf("[%s] rate_of_gte2draws_insameof7areas_in2games = %.2f\n", @lotto.name, @rate_of_gte2draws_insameof7areas_in2games);
        
        #puts "10-run 7-section-dist: #{@dist_of_7areas}"
    end

    def report_latest_detail
        skip_sorting = @skip_acc.each_with_index.sort_by{|v| -v[0]}
        
		puts "[#{@lotto.name}] acc from #{@acc_from_to[:from]} to #{@acc_from_to[:to]}:"
            @acc_data.each_with_index{|v,i| printf("##{i+1}(#{v}) ")}; printf("\n")
        puts "[#{@lotto.name}] acc.max = #{@acc_data.max}, half of acc.max = #{@acc_halfvalue}"
		#puts "[#{@lotto.name}] acc_data_of_next within base_n=#{@base_n}:"
        #    @acc_data_of_next.each_with_index{|v,i| printf("##{i+1}(#{v}) ")}; printf("\n")

    
        puts "[#{@lotto.name}] filtered_data = #{@filtered_data} (1.Repeated numbers in 4 games, 2.Serial number of prev game)"
        puts "[#{@lotto.name}] near_data = #{@near_data}"
        puts "[#{@lotto.name}] near_data_in_bw5 = #{@near_data_in_bw5}"
        #puts "[#{@lotto.name}] skip_acc = #{@skip_acc}"
        puts "[#{@lotto.name}] skip number(sorting): "
            skip_sorting.each{|v,i|
                printf("##{i+1}(#{v}) ")
            }
            printf("\n") 
        puts "[#{@lotto.name}] skip_numbers_eq_1 = #{@skip_numbers_eq_1}"
        puts "[#{@lotto.name}] skip_numbers_eq_2 = #{@skip_numbers_eq_2}"
        puts "[#{@lotto.name}] skip_numbers_btw_1_4 = #{@skip_numbers_btw_1_4}"
        puts "[#{@lotto.name}] skip_numbers_btw_5_10 = #{@skip_numbers_btw_5_10}"
        puts "[#{@lotto.name}] skip_numbers_gt = #{@skip_numbers_gt}"
        puts "[#{@lotto.name}] skip_numbers_gt_4 = #{@skip_numbers_gt_4}"
        puts "[#{@lotto.name}] skip_numbers_gt_14 = #{@skip_numbers_gt_14}"
        puts "[#{@lotto.name}] skip_numbers_le = #{@skip_numbers_le}"
        #puts "[#{@lotto.name}] minus_data = #{@minus_data}"
        puts "[#{@lotto.name}] distribution_of_7areas = #{@distribution_of_7areas}"
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
        h[:acc_data_of_next] = @acc_data_of_next
        h[:acc_halfvalue] = @acc_halfvalue
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
        h[:distribution_of_7areas] = @distribution_of_7areas
        
        h[:latest_10s] = @latest_10s_data
        
        h[:rate_of_7_array] = @rate_of_7_array
        h[:rate_of_gte2draws_insameof7areas_in2games] = @rate_of_gte2draws_insameof7areas_in2games
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
        total = @curr_data.length - get_drop_number()
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
        total = @curr_data.length - get_drop_number()
        start_index = (total - n_run)>=0 ? (total - n_run) : 0
        cnt = 0

        for i in start_index...total    #確認N期內
            if(LottoUtil.check_is_train(@curr_data[i].getDrawNum()) == 1)
                cnt += 1
            end
        end
            
        return cnt
    end 
    
    # ========================================================
    # Purpose:     確認N期內符合7-ARRAY的次數
    # Parameter:   
    # Return:
    # Remark:      
    # Revision:
    # ========================================================
    def check_N_run_7_array_cnt(n_run)
        total = @curr_data.length - get_drop_number()
        start_index = (total - n_run)>=0 ? (total - n_run) : 0
        cnt = 0

        for i in start_index...total    #確認N期內
            if(LottoUtil.check_is_7_array(@curr_data[i].getDrawNum()) == true)
                cnt += 1
            end
        end

        return cnt
    end 
    
    def rate_of_tail_intersection
        cnt = 0
        games = @base_n
        curr_data = @curr_data
        len = (games < curr_data.length) ? games : curr_data.length
        
        for i in 0...len
            curr = curr_data[-1-i].getDrawNum()
            prev = curr_data[-2-i].getDrawNum()
            if(LottoUtil.check_tail_intersection(prev, curr) == 0)
                cnt += 1
            end
        end
        return (len == 0) ? 0.0 : (cnt.to_f/len)
    end 
    
    # ========================================================
    # Purpose:      # {649二合}: 第n區連續開出任2碼，之後的第4或第5期又開出同一區有2碼的機率
    # Parameter:   
    # Return:       7 value of 1st,2nd,3th,...,7th rate
    # Remark:       
    # Revision:
    # ========================================================     
    def rate_of_SuccessAttack_for_repeated_nthOf7Area_after3games(base_n)
        rate_arr = []
        attack_arr = []

        success_attack_cnt = 0
        attack_cnt = 0
        curr_data = @curr_data
        len = (base_n < curr_data.length) ? base_n : curr_data.length
        drops = get_drop_number
        
        0.upto(6) do |nth| 
            success_attack_cnt = 0
            attack_cnt = 0
            for i in 0...len
                curr_game = curr_data[-2-i-drops]
                next_game = curr_data[-1-i-drops]

                prev3 = curr_data[-5-i-drops]
                prev4 = curr_data[-6-i-drops]
                prev5 = curr_data[-7-i-drops]
                
                dist_of_curr = LottoUtil.get_7areas_distribution(curr_game.getDrawNum)
                dist_of_next = LottoUtil.get_7areas_distribution(next_game.getDrawNum)
                dist_of_prev3 = LottoUtil.get_7areas_distribution(prev3.getDrawNum)
                dist_of_prev4 = LottoUtil.get_7areas_distribution(prev4.getDrawNum)
                dist_of_prev5 = LottoUtil.get_7areas_distribution(prev5.getDrawNum)
                
                if (dist_of_prev3[nth]==0 && dist_of_prev4[nth]>=2 && dist_of_prev5[nth]>=2)
                    attack_cnt += 1
                    if (dist_of_curr[nth] >= 2)
                        # nth: nth_area
                        puts "SuccessAttack(n=#{nth}): prev5=#{prev5.getEpi},prev4=#{prev4.getEpi},prev3=#{prev3.getEpi},curr=#{curr_game.getEpi}"
                        success_attack_cnt += 1
                    elsif (dist_of_next[nth] >= 2)
                        # nth: nth_area
                        puts "SuccessAttack(n=#{nth}): prev5=#{prev5.getEpi},prev4=#{prev4.getEpi},prev3=#{prev3.getEpi},next=#{next_game.getEpi}"
                        success_attack_cnt += 1                    
                    end
                end
            end
            rate = (attack_cnt == 0) ? 0.0 : (success_attack_cnt.to_f/attack_cnt).round(3)
            rate_arr.push(rate)
            attack_arr.push(attack_cnt)
        end
        return rate_arr, attack_arr
    end
    
    # ========================================================
    # Purpose:      上期第n碼的鄰居會在下期出現 (n=1,2,3,...)
    # Parameter:   
    # Return:
    # Remark:       ex: prev: [5,10,15,20,25,30], next may draw 14,16 with n=3
    # Revision:
    # ========================================================    
    def rate_of_neighbors_of_nth_of_prev_appears_in_next(nth)
        cnt = 0
        curr_data = @curr_data
        len = (@base_n < curr_data.length) ? @base_n : curr_data.length
        drops = get_drop_number
        
        for i in 0...len
            curr = curr_data[-1-i-drops].getDrawNum()
            prev = curr_data[-2-i-drops].getDrawNum()
            #nth_num = prev[nth-1]
            #neighbors = [nth_num-1, nth_num+1]
            #neighbors = neighbors.uniq.delete_if{|v| v<1 || v>@lotto.range}
            neighbors = LottoUtil.get_neighbors(prev, nth-1, @lotto.range)
            if((curr & neighbors).length > 0)
                cnt += 1
            end
            #puts "curr=#{curr}, prev=#{prev}, prev_#{nth}th's_neighbor=#{neighbors}"
        end
        return (len == 0) ? 0.0 : (cnt.to_f/len)
    end 
    
    # ========================================================
    # Purpose:     確認N期內7分區有2區以上為空的期數
    # Parameter:   
    # Return:
    # Remark:      
    # Revision:
    # ========================================================
    def check_N_run_2empty_of_n_sections(n_run, empty_num, n)
        total = @curr_data.length - get_drop_number()
        start_index = (total - n_run)>=0 ? (total - n_run) : 0
        cnt = 0

        for i in start_index...total    #確認N期內
            if(LottoUtil.check_empty_numbers_of_n_sections(@curr_data[i].getDrawNum(), n) >= empty_num)
                cnt += 1
            end
        end

        return cnt
    end  
    
    # ========================================================
    # Purpose:     確認N期內,7分區中，上期與本期在同區都開出>=2碼的期數
    # Parameter:   
    # Return:
    # Remark:      
    # Revision:
    # ========================================================    
    def check_N_run_gte2draws_insameof7areas_in2games(n_run) 
        total = @curr_data.length - get_drop_number()
        start_index = (total - n_run)>=0 ? (total - n_run) : 0
        cnt = 0

        for i in start_index...total-1
            prev_game = @curr_data[i]
            this_game = @curr_data[i+1]
            prev_draws = prev_game.getDrawNum
            this_draws = this_game.getDrawNum
            #prev_dist = LottoUtil.get_7areas_distribution(prev_draws)
            #this_dist = LottoUtil.get_7areas_distribution(this_draws)
            prev_indexes = LottoUtil.indexes_of_gte2draws_in_7areas(prev_draws)
            this_indexes = LottoUtil.indexes_of_gte2draws_in_7areas(this_draws)
            if((prev_indexes & this_indexes).size > 0)
                #puts "prev_epi=#{prev_game.getEpi}, this_epi=#{this_game.getEpi}"
                #puts "prev_draws=#{prev_draws}, this_draws=#{this_draws}"
                #puts "prev_indexes=#{prev_indexes}, this_indexes=#{this_indexes}"
                cnt += 1
            end
        end

        return cnt
    end
    
    ##----------------------------------------------------------------------##


    def get_acc_data
        #base = 99;#民國99年
        data_num = 0;
        stop = @curr_data.length - get_drop_number
        start = stop - @base_n

        @acc_from_to[:from] = @curr_data[start].getEpi
        @acc_from_to[:to] = @curr_data[stop-1].getEpi
        LottoUtil.init_array(@acc_data, @lotto.range);
        
        for k in start...stop
            for i in 0...@lotto.dim
                tmp = @curr_data[k].getDrawNum(i)
                if(tmp>0)
                    @acc_data[tmp-1] += 1
                end
            end
            data_num += 1
        end
        
        @acc_halfvalue = @acc_data.max / 2.to_f
    end
    
    # ========================================================
    # Purpose:		由上期號碼統計下期號碼的開出數(49x49的陣列). ex:本期開出#5, 統計開出#5後，開出1~49的次數
    # Parameter:   
    # Return:
    # Remark:       http://www.nfd.com.tw/lottery/tech/tech-001.htm
    # Author:
    # ========================================================
    def get_acc_data_of_next
        @acc_data_of_next.clear

        data_num = 0;
        stop = @curr_data.length - get_drop_number
        start = stop - @base_n
        stop = stop - 1

        for k in start...stop
            @curr_data[k].getDrawNum.each do |num|
                if @acc_data_of_next[num.to_s] == 0 
                    @acc_data_of_next[num.to_s] = Hash.new(0)
                end
                @curr_data[k+1].getDrawNum.each do |next_num|
                    @acc_data_of_next[num.to_s][next_num.to_s] += 1
                end
            end
        end

        if false
            puts "[#{@lotto.name}] next_acc from #{@curr_data[start].getEpi()} to #{@curr_data[stop-1].getEpi()}"
            @acc_data_of_next.each do |num,acc_arr|
                puts "cnt of next game for ##{num}:"
                sorting = acc_arr.sort_by {|k,v| -v}
                p sorting
            end
            #p @acc_data_of_next.sort_by do |num,acc_arr|
            #    num.to_i
            #end
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

    # ========================================================
    # Purpose:     bw=3 時，找左右距離為1的；bw=5時，找左右距離為2的, 結果存於arr
    # Parameter:   
    # Return:
    # Remark:
    # Revision:
    # ========================================================
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
    def query_near_data
        bw = 3
        query_near_data_at_dist(bw, @near_data, @@NEAR_DATA_DIM)

        bw = 5
        query_near_data_at_dist(bw, @near_data_in_bw5, @@NEAR_DATA_DIM)

        #check
        if(false)
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
    def query_skip_data
        cnt = 0
        len = 0
        end_index = @curr_data.length - get_drop_number() - 1
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
        if(false)
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
    
    def query_3star_skip_data
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
    
    def query_7areas_distribution
        @distribution_of_7areas = Array.new(7, 0)
        
        for i in 0...@base_n
            arr = @curr_data[-1-i-@drop_number].getDrawNum
            dist = LottoUtil.get_7areas_distribution(arr)
            for i in 0...7
                @distribution_of_7areas[i] += dist[i]
            end
        end
        
        return @distribution_of_7areas
    end    
end

## debug
#=begin
stat = LottoStatistics.new(Lotto649.curr_data, 100, "649")

1.upto(1) do |drop_number|
    coming_game = Lotto649.curr_data[Lotto649.curr_data.length - drop_number];
    printf("\n\n>>> Drops: %d, coming_game info: ", drop_number); coming_game.info();
    stat.calc(drop_number)
    stat.report
end
#=end
