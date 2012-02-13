require 'msfrpc-client'

class Framework
  include Cinch::Plugin
	
	# Administrative commands
	match /msf_connect (.+) (.+) (.+)/, method: :connect
	match /msf_ver/, method: :version
	match /msf_version/, method: :version

	# Info commands
	match /msf_list_exploits/, method: :list_exploits
	match /msf_list_auxiliary/, method: :list_auxiliary
	match /msf_list_post/, method: :list_post
	match /msf_list_payloads/, method: :list_payloads
	match /msf_list_encoders/, method: :list_encoders
	match /msf_list_nops/, method: :list_nops	
	match /msf_module_info (.+)/, method: :module_info		

	# Module commands
	match /msf_run_module (.+) (.+)/, method: :run_module
	
	# Session commands
	match /msf_list_sessions/, method: :show_sessions	
	match /msf_session (.+) (.+)/, method: :session_command

	# Job commands
	match /msf_list_jobs/, method: :list_jobs	
	match /msf_job_info (.+)/, method: :job_info		

	# Console commands
	match /msf_console (.+)/, method: :console_command

	def initialize(*args)
		super(*args)
		@username = nil
		@password = nil
		@console_num = nil
		@console_watcher = nil
		@session_watcher = nil
		@session_threads = []
	end

	def connect(m, system, username, password)
		@system = system
		@username = username
		@password = password

		@rpc  = Msf::RPC::Client.new(:host => @system, :port => "55552", :user => @username, :pass => @password, :ssl => false )
				
		if @rpc
			m.reply "#{bot.nick} connected to #{@system} with user #{@username}"
		else 
			m.reply "no dice"
		end
		
		_create_console(m)

		@console_watcher = Thread.new do
			while true
				message = @rpc.call("console.read", @console_num)
				if message["data"] != ""
					m.reply("#{message['prompt']} #{message['data']}")
				end
				sleep 1
			end
		end

		@sessions_watcher = Thread.new do
			while true
				sessions = @rpc.call("session.list")
				sessions.each do |k,v|
					# Read, and filter empty / non-existent replies
					read = @rpc.call("session.meterpreter_read", k)
					if read["data"] and read["data"] != ""
						output_or_link "Session #{k}> #{read["data"]}" 
					end
				end
				sleep 1
			end
		end

	end
		
	def version(m)
		return m.reply "Error: No connection" unless @rpc
		version_info = @rpc.call("core.version")
		
		output_or_link m, _pretty_hash(version_info) if version_info 
	end

	def list_exploits(m)
		return m.reply "Error: No connection" unless @rpc
		output_or_link m, @rpc.call("module.exploits")['modules'].join("\n")
	end

	def list_auxiliary(m)
		return m.reply "Error: No connection" unless @rpc
		output_or_link m, @rpc.call("module.auxiliary")['modules'].join("\n")
	end

	def list_post(m)
		return m.reply "Error: No connection" unless @rpc
		output_or_link m, @rpc.call("module.post")['modules'].join("\n")	
	end

	def list_payloads(m)
		return m.reply "Error: No connection" unless @rpc
		output_or_link m, @rpc.call("module.payloads")['modules'].join("\n") 
	end

	def list_encoders(m)
		return m.reply "Error: No connection" unless @rpc
		output_or_link m, @rpc.call("module.encoders")['modules'].join("\n")	
	end

	def list_nops(m)
		return m.reply "Error: No connection" unless @rpc
		output_or_link m, @rpc.call("module.nops")['modules'].join("\n")
	end

	def list_jobs(m)
		return m.reply "Error: No connection" unless @rpc
		jobs = @rpc.call("job.list")
		if jobs
			output_or_link(m, _pretty_hash(jobs))
		else
			m.reply "No known jobs"
		end
	end

	def module_info(m, module_name)
		return m.reply "Error: No connection" unless @rpc
		type = module_name.split("/").first
		return m.reply "Error, badly formed module name (preface w/ the type)" unless ["exploit", "auxiliary", "post", "encoder", "nop"].include? type
		
		hash = @rpc.call("module.info", type, module_name)
	
		return m.reply "Unable to get module info" unless hash

		output_string = _pretty_hash(hash)

		## open it & read
		source = File.open(hash['filepath'],"r").read
		output_string << "\n\n\nSource:\n #{source}"
		
		output_or_link m, output_string
	end

	def module_info(m, id)
		return m.reply "Error: No connection" unless @rpc
		hash = @rpc.call("job.info", id)
		return m.reply "Unable to get job info" unless hash

		output_string = pretty_hash(hash)
		
		## open it & read
		source = File.open(hash['filepath'],"r").read
		output_string << "\n\n\nSource:\n #{source}"
		
		output_or_link m, output_string
	end

	def console_command(m, command)

		return m.reply "Error: No connection" unless @rpc
		
		m.reply "Running console command: #{command}"		
		@rpc.call("console.write", @console_num, command)

		#message = @rpc.call("console.read", @console_num)
		#if message["data"] != ""
		#	m.reply("#{message['prompt']} #{message['data']}")
		#end
	end

	def session_command(m, session_num, command)

		return m.reply "Error: No connection" unless @rpc
		
		m.reply "Running command #{command} on session #{session}"
		message = @rpc.call("session.meterpreter_write", session_num, command)

		#message = @rpc.call("console.read", @console_num)
		#if message["data"] != ""
		#	m.reply("#{message['prompt']} #{message['data']}")
		#end
	end

	def run_module(m,module_name,options_string)
		
		return m.reply "Error: No connection" unless @rpc
		
		# split up the module name into type / name
		type = module_name.split("/").first
		return m.reply "Error, bad module name" unless ["exploit", "auxiliary", "post", "encoder", "nop"].include? type	

		# Start out with an empty settings hash	and pull out each of the options
		options_hash = {}
		options_string.split(",").each{ |setting| options_hash["#{setting.split("=").first}"] = setting.split("=").last }

		# Set the payload
		if type == "exploit"
			# Set a default payload unless it's already been set by the user
			options_hash["PAYLOAD"] = "windows/meterpreter/bind_tcp" unless options_hash["PAYLOAD"]
	
			# Set a default target unless it's already been set by the user
			options_hash["TARGET"] = 0 unless options_hash["TARGET"]
		end
		
		m.reply "Running #{module_name}"

		# then call execute
		@rpc.call("module.execute", type, module_name, options_hash)
		
		m.reply "Ran module: #{module_name} of type: #{type} with options: #{options_hash.to_s}"
	end

	def show_sessions(m)
		return m.reply "Error: No connection" unless @rpc
		m.reply @rpc.call("session.list")
	end

private

	def _pretty_hash(hash)
		output_string = ""
		hash.each{ |k,v| output_string << "#{k}: #{v}\n"}
		output_string
	end

	def _create_console(m)
		return m.reply "Error: No connection" unless @rpc

		console_hash = @rpc.call("console.create")
		@console_num = console_hash['id']
		
		#display only the useful part of the banner			
		first_read = @rpc.call("console.read", @console_num)
		banner_array = first_read['data'].split("\n")
		m.reply banner_array[-3]
		m.reply banner_array[-2]
		m.reply banner_array[-1]
	end
end
