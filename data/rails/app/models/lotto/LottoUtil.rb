module LottoUtil
    
    CANDIDATE_MAX = 49
	
    
    def self.min(a, b)
		#((a < b) ? a : b)
        [a, b].min
	end
	
	def self.fact(n)
		return 0 if n<0
		
		sum = 1
		case n
			when 0..1
				return 1
			when 2 
				return 2
			when 3 
				return 6
			when 4 
				return 24
			when 5 
				return 120
			when 6 
				return 720
			when 7 
				return 5070
			when 8 
				return 40320
			else
				for i in 1..n
					sum = sum * i
				end
				return sum
		end
    end
	
	def self.C_n_m(n, m)
        if (m > n)
            return 0;
        elsif (n<0 || m<0)
            return 0;
		else
			return fact(n)/(fact(m)*fact(n-m))
		end
    end

	def self.bubble_sort(arr)
		arr.sort!
	end
        
    # ========================================================
    # Purpose:	649: 奇數偶數比必需是4:2, 3:3 2:4，以得80%勝率
	# 			539: (3:2 + 2:3 佔 67%), (1:4, 2:3, 3:2, 4:1 佔94%)
    # Parameter:    
    # Return:      
    # Remark:      	parity: 奇偶性
    # Revision:
    # ========================================================
    def self.parity(arr)
        odd = 0;
        even = 0;
        
		return 0 if !arr
		
		for v in arr
			if((v&1) == 0)
				even += 1
			else
				odd += 1
			end
		end
        
		#puts "even=#{even}, odd=#{odd}"
        return (odd - even).abs;
    end
	
    def self.check_has_5x_7x_number(arr)
        if arr
			arr.each{|v| return true if v%5==0 ||  v%7==0}
		end

        return false
    end	
	
	# ================================================================================
    # Purpose:     確認arr[]中是否有連號
    # Parameters:  
    # Returns:     
    # Remarks: 
    # Revision & Author: welson
    # ================================================================================
    def self.check_is_train(arr)
        if arr
			for i in 0...(arr.length-1)
				if(arr[i] == arr[i+1] - 1)
					return 1
				end
			end
		end

        return 0
    end
	
	def self.check_is_repeat(arr, value)
		return 0 if !arr
		
		if arr.include?(value)
			return 1
		else
			return 0
		end
    end
	
	# ========================================================
    # Purpose:		確認是否符合7陣圖(只適用649)(至少一組號碼差為7的倍數, ex: (1,8), (1,15)
    # Parameter:   
    # Return:      
    # Remark:      7-array特性: 7x7的matrix內，號碼至少要一條垂直與一條水平
    #                          (1)垂直: (N1-N2) % 7 = 0
    #                          (2)水平: min(N1,N2)%7 != 0  &&  abs(N1-N2)<7
    # Revision:
    # ========================================================
    def self.check_is_7_array(arr)
		return false if !arr

        v_cnt = 0
        h_cnt = 0

		# C-version
        # for(int i=0; i<len-1; ++i)
        # {
            # for(int j=i+1; j<len; ++j)
            # {
                # if((arr[j]-arr[i]) % 7 == 0)
                    # ++v_cnt;
                
                # if( (min(arr[j], arr[i]) % 7 != 0)  &&
                    # (Math.abs(arr[j] - arr[i]) < 7)      )
                    # ++h_cnt;
            # }
        # }
        len = arr.length
		for i in (0...len-1) 
			for j in (i+1)...len
                if ((arr[j]-arr[i]) % 7 == 0)
                    v_cnt += 1
				end
                
                if( (min(arr[j], arr[i]) % 7 != 0)  &&
                    (arr[j] - arr[i]).abs < 7 )
                    h_cnt += 1
				end
			end
        end
		
        if(v_cnt > 0  &&  h_cnt > 0)
            return true
        else
            return false
		end
    end	
	
	# ================================================================================
    # Purpose:     Check the number of overlap
    # Parameters:  
    # Returns:     
    # Remarks:     
    # Revision & Author: welson
    # ================================================================================    
    def self.check_repeats(arr1, arr2)
        if(!arr1  ||  !arr2)
            return 0
		else
			return (arr1 & arr2).length
		end
    end
	
    # ================================================================================
    # Purpose:     
    # Parameters:  num_of_draw:抽出的號碼數
    # Returns:     
    # Remarks: 
    # Revision & Author: welson
    # ================================================================================
    def self.check_ac_value(array, num_of_draw)
		return 0 if !array
        
		len = array.length

        arr = array.sort
        
        # get ac_arr size
        size = C_n_m(len, 2);
        ac_arr = Array.new(size, 0)
        
        # process
        k = 0;
		for i in (0...len-1)
			for j in (i+1...len)
                tmp = arr[j] - arr[i];
				if(check_is_repeat(ac_arr, tmp) == 0)
                    ac_arr[k] = tmp;
                    k += 1;
                end
            end
        end

        # get ac-value
        cnt = ac_arr.count{|item| item!=0}
        ac_value = cnt - (num_of_draw - 1);        

        return ac_value;   
    end	
    
    def self.get_7areas_subranges
        return ranges = [
            (1..7).to_a,
            (8..14).to_a,
            (15..21).to_a,
            (22..28).to_a,
            (29..35).to_a,
            (36..42).to_a,
            (43..49).to_a
        ]
    end
    # ========================================================
    # Purpose:      取得7分區中, 開出2碼那區的index
    # Parameter:   
    # Return:       []
    # Remark:       gte: >=
    # Revision:
    # ======================================================== 
    def self.indexes_of_gte2draws_in_7areas(arr)
        indexes = []
        ranges = [
            (1..7).to_a,
            (8..14).to_a,
            (15..21).to_a,
            (22..28).to_a,
            (29..35).to_a,
            (36..42).to_a,
            (43..49).to_a
        ]

        ranges.each_with_index do |subrange,i|
            if(subrange & arr).size >= 2
                indexes.push(i)
            end
        end
        return indexes
    end
    
    def self.check_empty_numbers_of_n_sections(arr, n)
        r1 = []
        r2 = []
        r3 = []
        r4 = []
        r5 = []
        r6 = []
        r7 = []
        case(n)
            when 6
                r1 = [1,2,3,4,5,6,7,8]
                r2 = [9,10,11,12,13,14,15,16]
                r3 = [17,18,19,20,21,22,23,24]
                r4 = [25,26,27,28,29,30,31,32]
                r5 = [33,34,35,36,37,38,39,40]
                r6 = [41,42,43,44,45,46,47,48,49]
                r7 = []
            else
                r1 = [1,2,3,4,5,6,7]
                r2 = [8,9,10,11,12,13,14]
                r3 = [15,16,17,18,19,20,21]
                r4 = [22,23,24,25,26,27,28]
                r5 = [29,30,31,32,33,34,35]
                r6 = [36,37,38,39,40,41,42]
                r7 = [43,44,45,46,47,48,49]
        end
        ranges = [r1,r2,r3,r4,r5,r6,r7]

        cnt = 0
        for subrange in ranges
            if(subrange.length > 0)
                cnt += 1 if (subrange & arr).size == 0
            end
        end
        return cnt
    end
        
    # =====================================================
    # Purpose:     get tail number if appears greater than twice  
    # Parameter:   
    # Return:      the intersection length of tail-group of two array
    # Remark:
    #              ex: arr1={22,32,44}, mod number = 2
    #                  arr2={25,35,48}, mod number = 5
    #                  arr3={12,42,44}, mod number = 2
    #                  check_mod_number(arr1, arr2)=0, check_mod_number(arr1, arr3)=1
    # =====================================================     
    def self.check_tail_intersection(arr1, arr2)
        
        r1 = get_tail_number(arr1);
        r2 = get_tail_number(arr2);
        return (r1 & r2).size();
    end
    
    def self.array_copy(dst, src)

        return dst if dst==nil || src==nil

        src.each_index { |i| dst[i] = src[i] }
        return dst
    end
    
    def self.init_array(arr, len)
        return 0 if arr==nil
            
        for i in 0...len
            arr[i] = 0
        end
        return 1 # success
    end
    
    def self.array_sum(arr, len)
        return 0 if arr==nil
        return arr.inject(:+)
    end
    
    def self.array_avg(arr)
        return 0 if arr==nil
        return arr.inject(:+).to_f / arr.size
    end
    
    # ========================================================
    # Purpose:		範圍內random選一數字 
    # Parameter:
    # Return:
    # Remark:      從from 至 to任選一號, 最大值max
    # Revision:
    # ========================================================
    def self.select_random(from, to, max)
        start = (from>0) ? from : 1
        stop = (to<=max) ? to : max
        band = stop - start + 1
        select = start + rand(band)
    end
    
    # ========================================================
    # Purpose:		 
    # Parameter:    Bean[] curr_data, int prev_step
    # Return:
    # Remark:      
    # Revision:
    # ========================================================    
    def self.select_prev_game(curr_data, prev_step)
        index = curr_data.length - 1 - prev_step
        #index = curr_data.length - 1 - prev_step - drop_number
        
        if(index >= 0)
            return curr_data[index]
        else
            return nil
        end
    end
    def self.select_last_game(curr_data)
        index = curr_data.length - 1
        #index = curr_data.length - 1 - drop_number
        
        if(index >= 0)
            return curr_data[index]
        else
            return nil
        end
    end
    

    def self.find_max_index(arr, len)
        return -1 if arr==nil
        return arr.index(arr.max);
    end
    
    

	def self.find_n_index(arr, n, is_find_max, is_reverse_search)
		rslt = []
		if is_reverse_search
			#handle = arr.each_with_index.sort
			#handle = arr.each_with_index.sort{|x,y| if x[0] <=> y[0]}
			#handle = arr.each_with_index.sort{|x,y| if x[0] > y[0] then 1 else -1 end}
			if is_find_max
				handle = arr.each_with_index.sort
			else
				handle = arr.each_with_index.sort{|x,y| if x[0] > y[0] then 1 else -1 end}
			end
		else
			# '>=' to avoid the same value
			if is_find_max
				handle = arr.each_with_index.sort{|x,y| if x[0] >= y[0] then 1 else -1 end}
			else
				handle = arr.each_with_index.sort
			end
		end

		handle.reverse! if is_find_max
		rslt = handle.take(n).collect{|v| v[1]} 	##n.times{|i| rslt << handle[i][1]}
		return rslt
	end

	def self.max_n_index(arr, n)
		return find_n_index(arr, n, true, false)
	end

	def self.max_n_rindex(arr, n)
		return find_n_index(arr, n, true, true)
	end

	def self.min_n_index(arr, n)
		return find_n_index(arr, n, false, false)
	end

	def self.min_n_rindex(arr, n)
		return find_n_index(arr, n, false, true)
	end    
    
	# ========================================================
    # Purpose:     get neighbors by index
    # Parameter:	
    # Return:
    # Remark:		ex: [1,10,15,20,25,30] => [2] with index=0, [14,16] with index=2
    # Revision:    
    # ========================================================    
    def self.get_neighbors(arr, index, max)
		neighbors = [arr[index]-1, arr[index]+1]
		return neighbors.delete_if{|v| v<1 || v>max}
    end
    
    # ========================================================
    # Purpose:      get cnt for every section
    # Parameter:	
    # Return:       array. ex: [5,10,15,20,25,30], return [1,1,2,1,1,0,0], is the numbers of nth-section
    # Remark:
    # Revision:    
    # ========================================================    
    def self.get_7areas_distribution(arr)
        rslt = Array.new(7, 0)
        if arr
            arr.each do |v|
                i = (v-1) / 7
                rslt[i] += 1
            end
        end
        return rslt
    end
        
    # ========================================================
    # Purpose:     mod number of (33,43) = 3
    # Parameter:	
    # Return:
    # Remark:
    # Revision:    
    # ========================================================    
    def self.get_tail_number(arr)
		hash = {}
        rslt = []
        return rslt if arr==nil
        
		#~ for(int i=0; i<arr.length-1; ++i) {
			#~ for(int j=i+1; j<arr.length; ++j) {
				#~ mod = (arr[j]-arr[i]) % 10;
				#~ if(mod == 0) 
					#~ rslt.add(arr[i]%10);
			#~ }
		#~ }

        len = arr.length
        for i in 0...len-1
            for j in (i+1...len)
                if((arr[j]-arr[i])%10 == 0) 
                    mod = arr[i] % 10
					hash[mod] = mod
                end
            end
        end
		
        hash.each { |k,v|
            rslt << k
        }
		return rslt;
	end
    
    
    # ========================================================
    # Purpose:
    # Parameter:	int []arr: data array, 
    #				int len: data length
    #				int start/stop: from 'start' to 'stop' set to be 1	
    # Return:       
    # Remark:
    # Revision:
    # ========================================================
    def self.set_candidate(arr, len, start, stop)
    
        return if arr==nil
        
        for i in (start..stop)
            if(i < 0)
                next
            elsif(i >= arr.length-1)
                break
            else
                arr[i] = 1
            end
        end        
    end
    
    
    # ========================================================
    # Purpose:
    # Parameter:	arr: 資料陣列
    #				len: 陣列長度
    # Return:       peak value, (int)
    # Remark:       peak值相同時，再利用旁邊的合值判斷誰的趨勢較強(記錄在psop/csop)
    # Revision:
    # ========================================================
    def self.find_peak_value(arr, len, pulse_width)
    
        if(@candidate.nil?)
            init_candidate 
        end
        
		return 0 if arr==nil
        
        len = arr.length
        pulse_width = 1 if (pulse_width%2==0  ||  pulse_width>9)

        i = 0;
        max = 0;
        index = 0;
        select = 0;
        half = 0;
        psop = 0; #prev sum of peak
        csop = 0; #curr sum of peak

        #~ while(@candidate[i] == 1)    #不可使用i++, 因為有分是否為第一個
            #~ i += 1;
            #~ index = i;      #20110716 fix
        #~ end
        i = @candidate.index(0);
        index = i;
        
        max = arr[i];       #一般來說都是 max=arr[0], 但若上回 1 已被選時，就必需如此
        
        #20110920 add
        if(i==0)
            psop = arr[0] + arr[1];
        elsif(i == len-1)
            psop = arr[len-2] + arr[len-1];
        else
            psop = arr[i-1] + arr[i] + arr[i+1];
        end

        for i in (i...len)
            if(@candidate[i] == 0)
                if(arr[i] == max)
                    if(i==0)
                        csop = arr[0] + arr[1];
                    elsif(i == len-1)
                        csop = arr[len-2] + arr[len-1]
                    else
                        csop = arr[i-1] + arr[i] + arr[i+1]
                    end
                        
                    if(csop >= psop)    # '='有助於將趨勢推向後面的號碼
                        max = arr[i]
                        index = i
                        psop = csop
                    end
                elsif(arr[i] > max)
                    max = arr[i]
                    index = i
                end
            end
        end
        
        select = index + 1	#index變成實際數字
        
        half = (pulse_width - 1) / 2
        set_candidate(@candidate, CANDIDATE_MAX, index-half, index+half)

        return select
    end
    
    def self.init_candidate()
        @candidate = []
        init_array(@candidate, CANDIDATE_MAX)
    end    
end
