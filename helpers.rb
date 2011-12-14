
def sandwich_type
	@sandwiches = ["pbnj", "turkey", "bologna", "ham", "mayonaise", "horsemeat", "chicken","lizard" ,"chicken liver", "liver and onion"]
@sandwiches[rand(@sandwiches.count)]
end

def metasploit_channel_key
  File.open(File.join(File.dirname(__FILE__), "..", "..", "secure", "channel_key.txt")).read
end

def filter_command(string)
	return "" unless string # nil becomes empty string
	return unless string.class == String # Allow other types unmodified		
	
	unless /^[\w\s\[\]\{\}\/\\\.\-\"\(\)]*$/.match string
		raise "WARNING! Invalid character in: #{string}"
	end

string
end

def output_or_link(m, message)

	m.reply(message) unless	File.directory?(tmp_directory)

	if message.lines.count < 4
		m.reply(message)
	else
		m.reply(link(message))
	end
end

def tmp_directory
  "/var/www/metabot-tmp"
end

def server_link
  "http://#{get_hostname}/metabot-tmp"
end

def get_hostname
	require 'socket'
	host = Socket.gethostname
end

def link(message)
  x  = random_string
  File.open("#{tmp_directory}/#{x}","w"){|file| file.puts(message)}
  return "#{server_link}/#{x}"
end

def random_string(size=16)
	chars = ('a'..'z').to_a + ('A'..'Z').to_a
	(0...size).collect { chars[Kernel.rand(chars.length)] }.join
end

def is_admin?(user)
	true if @admins.include? user.nick 
end
