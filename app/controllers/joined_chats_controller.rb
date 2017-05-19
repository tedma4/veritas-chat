class JoinedChatsController < ApplicationController
	def index # the list of a users currently joined chats
		joined = JoinedChat.where(user_id: @current_user).first
		chats = joined.chats
		respond_with chats.map(&:build_chat_hash)
	end

	def create
		joined = JoinedChat.where(user_id: @current_user)
		if joined.any?
			join = joined.first
			join.chats << params[:chat_id] unless join.chats.include? params[:chat_id]
			join.save # if join.changed?
		else
			join = JoinedChat.new
			join.user_id = @current_user
			join.chats << params[:chat_id]
			join.save 
		end
	end

	def destroy
		joined = JoinedChat.where(user_id: @current_user)
		joined.chats.destroy(params[:chat_id]) if join.chats.include? params[:chat_id]
		joined.save # if joined.changed?
	end

end