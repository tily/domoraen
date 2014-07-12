# coding:utf-8
require 'thor'
require 'uri'
require 'nokogiri'
require 'open-uri'
require 'json'

class Domoraen::Cli < Thor
	option :save, type: :boolean
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

	no_commands do
		def domoraen
			@domoraen ||= Domoraen::Bot.new(config_file: File.dirname(__FILE__) + '/../../conf/domoraen.yaml')
		end

	end
end
