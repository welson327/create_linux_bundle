require_relative 'LottoFilter'
require_relative 'LottoStatistics'

class LottoFilter649 < LottoFilter
    private 
    @@DEBUG = false

    # ========================================================
    # Purpose:     init filter: Includes (1) filtered number
    #                                    (2) near data  
    # Parameter:   
    # Return:
    # Remark:      Maybe get latest data from Server
    # Revision:
    # ========================================================
    public 
    def initialize(stat)
		super(stat)
        @lotto.dim = 6
        @lotto.range = 49

        #shit
        @curr_data = Lotto649.curr_data
        @rate_of_7_array = @statistics.get_statistics[:rate_of_7_array]
    end

    def is_logical(result, len)
        if(pass_rate(result, len) >= 0.99)
            return true
        else
            return false
        end
    end
    
    # ========================================================
    # Purpose:      init filter: Includes (1) filtered number
    #                                     (2) near data  
    # Parameter:   
    # Return:
    # Remark:       Maybe get latest data from Server
    # Revision:
    # ========================================================
    def pass_rate(result, len)
        range1 = 105; #115
        range2 = 195; #185
        ac_critical = 7; # 7,8,9,10 佔 90%
        
        return 0.0 if (result == nil)
        
        tmp = result.clone()
        LottoUtil.array_copy(tmp, result)
        LottoUtil.bubble_sort(tmp)

        rate = 0.0
        pass_cnt = 0
        visit_cnt = 0


       
        #-------------------------------------------------------------------#
        #               Filtered Rule (Data-Indepedent)                     #
        #-------------------------------------------------------------------#
    
        # DI-1
        # check sum within 115-185(71% win for 649), 63-138(for 539)
        sum = LottoUtil.array_sum(tmp, @lotto.dim);
        pass_cnt += 1 if(sum >= range1  &&  sum <= range2)
        visit_cnt += 1


        # DI-2 (2011-07-28)
        # Parity: should be 3:3, 4:2, 2:4
        pass_cnt += 1 if(LottoUtil.parity(result) <= 2)
        visit_cnt += 1


        # DI-3 (2012-01-19)
        # 7-array
        if(@rate_of_7_array > 0.88)
            pass_cnt += 1 if(LottoUtil.check_is_7_array(tmp) == true)
            visit_cnt += 1
        end


        # DI-4 (2011-10-10)
        # AC value: >=7 could be 90% win
        ac_value = LottoUtil.check_ac_value(tmp, @lotto.dim); #it will bubble sort first
        pass_cnt += 1 if(ac_value >= ac_critical)
        visit_cnt += 1


=begin      
		# DI-5
        # tail number group
        if(@rate_of_tail_intersection >= 0.85) 
            tail = LottoUtil.get_tail_number(tmp)
            pass_cnt += 1 if(tail.size() > 0)
            visit_cnt += 1
            
			# 相鄰2期尾數群不可相同
            prev = @latest_10s_data[@@SERVER_DATA_NUM-1].getDrawNum();
            pass_cnt += 1 if(LottoUtil.check_tail_intersection(prev, tmp) == 0)
            visit_cnt += 1
		end
        
        
		# DI-6
        if(true) 
            pass_cnt += 1 if(LottoUtil.check_empty_numbers_of_n_sections(tmp, 7) >= 2)
            visit_cnt += 1
		end

		
		# DI-7 (~90%)
		pass_cnt += 1 if(LottoUtil.check_has_5x_7x_number(tmp))
		visit_cnt += 1

        #DI-8 (aggressive predict)
        pass_cnt += 1 if(! has_nth_section_of_7(tmp, 1))
        visit_cnt += 1
=end
        
        
=begin
        # 使用者自選號
        #if(check_include_user_select(result, @lotto.dim, user_num, USER_NUM_MAX) == 0)
            #~ System.out.println("Not include user selection!!");
        #    get_anal_number(type, rslt);
        #    return;
        #end

        # 連號機率 55% (Welson's concept)
        serial_ref = 0;
        if(@is_need_serial == -1)
            #serial_ref = (int)Math.floor(Math.random()*100) + 1;
            serial_ref = rand(100) + 1
            @is_need_serial = (serial_ref < @rate_of_serial*100) ? 1 : 0;
        end
        if(LottoUtil.check_is_train(tmp) == @is_need_serial) #需求符
            @is_need_serial = -1;
            pass_cnt += 1
        end
        visit_cnt += 1
