class Report
	include Mongoid::Documents
	include Mongoid::TimeStamps
	belongs_to :message, index: true
	field :reporter_id, type: String
	field :reason, type: String
	validates_presence_of :message_id, :user_id, :reason
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