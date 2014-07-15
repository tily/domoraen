# coding:utf-8

require 'logger'
require 'json'
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

class Domoraen
	SLEEP = 60
	VERSION = File.read(File.join File.dirname(__FILE__), '../VERSION').chomp

	@env = ENV['DOMORAEN_ENV'] || 'test'
	@logger = Logger.new(File.join File.dirname(__FILE__), "../log/#{@env}.log")

	class << self
		attr_accessor :env
		attr_accessor :logger

		def stream
		end

		def start
			@domoraen = Domoraen::Bot.new(
				config_file: File.dirname(__FILE__) + "/../conf/#{Domoraen.env}.yaml"
			)
			@domoraen.markov.load_chains('hatsumei')
			@domoraen.update_profile
			logger.info 'starting'

			loop do
				logger.info 'loop start'
				begin
					logger.info 'receiving messages'
					messages = @domoraen.queue.receive_message(:limit => 5)
					messages.each do |message|
						begin
							logger.info "received: #{message.body}"
							json = JSON.parse(message.body)
							@domoraen.client.update("#{json['user']} ハイ 「#{json['text']}」#{'!'*(1..3).to_a.sample}", :in_reply_to_status_id => json['status_id'])
						rescue StandardError => e
							logger.info "#{e.class}: #{e.message}"
						ensure
							message.delete
						end
					end

					if rand(10) == 1
						logger.info 'tweeting'
						if text = @domoraen.produce_tool
							@domoraen.tweet(text)
						end
					end

					if rand(2) == 1
						@domoraen.replies.each do |tweet|
							if tweet.user.screen_name == "domoraen"
								logger.warn 'self reply detected. skipping ...'
							end
							@domoraen.react_to(tweet)
						end
					end

					@domoraen.update_config
				rescue Exception => e
					logger.error e
					@domoraen.tweet "@tily #{e.class}: #{e.message}"
					next
				end

				logger.info 'loop end'
				sleep 60
			end
		end
	end
end

require 'chatterbot'
require 'domoraen/producer'
require 'domoraen/messenger'
require 'domoraen/markov'
require 'domoraen/bot'
require 'domoraen/cli'
require 'domoraen/future'
