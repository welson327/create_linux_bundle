require 'open-uri'
#require_relative 'LOTTO'

class LottoArclinkParser
    private 
    @@WEBSITE = "http://lotto.arclink.com.tw/jsp/lotto/historyKind111000.jsp?n1=&n2=&n3="
    
    def initialize(url)
        @url = url
        @historyData = []
    end

    #--------------------------------------------------------------//
    
    public
    def parse
        
        @historyData = []
		src_code = []

		begin
			f = open(@url)
			src_code = f.readlines
            @historyData = getHistoryData(src_code)
		rescue OpenURI::HTTPError => e
			puts "Connect #{url} fail, msg:#{e.message}"
			#puts "raise OpenURI::HTTPError"
			#raise e
		rescue Exception => e
			#puts "raise Exception"
			#raise e
		ensure
			#puts "ensure-clause"
		end
		
		return @historyData
    end
    
    private
    def getHistoryData(src_code)
        output = []
        target_line = nil
        src_code.each_with_index do |v,i|
            if v.start_with?("a[0] = new Array")
                #puts "[#{i}] line=#{v}"
                target_line = v.chomp
                break
            end
        end
        #~ target_line = src_code.select {|v| v.start_with?("a[0] = new Array")}
        #~ p target_line
        
        arr = target_line.split(/;/)
        arr.each do |v|
            pos1 = v.index("(")
            pos2 = v.index(")")
            elem = v[pos1+1 ... pos2]   # "'093060', '20', '31', '33', '40', '42', '46', '30'"
            elem.gsub!("', '", " ")     
            elem = elem[1...-1]
            output.push(elem)
        end
        
        output.reverse!
        epi_from = output[0][0...6]
        epi_to   = output[-1][0...6]
        
        output_filename = "649_#{epi_from}-#{epi_to}.txt"
        f = File.new(output_filename, "w")
        output.each { |line| f.puts "#{line}" }
        
        return output
    end
end


WEBSITE = "http://lotto.arclink.com.tw/jsp/lotto/historyKind111000.jsp?n1=&n2=&n3="
parser = LottoArclinkParser.new(WEBSITE)
parser.parse
