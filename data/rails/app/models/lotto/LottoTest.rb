require_relative 'LOTTO'
require_relative 'LottoUtil'
require_relative 'Lotto649'
require_relative 'LottoFilter649'
require_relative 'LottoEngine'
require_relative 'LottoDataBackup'

def time_elapsed(msg)
    t1 = Time.now
    printf("\n\n\n");
    puts "Start @ #{t1}, task: #{msg}"
    yield
    t2 = Time.now
    puts "End   @ #{t2}, time elapsed = #{t2-t1}"
end

class LottoTest
    private
        WIN_2 		= 0      # only for 539
        WIN_3 		= 1
        WIN_3_AND_1 = 2
        WIN_4 		= 3
        WIN_4_AND_1 = 4
        WIN_5 		= 5
        WIN_5_AND_1 = 6
        WIN_6 		= 7
        MATCH_2     = 20    # select 2 numbers and match 2 of 6(exclusive of special)
        MATCH_3     = 30
        MATCH_4     = 40
        NONE 		= -1
    
    public
    
    def initialize(type)
		@lotto_type = type
		@curr_data = nil
		@game = nil
		@filter = nil
		@random_match_cnt = 0
        
		
        case(type)
            when LOTTO::TYPE_649
                @game = Lotto649.new
                #@game.update();
                #@filter = LottoFilter649.new
                @curr_data = Lotto649.curr_data.clone();
                @engine = LottoEngine.new("649", @curr_data)
            
            when LOTTO::TYPE_539
                @game = Lotto539.new
                #@game.update();
                #@filter = LottoFilter539.new
                @curr_data = Lotto539.curr_data.clone();
                @engine = LottoEngine.new("539", @curr_data)
        end

        @engine.set_advance_prediction(false)
        @engine.init
        @engine.report
    end
    
    def get_number(rslt)
        @engine.get_numbers(rslt)
        #@engine.get_numbers_v2(rslt)
    end
        
    def get_lucky_cnt(input)
        cnt = 0
        rslt = Array.new(6, -1)
        goal = input.getDrawNum() # is []
        
        while(goal.eql?(rslt) == false)
            if(cnt > 100000)
                puts "lucky cnt over #{cnt}"
                break
            end
            
            cnt += 1
            get_number(rslt);
        end
            
        return cnt
    end
    
    # ========================================================
    # Purpose:     
    # Parameter:   Bean nth_game
    # Return:       match_cnt & profit
    # Remark:      
    # Revision:
    # ========================================================     
    def get_match_info(nth_game, simulated_cycles, is_use_ot)
        match_cnt = 0
        profit = 0
        cost = 0
        match_cnt, profit, cost = get_match_n_info(nth_game, simulated_cycles, is_use_ot, 6)
        return match_cnt, profit, cost
    end
    
    # ========================================================
    # Purpose:      n=2: 二合
    # Parameter:   
    # Return:      
    # Remark:      
    # Revision:
    # ========================================================  
    def get_match_n_info(nth_game, simulated_cycles, is_use_ot, n)
        match_cnt = 0
        profit = 0
        cycle_cnt = 0
        size = nth_game.getDrawNum().size
        rslt = Array.new(size, -1)
        cost = 0
        
		if n == 2
			rslts = @engine.get_politic_match2_numbers
			puts "engine -> match2 numbers: #{rslts}"
			
            rslts.each do |rslt|
                #permutation = rslt.permutation(n).to_a.each{|v| v.sort!}.uniq
                #puts "selected match2 permutation: #{permutation}" if n==2
                combination = rslt.combination(n).to_a
                combination.each do |v|
                    match_cnt += check_repeats(nth_game.getDrawNum(), v)
                    profit += get_profit(nth_game, v)
                end
                cost += combination.size * 25
            end
		else
			begin
				cycle_cnt += 1 
			
				if(is_use_ot)
					get_number(rslt)
				else
					@engine.get_random_number(@lotto_type, rslt)
				end
				
				match_cnt += check_repeats(nth_game.getDrawNum(), rslt)
				profit += get_profit(nth_game, rslt)
			end while cycle_cnt < simulated_cycles
			cost = cycle_cnt * 50
		end

		return match_cnt, profit, cost
    end
    
    # ========================================================
    # Purpose:     
    # Parameter:   Bean nth_game/Array rslt: 對照組(已開的)/實驗組(預測的)
    # Return:
    # Remark:      
    # Revision:
    # ========================================================      
    def get_profit(nth_game, rslt)
        bonus = 0
        win_type = NONE
            
        win_type = check_prize_type(nth_game, rslt);
        case(@lotto_type)
            when LOTTO::TYPE_649
                case(win_type)
                    when WIN_3
                        bonus += 400;
                    when WIN_3_AND_1
                        bonus += 1000;
                    when WIN_4
                        bonus += 4000;
                    when WIN_4_AND_1
                        bonus += 20000;
                    when WIN_5
                        bonus += 80000;
                    when WIN_5_AND_1
                        bonus += 1500000;
                    when WIN_6
                        bonus += 150000000;
                    when MATCH_2
                        bonus += 1250;
                    when MATCH_3
                        bonus += 12500;
                    when MATCH_4
                        bonus += 200000;
                end
            
            when LOTTO::TYPE_539
                case(win_type)
                    when WIN_2
                        bonus += 50;
                    when WIN_3
                        bonus += 300;
                    when WIN_4
                        bonus += 20000;
                    when WIN_5
                        bonus += 8000000;
                end
        end
        
        cost = rslt.length>=5 ? 50 : 25
        
        return (bonus - cost)
    end
    
    # ========================================================
    # Purpose:     
    # Parameter:   Bean nth_game: n-th db data to simulate
    # Return:
    # Remark:      
    # Revision:
    # ========================================================    
    def get_balance_cnt(nth_game)
        #~ balance = 0
        #~ bonus = 0
        #~ cnt = 0
        #~ rslt = Array.new(6, -1)
        #~ goal = nth_game.getDrawNum()
        #~ prize_type = NONE;
        #~ 
        #~ while(balance <= 0)
            #~ cnt += 1
            #~ balance += get_profit(nth_game, 1)
            #~ 
            #~ if(cnt % 100000 == 0)
                #~ printf("cnt/balance = %d/%d\n", cnt, balance)
            #~ end
            #~ if(cnt > 300000)
                #~ printf("Can not balance!!!!\n")
                #~ break
            #~ end
        #~ end
        #~ 
        #~ printf(">>> cnt/balance = %d/%d\n", cnt, balance)
        #~ return cnt
    end
    
    # check if LottoEngine's random is isotropic
    def check_random 
        acc = Array.new(49, 0)
        numbers = Array.new(6, -1)
        10000.times do |i|
            @engine.get_random_number(LOTTO::TYPE_649, numbers)
            numbers.each{ |v| acc[v-1] += 1}
        end
        
        puts "[#{__FILE__}] check_random:"
        p acc
    end
    
    # ========================================================
    # Purpose:     
    # Parameter:   	Bean bean: Control Group, 
    #				int ot_num[]: Experiment Group
    # Return:
    # Remark:      	ot_num: numbers generated by OT  
    # Revision:
    # ========================================================
    def check_prize_type(bean, ot_num)
        cnt = 0
        sp = 0
        
		return NONE if(bean==nil  ||  ot_num==nil)
        
        cnt = check_repeats(bean.getDrawNum(), ot_num)

        if ot_num.include?(bean.getSpecialNum)
            sp += 1
        end
        
        #printf("[check_prize_type] cnt/sp = %d,%d\n", cnt, sp);

        case(cnt)
            when 2
				if(sp==0 && cnt==ot_num.size) # for 649
					return MATCH_2
				elsif(sp==0)
					return WIN_2
				end
            when 3
				if(sp==0 && cnt==ot_num.size) # for 649
					return MATCH_3          
				elsif(sp==0)
					return WIN_3
				else
					return WIN_3_AND_1
				end
            when 4
				if(sp==0 && cnt==ot_num.size) # for 649
					return MATCH_4            
				elsif(sp==0)
					return WIN_4
				else
					return WIN_4_AND_1
				end
            when 5
				if(sp==0)
					return WIN_5
				else
					return WIN_5_AND_1
				end
            when 6
				return WIN_6
            else
				return NONE
        end
    end
    
    private 
    def check_repeats(arr1, arr2)
        return LottoUtil.check_repeats(arr1, arr2)
    end
    
    
    public 
    def check_rate_of_OT_rule
		_pass_rate = 0.80 #15.to_f / 15
        n = 200;
        cnt = 0;
        drops = 0;
        rate = 0.0
        
        for i in 0...n
            drops = i+1
            bean = @curr_data[-drops]; #@curr_data[@curr_data.length-1-(drops-1)];
            tmp = bean.getDrawNum();  
            
            # reset filter
            #puts "\nDrop #{drops} games to check pass_rate of #{bean.getEpi()}"
            printf("\nDrop %d games to check pass_rate of %s\n", drops, bean.getEpi());
            @filter.set_drop_numbers(drops);
            @filter.reset_filter();

            if(@filter.pass_rate(tmp, tmp.length) >= _pass_rate)
                cnt += 1
            end
        end
        
        rate = cnt.to_f / n
        printf("\n\n\n[649] rate_of_OT_rule(>=%.2f) = %.2f, n = %d\n", _pass_rate, rate, n)
        return rate
    end 
    
    def check_match_cnt
        coming_game = nil
        sets = 1;
        profit_woap=0; profit_wap=0; profit_wap_match2=0; profit_random=0;
        ap = true;# ap = advanced prediction
        total_match_cnt_without_ap = 0;
        total_match_cnt_with_ap = 0;
        total_match2_cnt_with_ap = 0;
        total_match_cnt_random = 0;
        total_cost_match2 = 0;
        drops = 16;

        

        # check match cnt
        for i in 1..drops
            game_profit_wap = 0;	#wap=with ap, 
            game_profit_woap = 0;	#woap=without ap
            game_profit_random = 0;
            cnt = Array.new(4, 0)
            game_profit = Array.new(4, 0)
            cost = Array.new(4, 0)
            

            coming_game = Lotto649.curr_data[Lotto649.curr_data.length-i];
            prev_game = Lotto649.curr_data[Lotto649.curr_data.length-i-1];
            printf("\n\n>>> Drops: %d\n", i);
            printf("coming_game info: "); coming_game.info();
            printf("prev_game info: "); prev_game.info();
            @engine.set_drop_number(i)
            @engine.reset
            #@engine.report
            
            #printf(".set_advance_prediction(false)\n")
            #@engine.set_advance_prediction(false)
            #cnt[0], game_profit[0], cost[0] = get_match_info(coming_game, sets, true)

            #printf(".set_advance_prediction(true)\n")
            #@engine.set_advance_prediction(true)
            #cnt[1], game_profit[1], cost[1] = get_match_info(coming_game, sets, true)
            cnt[2], game_profit[2], cost[2] = get_match_n_info(coming_game, sets, true, 2)
            
            # random
            #cnt[3], game_profit[3], cost[3] = get_match_info(coming_game, sets, false)
            
            
            # match cnt
            printf("match_cnt(woap/wap/wap(match2)/random) for %d sets a game = %d/%d/%d/%d\n", sets, cnt[0], cnt[1], cnt[2], cnt[3])
            total_match_cnt_without_ap += cnt[0]
            total_match_cnt_with_ap    += cnt[1]
            total_match2_cnt_with_ap   += cnt[2]
            total_match_cnt_random     += cnt[3]
            
            # total cost
            total_cost_match2 += cost[2]
            
            # profit
            printf("game_profit(woap/wap/wap(match2)/random) = %d/%d/%d/%d\n", game_profit[0], game_profit[1], game_profit[2], game_profit[3])
            printf("cost(normal/match2) = %d/%d\n", cost[0], cost[2])
            profit_woap         += game_profit[0]
            profit_wap          += game_profit[1]
            profit_wap_match2   += game_profit[2]
            profit_random       += game_profit[3]

            
            # balance cnt
            #System.out.printf("balance_cnt = %d with ap=%b\n", get_balance_cnt(coming_game), ap);
        end

        printf("\n\n\n")
        printf(">>> [Test Runs: %d]\n", drops)
        printf(">>> Total match_cnt(woap/wap/wap(2)/random) in %d games is %d/%d/%d/%d\n", drops, total_match_cnt_without_ap, total_match_cnt_with_ap, total_match2_cnt_with_ap, total_match_cnt_random)
        printf(">>> OT_without_ap / random = %.3f\n", total_match_cnt_without_ap.to_f / total_match_cnt_random)
        printf(">>> OT_with_ap / random = %.3f\n", total_match_cnt_with_ap.to_f / total_match_cnt_random)
        printf(">>> total cost of match2 = %d\n", total_cost_match2)
        printf(">>> profit(woap/wap/wap(2)/random) = %d/%d/%d/%d within %d games\n", profit_woap, profit_wap, profit_wap_match2, profit_random, drops)
        @engine.info()    
    end 
end


printf("\n\n ======================================== \n");
printf("649 info: \n");
ltest = LottoTest.new(LOTTO::TYPE_649)
#ltest.check_random
#p ltest.check_prize_type(Lotto649.curr_data[Lotto649.curr_data.length-1], [38,40])
#ltest.check_rate_of_OT_rule
time_elapsed "check_match_cnt" do
    ltest.check_match_cnt
end
