# coding:utf-8
#require 'mecab'

class Domoraen::Markov
	def db_path(name)
		File.join File.dirname(__FILE__), "/../../data/#{name}.json"
	end

	def read_db(name)
		JSON.parse File.read db_path(name)
	end

	def write_db(name, content)
		File.write db_path(name), JSON.pretty_generate(content)
	end

	def add_chain(text)
		@chains ||= Hash.new {|h, k| h[k] = []}
		@firsts ||= []
		node_list = get_node_list(text)
		node_list.each_cons(2) do |first, second|
			key, val = first[:surface], second[:surface]
			val = 'EOS' if val == ''
			@chains[key] << val
			if first[:feature].encode('utf-8') !~ /^(助詞|助動詞|記号|連体詞|フィラー|接続詞)/
				@firsts << key unless @firsts.include?(key)
			end
		end
	end

	def load_chains(name)
		db = read_db(name)
		@chains, @firsts, @originals = db['chains'], db['firsts'], db['originals']
	end

	def save_chains(name)
		db = read_db(name)
		db.update('chains' => @chains, 'firsts' => @firsts)
		write_db(name, db)
	end

	def generate(first=nil)
		first ||= @firsts.sample
		return nil unless @chains[first]
		text = ''
		until first == 'EOS'
			text += first
			first = @chains[first].sample
		end
		text = text.gsub(/[\(\)（）「」]/) {''}
		return nil if @originals.include?(text)
		text
	end

	def get_node_list(text)
		list = []
		tagger = MeCab::Tagger.new
		node = tagger.parseToNode(text)
		while node = node.next
			elem = {
				surface: node.surface.force_encoding('utf-8'),
				feature: node.feature.force_encoding('utf-8')
			}
			list << elem
		end
		list
	end
end
