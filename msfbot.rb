#/usr/bin/ruby

$:.unshift(File.dirname(__FILE__))
$:.unshift(File.join(File.dirname(__FILE__), "..", ".."))

require 'cinch'
require 'plugins'
require 'helpers'

bot = Cinch::Bot.new do
	configure do |c|
		c.server = "irc.freenode.net"
		c.port = 6667
		c.channels = ["#metasploit"]
		c.realname = "msfbot"
		c.user = "msfbot"
		c.nick = "msfbot"
		c.verbose = true
		c.plugins.plugins = [ MsfInfo ]
		@version = "0.9.9"
	end

	## !version command
	on :channel, /^!version/ do |m|
	  m.reply "#{bot.nick}: Version #{@version}"
	end
end

bot.start
