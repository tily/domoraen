# coding:utf-8
require 'thor'
require 'uri'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'earthquake'

class Domoraen::Cli < Thor
	option :save, type: :boolean
	desc 'classic', 'scrape classic tools and update database'
	def classic
		tools = []
		%w|ひみつ道具一覧_(あ-そ) ひみつ道具一覧_(た-わ)|.each do |page|
			url = URI.escape("http://ja.wikipedia.org/wiki/#{page}")
			xpath1 = '//*[@id="mw-content-text"]/ul/li/a/text()'
			xpath2 = '//*[@id="mw-content-text"]/ul/li/text()'
			doc = Nokogiri::HTML(open(url).read)
			tools1 = doc.xpath(xpath1).map {|x| x.to_s }
			tools2 = doc.xpath(xpath2).map do |x|
				x.to_s.gsub(/(（.+|→|⇒|\s)/) {''}
			end
			tools2 = tools2.reject {|x| x == '' || x == 'ー' || x[/^[\(\)（）]/] }
			tools += tools1
			tools += tools2
		end
		if options[:save]
			db = domoraen.markov.read_db('classic') rescue {}
			db.update("originals" => tools)
			domoraen.markov.write_db('classic', db)
		end
		puts tools
	end

	option :save, type: :boolean
	desc 'tools', 'scrape tools and update database'
	def tools
		url = URI.escape("http://ja.doraemon.wikia.com/wiki/道具一覧")
		xpath = '//*[@id="mw-content-text"]/ul/li/a/text()'
		doc = Nokogiri::HTML(open(url).read)
		tools = doc.xpath(xpath).map {|x| x.to_s.gsub(/（道具）/) {''} }
		if options[:save]
			db = domoraen.markov.read_db('tools') rescue {}
			db.update("originals" => tools)
			domoraen.markov.write_db('tools', db)
		end
		puts tools
	end

	desc 'hatsumei', 'scrape hatsumei and add new items to database'
	def hatsumei
		db = domoraen.markov.read_db('hatsumei') rescue {'originals' => []}
		known = db['originals']
		tools = []
		1.upto(500) do |i|
			begin
				puts "scraping page #{i}"
				url = URI.escape("http://www.j-tokkyo.com/page/#{i}")
				xpath = '//h3[@class="storytitle"]/a/text()'
				doc = Nokogiri::HTML(open(url).read)
				found = doc.xpath(xpath).map {|x| x.to_s }
				p found
				break if (known & found).size > 0
				tools += found
			rescue OpenURI::HTTPError => e
				break
			end
		end
		tools = tools | known
		db.update("originals" => tools)
		domoraen.markov.write_db('hatsumei', db)
	end

	option :target, required: true
	desc 'chain', 'create markov chain index and update database'
	def chain
		db = domoraen.markov.read_db(options[:target])
		db['originals'].each do |text|
			domoraen.markov.add_chain(text)
		end
		domoraen.markov.save_chains(options[:target])
	end

	option :target, required: true
	desc 'markov', 'generate markov sentence using database'
	def markov
		domoraen.markov.load_chains(options[:target])
		puts domoraen.markov.generate
	end

	desc 'console', 'start console'
	def console
		Earthquake.start(dir: File.dirname(__FILE__) + "/../../conf/#{Domoraen.env}/earthquake/")
	end

	no_commands do
		def domoraen
			@domoraen ||= Domoraen::Bot.new(config_file: File.dirname(__FILE__) + "/../../conf/#{Domoraen.env}.yaml")
		end
	end
end
