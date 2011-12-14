require 'helpers'
require 'nexpose'

class NexposePlugin
  include Cinch::Plugin

	match /nx_ver/, method: :ver
	match /nx_connect (.+) (.+) (.+)/, method: :connect
	match /nx_list_sites/, method: :list_sites

	def initialize(*args)
		super(*args)
		@port = "3780"
	end

	def connect(m, host, user, pass)

		
		host="nexpose" unless host

		begin
			@nsc = Nexpose::Connection.new(host, user, pass, @port)
			@nsc.login
		rescue ::Nexpose::APIError => e
			return output_or_link m, "Connection failed"
		rescue SocketError => e
			return output_or_link m, "Couldn't resolve #{host}\n #{e}"
		rescue Exception => e
			return output_or_link m, "Error:\n #{e}"
		end
		m.reply "Logged into #{host} successfully"
	end

	def ver(m)

		return m.reply "Not connected" unless @nsc
		
		res = @nsc.console_command("ver")
		output_or_link m, "Nexpose version: #{res}"
	end

	def list_sites(m)

		return m.reply "Not connected" unless @nsc
		
		#
		# Query a list of all NeXpose sites and display them
		#
		sites = @nsc.site_listing || []
		m.reply("There are currently no active sites on this NeXpose instance") if sites.length == 0
		
		site_string = ""
		sites.each do |site|
		 site_string << "    Site ##{site[:site_id]} '#{site[:name]}' Risk Factor: #{site[:risk_factor]} Risk Score: #{site[:risk_score]}\n"
		end

    		output_or_link m, site_string
	end


end
