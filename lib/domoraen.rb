# coding:utf-8

class Domoraen
	VERSION = File.read File.join File.dirname(__FILE__), '../VERSION'

	@env = ENV['DOMORAEN_ENV'] || 'test'

	class << self
		attr_accessor :env
	end
end

require 'chatterbot'
#require 'domoraen/config'
#require 'domoraen/logger'
require 'domoraen/dsl'
require 'domoraen/producer'
require 'domoraen/messenger'
require 'domoraen/markov'
require 'domoraen/bot'
require 'domoraen/cli'
