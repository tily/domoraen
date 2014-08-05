require 'domoraen'
require 'json'
require 'sinatra/base'

$DomoraenHttpdGlobals = {}

class Domoraen::Httpd < Sinatra::Base
	include Domoraen::Producer
	set :globals, $DomoraenHttpdGlobals

	before do
		content_type :json
		markov.load_chains(settings.globals['chains'] || 'tools')
	end

	error do |e|
		{error_class: e.class.to_s, error: e.message}.to_json
	end

	get '/' do
		redirect 'https://twitter.com/domoraen'
	end

	get '/healthcheck.json' do
		{status: 'success'}.to_json
	end

	get '/tools.json' do
		while !@message || @message == 'null'
			@message = produce_tool
		end
		{message: @message}.to_json
	end

	get '/tools/:seed.json' do
		while !@message || @message == 'null'
			@message = produce_tool_for params[:seed]
		end
		{message: @message}.to_json
	end

	post '/chains/:name/activation.json' do
		unless %w(classic hatsumei tools).include? params[:name]
			raise "chain #{params[:name]} not available"
		end
		settings.globals['chains'] = params[:name]
		{status: 'success', new_chain: params[:name]}.to_json
	end
end
