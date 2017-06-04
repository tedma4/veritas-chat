class ReportsController < ApplicationController

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
		params.require(:report).permit(:message_id, :user_id, :reason)
	end

end