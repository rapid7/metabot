require 'nokogiri'
require 'open-uri'

class Google
  include Cinch::Plugin
  match /google (.+)/, method: :search

  def search(query)
    url = "http://www.google.com/search?q=#{::CGI.escape(query)}"
    res = Nokogiri::HTML(open(url)).at("h3.r")

    title = res.text
    link = res.at('a')[:href]
    desc = res.at("./following::div").children.first.text
    ::CGI.unescape_html "#{title} - #{desc} (#{link})"
  rescue
    "No results found"
  end

  def execute(m, query)
    output_or_link(m,search(query))
  end
end
