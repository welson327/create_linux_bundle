require_relative 'LottoUtil'

puts "Check 7-array:"
a = [5,27,29,36,40,42] #102108
p LottoUtil.check_is_7_array(a)
p LottoUtil.check_has_5x_7x_number(a)


puts "Check max_n_index:"
b = a.shuffle
puts "b=#{b}, max_n_index=#{LottoUtil.max_n_index(b, 8)}"


puts "Check neighbors:"
puts "neighbors=#{LottoUtil.get_neighbors(a, 5, 49)}"

