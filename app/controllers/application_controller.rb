class ApplicationController< ActionController::API
 
 include CanCan::ControllerAdditions

 rescue_from CanCan::AccessDenied do |exception|
     error("Auth user failed", "AUTH_USER_FAILED", "Invalid token")
 end

 
 def prepareRequest(url_params)
    params = Hash.new
    if (url_params.has_key?(:input_format) && url_params[:input_format] == 'json')
      url_params = JSON.parse url_params[:input_data]
    end
    url_params.each do | key, value|
      params[key] = value
    end
    return params
 end

 # Parse json or http params from url
 def get_params_from_url
   request_params = params
   @params = prepareRequest request_params
 end


 # Returns the user belonging to the access token
  def current_user
    get_params_from_url
    api_key = ApiKey.where(access_token: @params['token']).first

    if api_key
      @currentUser = api_key.user
    else
      return nil
    end
  end
  

def show_response(response_data)
  data = {"result" => "success", "data" => response_data}
  render json: data, status: 201
end

def error(error_text, error_code, error_data)
  data = {"result"=>"errors", "error_text" => error_text, "error_code"=> error_code, "error_data"=> error_data}
  render json: data, status: 422
end


def domain_owner?(domain_id) 
  if current_user.domains.where(["id = ?", @params['domain_id']]).present?
    return true
  else
    raise StandardError.new(message:"domain not found")
  end
end

def generate_user_hash
    code = Array.new(5){[*'0'..'9'].sample}.join
  end

#NEXMO
def send_registration_sms(cellphone, user_hash)
    require 'nexmo'
    nexmo = Nexmo::Client.new(key: 'ac5a236a', secret: '49ffb251')
    sms_answer = nexmo.send_message(from: 'PS App', to: '+' + cellphone, text: 'Your confirmation code:' + user_hash)  
    if sms_answer
      return true
    else
      error("Send sms failed", "SEND_SMS_FAILED", {"message"=>"Try later"})
    end
end

#SMSC
def send_reg_sms(cellphone, user_hash)
  require '/home/api-ps/smsc_api'
  sms = SMSC.new()
  ret = sms.send_sms('+' + cellphone, 'Your confirmation code:' + user_hash, 0, 0, 0, 0, 'ps-app', "maxsms=3")
  if ret[1] == '1'
    return true
  else
    error("Send sms failed", "SEND_SMS_FAILED", {"message"=>"Try later"})
  end
end 

  def send_ios_notify(device, message)
    APNS.host = 'gateway.sandbox.push.apple.com'
    APNS.port = 2195
    APNS.pem  = '/home/api-ps/config/apns-dev.pem'
    APNS.pass = 'a982lsnn'

    sleep 10
    APNS.send_notification(device, message )
    APNS.send_notification(device, :alert => message, :badge => 1, :sound => 'default')
  end

  def send_android_notify(device, message)
    GCM.host = 'https://android.googleapis.com/gcm/send'
    GCM.format = :json
    GCM.key = "AIzaSyA3iMzszSOpKtg0gtukqH4j907yegFMNcw"
  
    GCM.send_notification( device, message )
  end

  private

  def current_ability
    @current_ability ||= Ability.new(@params['token'])
  end

end
