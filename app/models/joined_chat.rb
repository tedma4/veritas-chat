class JoinedChat
	include Mongoid::Document  
	include Mongoid::Timestamps
  has_and_belongs_to_many :chats, class_name: 'Chat', index: true, inverse_of: :joined_chats
  has_many :grouped_lists, class_name: 'Chat', inverse_of: :individual_list
	field :user_id, type: String
	index({ user_id: 1 }, { unique: true })
	# validates_uniqueness_of :chats
end