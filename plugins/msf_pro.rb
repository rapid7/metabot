#require 'msfrpc-client'

class MsfPro
  include Cinch::Plugin

	match /pro_connect(?: (.+))?/, method: :connect

	match /pro_ver/, method: :version
	match /pro_check_update/, method: :check_update
	match /pro_install_update/, method: :update
	match /pro_restart/, method: :update

	match /pro_list_exploits/, method: :list_exploits
	match /pro_list_auxiliary/, method: :list_auxiliary
	match /pro_list_post/, method: :list_post
	match /pro_list_payloads/, method: :list_payloads
	match /pro_list_encoders/, method: :list_encoders
	match /pro_list_nops/, method: :list_nops	
	match /pro_module_info (.+)/, method: :module_info		

	match /pro_discover (.*)/, method: :discover
	match /pro_nexpose (.*)/, method: :nexpose
	match /pro_bruteforce (.*)/, method: :bruteforce
	match /pro_exploit (.*)/, method: :exploit
	match /pro_import (.*)/, method: :import
	
	def initialize(*args)
		super(*args)
		@username = nil
		@password = nil
	end
	
	def connect(m, system="localhost", username, password)
		begin
			@username = username
			@password = password
		
			@rpc  = Msf::RPC::Client.new(:host => system)
			result = @rpc.login(@username, @password)
			m.reply "#{bot.nick} connected to #{system}"
		rescue Exception => e
			m.reply "Error connecting..."
			m.reply e
		end
	end
		
	def version(m)
		return m.reply "Error: No privs" 
		return m.reply "Error: No connection" unless @rpc
		m.reply @rpc.call("core.version")
	end

	def check_update(m)
		return m.reply "Error: No privs" 
		return m.reply "Error: No connection" unless @rpc
		ret = @rpc.call("pro.update_available")
		while true
			sleep 1 	
			break if ret['status'] == "success"
		end
		
		if ret['result'] == "update"
			m.reply "Current Version: #{ret['current']}"
			m.reply "Update Version: #{ret['version']}"
		else
			m.reply "No Update Found"
		end
	end

	def update(m, version)
		return m.reply "Error: No privs" 
		return m.reply "Error: No connection" unless @rpc
		
		@rpc.call("pro.update_install", {:version => version}) 

		while true
			stat = @rpc.call("pro.update_status")
			sleep 1 	
			break if stat['status'] == "success"
		end
	
		m.reply "Update #{version} applied, please restart"
	end
 list_exploits(m)
		return m.reply "Error: No privs" 
		return m.reply "Error: No connection" unless @rpc
		output_or_link m, @rpc.call("module.exploits")['modules'].join("\n")
	end

	def list_auxiliary(m)
		return m.reply "Error: No privs" 
		return m.reply "Error: No connection" unless @rpc
		output_or_link m, @rpc.call("module.auxiliary")['modules'].join("\n")
	end

	def list_post(m)
		return m.reply "Error: No privs" 
		return m.reply "Error: No connection" unless @rpc
		output_or_link m, @rpc.call("module.post")['modules'].join("\n")	
	end

	def list_payloads(m)
		return m.reply "Error: No privs" 
		return m.reply "Error: No connection" unless @rpc
		output_or_link m, @rpc.call("module.payloads")['modules'].join("\n") 
	end

	def list_encoders(m)
		return m.reply "Error: No privs" 
		return m.reply "Error: No connection" unless @rpc
		output_or_link m, @rpc.call("module.encoders")['modules'].join("\n")	
	end

	def list_nops(m)
		return m.reply "Error: No privs" 
		return m.reply "Error: No connection" unless @rpc
		output_or_link m, @rpc.call("module.nops")['modules'].join("\n")
	end

	def module_info(m, module_name)
		return m.reply "Error: No privs" 
		return m.reply "Error: No connection" unless @rpc
		type = module_name.split("/").first
		return m.reply "Error, bad module name" unless ["exploit", "auxiliary", "post", "encoder", "nop"].include? type
		
		hash = @rpc.call("module.info", type, module_name) 

		output_string = ""
		hash.each{ |k,v| output_string << "#{k}: #{v}\n"}

		## open it & read
		source = File.open(hash['filepath'],"r").read
		output_string << "\n\n\nSource:\n #{source}"
		
		output_or_link m, output_string
	end

	def discover(m, range = ["10.6.200.0/24"])
		return m.reply "Error: No connection" unless @rpc
		m.reply "Starting Discover Task!"
		opts = { :token => @token }
		# Provide default values for certain options - If there's no alternative set
		# use the default provided by Pro -- see the documentation.
		project 			= opts[:project]		|| "default"
		targets 			= [range]
		blacklist			= opts[:blacklist]		|| ""
		speed				= opts[:speed]			|| "Insane"
		extra_ports			= opts[:extra_ports]		|| ""
		blacklist_ports			= opts[:blacklist_ports]	|| ""
		custom_ports			= opts[:custom_ports]		|| ""
		portscan_timeout		= opts[:portscan_timeout] 	|| 300
		source_port			= opts[:source_port]		|| ""
		custom_nmap_options		= opts[:custom_nmap_options] 	|| ""
		disable_udp_probes		= opts[:disable_udp_probes] 	|| false
		disable_finger_users		= opts[:disable_finger_users] 	|| false
		disable_snmp_scan		= opts[:disable_snmp_scan] 	|| false
		disable_service_identification	= opts[:disable_service_identification] || false
		smb_user			= opts[:smb_user] 		|| ""
		smb_pass			= opts[:smb_pass] 		|| ""
		smb_domain			= opts[:smb_domain] 		|| ""
		single_scan			= opts[:single_scan]		|| false
		fast_detect			= opts[:fast_detect] 		|| false

		# Create the task object with all options
		task = @rpc.call("pro.start_discover", {
			'workspace'		=> project,
			'username' 		=> "metabot",
			'ips'			=> targets,
			'DS_BLACKLIST_HOSTS'	=> blacklist,
			'DS_PORTSCAN_SPEED'	=> speed,
			'DS_PORTS_EXTRA'	=> extra_ports,
			'DS_PORTS_BLACKLIST'	=> blacklist_ports,
			'DS_PORTS_CUSTOM'	=> custom_ports,
			'DS_PORTSCAN_TIMEOUT' 	=> portscan_timeout,
			'DS_PORTSCAN_SOURCE_PORT' => source_port,
			'DS_CustomNmap'		=> custom_nmap_options,
			'DS_UDP_PROBES'		=> disable_udp_probes,
			'DS_FINGER_USERS'	=> disable_finger_users,
			'DS_SNMP_SCAN'		=> disable_snmp_scan,
			'DS_IDENTIFY_SERVICES'	=> disable_service_identification,
			'DS_SMBUser'		=> smb_user,
			'DS_SMBPass'		=> smb_pass,
			'DS_SMBDomain'		=> smb_domain,
			'DS_SINGLE_SCAN'	=> single_scan, 
			'DS_FAST_DETECT'	=> fast_detect
		})

		if not task['task_id']
			m.reply "[-] Error starting the task: #{task.inspect}"
		end

		m.reply "[*] Creating Task ID #{task['task_id']}..."
		while true
			stat = @rpc.call("pro.task_status", task['task_id'])

			return m.reply "[-] Error checking task status" if stat['status'] == 'invalid'
			info = stat[ task['task_id'] ]
			return m.reply "[-] Error finding the task" if not info
			return 	m.reply "[-] Error generating report: #{info['error']}" if not info
			break if info['progress'] == 100
		end
		m.reply "[+] Task Complete!"
	end

	def nexpose(m, range)
		return m.reply "Error: No privs" 
		return m.reply "Error: No connection" unless @rpc
		m.reply "[+] Task Complete!"
	end

	def bruteforce(m, range)
		return m.reply "Error: No privs" 
		return m.reply "Error: No connection" unless @rpc
		m.reply "[+] Task Complete!"
	end

	def exploit(m, range)
		return m.reply "Error: No privs" 
		return m.reply "Error: No connection" unless @rpc
		m.reply "[+] Task Complete!"
	end

	def import(m, path)
		return m.reply "Error: No privs" 
		return m.reply "Error: No connection" unless @rpc
		m.reply "[+] Task Complete!"
	end
end
