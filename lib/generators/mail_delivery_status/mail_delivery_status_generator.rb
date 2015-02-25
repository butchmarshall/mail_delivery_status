require 'rails/generators/base'
require 'mail_delivery_status/compatibility'

class MailDeliveryStatusGenerator < Rails::Generators::Base
	source_paths << File.join(File.dirname(__FILE__), 'templates')

	def create_executable_file
		template 'script', "#{MailDeliveryStatus::Compatibility.executable_prefix}/mail_delivery_status"
		chmod "#{MailDeliveryStatus::Compatibility.executable_prefix}/mail_delivery_status", 0755
	end
end