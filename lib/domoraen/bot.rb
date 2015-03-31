# coding:utf-8
require 'logger'
#require 'chatterbot'
require 'domoraen/logger'
require 'domoraen/producer'
require 'domoraen/messenger'
require 'domoraen/future'
require 'json'

class Domoraen::Bot < Chatterbot::Bot
	include Domoraen::Logger
	include Domoraen::Producer
	include Domoraen::Messenger

	attr_accessor :config_file
	attr_accessor :markov

	def initialize(params={})
		@config_file = params.delete(:config_file)
		@markov = Domoraen::Markov.new
		@mode = :modern
		super(params)
	end

	def update_profile
		client.update_profile(
			name: 'domoraen',
			url: 'https://github.com/tily/domoraen',
			description: "猫型マルコフロボット／@リプライで便利な道具を出す／何かありましたら tily まで (v#{Domoraen::VERSION})"
		)
	end

	def react_to(tweet)
		logger.info "reply received: #{tweet}"
		text = nil
		#to_status_id = true
		case tweet[:text]
		when Domoraen::Future::REGEXP
			match = Regexp.last_match
			sec = Domoraen::Future.parse_match(match)
			logger.info "messenger sec: #{sec}"
			if sec < 60*3 || sec > 60 * 60 * 24 * 14
				text = "3 分以上 14 日間以内でないと無理です #{Time.now.to_i}"
			else
				message = {'text' => match[:echo], 'user' => tweet_user(tweet), 'status_id' => tweet[:id] }.to_json
				queue.send_message(message, :delay_seconds => sec)
				text = "約 #{sec} 秒後にエコーします #{Time.now.to_i}"
				#to_status_id = false
			end
		when /モダンモード/
			if @mode == :modern
				text = "すでにモダンモードで稼働中です #{Time.now.to_i}"
			else
				markov.load_chains('hatsumei')
				@mode = :modern
				text = "モダンモードに切り替えました #{Time.now.to_i}"
			end
		when /クラシックモード/
			if @mode == :classic
				text = "すでにクラシックモードで稼働中です #{Time.now.to_i}"
			else
				markov.load_chains('classic')
				@mode = :classic
				text = "クラシックモードに切り替えました #{Time.now.to_i}"
			end
		else
			text = produce_tool_for(tweet[:text])
		end
		logger.info "reply: #{text}"
		#if to_status_id
			reply "#{tweet_user(tweet)} #{text}", tweet
		#else
		#	client.update "#{tweet_user(tweet)} #{text}"
		#end
	end
end
