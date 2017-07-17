class Device
  include Mongoid::Document
  include Mongoid::Timestamps
  field :registration_id, type: String 
  field :device_type, type: String
  field :user_id, type: String

end