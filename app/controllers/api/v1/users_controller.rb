class Api::V1::UsersController < ApplicationController
  

  require 'digest/sha1'
  

  api :GET, "/v1/user/list", "Получить список пользователей"
  param :token, String, :desc => "Пользовательский токен", :required => true
  error :code => 301, :desc => "Invalid token", :meta => {:описание => "Неправильный токен или токен не был передан"}
  
  def list
    authorize! :show, @users
    users = User.all.as_json(only: [:id, :name, :cellphone, :email, :user_credential_id, :device_token])
    show_response(users)
  end


  api :GET, "/v1/user/info", "Получить информацию о пользователе"
  param :token, String, :desc => "Пользовательский токен", :required => true
  error :code => 301, :desc => "Invalid token", :meta => {:описание => "Неправильный токен или токен не был передан"}
  
  def info
    authorize! :show, @info
    info = current_user.as_json(only: [:id, :name, :cellphone, :email, :user_credential_id, :device_token])
    show_response(info)
  end

  api :GET, "/v1/user/create", "Создание пользователя"
  param :cellphone, String, :desc => "Телефон пользователя", :required => true
  param :device_token, String, :desc => "Токен девайса", :required => true
  error :code => 301, :desc => "REG_USER_FAILED", :meta => {:описание => "Неправильный телефон или токен девайса"}
  error :code => 301, :desc => "REG_USER_FAILED", :meta => {:описание => "Проблема с SMS gateway"}
  
  def create
    confirmation_hash = generate_user_hash
    user = User.create(cellphone: @params['cellphone'], confirmation_hash: Digest::SHA1.hexdigest(confirmation_hash), device_token: @params['device_token'])
    if !user.new_record?
      if send_reg_sms(user.cellphone, confirmation_hash)
        show_response({"message" =>  "SMS successfully sended"})
      end
    else
      error("register user failed", "REG_USER_FAILED", user.errors)
    end
  end


  api :GET, "/v1/user/delete", "Удаление пользователя"
  param :token, String, :desc => "Пользовательский токен", :required => true
  error :code => 301, :desc => "DEL_DOMAIN_FAILED", :meta => {:описание => "Пользователь не найден"}
  error :code => 301, :desc => "Invalid token", :meta => {:описание => "Неправильный токен или токен не был передан"}
 
  def delete
    authorize! :delete, @info
     if current_user
       current_user.destroy
       if current_user.destroyed?
         show_response({"message"=>"User successfully delete"})
       else
         error("Delete user failed", "DEL_DOMAIN_FAILED", current_user.errors)
       end

     else
       error("Delete user failed", "DEL_DOMAIN_FAILED", {"message"=>"no such user"})    
     end
  end


  api :GET, "/v1/user/confirm", "Подтверждение пользователя по смс"
  param :cellphone, String, :desc => "Телефон пользователя", :required => true
  param :confirm_code, String, :desc => "Код высланный по смс пользователю", :required => true
  error :code => 301, :desc => "USER_CONFIRM_FAILED", :meta => {:описание => "Неправильный код подтверждения или пользователь уже активирован"}
  error :code => 301, :desc => "USER_CONFIRM_FAILED", :meta => {:описание => "Пользователь не найден"}
  
  def confirm
    user = User.where("cellphone = ?", @params['cellphone']).first
    if user && !user.activated?
      if @params['confirm_code'] && user.confirmation_hash == Digest::SHA1.hexdigest(@params['confirm_code']) 
          if user.update_attribute( :activated, true ) 
             api_key = user.find_api_key['access_token']
             show_response({"access_token" => api_key})
          else 
            error("Confirm user failed", "USER_CONFIRM_FAILED", user.errors)
          end
      else 
        error("Confirm user failed", "USER_CONFIRM_FAILED", {"message"=>"not valid code"})
      end
    else
      error("Confirm user failed", "USER_CONFIRM_FAILED", {"message"=>"user not exist or already activated"})
    end
  end


  api :GET, "/v1/user/update_device", "Изменить device_token у пользователя"
  param :device_token, String, :desc => "Токен девайса", :required => true
  param :token, String, :desc => "Пользовательский токен", :required => true
  error :code => 301, :desc => "UPDATE_DEVICE_TOKEN_FAILED", :meta => {:описание => "Проблемы с SMS gateway"}
  error :code => 301, :desc => "UPDATE_DEVICE_TOKEN_FAILED", :meta => {:описание => "Пользователь не найден"}

  def update_device
    authorize! :update, @info
    user = current_user
    if user.update_attribute( :device_token, @params['device_token'] ) 
      show_response({"message" => "device token updated"})
    else
      error("Update device token failed", "UPDATE_DEVICE_TOKEN_FAILED", user.errors)
    end
  end
  

  api :GET, "/v1/user/resend_code", "Отправить код подтверждения пользователя заново"
  param :cellphone, String, :desc => "Телефон пользователя", :required => true
  error :code => 301, :desc => "UPDATE_DEVICE_TOKEN_FAILED", :meta => {:описание => "Проблемы с SMS gateway"}
  error :code => 301, :desc => "UPDATE_DEVICE_TOKEN_FAILED", :meta => {:описание => "Пользователь не найден или уже подтвердил код"}
  
  def resend_code
    user = User.where("cellphone = ?", @params['cellphone']).first
    if user && user.activated? == false
      confirmation_hash = rand(36**5).to_s(36)
      if user.update_attribute( :confirmation_hash, Digest::SHA1.hexdigest(confirmation_hash) ) 
        sms_answer = send_reg_sms(user.cellphone, confirmation_hash)
        if sms_answer
          show_response({"message" => "SMS successfully sended"})
        else 
          error("Resend SMS failed", "RESEND_SMS_FAILED", {"message"=>"Try later"})
        end
      end
    else
      error("Resend SMS failed", "RESEND_SMS_FAILED", {"message"=>"user already confirm or not exist"})
    end
  end
  
  #TODO DESTROY IN PRODUCTION
  def delete_by_phone
      user = User.where("cellphone = ?", @params['cellphone']).first
       user.destroy
       if user.destroyed?
         show_response({"message"=>"User successfully delete"})
       else
         error("Delete user failed", "DEL_DOMAIN_FAILED", user.errors)
       end
  end
  
  api :GET, "/v1/user/test_push_ios", "Тестовый метод отправки push-а для ios"
  param :token, String, :desc => "Пользовательский токен", :required => true
  
  def test_push_ios
    authorize! :show, @info
    send_ios_notify(current_user.device_token, 'Hello iPhone!')
  end


  api :GET, "/v1/user/test_push_android", "Тестовый метод отправки push-а для android-а"
  param :token, String, :desc => "Пользовательский токен", :required => true

  def test_push_android
    authorize! :show, @info
    send_android_notify(current_user.device_token, {:hello => "world"})
  end

end
