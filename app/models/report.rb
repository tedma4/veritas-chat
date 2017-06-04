class Report
	include Mongoid::Document
  include Mongoid::Timestamps
	belongs_to :message, index: true, optional: true
	belongs_to :chat, index: true, optional: true
	field :reporter_id, type: String
	field :reason, type: String
	validates_presence_of :user_id, :reason
	index({user_id: 1})

	def build_report_hash
		report = {
			id: self.id,
			reason: self.reason
		}
		# need to make the user project bridge thing
		report[:user] = self.user_id
		report[:message] = self.message.build_message_hash
	end
end