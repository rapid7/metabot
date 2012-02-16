require 'nokogiri'
require 'open-uri'
require 'cgi'

class UrbanDictionary
  include Cinch::Plugin

  match /urban (.+)/, method: :urban
  
  def urban(m, word)
  	begin
	    url = "http://www.urbandictionary.com/define.php?term=#{::CGI.escape(word)}"
	    m.reply ::CGI.unescape(Nokogiri::HTML(open(url)).at("div.definition").text.gsub(/\s+/, ' '))
	rescue
		"Error: no results found"
	end
  end
end
