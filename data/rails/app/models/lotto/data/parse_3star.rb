## ref: http://www.9800.com.tw/trend.asp?p1=100001&p2=103052&l=0&type=3


f = File.new("3star_100001-103052.txt", "r")

lines = f.readlines
output = []

#"103051\t2014-02-28\t0 8 3\t0\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t8\t\t\t\t\t3\t\t\t\t\t\t\t11\t1:2\n"
lines.each do |line|
	arr = line.split(/[\t\n]{1,}/)
	output.push(arr[0]+" "+arr[1]+" "+arr[2])
	#output.push(arr[0]+" "+arr[1]+" "+arr[2].delete(" "))
end

f = File.new("3star.txt", "w")
output.each { |v| f.write(v + "\n") }
