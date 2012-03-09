require 'nokogiri'
require 'open-uri'
require 'cgi'

class UrbanDictionary
  include Cinch::Plugin

  match /urban (.+)/, method: :urban
  
  def urban(m, word)
    begin
      url = "http://www.urbandictionary.com/define.php?term=#{::CGI.escape(word)}"
      m.reply shorten(::CGI.unescape(Nokogiri::HTML(open(url)).at("div.definition").text.gsub(/\s+/, ' ')))
    rescue
      "Error: no results found"
    end
  end

  def shorten(string, count=200)
    if string.length >= count 
      shortened = string[0, count]
      splitted = shortened.split(/\s/)
      words = splitted.length
      string = splitted[0, words-1].join(" ") << ' ...'
    end
  string
  end

end