=end


        #-------------------------------------------------------------------#
        #               Filtered Rule (Data-Depedent)                       #
        #-------------------------------------------------------------------#        
        # DD-1 (2011-07-28)
        # Check history
        pass_cnt += 1 if (check_is_history(tmp) == 0)
        visit_cnt += 1

            
        # DD-3 (2011-07-28)
        # 不可是上期連號 or 4期內有連莊
        if(check_is_prev_train_or_again_by_array(tmp, @@FILTER_RATE) == 0)
            pass_cnt += 1
        end
        visit_cnt += 1



		# DD-2 (2011-09-03)
        # Selected numbers should be beside the previous draws.
        near_num = check_near_num(result, @lotto.dim);
        if near_num.between?(2,3)
            # 根據研究, 使用Gail Howard的方式，可濾掉約20%的極端情況
            pass_cnt += 1
        end
        visit_cnt += 1


=begin
        # DD-4 (2011-11-27)
        # 與上期號碼重複數
        if(check_repeat_by_prev(result) <= 2)
            if(@@DEBUG)
                puts "Rpt num. checked prev <= 2!! ---> #{result}"
            end
            pass_cnt += 1
        end
        visit_cnt += 1


        # DD-5
        # 649: 上期特別號不再開出(機率90%)
        pass_cnt += 1 if(check_include_prev_special(tmp) == 0)
        visit_cnt += 1
=end



=begin
        # DD-6 (2011-12-18)
        # 4 runs check
        if(@rate_of_4_run_repeat_3_num < 0.12) # 歷史資料 <12% 就濾
            pass_cnt += 1 if(check_is_N_run_M_num(tmp, 4, 3) == 0) # 4期內不可重複3碼
			visit_cnt += 1
        end
        if(@rate_of_4_run_repeat_1_num > 0.88)
            pass_cnt += 1 if(check_is_N_run_M_num(tmp, 4, 1) == 1) # 4期內至少重複1碼
			visit_cnt += 1
        end
		#if(@rate_of_6_run_repeat_2_num > .50) # v2.3.2 add
		#	pass_cnt += 1 if(check_is_N_run_M_num(tmp, 6, 2) == 1)
		#	visit_cnt += 1
        #end


        # DD-7 (2012-03-07)
        # skip data > 10 check
        if(check_include_skip_number(tmp))
            # 拿101018期為例, 跑30組共濾掉約12000次
            #System.out.printf("[%s] Not include skip > 10 !!", lotto.name);
            pass_cnt += 1
        end
        visit_cnt += 1

        
        rate = pass_cnt.to_f / visit_cnt
        return rate
=end
    end

    # ========================================================
    # Purpose:     確認N期內符號7-ARRAY的次數
    # Parameter:   
    # Return:       double
    # Remark:      
    # Revision:
    # ========================================================
    def check_rate_of_di
        total_pass_cnt = 0
        n = 100
        
        bean = nil
        tmp = nil
        pass_cnt = 0
        visit_cnt = 0
        
        ac_critical = 7 # 7,8,9,10 佔 90%
        sum = 0
        parity = 0
        ac_value = 0
        tail = nil #hash
        
        for i in 0...n
            pass_cnt = 0
            visit_cnt = 0
            
            bean = @curr_data[-1-i]
            tmp = bean.getDrawNum()
            
            # sum
            sum = LottoUtil.array_sum(tmp, @lotto.dim)
            
            pass_cnt += 1 if(sum >= 100  &&  sum <= 200)
            visit_cnt += 1

            # Parity
            pass_cnt += 1 if(LottoUtil.parity(tmp) <= 2)
            visit_cnt += 1

            # 7-array
            pass_cnt += 1 if(LottoUtil.check_is_7_array(tmp) == true)
            visit_cnt += 1
            
            # AC
            ac_value = LottoUtil.check_ac_value(tmp, @lotto.dim); #it will bubble sort first
            pass_cnt += 1 if(ac_value >= ac_critical)
            visit_cnt += 1
            
            # tail
            tail = LottoUtil.get_tail_number(tmp)
            pass_cnt += 1 if(tail.size() > 0)
            visit_cnt += 1
            
            total_pass_cnt += 1 if(pass_cnt == visit_cnt) 
        end
        
        return (total_pass_cnt.to_f / n)
    end
    
    
