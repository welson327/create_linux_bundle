require_relative 'LOTTO'

class LottoDataBackup
    @@SEP = File::SEPARATOR

    def self.put(bean_array, dst_path)
        f = File.new(dst_path, "w")
        bean_array.each do |bean|
            epi = LOTTO._EPI_NUM(bean.getEpi)
            draw_str = bean.getDrawNum.join(" ")
            
            if (bean.getSpecialNum == -1) # 539
                f.puts "#{epi} #{draw_str}"
            else
                f.puts "#{epi} #{draw_str} #{bean.getSpecialNum}"
            end
        end
    end
    
    def self.run(type)
        t = Time.now
        ts = sprintf("%04d%02d%02d-%02d%02d%02d", t.year, t.month, t.day, t.hour, t.min, t.sec)
        lotto = nil
        curr_data = nil
        case(type)
            when LOTTO::TYPE_539
                lotto = Lotto539.new.update
                dst = sprintf("data%s539_%s.txt", @@SEP, ts)
                curr_data = Lotto539.curr_data
            else
                lotto = Lotto649.new.update
                dst = sprintf("data%s649_%s.txt", @@SEP, ts)
                curr_data = Lotto649.curr_data
        end
        
        if Lotto649.get_update_status == true
			LottoDataBackup.put(curr_data, dst)
		else
			puts "Lotto(#{type}) update fail!"
		end
    end
end
