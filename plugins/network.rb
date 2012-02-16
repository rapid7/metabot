class Network
  include Cinch::Plugin

	match /nmap (.+)/, method: :nmap
	match /ping (.+)/, method: :ping
	match /ping_long (.+) (.+)/, method: :ping_long
	
	
	def initialize(*args)
		super(*args)
	end
	
	def nmap(m, range)	
		output_or_link m, `nmap #{filter_command(range)}` if is_admin? m.user
	end
	
	def ping(m, system)	
		output_or_link m, `ping -c 2 #{filter_command(system)}` if is_admin? m.user
	end		

	def ping_long(m, system, count=100)
		output_or_link m, `ping -c #{filter_command(count)} #{filter_command(system)}` if is_admin? m.user
	end	
end
