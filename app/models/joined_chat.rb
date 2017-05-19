class JoinedChat
	include Mongoid::Document  
	include Mongoid::Timestamps
	has_many :chats
	field :user_id, type: String
	index({ user_id: 1 }, { unique: true })
	
end