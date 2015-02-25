# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mail_delivery_status/version'

Gem::Specification.new do |spec|
	spec.name          = "mail_delivery_status"
	spec.version       = MailDeliveryStatus::VERSION
	spec.authors       = ["Butch Marshall"]
	spec.email         = ["butch.a.marshall@gmail.com"]
	spec.summary       = "Figure out of email was delivered successfully"
	spec.description   = "Tracks emails queued for delivery, parses log files to determine delivery status"
	spec.homepage      = "https://github.com/butchmarshall/mail_delivery_status"
	spec.license       = "MIT"

	spec.files         = `git ls-files -z`.split("\x0")
	spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
	spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
	spec.require_paths = ["lib"]

	spec.add_dependency "file-tail"
	spec.add_dependency "activerecord", [">= 3.0", "< 5.0"]

	spec.add_development_dependency	"rspec"
	spec.add_development_dependency "bundler", "~> 1.7"
	spec.add_development_dependency "rake", "~> 10.0"
end
