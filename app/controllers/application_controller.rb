class ApplicationController < ActionController::API
  # include ActionController::ImplicitRender
  # respond_to :json

  before_action :authenticate_user_from_token!
  require 'json_web_token'

  def authenticate_user_from_token!
    if claims and @current_user = valid_session?(claims)
      @current_user
    else
      render json: {errors: { unauthorized: ["You can't do that"] }}, status: 401
    end
  end

  def jwt_token(user)
    # ex: {data: {id: "tedma4@email.com"}}
    JsonWebToken.encode(user)
  end

  def valid_session?(claims)
    session = JsonWebToken.decode claims
    if session
      return session[:data][:session_id] # Need to update to become the current user_id
    else
      return false
    end
  end

  protected

  def claims
    auth_header = request.headers['HTTP_AUTHORIZATION'] and ::JsonWebToken.decode(auth_header)
  rescue
    nil
  end
end
