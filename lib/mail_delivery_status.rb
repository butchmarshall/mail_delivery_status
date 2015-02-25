require 'active_support'

require 'mail_delivery_status/version'
require 'logger'
require 'benchmark'
require 'file-tail'

module MailDeliveryStatus
	class SendmailLog < ::ActiveRecord::Base
		self.table_name = "mail_delivery_status_sendmail_logs"
	end

	class FileMonitor
		DEFAULT_LOG_LEVEL = 'info'
		DEFAULT_LOG_FILE = '/var/log/mail.log'
		DEFAULT_BACKWARD = 0
		DEFAULT_INTERVAL = 1

		cattr_accessor :default_log_level, :logger, :log_file, :line_matches,
						:backward, :interval

		# By default, Signals INT and TERM set @exit, and the worker exits upon completion of the current job.
		# If you would prefer to raise a SignalException and exit immediately you can use this.
		# Be aware daemons uses TERM to stop and restart
		# false - No exceptions will be raised
		# :term - Will only raise an exception on TERM signals but INT will wait for the current job to finish
		# true - Will raise an exception on TERM and INT
		cattr_accessor :raise_signal_exceptions
		self.raise_signal_exceptions = false

		def initialize(options = {})
			@quiet = options.key?(:quiet) ? options[:quiet] : true

			self.default_log_level = options.key?(:log_level) ? options[:log_level] : DEFAULT_LOG_LEVEL
			self.log_file = options.key?(:log_file) ? options[:log_file] : DEFAULT_LOG_FILE
			self.backward = options.key?(:backward) ? options[:backward] : DEFAULT_BACKWARD
			self.interval = options.key?(:interval) ? options[:interval] : DEFAULT_INTERVAL

			self.line_matches = {
				:sendmail => {
					:keys => ["date", "host", "pid", "qid", "data"],
					:regexp => /^([A-Za-z]+\s[0-9]+\s[0-9]+:[0-9]+:[0-9]+)\s([^\s]+)\s[^\[]+\[([^\]]+)\]:\s([^:]+):\s([^$]+)/
				}
			}
		end

		def start
			say "Starting mail_delivery_status monitor #{self.log_file}"

			# Tail the log file, parse each line for information
			File.open(self.log_file) do |log|
				log.extend(File::Tail)
				log.interval = self.interval
				log.backward(self.backward)

				log.tail { |line|
					break if stop?

					# Attempt to match sendmail log file format
					line_match = self.line_matches[:sendmail]
					if match_data = line.match(line_match[:regexp])
						columns = {}
						match_data.to_a.each_with_index { |match, index|
							columns[line_match[:keys][index-1]] = match if index > 0
						}
						data_parts = columns["data"].split(/,\s/).each_with_object({}) { |datum,data| p = datum.split(/=/); data["what_#{p[0].to_s}"] = p[1].to_s.gsub(/\n/,'').strip }
						columns.delete("data")
						columns.merge!(data_parts)

						# Log it
						begin
							MailDeliveryStatus::SendmailLog.create(columns)
						rescue Exception => e
							say line
							say e.inspect
						end
					end
				}
			end
		end

		def stop
			@exit = true
		end

		def stop?
			!!@exit
		end

		def name
			return @name unless @name.nil?
			"#{@name_prefix}host:#{Socket.gethostname} pid:#{Process.pid}" rescue "#{@name_prefix}pid:#{Process.pid}" # rubocop:disable RescueModifier
		end

		def say(text, level = default_log_level)
			text = "[Worker(#{name})] #{text}"
			puts text unless @quiet
			return unless logger
			# TODO: Deprecate use of Fixnum log levels
			unless level.is_a?(String)
				level = Logger::Severity.constants.detect { |i| Logger::Severity.const_get(i) == level }.to_s.downcase
			end
			logger.send(level, "#{Time.now.strftime('%FT%T%z')}: #{text}")
		end

        def self.before_fork
			::ActiveRecord::Base.clear_all_connections!
        end

        def self.after_fork
			::ActiveRecord::Base.establish_connection
        end
	end

	#class Observer
	#	def self.delivered_email(message)
	#		MailDeliveryStatus::SendmailLog.create(:msgid => message.message_id)
	#	end
	#end
end

# Register observer so we know about all emails sent through the system
# ActionMailer::Base.register_observer(MailDeliveryStatus::Observer)