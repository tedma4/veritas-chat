class Chat
	include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Geospatial
	mount_uploader :cover, AttachmentUploader
  # associations
	has_many :messages, dependent: :destroy
	# chat fields
	field :area_id, index: true
	field :user_id, index: true
	field :title, type: String
	field :chat_type, type: String, default: "private" # "private", "geo", "user"
	field :location, type: Point, sphere: true
	# Chat statues are for finding out which chats to archive
	field :status, type: String, default: "active" # "active", "stale", "pending", nil, "delete soon"
  # validates_presence_of :cover
  delegate :url, :size, :path, to: :cover
  field :cover, type: String#, null: false

	# Favorites are a future thing
	# Users can have many favorite Chats
	# Many Users can favorite the same chat
	# field :favorite, type: Array, default: Array.new

	def build_chat_hash
		# user = self.user_id
		chat = {
			id: self.id.to_s,
			chat_type: self.chat_type
			# status: self.status
		}
		chat[:title] = self.title if self.title
		chat[:cover] = self.cover.url if self.title
		# chat[:area] = self.area_id.to_s if self.area_id
		# chat[:user] = {id: user.id.to_s, user_name: user.user_name, avatar: user.avatar.url } if self.user
		unless self.messages.blank?
			chat[:last_message] = self.messages.last.build_message_hash[:text]
		else
			chat[:last_message] = ""
		end
		chat
	end

	def inside_area?(level)
		area = Area.where(
		  area_profile: {"$geoIntersects" => {"$geometry"=> {type: "Point",coordinates: [self.location.x, self.location.y] }}},
		  level: level
		)
    area
	end
end


