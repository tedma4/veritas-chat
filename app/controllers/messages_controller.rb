class MessagesController < ApplicationController
  require 'string_image_uploader'
  before_action :ensure_params_exist

	def create
		params[:message][:user_id] = @current_user
		@message = Message.create(message_params)
		if @message.content && !@message.content.blank?
			@message.message_type = "image"
		end
		if @message.save
			if @message.content && !@message.content.blank?
				chat = @message.chat 
				chat.cover = @message.content
				chat.save
			end
			render json: @message.build_message_hash
		else
			render json: @message.errors, status: :unprocessable_entity
		end

	end

	def index
		@chat = Chat.find(params[:chat_id])
		@messages = @chat.messages.limit(10)
		render json: @messages.map(&:build_message_hash)
	end

	private

	def message_params
		the_params = params.require(:message).permit(:user_id, :chat_id, :message_type, :text, :content, :location, :timestamp)
		the_params[:content] = StringImageUploader.new(the_params[:content], 'message').parse_image_data if the_params[:content]
		the_params[:location] = params[:message][:location] if params[:message][:location]
		the_params
	end

  def ensure_params_exist
    if message_params[:text].blank? && message_params[:content].blank?
       render json: {error: "Requires Text/Content"}, status: 400
    end
  end

end