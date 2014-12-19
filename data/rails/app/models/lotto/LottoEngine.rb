require_relative 'LOTTO'
require_relative 'LottoUtil'
require_relative 'Parameter'
require_relative 'Lotto649'
require_relative 'LottoStatistics'
require_relative 'Lotto3Statistics'
require_relative 'LottoFilter'
require_relative 'LottoFilter649'
#require_relative 'Lotto539'

class LottoEngine
=begin    
    @@DEBUG = false
    @@CANDIDATE_MAX = LottoUtil::CANDIDATE_MAX
    
    @@LOTTO649_DIM = 6
    @@LOTTO649_RANGE = 49
    @@LOTTO539_DIM = 5
    @@LOTTO539_RANGE = 39

    @@SAMPLING_PEAK_MAX = 10
    @@SAMPLING_PEAK_NUM_649 = 8
    @@SAMPLING_PEAK_NUM_539 = 8
    
    @@ACC_BASE_649 = 100
    @@ACC_BASE_539 = 80
=end


    

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
        
    @@param_rand = Parameter.new
        @@param_rand.sampling_peak_num = 0
        @@param_rand.sel_region_num = 0
        @@param_rand.band_width = 0
        @@param_rand.peak_resolution = 0
    @@param649 = Parameter.new
        @@param649.sampling_peak_num = 8
        @@param649.sel_region_num = 5     # 5 of 10, default
        @@param649.band_width = 3
        @@param649.peak_resolution = 3
    @@param539 = Parameter.new
        @@param539.sampling_peak_num = 0
        @@param539.sel_region_num = 0
        @@param539.band_width = 5
        @@param539.peak_resolution = 3

