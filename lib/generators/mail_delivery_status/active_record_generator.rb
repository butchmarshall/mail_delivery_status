require "generators/mail_delivery_status/mail_delivery_status_generator"
require "generators/mail_delivery_status/next_migration_version"
require "rails/generators/migration"
require "rails/generators/active_record"

# Extend the MailDeliveryStatusGenerator so that it creates an AR migration
module MailDeliveryStatus
	class ActiveRecordGenerator < ::MailDeliveryStatusGenerator
		include Rails::Generators::Migration
		extend NextMigrationVersion

		source_paths << File.join(File.dirname(__FILE__), "templates")

		def create_migration_file
			migration_template "migration.rb", "db/migrate/create_mail_delivery_status.rb"
		end

		def self.next_migration_number(dirname)
			ActiveRecord::Generators::Base.next_migration_number dirname
		end
	end
end
