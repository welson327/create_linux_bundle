require 'json'

class Example::ApiController < ApplicationController
	def hash
		puts "----------------> /hash"
		request_body = request.body.read
		puts "request.body.read=#{request_body}"
		puts "request_body[:keyword]=#{request_body["keyword"]}"
		puts "params=#{params}"
		puts "params[:keyword]=#{params[:keyword]}"
		
		keyword = params[:keyword];
		
		h = {}
		h[:before] = keyword
		h[:after] = keyword.reverse
		respond_to do |format|
			format.json {
				render json: h
			}
			format.text {
				render text: h.to_s
			}
		end
	end
	
	def get_magic
		puts "----------------> /get_magic"
		
		params.each do |key,value|
			puts "GET: params[#{key}]:#{value}"
		end
		
		h = {}
		h[:magicNumber] = 312
		h[:resultCode] = 200
		respond_to do |format|
			format.json {
				render json: h
			}
			format.text {
				render text: h.to_s
			}
		end
	end
end