public
    def initialize(lotto_name, curr_data)
        case lotto_name
            when "649"
                @lotto = @@L649
                @param = @@param649
                @base_n = 100
            when "539"
                @lotto = @@L539
                @param = @@param539
                @base_n = 80
            when "3"
                @lotto = @@L3
                @param = nil
                @base_n = 500
        end
        
        @curr_data = curr_data
        
        
        #~ @is_init = false
        #~ @lotto_type = LOTTO::TYPE_649   # 649, 539

        #~ @@lotto649 = LOTTO.new
        #~ @@lotto539 = LOTTO.new
        #~ @@param649 = Parameter.new
        #~ @@param539 = Parameter.new
            
        #@@data649 = Lotto649.curr_data
        #@@data539 = Lotto539.curr_data
        
        #@statistics649 = LottoStatistics.new(@@data649, 100, "649")
        #@statistics539 = LottoStatistics.new(@@data539, 100, "539")
        @statistics = nil
        
        #@@filter649 = LottoFilter649.new
        #@@filter539 = LottoFilter539.new

        #@@acc_data649 = Array.new(@@LOTTO649_RANGE){|i| 0}  #統計累積次數
        #@@acc_data539 = Array.new(@@LOTTO539_RANGE){|i| 0}
        
        # 開出x號後，統計下期開出1~49的次數. ex: next_acc_649[4][9]代表開出5號下期開出10號的次數
        #@@next_acc_649 = Hash.new(0)
        
        #@@acc_halfvalue_649 = 0.0

        @g_sampling_peak = []     #取樣peak值(共10組)
        @g_selected_peak = []     #被選的peak(0/1), 只會有4或5個值為1

        
        @analysis_num = 0               #已分析次數

        
        #~ @@is_ranking = false
        #~ @@rank649 = []
        #~ @@rank539 = []
        
        @is_advance_prediction = true
        #~ @@filter_end_index = -1

        @drop_number = 0
    end

    def init
        case @lotto.name
            when "649"
                @statistics = LottoStatistics.new(@curr_data, @base_n, @lotto.name)
                #Lotto649.update
                @filter = LottoFilter649.new(@statistics)
            when "539"
                @statistics = LottoStatistics.new(@curr_data, @base_n, @lotto.name)
                #Lotto539.update
                @filter = LottoFilter539.new(@statistics)
            when "3"
                @statistics = Lotto3Statistics.new(@curr_data, @base_n, @lotto.name)
                #Lotto3.update
                @filter = nil
        end
    end
    
	def reset
		if @statistics
			@statistics.set_drop_number(@drop_number)
			@statistics.calc(@drop_number)
        end
        if @filter
			@filter.reset(@statistics)
        end
    end

    def info
        printf("-------------------------------------\n");
        printf("LottoEngine: \n");
        printf("[%s]: \n", @lotto.name);
        #printf("pass_threshold = %.2f\n", @@filter649.get_pass_threshold);
        printf("ACC_BASE = %d\n", @base_n);
        #printf(".drop number = %d\n", @@filter649.get_drop_numbers);
        printf(".sampling_peak_num = %d\n", @param.sampling_peak_num);
        printf(".sel_region_num = %d\n", @param.sel_region_num);
        printf(".band_width = %d\n", @param.band_width);
        printf(".peak_resolution = %d\n", @param.peak_resolution);
        printf("-------------------------------------\n");
    end
            
    # ========================================================
    # Purpose:		設定是否要預測峰值區間
    # Parameter:   
    # Return:
    # Remark:
    # Revision:
    # ========================================================
    def set_advance_prediction(onoff)
    	@is_advance_prediction = onoff
        
        if @is_advance_prediction
            @param = @@param649
        else
            @param = @@param_rand
        end
    end
                
    def set_statistics(statistics)
        @statistics = statistics
    end
    
    def set_filter(filter)
        @filter = filter
    end

    def set_drop_number(n)
        @drop_number = n
    end
    
    def report
        @statistics.report
    end
    

    
    # ========================================================
    # Purpose:		Only random number without OT-filter
    # Parameter:   
    # Return:
    # Remark:
    # Revision:
    # ========================================================    
    def get_random_number(type, result)
        
        return if (result.length<@lotto.dim  ||  result==nil)
                
        for j in 0...@lotto.dim
            begin
                select = LottoUtil.select_random(1, @lotto.range, @lotto.range)
            end while (LottoUtil.check_is_repeat(result, select) == 1)
            result[j] = select
        end

        LottoUtil.bubble_sort(result)
    end
    

    def get_numbers(rslt)
        LottoUtil.init_candidate
        
        #~ @analysis_num += 1
        #~ if(@analysis_num > 2147483647 - 1)
            #~ @analysis_num = 0
        #~ end
        
        
        #~ case(@@lotto_type)
            #~ when LOTTO::TYPE_539
                        #~ lotto = @@lotto539;
                        #~ option = @@param539;
                        #~ acc_data = @@acc_data539;
                        #~ pr = @@param539.peak_resolution;
                        #~ filter = @@filter539;
            #~ else
                        #~ lotto = @@lotto649;
                        #~ option = @@param649;
                        #~ acc_data = @@acc_data649;
                        #~ pr = @@param649.peak_resolution;
                        #~ filter = @@filter649;                        
        #~ end
        
        dim = @lotto.dim
        range = @lotto.range
        acc_data = @statistics.get_statistics[:acc_data]
        pr = @param.peak_resolution
        
        
        tmp = []
        result = []
        
        half = (@param.band_width-1)/2

        # init array
        #LottoUtil.init_array(result, dim)
        LottoUtil.init_array(@g_sampling_peak, @param.sampling_peak_num)
        LottoUtil.init_array(@g_selected_peak, @param.sampling_peak_num)
        
        
        
        # find peak value(找出10個peak)
        for i in 0...@param.sampling_peak_num
            @g_sampling_peak[i] = LottoUtil.find_peak_value(acc_data, range, pr)
        end


        # 挑選取樣區間
        for i in 0...@param.sel_region_num #sel_region_num = 4,5 of 10
            begin
                index = rand(@param.sampling_peak_num);
                #index = (int)Math.floor(Math.random()*@param.sampling_peak_num);
            end while (@g_selected_peak[index] == 1)
            @g_selected_peak[index] = 1
        end

        # 建議號碼
        for i in 0...@param.sampling_peak_num
            if( @g_selected_peak[i]==1 )
                peak = @g_sampling_peak[i];

                # check if repeated or not
                begin
                    select = LottoUtil.select_random(peak-half, peak+half, range)
                end while (LottoUtil.check_is_repeat(result, select) == 1)
                         
                result << select
            end
        end


        # Other number (ex: 649 is 第5、6個號碼)
        for j in @param.sel_region_num...dim #sel_region_num = 4 or 5 (of 10)
            begin
                select = LottoUtil.select_random(1, range, range)
            end while(LottoUtil.check_is_repeat(result, select) == 1)
            result << select;
        end

        
        
        LottoUtil.array_copy(tmp, result)
        LottoUtil.bubble_sort(tmp)
    
    

    
        
        #-------------------------------------------------------------------#
        #                         Filtered Rule                             #
        #-------------------------------------------------------------------#
        if(@filter.is_logical(tmp, dim) == false)
			tmp = nil
			result = nil

            get_numbers(rslt)
            return
        end

        #Copy to user's array
        tmp.each_index{|i| rslt[i] = tmp[i]}
    end
    
    
    # ========================================================
    # Purpose:      OT號碼取統計上前n名
    # Parameter:   
    # Return:      
    # Remark:      
    # Revision:
    # ========================================================    
    #~ public
    #~ def get_statistic_number(type, rslt, n)
        #~ case(type)
            #~ when LOTTO::TYPE_539
                #~ dim = @@LOTTO539_DIM
                #~ range = 39
            #~ else
                #~ dim = @@LOTTO649_DIM
                #~ range = 49
        #~ end
        #~ tmp = Array.new(dim, -1)
        #~ acc = Hash.new(0)
        #~ 
        #~ 100.times do |i|
            #~ LottoEngine.get_numbers(type, tmp)
            #~ tmp.each{|number| acc[number] += 1}
        #~ end
        #~ 
        #~ sort_acc = acc.sort_by{|k,v| -v} # desc sort
        #~ 
        #~ for i in 0...n
            #~ rslt[i] = sort_acc[i][0]
        #~ end
    #~ end
    
    def get_politic_3star_numbers
        rslt = []
        statistics = @statistics.get_statistics
        acc_data = statistics[:acc_data]
        skip_data = statistics[:skip_acc]
        acc_halfvalue = statistics[:acc_halfvalue]
        
        pack_len = 7
        selection = Array.new(3) {[]}
        
        puts "++++++++++++++"
        puts "acc=#{acc_data}, len=#{statistics[:acc_len]}"
        puts "skip=#{skip_data}"
        
        # digit in hundreds
        sorting_array = acc_data[0].each_with_index.to_a.sort_by{|v| -v[0]}
        selection[0] = sorting_array[0, pack_len].collect{|v| v[1]}
        
        
        # digit in tens (find most skip number but is top 3 hot number)
        policy = 5
        case policy
            when 1
                sorting_array = skip_data[1].each_with_index.to_a.sort_by{|v| -v[0]}
                most_skip_number = sorting_array[0][1]
                puts "most_skip_number=#{most_skip_number}"
                top3acc = acc_data[1].each_with_index.to_a.sort_by{|v| -v[0]}[0,3].collect{|v| v[1]}
                if top3acc.include?(most_skip_number)
                    selection[1].push(most_skip_number)
                end
            
            when 2
                sorting_array = skip_data[1].each_with_index.to_a.sort_by{|v| -v[0]}
                most_skip_number = sorting_array[0][1]
                puts "most_skip_number=#{most_skip_number}"
                top3acc = acc_data[1].each_with_index.to_a.sort_by{|v| -v[0]}[0,3].collect{|v| v[1]}
                #if top3acc.include?(most_skip_number)
                    selection[1].push(most_skip_number)
                #end
                
            when 3
                sorting_array = acc_data[1].each_with_index.to_a.sort_by{|v| -v[0]}
                most_hot_number = sorting_array[0][1]
                puts "most_hot_number = #{most_hot_number}"
                selection[1].push(most_hot_number)
                
            when 4
                most_hot_number = acc_data[1].each_with_index.to_a.sort_by{|v| -v[0]}[0][1]
                puts "most_hot_number = #{most_hot_number}"
                if(skip_data[1][most_hot_number] > 10)
                    selection[1].push(most_hot_number)
                end
                
            when 5
                sorting_array = acc_data[1].each_with_index.to_a.sort_by{|v| -v[0]}
                most_hot_numbers = sorting_array[0,10].collect{|v| v[1]}
                puts "most_hot_numbers = #{most_hot_numbers}"
                most_hot_numbers.each do |hot_number|
                    if(skip_data[1][hot_number] > 12)
                        selection[1].push(hot_number)
                    end
                end
                
            when 6
                sorting_array = acc_data[1].each_with_index.to_a.sort_by{|v| -v[0]}
                most_hot_numbers = sorting_array[0,1].collect{|v| v[1]}
                puts "most_hot_numbers = #{most_hot_numbers}"
                selection[1] = most_hot_numbers.clone
        end
        
        
        # digit in ones
		sorting_array = acc_data[2].each_with_index.to_a.sort_by{|v| -v[0]}
        selection[2] = sorting_array[0, pack_len].collect{|v| v[1]}
        
        #puts "top3acc=#{top3acc}"
        puts "selection=#{selection}"
        
        return selection
    end
    
    def get_politic_match2_numbers
        
        rslt = []
        #rslt = Array.new(dim, -1)
        
        dim = @lotto.dim
		range = @lotto.range
        

        # find skip_gt > 14 & acc_value > acc_halfvalue
        statistics = @statistics.get_statistics
        acc_data = statistics[:acc_data]
        near_data = statistics[:near_data]
        filtered_data = statistics[:filtered_data]
        skip_acc = statistics[:skip_acc]
        skip_numbers_eq_1 = statistics[:skip_numbers_eq_1]
        skip_numbers_eq_2 = statistics[:skip_numbers_eq_2]
        skip_numbers_btw_1_4 = statistics[:skip_numbers_btw_1_4]
        skip_numbers_btw_5_10 = statistics[:skip_numbers_btw_5_10]
        skip_numbers_gt_14 = statistics[:skip_numbers_gt_14]
        acc_halfvalue = statistics[:acc_halfvalue]
        
        # Policy 1
        #rslt += skip_numbers_gt_14.select{|num| @@acc_data649[num-1] >= @@acc_halfvalue_649}
        #rslt += skip_numbers_eq_1.select{|num| @@acc_data649[num-1] < @@acc_halfvalue_649}
        #rslt += skip_numbers_eq_2.select{|num| @@acc_data649[num-1] < @@acc_halfvalue_649}
        
        # Policy 2
        #next_hot = get_next_hot.sort_by{|k,v| -v}
        #puts "next_hot = #{next_hot}"
        
        #rslt += skip_numbers_btw_1_4.select{|num| @@acc_data649[num-1] >= @@acc_halfvalue_649}[0...3]
        #rslt += skip_numbers_btw_5_10.select{|num| @@acc_data649[num-1] >= @@acc_halfvalue_649}[0...2]
        #rslt += skip_numbers_gt_14.select{|num| @@acc_data649[num-1] >= @@acc_halfvalue_649}[0...2]
        ##add = next_hot.find{|v| (@@acc_data649[v[0].to_i-1] >= @@acc_halfvalue_649) && (v[0].to_i&1==0)}
        #add = next_hot.find{|v| v[0].to_i > 42}
        ##rslt << add[0].to_i unless add.nil?
        ##rslt += get_neighbors([ next_hot[0][0].to_i ], @@LOTTO649_RANGE)
        #rslt.uniq!
        
        #prev_3_games_numbers = []
        #prev_3_games_numbers += @statistics.get_prev_game(1).getDrawNum
        #prev_3_games_numbers += @statistics.get_prev_game(2).getDrawNum
        #prev_3_games_numbers.uniq!
        #prev_3_games_numbers_with_high_rate = prev_3_games_numbers.select{|num| acc_data[num-1] >= acc_halfvalue}
		#puts "prev_3_games_numbers=#{prev_3_games_numbers}"
		#puts "prev_3_games_numbers_with_high_rate=#{prev_3_games_numbers_with_high_rate}"

