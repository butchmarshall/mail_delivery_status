MailDeliveryStatus
============

A Rails plugin that monitors your sendmail log file for delivery statuses and records what it finds.

Installation
============

```ruby
gem 'mail_delivery_status'
```

The Active Record migration is required to create the mail_delivery_status table. You can create that table by
running the following command:

    rails generate mail_delivery_status:active_record
    rake db:migrate

Running Log Parsers
============

`script/mail_delivery_status` can be used to start a parser background process which process log files.

You can then do the following:

	# start and stop daemon
    RAILS_ENV=production script/mail_delivery_status start --log-file=/var/log/mail.log
    RAILS_ENV=production script/mail_delivery_status stop

    # or to run in the foreground
    RAILS_ENV=production script/mail_delivery_status run

Special Thanks
============
A lot of this gems code was inspired by the [delayed_job](https://github.com/collectiveidea/delayed_job) gem