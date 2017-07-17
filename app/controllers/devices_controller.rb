class DevicesController < ApplicationController

	def create
		@device = Device.new(device_params)
		@device.user_id = @current_user
		if @device.save
			render json: {status: 200}
		else
			render json: {}
		end

	end

	def update
		@device = Device.where(registration_id: params[:device][:registration_id])
		@device.update(device_params)
		if @device.save
			render json: {status: 200}
		else
			render json: {}
		end
	end

	private
	def device_params
		params.require(:device).permit(:registration_id, :user_id, :device_type)
	end
end