=begin        
        # Policy 3 (skip_gt_14 & near_data)
        prev = @statistics.get_last_game
        puts "prev game[#{prev.getEpi}] = #{prev.getDrawNum}"
        neighbors = (LottoUtil.get_neighbors(prev.getDrawNum, 2, 49) + LottoUtil.get_neighbors(prev.getDrawNum, 4, 49)).uniq
        if (LottoUtil.check_is_7_array(prev.getDrawNum))
            rslt += skip_numbers_btw_5_10.select{|num| @@acc_data649[num-1] >= @@acc_halfvalue_649}
            rslt += prev_3_games_numbers_with_high_rate
            rslt += neighbors
            rslt.uniq!
        end
        
        ot_num = []
        cnt = 0
        begin
			cnt += 1
			break if cnt > 10000
			
			ot_num.clear
			get_numbers(LOTTO::TYPE_649, ot_num)
			filtered_rslt = (rslt & ot_num)
        end while !filtered_rslt.size.between?(6,8) 
        rslt = filtered_rslt
        puts "filtered_rslt=#{filtered_rslt}"

		# policy 4
		# http://www.nfd.com.tw/lottery/tech/tech-001.htm
		# http://www.nfd.com.tw/lottery/photo/china-02.htm
		prev = @statistics.get_last_game
        puts "prev game[#{prev.getEpi}] = #{prev.getDrawNum}"
        primary = [prev.getDrawNum(2), prev.getDrawNum(4)]
        neighbors = (LottoUtil.get_neighbors(prev.getDrawNum, 2, 49) + LottoUtil.get_neighbors(prev.getDrawNum, 4, 49)).uniq
        tails = (primary + neighbors).collect{|v| v%10}.uniq
        puts "primary=#{primary}, neighbors=#{neighbors}, tails=#{tails}"
