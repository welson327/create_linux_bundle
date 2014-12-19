require_relative 'LOTTO'
require_relative 'LottoUtil'
require_relative 'Lotto649'
require_relative 'LottoDataBackup'
require_relative 'LottoEngine'

def main
	puts "This is ruby version of OT"
    
=begin    
    puts ">>> [LottoUtil.rb]"
	arr = [6,5,4,3,2]
	
	puts "min(55,10) = %d" % LottoUtil.min(55,10)
	printf("fact(15) = %d\n", LottoUtil.fact(15))
	printf("C(10,3) = %d\n", LottoUtil.C_n_m(10,3))
	
	LottoUtil.bubble_sort(arr)
	p arr
	
	arr = [11,25,22,23,25,16]
	printf("parity = %d\n", LottoUtil.parity(arr))
	printf("check_is_train() = %d\n", LottoUtil.check_is_train(arr))
	printf("check_is_repeat() = %d\n", LottoUtil.check_is_repeat(arr, 25))
	printf("check_is_7_array() = %s\n", LottoUtil.check_is_7_array(arr))
	printf("check_repeats() = %s\n", LottoUtil.check_repeats(arr, [11,22,33,44,55]))
	printf("check_ac_value() = %d\n", LottoUtil.check_ac_value(arr, 6))
    
    dst = []
    LottoUtil.array_copy(dst, arr)
    p dst
    
    LottoUtil.init_array(dst, dst.length)
    p dst
    
    arr = [1,3,5,7,9]
    printf("array_sum(arr) = %d\n", LottoUtil.array_sum(arr, arr.length))
    
    0.upto(5) { |i|
        printf("select_random(2,5) = %d\n", LottoUtil.select_random(2,5,5))
    }
    
    printf("find_max_index() = %d\n", LottoUtil.find_max_index(arr, arr.length))
    
    arr = [22,33,44,52,67]
    h = LottoUtil.get_tail_number(arr)
    printf("tail numbers: "); p h
    
    LottoUtil.set_candidate(arr, arr.length, 2, 4)
    p arr
    
    arr = [100,11,12,13,100,12,14,9,1,100,22,10]
    #~ LottoUtil.init_candidate
    printf("find_peak_value() = %d\n", LottoUtil.find_peak_value(arr, arr.length, 3))

    
    
    puts ">>> [Bean.rb]"
    require 'Bean'
    Bean.new("1023345", [5,10,22,33,44,49], 18).info


    
    puts ">>> [LOTTO.rb]"
    require 'LOTTO'
    puts LOTTO._EPI_NUM("100000123")
    
    
=end


    puts ">>> [Lotto649.rb]"
    #lotto649 = Lotto649.new
    #lotto649.update

    puts ">>> [LottoDataBackup.rb]"
	LottoDataBackup.run(LOTTO::TYPE_649)


	puts "Lotto649.latest_10s = "
    p Lotto649.latest_10s


    puts ">>> [LottoEngine.rb]"
    rslt = Array.new(6, -1)

    engine = LottoEngine.new("649", Lotto649.curr_data)
    engine.init
    engine.set_drop_number(0)
    engine.reset

    10.times do |i| 
		engine.get_numbers(rslt)
        p rslt
    end

	puts "<END>"
end


main
