class JoinedChatsController < ApplicationController

	def index # the list of a users currently joined chats
		@joined = JoinedChat.find_or_create_by(user_id: @current_user)
		if chats = @joined.chats and !chats.blank?
			user_ids = chats.pluck(:user_id).uniq
			users = Chat.get_user_data user_ids
			chats = chats.map { |c| 
				c_hash = c.build_chat_hash
				found = users.find {|u| u[:"#{c.user_id}"] }
				c_hash[:user] = found ? found[:"#{c.user_id}"] : ""
				c_hash
			}
			# render json: chats.map(&:build_chat_hash)
			render json: chats
		elsif chats.blank?
			render json: {empty: []}, status: 200
		else
			render json: {error: "Something happened"}, status: 401
		end
	end

	def create
		@joined = JoinedChat.find_or_create_by(user_id: @current_user)
		@joined.chat_ids << BSON::ObjectId(join_params[:chat_id]) if 
			join_params[:chat_id] && 
			!join_params[:chat_id].blank? && 
			!@joined.chat_ids.include?(BSON::ObjectId(join_params[:chat_id]))
		if @joined.changed? && @joined.save
			render json: @joined.build_joined_hash
		else
			render json: {error: "Something happened"}, status: 401
		end
	end

	def destroy
		@joined = JoinedChat.where(user_id: @current_user).first
		@joined.chat_ids.delete(BSON::ObjectId(join_params[:chat_id])) if 
			join_params[:chat_id] && 
			!join_params[:chat_id].blank? && 
			@joined.chat_ids.include?(BSON::ObjectId(join_params[:chat_id]))
		if @joined.changed? && @joined.save
			render json: @joined.build_joined_hash
		else
			render json: {error: "Something happened"}, status: 401
		end
	end

	private

	def join_params
		params.require(:join).permit(:user_id, :chat_id)
	end
end