=end        
        
        # policy 5
        prev_game = @statistics.get_prev_game(0)
        pprev_game = @statistics.get_prev_game(1)
        prev_draws = prev_game.getDrawNum
        pprev_draws = pprev_game.getDrawNum
        prev_indexes = LottoUtil.indexes_of_gte2draws_in_7areas(prev_draws)
        pprev_indexes = LottoUtil.indexes_of_gte2draws_in_7areas(pprev_draws)
        indexes = prev_indexes - pprev_indexes
        dist = LottoUtil.get_7areas_distribution(prev_draws)
        cnt2 = dist.count(2) # 開出2碼的區數
        cnt3 = dist.count(3)
        neighbors = (LottoUtil.get_neighbors(prev_draws, 2, 49) + LottoUtil.get_neighbors(prev_draws, 4, 49)).uniq
        indexes.each do |i| ##上期&上上期沒有同區都開出2碼 && 上期有某區開出2碼
            subrange = LottoUtil.get_7areas_subranges[i]
            # investment msg
            #~ if ((prev_indexes & pprev_indexes).size == 0 && ##上期&上上期沒有同區都開出2碼
                 #~ prev_indexes.size > 0)                      ##上期有某區開出2碼    
                #~ rslt += subrange
                #~ rslt -= prev_draws
                #~ rslt.uniq!
            #~ end
			
			numbers = subrange.select{|num| acc_data[num-1] >= acc_halfvalue}
            
            rslt.push(numbers)
        end
        
