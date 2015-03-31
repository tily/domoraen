require 'httparty'

class Domoraen::MorphAnalysis
  include HTTParty
  base_uri 'http://jlp.yahooapis.jp/MAService/V1'

  def initialize(options={})
    @appid = options[:appid] || ENV['YAHOO_JLP_APP_ID']
    if @appid.nil?
      raise 'Error: appid is not specified.'
    end
  end

  def word_list(sentence)
    response = self.class.post('/parse', :body => {appid: @appid, sentence: sentence, results: 'ma'})
    response['ResultSet']['ma_result']['word_list']['word']
  end

  def func_words(sentence)
    list = word_list(sentence)
    list = list.select { |item| %w(動詞 名詞 形容詞).include?(item['pos']) }
    list.map {|item| item['surface'] }
  end
end
