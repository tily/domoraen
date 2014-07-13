# coding:utf-8

require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

class Domoraen
	VERSION = File.read File.join File.dirname(__FILE__), '../VERSION'

	@env = ENV['DOMORAEN_ENV'] || 'test'

	class << self
		attr_accessor :env
	end

	def self.start
		@domoraen = Domoraen::Bot.new(
			config_file: File.dirname(__FILE__) + '/../conf/domoraen.yaml'
		)
		# TODO: update profile with current version

		loop do
			if text = @domoraen.produce_tool
				@domoraen.status(text)
			end

			@domoraen.replies.each do |tweet|
				text = @domoraen.react_to(tweet)
				@domoraen.reply(text, tweet)
			end

			@domoraen.update_config

			sleep SLEEP
		end
	end
end

require 'chatterbot'
#require 'domoraen/config'
#require 'domoraen/logger'
require 'domoraen/producer'
require 'domoraen/messenger'
require 'domoraen/markov'
require 'domoraen/bot'
require 'domoraen/cli'