=begin
        # investment msg
        if(LottoUtil.check_empty_numbers_of_n_sections(prev.getDrawNum, 7) >= 2)
        #if ( LottoUtil.check_is_7_array(prev.getDrawNum) )
			rslt = (1..range).to_a.select { |num|
				(acc_data[num-1] >= acc_data.max.to_f*2/3) &&
				(tails.include?(num%10))
			}
            rslt.uniq!
			#puts "match2 package(before filtered)=#{rslt}"
			
			rslt = (rslt - filtered_data)
			puts "match2 package(after  filtered)=#{rslt}"
        end

		# find 4-runs-2-num
		numbers = @@filter649.get_numbers_of_arising_in_N_run(4, 2, true)
		return numbers
=end
=begin
        # find [1..49] - @minus_data
        numbers = (1..49).to_a - @@filter649.get_query_data[:minus_data]
        return numbers
=end
=begin
        # find top 2 of 7-section
        sets = []
        filtered_data = @@filter649.get_query_data[:filtered_data]
        near_data = @@filter649.get_query_data[:near_data]
        indexes = LottoUtil.max_n_index(@distribution_of_7areas, 7)
        #maxes = @distribution_of_7areas.sort.reverse[0..1]
        #indexes[0] = @distribution_of_7areas.index(maxes[0])
        #indexes[1] = @distribution_of_7areas.rindex(maxes[1])
        p indexes
        3.times do |i|
        puts ">>>>>>>>>>>> #{indexes[i]}"
            arr = (1..7).to_a.collect{|v| v += 7*indexes[i]} - filtered_data
            sets << arr if (arr & near_data).size > 0
            #break if sets.size >= 2
        end
        p sets
        return sets
