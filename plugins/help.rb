class Help
  include Cinch::Plugin

	react_on :message

	match /help/, method: :help
	match /help (.+)/, method: :help

	def help(m, method=nil)
	
		methods = { 	"help" => "Displays this help command",
			
			        # System Plugin
			        "ps" => "List processes on bot host", 
			        "df" => "Show disk usage", 
			        
				# Network Plugin
				"ping [host]" => "Ping a host",
				"ping_long [host] [count]" => "Ping a host for a specified interval (default to 100)",
				"nmap [host]" => "Nmap a host",

				# Vm Control Plugin
				"vm_show_vms" => "List all known vms",
        			"vm_list_vms" => "List all known vms", 
       				"vm_running" => "List running vms", 
       				"vm_list_running" => "List running vms", 
				"vm_start [vmid]" => "Starts a vm",
				"vm_stop [vmid]" => "Stop a vm",
				"vm_create_snapshot [vmid] [snapshot]" => "Create a vm snapshot",
				"vm_delete_snapshot [vmid] [snapshot]" => "Delete a vm snapshot",
				"vm_revert [vmid] [snapshot]" => "Revert a vm", 
        			"vm_reset [vmid]" => "Reset a vm", 
        			"vm_status [vmid]" => "Show a vm's status", 
			        "vm_describe [vmid]" => "Show a vm's description", 
			        "vm_install_pro [vmid]" => "Install latest pro rev on a specified host", 

			        # Build Plugin
			        #"build_installers [revision_name]" => "Build installers",
			        #"build_update [revision_name]" => "Build an update package",
			        #"build_ami [revision_name]" => "Build an AMI",
			        #"build_ovf [revision_name]" => "Build an OVF",
			        #"release_noes [old_revision] [new_revision]" => "Generate release notes",

			        # Test Plugin
				#"smoke" => "Run a smoke test",
				
				# NeXpose Plugin
				"nx_connect [host]" => "Connect to a nexpose host",
				"nx_ver" => "Show the nexpose version",
				"nx_list_sites" => "List the nexpose sites",
				
				# Metasploit Pro Plugin
				"pro_connect [host]" => "Show the msf pro version",
				"pro_ver" => "Show Pro version",
				"pro_check_update" => "Check for updates",
				"pro_install_update [name]" => "Install the named update",
				"pro_restart" => "Restart services",

				"pro_list_exploits" => "List known exploit modules",
				"pro_list_auxiliary" => "List known auxiliary modules",
				"pro_list_post" => "List known post modules",
				"pro_list_payloads" => "List known payload modules",
				"pro_list_encoders" => "List known encoder modules",
				"pro_list_nops" => "List known nop modules",	
				"pro_module_info [module_name]" => "Show a module's name",		

				"pro_discover [range]" => "Run discovery against a range",
				#"pro_nexpose [range]" => "Run nexpose against a range",
				#"pro_bruteforce [range]" => "Run bruteforce against a range",
				#"pro_exploit [range]" => "Run exploitation against a range",
				#"pro_import [path]" => "Import a file"

    		}
		string = ""
		methods.each do |key,value|
			string <<  key + ": " + value + "\n"
		end
		
		output_or_link m, string
	end

end
