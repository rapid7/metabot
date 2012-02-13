require 'lab'
require 'helpers'

class VmControl
  include Cinch::Plugin

	# Drivers / Individual vm
	match /vm_start (.+)/, method: :vm_start
	match /vm_revert (.+) (.+)/, method: :vm_revert
	match /vm_create_snapshot (.+) (.+)/, method: :vm_create_snapshot
	match /vm_delete_snapshot (.+) (.+)/, method: :vm_delete_snapshot
	match /vm_stop (.+)/, method: :vm_stop
	match /vm_reset (.+)/, method: :vm_reset
	match /vm_status (.+)/, method: :vm_status
	match /vm_describe (.+)/, method: :vm_describe

	# Controllers / Multiple vms
	match /vm_load (.+)/, method: :vm_load_lab
	match /vm_list/, method: :vm_show
	match /vm_show/, method: :vm_show
	match /vm_list_running/, method: :vm_running
	match /vm_show_running/, method: :vm_running
	match /vm_running/, method: :vm_running

	# Depend on modifiers
	match /vm_install_pro (.+) (.+)/, method: :vm_install_pro
	
	def initialize(*args)
		super(*args)
	end

	def valid_vmid?(vmid)
		return true if @vm_controller[vmid]
	end

	def vm_load_lab(m, name)
		@lab_config = "#{File.dirname(__FILE__)}/../../../data/lab/#{name}_lab.yml"
		
		# Set up vm controller
		@vm_controller = Lab::Controllers::VmController.new()
		@vm_controller.from_file(@lab_config)
		m.reply "#{bot.nick} loaded lab #{name}_lab" if @vm_controller
	end

 	def vm_describe(m, vmid)
   		return m.reply "configure the lab first" unless @vm_controller
		return m.reply "invalid vmid" unless valid_vmid?(vmid)

		if @vm_controller[vmid].description != ""
			output_or_link(m, @vm_controller[vmid].description)
		else
			m.reply "no description for vmid, please add it."
		end
	end
	
	def vm_status(m,vmid)
   		return m.reply "configure the lab first" unless @vm_controller
		return m.reply "invalid vmid" unless valid_vmid?(vmid)

		begin
			if @vm_controller[vmid].running?
				m.reply "#{vmid} is running (#{vm.driver.class})"
			else
				m.reply "#{vmid} is not running (#{vm.driver.class})"
			end		
		rescue RuntimeError => e
			return m.reply "Error #{e}"
		end
	end

	def vm_show(m)
   		return m.reply "configure the lab first" unless @vm_controller
		m.reply "#{bot.nick} gathering VMs..."
		output_string = ""
		@vm_controller.each do |vm|
			output_string << "#{vm.hostname}: #{vm.location} (#{vm.driver.class})\n"
		end
		output_or_link(m, output_string)
	end

	def vm_running(m)
   		return m.reply "configure the lab first" unless @vm_controller
		m.reply "#{bot.nick} gathering running VMs..."
		output_string = ""
		@vm_controller.each do |vm|
			begin
				if vm.running?
					output_string << "#{vm.hostname}: #{vm.location} (#{vm.driver.class})\n"
				end
			rescue RuntimeError => e
				return m.reply "Error #{e}"
			end
		end
		output_or_link(m, output_string)
	end

	def vm_start(m, vmid)
   		return m.reply "configure the lab first" unless @vm_controller
		return m.reply "invalid vmid" unless valid_vmid?(vmid)

		m.reply "#{bot.nick} starting #{vmid}"
		if @vm_controller[vmid]
			begin
				@vm_controller[vmid].start
			rescue RuntimeError => e
				return m.reply "Error #{e}"
			end
			m.reply "#{bot.nick} started #{vmid}"
		else
			m.reply "ERROR #{bot.nick} could not find #{vmid}"
		end

	end

	def vm_revert(m, vmid, snapshot)
   		return m.reply "configure the lab first" unless @vm_controller
		return m.reply "invalid vmid" unless valid_vmid?(vmid)

		m.reply "#{bot.nick} reverting #{vmid} to #{snapshot}"
		if @vm_controller[vmid]
			begin
				@vm_controller[vmid].revert_snapshot(snapshot)
			rescue RuntimeError => e
				return m.reply "Error #{e}"
			end
			m.reply "#{bot.nick} reverted #{vmid}"
		else
			m.reply "ERROR #{bot.nick} could not find #{vmid}"
		end
	end

	def vm_create_snapshot(m, vmid, snapshot)
   		return m.reply "configure the lab first" unless @vm_controller
		return m.reply "invalid vmid" unless valid_vmid?(vmid)

		m.reply "#{bot.nick} creating #{vmid} #{snapshot}"
		if @vm_controller[vmid]
			begin
				@vm_controller[vmid].create_snapshot(snapshot)
			rescue RuntimeError => e
				return m.reply "Error #{e}"
			end
			m.reply "#{bot.nick} created snapshot on #{vmid}"
		else
			m.reply "ERROR #{bot.nick} could not find #{vmid}"
		end

	end

	def vm_delete_snapshot(m, vmid, snapshot)
   		return m.reply "configure the lab first" unless @vm_controller
		return m.reply "invalid vmid" unless valid_vmid?(vmid)

		m.reply "#{bot.nick} deleting #{vmid} #{snapshot}"
		if @vm_controller[vmid]
			begin
				@vm_controller[vmid].delete_snapshot(snapshot)
			rescue RuntimeError => e
				return m.reply "Error #{e}"
			end
			m.reply "#{bot.nick} created snapshot on #{vmid}"
		else
			m.reply "ERROR #{bot.nick} could not find #{vmid}"
		end
	end


	def vm_stop(m, vmid)
   		return m.reply "configure the lab first" unless @vm_controller
		return m.reply "invalid vmid" unless valid_vmid?(vmid)

		m.reply "#{bot.nick} stopping #{vmid}"
		if @vm_controller[vmid]
			begin
				@vm_controller[vmid].stop
			rescue RuntimeError => e
				return m.reply "Error #{e}"
			end
			m.reply "#{bot.nick} stopped #{vmid}"
		else
			m.reply "ERROR #{bot.nick} could not find #{vmid}"
		end
	end  

	def vm_reset(m, vmid)
   		return m.reply "configure the lab first" unless @vm_controller
		return m.reply "invalid vmid" unless valid_vmid?(vmid)

		m.reply "#{bot.nick} resetting #{vmid}"
		if @vm_controller[vmid]
			begin
				@vm_controller[vmid].reset
			rescue RuntimeError => e
				return m.reply "Error #{e}"
			end
			m.reply "#{bot.nick} reset #{vmid}"
		else
			m.reply "ERROR #{bot.nick} could not find #{vmid}"
		end
	end
end
