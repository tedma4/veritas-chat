class ReportsController < ApplicationController

  before_action :ensure_params_exist,  only: :create

	def create
		@report = Report.new(report_params)
		if @report.save
			render json: {status: 200}
		else
			render json: @report.errors
		end
	end

	private
	
	def report_params
		params.require(:report).permit(:message_id, :chat_id, :user_id, :reason)
	end

  def ensure_params_exist
    if report_params[:message_id].blank? && report_params[:chat_id].blank?
       render json: {error: "Requires Message/Chat"}, status: 400
    end
  end

end