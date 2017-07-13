class Message
  include Mongoid::Document
  # include Mongoid::Timestamps
  include Mongoid::Geospatial
	mount_uploader :content, AttachmentUploader
	# Associations
	belongs_to :chat, index: true
	has_many :reports, dependent: :destroy
	# has_one :notification
	# Fields
	field :user_id, type: String
	field :message_type, type: String, default: "text" # "notification", "post", 
	field :text, type: String
	field :location, type: Point, sphere: true
	field :timestamp, type: DateTime

  # validates_presence_of :content
  delegate :url, :size, :path, to: :content
  field :content, type: String#, null: false

  # Indexes
  index({user_id: 1})

	def build_message_hash
		# user = self.user
		message = {
			id: self.id.to_s,
			message_type: self.message_type,
			user_id: self.user_id,
			timestamp: self.timestamp
		}
			message[:chat_id] = self.chat_id.to_s if self.chat_id
			message[:text] = self.text || ''
			message[:normal_content] = self.content.url if self.content
			message[:thumb_content] = self.content.thumb.url if self.content
			message
	end
end
