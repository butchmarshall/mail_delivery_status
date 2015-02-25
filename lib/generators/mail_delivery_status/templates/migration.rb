class CreateMailDeliveryStatus < ActiveRecord::Migration
	def self.up
		# Create a table to hold parsed entries from the sendmail log
		#
		# Spec for sendmail log can be found here:
		# http://docstore.mik.ua/orelly/networking/sendmail/ch26_01.htm
		create_table :mail_delivery_status_sendmail_logs do |table|
			table.datetime :date		#= 	The date is the month, day, and time that the line of information was logged (note that the year is absent).
			table.string :host			#= 	The host is the name of the host that produced this information (note that this may differ from the name of the host on which the log files are kept).
			table.integer :pid			#=	The sendmail is literal. Because of the LOG_PID argument that is given to openlog (3) by sendmail (see Section 26.1.1 ), the process ID of the invocation of sendmail that produced this information is included in square brackets.
			table.string :qid			#=	Each line includes the qid queue identifier (see Section 23.2.1, "The Queue Identifier" ) that uniquely identifies each message on a given host.

			table.string :what_msgid 	#=	Section 26.1.3.5, 	"msgid= the Message-ID: identifier"					The Message-ID: identifier
			table.string :what_from 	#=	Section 26.1.3.3, 	"from= show envelope sender"						Show envelope sender
			table.string :what_to 		#=	Section 26.1.3.12, 	"to= show final recipient"							The final recipient
			table.string :what_stat 	#=	Section 26.1.3.11, 	"stat= status of delivery"							Status of delivery
			table.string :what_class 	#=	Section 26.1.3.1, 	"class= the queue class"							The queue class
			table.string :what_delay 	#=	Section 26.1.3.2, 	"delay= total time to deliver"						Total time to deliver
			table.string :what_mailer 	#=	Section 26.1.3.4, 	"mailer= the delivery agent used"					The delivery agent used
			table.string :what_nrcpts 	#=	Section 26.1.3.6, 	"nrcpts= the number of recipients"					The number of recipients
			table.string :what_pri 		#=	Section 26.1.3.7, 	"pri= the initial priority"							The initial priority
			table.string :what_proto 	#=	Section 26.1.3.8, 	"proto= the protocol used in transmission"			The protocol used in transmission
			table.string :what_relay 	#=	Section 26.1.3.9, 	"relay= the host that sent or accepted the message"	The host that sent or accepted the message
			table.string :what_size 	#=	Section 26.1.3.10, 	"size= the size of the message"						The size of the message
			table.string :what_xdelay 	#=	Section 26.1.3.13, 	"xdelay= transaction"								Transaction delay for this address only
			table.string :what_dsn 		#=	???
			table.string :what_daemon 	#=	???

			table.timestamps
		end
	end

	def self.down
		drop_table :mail_delivery_status_sendmail_log
	end
end