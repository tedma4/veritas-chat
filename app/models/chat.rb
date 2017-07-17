class Chat
	include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Geospatial
  scope :android, -> { where(device_type: 'android') }
  scope :ios, -> { where(device_type: 'ios') }
	mount_uploader :cover, AttachmentUploader
  # associations
	has_many :messages, dependent: :destroy
  has_many :hashtags, dependent: :destroy
  has_and_belongs_to_many :joined_chats, class_name: 'JoinedChat', index: true, inverse_of: :chats
  # belongs_to :individual_list, class_name: 'JoinedChat', index: true, inverse_of: :grouped_lists, optional: true
	# chat fields
	field :area_id, type: String
	field :user_id, type: String
	field :title, type: String
	field :chat_type, type: String, default: "private" # "private", "geo", "user"
	field :location, type: Point, sphere: true
	# Chat statues are for finding out which chats to archive
	field :status, type: String, default: "active" # "active", "stale", "pending", nil, "delete soon"
  # validates_presence_of :cover
  delegate :url, :size, :path, to: :cover
  field :cover, type: String#, null: false

  field :name, type: String
  field :address, type: String
  field :description, type: String
  field :types, type: String
  field :device_type, type: String

  # Indexes
  index({area_id: 1, user_id: 1})
  validates_presence_of :title, :user_id, :location, on: :create
  # validates_uniqueness_of :joined_chat
	# Favorites are a future thing
	# Users can have many favorite Chats
	# Many Users can favorite the same chat
	# field :favorite, type: Array, default: Array.new

	def build_chat_hash
		# user = self.user_id
		chat = {
			id: self.id.to_s,
			chat_type: self.chat_type,
			created_at: self.created_at
			# status: self.status
		}
		chat[:location] = self.location if self.location
		chat[:title] = self.title if self.title
		chat[:normal_cover] = self.cover.url if self.cover
		chat[:thumb_cover] = self.cover.thumb.url if self.cover
		chat[:darkened_cover] = self.cover.darkened.url if self.cover
		chat[:area_id] = self.area_id if self.area_id
		chat[:user_id] = self.user_id if self.user_id
		# chat[:user] = {id: user.id.to_s, user_name: user.user_name, avatar: user.avatar.url } if self.user
		unless self.messages.blank?
			messages = self.messages
			last_message = messages.last
			chat[:last_message] = last_message.build_message_hash
			chat[:message_count] = messages.count
		else
			chat[:last_message] = ""
			chat[:message_count] = 0
		end
		chat
	end

	def self.inside_area(level, coordx, coordy)
		client = Mongo::Client.new(ENV['VERITAS-LOCATION-DB'])
		collection = client[:areas]
		area = collection.find( 
			{ "$and": 
				[
					{"area_profile": 
						{"$geoIntersects" => 
							{"$geometry" => {type: "Point", coordinates: [coordx, coordy]}
							}
						}
					},
					{level: level }
				]
			}
		)
		area.to_a
	end

	def self.get_user_data(user)
		user = user.map {|u| BSON::ObjectId(u)}
		client = Mongo::Client.new(ENV["VERITAS-USER-DB"])
		collection = client[:users]
		users = collection.find( { _id: { "$in": user } } ).to_a
		user_arr = []
		users.each do |u| 
			user = {
				id: u["_id"].to_s,
			}
			user[:user_name] = u["user_name"] ? u["user_name"] : ""
			user[:first_name] = u["first_name"] ? u["first_name"] : ""
			user[:last_name] = u["last_name"] ? u["last_name"] : ""
			url_base = "https://s3-us-west-2.amazonaws.com/veritas-user/uploads/user/avatar/#{user[:id]}/"
			user[:normal_avatar] = (url_base + u[:avatar]) if u[:avatar]
			user[:thumb_avatar] = (url_base + "thumb_" + u[:avatar]) if u[:avatar]
			user_arr << {"#{user[:id]}": user}
			# {"#{user[:id]}": user}
		end
		user_arr
	end

	def has_tags?
		if self.description and tags = self.description.scan(/(?:\s|^)(?:#(?!(?:\d+|\w+?_|_\w+?)(?:\s|$)))(\w+)(?=\s|$)/i) and tags.any?
			tags
		else
			false
		end
	end
  
  def self.notify(data, collapse_key = nil)
    require 'fcm'
    fcm = FCM.new(ENV['fcm_api_key']) # an api key from prerequisites
    registration_ids = Device.android.map(&:registration_id) # an array of one or more client registration IDs
    options = {
      data: data,
      collapse_key: collapse_key || 'my_app'
    }
    response = fcm.send(registration_ids, options)
  end  

  # def self.notify_ios(text, data = nil)
  #   apn = Houston::Client.development
  #   apn.certificate = File.read("../../") # certificate from prerequisites
  #   Device.ios.each do |device|
  #     notification = Houston::Notification.new(device: device.registration_id)
  #     notification.alert = text
  #     # take a look at the docs about these params
  #     notification.badge = 57
  #     notification.sound = "sosumi.aiff"
  #     notification.custom_data = data unless data.nil?
  #     apn.push(notification)
  #   end
  # end	

# This is for getting a single user's data
# chat = Chat.where(id: id)
# c = chat.build_chat_hash
# d = Chat.get_user_data [c[:user_id]]
# c[:user] = d[:"#{c[:user_id]}"] if d.count == 1


# This is for getting the user data for messages
# chat = Chat.includes(:messages).where(id: id)
# mess = chat.messages
# m = mess.map(&:build_message_hash)
# uids = mess.pluck(:user_id).uniq 
# users = Chat.get_user_data uids
# messages = m.map {|u| 
# 	udata = users.find {|usr| usr[:"#{u[:user_id]}"]}
# 	u[:user] = udata[:"#{u[:user_id]}"]
# }


end


