require_relative "#{Rails.root}/app/models/lotto/LOTTO"
require_relative "#{Rails.root}/app/models/lotto/LottoCalc"
require_relative "#{Rails.root}/app/models/lotto/Lotto649"
require_relative "#{Rails.root}/app/models/lotto/LottoFilter649"
require_relative "#{Rails.root}/app/models/lotto/LottoEngine"
require_relative "#{Rails.root}/app/models/lotto/LottoDataBackup"

class Lotto::LottoController < ApplicationController
	@@update_time = nil
	@@curr_data649 = nil
	
	def initialize
		@draw = nil
		@db_version = nil
		@engine = nil

		now = Time.now
		if update?(now)
			puts ">>> updating ..."
			Lotto649.new.update
			@@curr_data649 = Lotto649.curr_data
			@@update_time = now
			puts ">>> update done, version: #{Lotto649.curr_data[-1].getEpi}"

		else
			puts "Current db version, #{Lotto649.curr_data[-1].getEpi} , is latest version."
		end
		
		@engine = LottoEngine.new("649", Lotto649.curr_data)
	    @engine.init
	    @engine.set_drop_number(0)
	    @engine.reset
		
		@server_data = @@curr_data649
	end
	
	def index
		generate
	end
	
	def generate
		puts ">>> generate"
		@draw = Array.new(6, -1) if @draw == nil
		@engine.get_numbers(@draw)
	end
	
	
	def update?(now)
		if @@update_time == nil
			return true
		else
			if now > @@update_time
				#if (now.day > @@update_time.day)  ||
				#   (now.day == @@update_time.day  &&  now.hour>=22)
				if now.day > @@update_time.day
					return true
				else
					return false
				end
			else
				return false
			end
		end
	end
	
	def engine_info
		@engine_info = []
	end
	
=begin	
	def random(min, max)
		rand(max-min+1) + min
	end
	def jruby_test
		t = TimeStamp.new
		@jr = t.getTimeStamp("-", true)
	end
=end	
end
