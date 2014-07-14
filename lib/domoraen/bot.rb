# coding:utf-8
require 'logger'
require 'chatterbot'
require 'domoraen/logger'
require 'domoraen/producer'
require 'domoraen/messenger'

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
		case tweet[:text]
		when /モダンモード/
			if @mode == :modern
				text = "すでにモダンモードで稼働中です"
			else
				markov.load_chains('hatsumei')
				@mode = :modern
				text = "モダンモードに切り替えました"
			end
		when /クラシックモード/
			if @mode == :classic
				text = "すでにクラシックモードで稼働中です"
			else
				markov.load_chains('classic')
				@mode = :classic
				text = "クラシックモードに切り替えました"
			end
		else
			text = produce_tool_for(tweet[:text])
		end
		logger.info "reply: #{text}"
		text
	end
end