=begin      
private    
	def has_nth_section_of_7(arr, n)
		r1 = [1,2,3,4,5,6,7]
		r2 = [8,9,10,11,12,13,14]
		r3 = [15,16,17,18,19,20,21]
		r4 = [22,23,24,25,26,27,28]
		r5 = [29,30,31,32,33,34,35]
		r6 = [36,37,38,39,40,41,42]
		r7 = [43,44,45,46,47,48,49]
		area = [r1, r2, r3, r4, r5, r6, r7]
		n = 1 if n>6 || n<0

		expect = area[n]
		if (expect & arr).size > 0
			return true
		else
			return false
		end
	end

    
    
    # ========================================================
    # Purpose:		
    # Parameter:   
    # Return:      
    # Remark:      
    # Revision:
    # ========================================================
    def check_has_max_interval(arr, max_interval, is_consider_side)
        max = is_consider_side ? arr[0] : arr[1]-arr[0]
        for i in 0...arr.length-1
            interval = arr[i+1] - arr[0]
            max = interval if interval > max
        end
        return 1
    end
    # ========================================================
    # Purpose:     確認N期內符合7-ARRAY的次數
    # Parameter:   
    # Return:
    # Remark:      
    # Revision:
    # ========================================================
    public 
    def check_N_run_7_array_cnt(n_run)
        total = @curr_data.length - get_drop_numbers()
        start_index = (total - n_run)>=0 ? (total - n_run) : 0
        cnt = 0

        for i in start_index...total    #確認N期內
            if(LottoUtil.check_is_7_array(@curr_data[i].getDrawNum()) == true)
                cnt += 1
            end
        end

        return cnt
    end
   
    # ========================================================
    # Purpose:     確認N期內7分區有2區以上為空的次數
    # Parameter:   
    # Return:
    # Remark:      
    # Revision:
    # ========================================================
    public 
    def check_N_run_empty_of_n(n_run, empty_num, n)
        total = @curr_data.length - get_drop_numbers()
        start_index = (total - n_run)>=0 ? (total - n_run) : 0
        cnt = 0

        for i in start_index...total    #確認N期內
            if(LottoUtil.check_empty_numbers_of_n_sections(@curr_data[i].getDrawNum(), n) >= empty_num)
                cnt += 1
            end
        end

        return cnt
    end

    public 
    def rate_of_tail_intersection
        cnt = 0
        games = 100
        #int[] curr, prev
        curr_data = Lotto649.curr_data
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
    # Purpose:      上期第n碼的鄰居會在下期出現 (n=1,2,3,...)
    # Parameter:   
    # Return:
    # Remark:       ex: prev: [5,10,15,20,25,30], next may draw 14,16 with n=3
    # Revision:
    # ========================================================    
    def rate_of_neighbors_of_nth_of_prev_appears_in_next(nth)
        cnt = 0
        games = 100
        curr_data = Lotto649.curr_data
        len = (games < curr_data.length) ? games : curr_data.length
        
        for i in 0...len
            curr = curr_data[-1-i].getDrawNum()
            prev = curr_data[-2-i].getDrawNum()
            #nth_num = prev[nth-1]
            #neighbors = [nth_num-1, nth_num+1]
            #neighbors = neighbors.uniq.delete_if{|v| v<1 || v>49}
            neighbors = LottoUtil.get_neighbors(prev, nth-1, 49)
            if((curr & neighbors).length > 0)
                cnt += 1
            end
            #puts "curr=#{curr}, prev=#{prev}, prev_#{nth}th's_neighbor=#{neighbors}"
        end
        return (len == 0) ? 0.0 : (cnt.to_f/len)
    end
=end 
end
