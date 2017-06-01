class JoinedChat
	include Mongoid::Document  
	include Mongoid::Timestamps
  has_and_belongs_to_many :chats, class_name: 'Chat', index: true, inverse_of: :joined_chats
  # has_many :grouped_lists, class_name: 'Chat', inverse_of: :individual_list
	field :user_id, type: String
	index({ user_id: 1 }, { unique: true })
	# validates_uniqueness_of :chats

	def build_joined_hash
		joined = {
			id: self.id.to_s,
			user_id: self.user_id
		}
		joined[:chat_ids] = self.chat_ids.map(&:to_s) if self.chat_ids && !self.chat_ids.blank?
		joined 
	end
end