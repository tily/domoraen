require 'aws-sdk'

module Domoraen::Messenger
	def sqs
		@sqs ||= ::AWS::SQS.new(
			sqs_endpoint: @config[:messenger][:sqs_endpoint],
			access_key_id: @config[:messenger][:access_key_id],
			secret_access_key: @config[:messenger][:secret_access_key]
		)
	end

	def queue
		@queue ||= sqs.queues.create(@config[:messenger][:queue_name])
	end
end
