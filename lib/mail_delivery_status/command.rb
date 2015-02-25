unless ENV['RAILS_ENV'] == 'test'
	begin
		require 'daemons'
	rescue LoadError
		raise "You need to add gem 'daemons' to your Gemfile if you wish to use it."
	end
end
require 'optparse'

module MailDeliveryStatus
	class Command
		def initialize(args)
			@options = {
				:quiet => true,
				:pid_dir => "#{Rails.root}/tmp/pids"
			}

			@monitor = false

			opts = OptionParser.new do |opt|
				opt.banner = "Usage: #{File.basename($PROGRAM_NAME)} [options] start|stop|run"

				opt.on('-h', '--help', 'Show this message') do
					puts opt
					exit 1
				end
				opt.on('--interval=INT', 'File::Tail interval.') do |i|
					@options[:interval] = i.to_f
				end
				opt.on('--backward=INT', 'File::Tail backward.  How far back to start tailing the file from.') do |i|
					@options[:backward] = i.to_i
				end
				opt.on('--pid-dir=DIR', 'Specifies an alternate directory in which to store the process ids.') do |i|
					@options[:pid_dir] = i
				end
				opt.on('--log-file=DIR', 'Specify the location of the log file.') do |i|
					@options[:log_file] = i
				end
			end
			@args = opts.parse!(args)
		end

		def daemonize
			dir = @options[:pid_dir]
			Dir.mkdir(dir) unless File.exist?(dir)

			run_process('mail_delivery_status', @options)
		end

		def run_process(process_name, options = {})
			MailDeliveryStatus::FileMonitor.before_fork
			Daemons.run_proc(process_name, :dir => options[:pid_dir], :dir_mode => :normal, :monitor => @monitor, :ARGV => @args) do |*_args|
				$0 = File.join(options[:prefix], process_name) if @options[:prefix]
				run process_name, options
			end
		end

		def run(worker_name = nil, options = {})
			Dir.chdir(Rails.root)

			MailDeliveryStatus::FileMonitor.after_fork
			MailDeliveryStatus::FileMonitor.logger ||= Logger.new(File.join(Rails.root, 'log', 'mail_delivery_status.log'))

			file_monitor = MailDeliveryStatus::FileMonitor.new(options)
			file_monitor.start
		rescue => e
			Rails.logger.fatal e
			STDERR.puts e.message
			exit 1
		end
	end
end
