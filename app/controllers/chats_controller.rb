 class ChatsController < ApplicationController
  require 'string_image_uploader'

	def create
		params[:chat][:user_id] = @current_user
		@chat = Chat.create(chat_params)
		area = Chat.inside_area('L2', @chat.location.x, @chat.location.y)
		if area.any?
			@chat.area_id = area[0]["_id"].to_s
			@chat.chat_type = "AreaChat"
		end
		
		if @chat.save
			joined = JoinedChat.find_or_create_by(user_id: @current_user)
			joined.chat_ids << @chat.id
			joined.save
			render json: @chat.build_chat_hash
		else
			render json: @chat.errors, status: 401
		end
		# $redis.lpush "users:#{@chat.id.to_s}", @chat.user_id.to_s

	end

	def list_local_chats 
		loc = params[:location].split(",").map(&:to_f)
		area = Chat.inside_area("L2", loc.first, loc.last)
		@chats = Chat.includes(:messages).where( chat_query_builder(loc, area) )
		user_ids = @chats.pluck(:user_id).uniq
		if @chats
			render json: @chats.map(&:build_chat_hash) 
		end
	end

	private

	def chat_query_builder(loc, area)
		chat = {
			location: {
				"$geoWithin" => {
					"$centerSphere": [loc, 15/3963.2]
				}
			},
			:user_id.nin => [@current_user]
		}
		chat[:area_id] = area.any? ? area[0]["_id"].to_s : nil
		chat
	end

	def chat_params
		the_params = params.require(:chat).permit(:area_id, :user_id, :title, :chat_type, :location, :cover)# , { users: [] }
		the_params[:cover] = StringImageUploader.new(the_params[:cover], 'chat').parse_image_data if the_params[:cover]
		the_params[:location] = params[:chat][:location] if params[:chat][:location]
		the_params[:user_id] = params[:chat][:user_id] if params[:chat][:user_id]
		the_params
	end
end