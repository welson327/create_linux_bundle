require_relative 'Bean'

class DataProvider
    def initialize(file_path)
        @file_path = file_path
        @bean_array = []
    end
    
    def get_data
        f = File.new(@file_path, "r")
        lines = f.readlines
        lines.each do |line|
            if line.include? "<END>"
                break
            end
            
            line = line.chomp
            elem = line.split(/ /)

            if @file_path.end_with?("649.txt")
				epi = elem[0]
				draw_num = elem[1..6].collect{|v| v.to_i}
				special = elem[7].to_i
			elsif @file_path.end_with?("539.txt")
				epi = elem[0]
				draw_num = elem[1..5].collect{|v| v.to_i}
				special = -1			
			elsif @file_path.end_with?("3star.txt")
				epi = elem[0]
				draw_num = elem[2..4].collect{|v| v.to_i}
				special = -1			
			end
			
            @bean_array.push(Bean.new(epi, draw_num, special))
        end
        puts "[DataProvider] Read Last Doc: #{@bean_array[-1].getEpi}"
        return @bean_array
    end
end

#file_path = "data" +  File::SEPARATOR + "649_093060-103013.txt"
#dp = DataProvider.new(file_path)
#dp.get_data
