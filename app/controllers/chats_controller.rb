 class ChatsController < ApplicationController
  require 'string_image_uploader'

	def create
		params[:chat][:user_id] = @current_user
		@chat = Chat.create(chat_params)
		# area = @chat.inside_area?('L2')
		# if area.any?
		# 	@chat.area_id = area.first.id
		# 	@chat.chat_type = "AreaChat"
		# end
		
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

	def list_local_chats # Gotta find out to use without the area table
		# area_chats = User.inside_an_area?(params[:location].split(",").map(&:to_f))
		@chats = []
		# if area_chats.first && area_chats.last.level == "L2"
		# 	@chats << area_chats.last.chats
		# end
			@chats << Chat.includes(:messages).where(
				location: {
					"$geoWithin" => {
						"$centerSphere": [params[:location].split(",").map(&:to_f), 15/3963.2]
					}
				},
				:user_id.nin => [@current_user],
				:area => nil
			).to_a
		if @chats
			render json: @chats.flatten.map(&:build_chat_hash) 
		end
		# $redis.smembers "users:#{chats.first.id}"
		# @area = Area.where(
		# 	area_profil: {
		# 		"$goeIntersects" => {
		# 			"$geometry" => {
		# 				type: "Point",
		# 				coordinates: [params[:coords].last, params[:coords].first]
		# 			}
		# 		}
		# 	},
		# 	:level.nin => ["L0"],
		# 	:level.in => ["L1", "L2"]
		# 	)
		# @area.chats
	end

	private

	def chat_params
		the_params = params.require(:chat).permit(:area_id, :user_id, :title, :chat_type, :location, :cover)# , { users: [] }
		the_params[:cover] = StringImageUploader.new(the_params[:cover], 'chat').parse_image_data if the_params[:cover]
		the_params[:location] = params[:chat][:location] if params[:chat][:location]
		the_params[:user_id] = params[:chat][:user_id] if params[:chat][:user_id]
		the_params
	end
end