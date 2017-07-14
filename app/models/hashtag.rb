class Hashtag
	include Mongoid::Document
	belongs_to :chat, dependent: :destroy, index: true
	field :tags, type: Array, default: Array.new

end