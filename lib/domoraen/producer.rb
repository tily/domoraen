# coding:utf-8

module Domoraen::Producer
	NOES = %w|もう大人でしょ…  自分でなんとかしろよ… それ無理…|

	def markov
		@markov ||= Domoraen::Markov.new
	end

	def produce_tool
		tool = @markov.generate
		tool ?  tool + suffix : nil
	end

	def produce_tool_for(text)
		words = function_words(text)
		tools = words.map {|word| @markov.generate(word) }.compact
		return NOES.sample if tools.empty?
		prefix + tools.sample + suffix
	end

	def function_words(text)
		node_list = markov.get_node_list(text)
		node_list.select {|node|
			node[:surface] != 'EOS' &&
			node[:feature] =~ /^(名詞|動詞|形容詞)/u
		}.map {|node| node[:surface] }
	end

	def prefix
		"ハイ "
	end

	def suffix
		'!' * (1..3).to_a.sample
	end
end