=end
=begin        
        # find 8's ot numbers
        ot = []
        n = 8 if n == -1
        begin
            LottoEngine.get_numbers(@lotto_type, rslt)
            rslt.each do |v| 
                ot << v
                ot.uniq!
                break if ot.size >= n
            end
        end while ot.size < n
        return ot
=end        
=begin
        # find odds
        odds_of_ot = []
        begin
            LottoEngine.get_numbers(@lotto_type, rslt)
            rslt.each do |v| 
                odds_of_ot << v if v & 1 == 1
                odds_of_ot.uniq!
                break if odds_of_ot.size >= n
            end
        end while odds_of_ot.size < n
        return odds_of_ot

        LottoEngine.get_statistic_number(type, rslt, n)
        return rslt
=end        

        return rslt
    end
    
    
    # ========================================================
    # Purpose:      因OT每次出來只中1~2碼。所以每次產出的號碼在其中任選1~2碼，直至6碼。
    # Parameter:   
    # Return:      
    # Remark:      
    # Revision:
    # ========================================================    
    def get_numbers_v2(rslt)
        numbers = {}
        
        #~ case(type)
            #~ when LOTTO::TYPE_539
                #~ dim = @@LOTTO539_DIM
            #~ else
                #~ dim = @@LOTTO649_DIM
        #~ end
        dim = @lotto.dim
        tmp = Array.new(dim, -1)
        
        while(numbers.size < dim)
            self.get_numbers(type, tmp)
            n = rand(2) + 1; # get 1~2
            arr = tmp.shuffle()[0...n]
            arr.each{|v| numbers[v] = v}
        end
        
        i = 0
        numbers.each do |k,v| 
            rslt[i] = v 
            i += 1
        end
        rslt.sort!
    end



    # ========================================================
    # Purpose:      統計n期的acc，並找出值為acc_value的號碼
    # Parameter:       
    # Return:
    # Remark:
    # Revision:
    # ========================================================
    #~ def get_numbers_by_acc_value_in_n_games(type, acc_value, n)
        #~ rslt = []
