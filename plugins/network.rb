class Network
  include Cinch::Plugin

	match /nmap (.+)/, method: :nmap
	match /ping (.+)/, method: :ping
	match /ping_long (.+) (.+)/, method: :ping_long
	
	
	def initialize(*args)
		super(*args)
	end
	
	def nmap(m, range)	
		m.reply "nmapping #{system}"
		output_or_link m, `nmap #{filter_command(range)}`
	end
	
	def ping(m, system)
		m.reply "pinging #{system}"
		output_or_link m, `ping -c 2 #{filter_command(system)}`
	end		

	def ping_long(m, system, count=100)
		m.reply "pinging #{system} #{count} times"
		output_or_link m, `ping -c #{filter_command(count)} #{filter_command(system)}`
	end	
end
