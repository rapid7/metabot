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
		c.channels = ["#metasploit"]
		c.realname = "metabot"
		c.user = "metabot"
		c.nick = "metabot"
		c.verbose = true
		#c.ssl = OpenStruct.new({:use => true, :verify => false})
		c.plugins.plugins = [ VmControl, System, Network, Framework, Nexpose, MsfPro, Test, Build, Jenkins ]
		@version = "0.3.0"
	end

	## !version command
	on :channel, /^!version/ do |m|
	  m.reply "#{bot.nick}: Version #{@version}"
	end
end

bot.start
