class LOTTO
    # enum
    TYPE_649 = 0
    TYPE_539 = 1
    TYPE_6388 = 2

	@name = ""
    @dim = 0           # ex: 649 is 6
    @range = 0         # ex: 649 is 49
    @def_db_ver = ""   # default db version
    @curr_db_ver = ""  # current db version = def db + web data

    attr_accessor :name, :dim, :range, :def_db_ver, :curr_db_ver




    def self._EPI_NUM(epi)
        # web db epi_num is "100000123"
        if(epi.length > 6)
            left = epi.slice(0..2)    # "100"
            right = epi.slice(-3..-1) # "123"
            return (left + right)
        else
            return epi
        end
    end

    #~ =====================================================
    #~ Purpose:  	check data gap       
    #~ Parameter:   Bean[] data
	#~ Return: 		length of gap
	#~ Remark:		We don't know the last game per year(maybe 102-106), but not a bug.
	#~ Author: 		welson
    #~ ===================================================== 	
	def self.check_max_data_gap(data)

        return 0 if data==nil
		
        (data.length).downto(1) do |i|
			curr_epi = data[i].getEpi();
			prev_epi = data[i-1].getEpi();
    		curr = curr_epi.slice(-3..-1).to_i;
    		prev = prev_epi.slice(-3..-1).to_i;
    		gap = curr - prev;
    		if(gap > 1)
    			return gap
    		elsif(gap < 1  &&  curr > 1)
    			return (105-prev)+curr
			elsif(gap < 1  &&  curr == 1)
				gap = 1
            end
    	end
    	return gap
    end
end
