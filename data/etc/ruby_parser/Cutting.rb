file = ARGV[0]

def parse(file)
	
	total = 0
	File.open(file).readlines.each do |line|
		num = line.chomp.split(/\t/)[2].to_i
		total += num
	end
	return total
end

puts "Parsing #{file}:\n"
total = parse(file)
puts "Total = #{total}"
