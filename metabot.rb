#/usr/bin/ruby

$:.unshift(File.dirname(__FILE__))
$:.unshift(File.join(File.dirname(__FILE__), "..", ".."))

require 'cinch'
require 'plugins'
require 'helpers'

bot = Cinch::Bot.new do
	configure do |c|
		c.server = "localhost"
		c.port = 6667
		c.channels = ["#bots"]
		c.realname = "metabot"
		c.user = "metabot"
		c.nick = "metabot"
		c.verbose = true
		#c.ssl = OpenStruct.new({:use => true, :verify => false})
		c.plugins.plugins = [ VmControl, System, Network, FrameworkPlugin NexposePlugin, MsfPro ]
		@version = "0.3"
	end

	## !version command
	on :channel, /^!version/ do |m|
	  m.reply "#{bot.nick}: Version #{@version}"
	end

	on :channel, /!trout (.+)/ do |m, user|
		m.reply "#{bot.nick} slaps #{user} with a trout" 
	end

end

bot.start
