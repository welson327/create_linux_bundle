class Bean
    def initialize(*arg)
        case arg.length
            when 0
                @epi_num = "------"
                @draw_num = [-1,-1,-1,-1,-1,-1]
                @special = -1
            # for 539
            when 2  
                @epi_num = arg[0]
                @draw_num = arg[1]
                @special = -1
            # for 649
            when 3  
                @epi_num = arg[0]
                @draw_num = arg[1]
                @special = arg[2]
            else
                puts "Error argument on Bean()"
        end     
    end
    
    # getter
    def getEpi
        return @epi_num
    end
    def getDrawNum(*argv)
		if argv.length == 0
			return @draw_num
		else
			index = argv[0]
			return @draw_num[index]
		end
    end
    #~ def getDrawNum(index)
        #~ return @draw_num[index]
    #~ end
    def getSpecialNum
        return @special
    end
    
    # setter
    def setEpi(epi)
        @epi_num = epi;
    end
    def setDrawNum(*argv) # draw is []
		if argv.length == 1
			draw = argv[0]
			@draw_num = draw
		elsif argv.length == 2
			index = argv[0]
			value = argv[1]
			@draw_num[index] = value
		end
    end
    #~ def setDrawNum(index, value)
        #~ @draw_num[index] = value;
    #~ end
    def setSpecialNum(sp)
        @special = sp
    end
	def info
        puts "[#{@epi_num}] #{@draw_num}, special: #{@special}"
	end
end