#~ 
        #~ acc = Array.new(@lotto.range, 0)
        #~ dim = @lotto.dim
        #~ 
        #~ stop = @curr_data.length - @drop_number
        #~ start = stop - n
        #~ for k in start...stop
            #~ for i in 0...dim
                #~ tmp = @curr_data[k].getDrawNum(i)
                #~ if(tmp>0)
                    #~ acc[tmp-1] += 1
                #~ end
            #~ end
        #~ end
#~ 
        #~ acc.each_index{|i| rslt << (i+1) if acc[i]==acc_value}
        #~ return rslt    
    #~ end

	# ========================================================
    # Purpose:		由上期號碼中找出熱門號，並統計其下期號碼的開出次數
    # Parameter:   
    # Return:
    # Remark:       http://www.nfd.com.tw/lottery/tech/tech-001.htm
    # Revision:
    # ========================================================
    #~ def get_next_hot
        #~ next_hot = Hash.new(0)
        #~ prev_hot = @statistics.get_prev_game(0).getDrawNum.select{|num| @@acc_data649[num-1] >= @@acc_halfvalue_649}
        #~ #puts "prev_hot = #{prev_hot}"
        #~ prev_hot.each do |num|
            #~ h = @@next_acc_649[num.to_s]
            #~ h.select{|k,v| v>=2}.each{|k,v| next_hot[k] += v}
        #~ end
        #~ return next_hot
    #~ end
    
    def get_neighbors(arr, max)
        neighbor = []
        arr.each do |v|
            neighbor << v-1 if v-1 >= 1
            neighbor << v+1 if v+1 <= max
        end
        return neighbor
    end    


    #~ def get_next_acc_data
		#~ @@next_acc_649.clear
		#~ 
		#~ @@data649 = Lotto649.curr_data  # maybe 'Lotto649.curr_data' is a new memory
#~ 
        #~ #---------------------------------------------------------649
        #~ stop = @@data649.length - @drop_number
        #~ start = stop - @base_n
		#~ 
		#~ stop = stop - 1
        #~ for k in start...stop
            #~ @@data649[k].getDrawNum.each do |num|
				#~ if @@next_acc_649[num.to_s] == 0 
					#~ @@next_acc_649[num.to_s] = Hash.new(0)
				#~ end
				#~ @@data649[k+1].getDrawNum.each do |next_num|
					#~ @@next_acc_649[num.to_s][next_num.to_s] += 1
				#~ end
            #~ end
        #~ end
#~ 
        #~ if false
            #~ puts "[#{@@lotto649.name}] next_acc from #{@@data649[start].getEpi()} to #{@@data649[stop-1].getEpi()}"
            #~ h = @@next_acc_649.sort_by do |k,v|
                #~ k
                #~ v.sort_by {|k,v| v}
            #~ end
            #~ p h
        #~ end
    #~ end
    
private 
    # ========================================================
    # Purpose:
    # Parameter:   
    # Return:
    # Remark:
    # Revision:
    # ========================================================
    def get_acc_data
        @statistics.get_statistics[:acc_data]
    end


    #~ def init_acc
        #~ LottoUtil.init_array(@@acc_data649, @@LOTTO649_RANGE);
        #~ LottoUtil.init_array(@@acc_data539, @@LOTTO539_RANGE);
        #~ get_acc_data
        #~ 
        #~ @@analysis_num = 0
        #~ 
    #~ end
    #~ 
    #~ def init_statistics
        #~ @@data649 = Lotto649.curr_data  # maybe 'Lotto649.curr_data' is a new memory
        #~ 
        #~ init_acc
        #~ get_next_acc_data
        #~ 
    #~ end
    #~ 
    #~ def set_anal_cnt(cnt)
        #~ @analysis_num = cnt
    #~ end
    #~ 
    #~ def get_anal_cnt
        #~ return @analysis_num
    #~ end
end


## demo code
=begin
    engine = LottoEngine.new("649", Lotto649.curr_data)
    engine.init
    engine.set_drop_number(0)
    engine.reset
    engine.get_numbers
=end
