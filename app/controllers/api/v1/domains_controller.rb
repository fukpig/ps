class Api::V1::DomainsController < ApplicationController
  include GoogleHelper
  include RegruHelper
  
  api :GET, "/v1/domain/list", "Получить список доменов"
  param :token, String, :desc => "Пользовательский токен", :required => true
  error :code => 301, :desc => "Invalid token", :meta => {:описание => "Неправильный токен или токен не был передан"}
  
  def list
    authorize! :show, @users
    domains = current_user.domains
    show_response(domains.as_json(only: [:id, :domain, :registration_date, :expiry_date, :status, :ns_list]))
  end

  api :GET, "/v1/domain/info", "Получить информацию о домене"
  param :token, String, :desc => "Пользовательский токен", :required => true
  param :domain_id, String, :desc => "Id домена", :required => true
  error :code => 301, :desc => "Invalid token", :meta => {:описание => "Неправильный токен или токен не был передан"}
  error :code => 301, :desc => "FIND_DOMAIN_FAILED", :meta => {:описание => "Домен не найден"}
  
  def info
    authorize! :show, @domain
    if current_user.domains.where(["id = ?", @params['domain_id']]).present?
      domain = current_user.domains.find( @params['domain_id'])
	    show_response(domain.as_json(only: [:id, :domain, :registration_date, :expiry_date, :status, :ns_list]))
    else
	    error("no such domain", "FIND_DOMAIN_FAILED", {"message"=>"no such domain"})
    end
  end

  

  api :GET, "/v1/domain/create", "Создать домен(пока локально)"
  param :token, String, :desc => "Пользовательский токен", :required => true
  param :domain, String, :desc => "Домен", :required => true
  error :code => 301, :desc => "Invalid token", :meta => {:описание => "Неправильный токен или токен не был передан"}
  error :code => 301, :desc => "REG_DOMAIN_FAILED", :meta => {:описание => "Не передан один из параметров"}
  
  def create
    authorize! :create, @domain
    domain = Domain.create(user_id: current_user['id'], domain: @params['domain'], registration_date: DateTime.now, expiry_date: 1.year.from_now, status: 'ok', ns_list: 'ns.ps.kz,ns1.ps.kz')
    if !domain.new_record?
	    show_response(domain.as_json(only: [:id, :domain, :registration_date, :expiry_date, :status, :ns_list]))
    else
      error("Register domain failed", "REG_DOMAIN_FAILED", domain.errors)
    end
  end

  api :GET, "/v1/domain/delete", "Удалить домен(пока локально)"
  param :token, String, :desc => "Пользовательский токен", :required => true
  param :domain_id, String, :desc => "ID домена", :required => true
  error :code => 301, :desc => "Invalid token", :meta => {:описание => "Неправильный токен или токен не был передан"}
  error :code => 301, :desc => "DEL_DOMAIN_FAILED", :meta => {:описание => "Домен не найден"}
  
  def delete
    authorize! :delete, @users
    if current_user.domains.where(["id = ?", @params['domain_id']]).present?
      domain = Domain.find(@params['domain_id'])
      domain.destroy
      if domain.destroyed?
		    show_response({"message"=>"domain successfully delete"})
      else
        error("Delete domain failed", "DEL_DOMAIN_FAILED", domain.errors)
      end
    else
      error("Delete domain failed", "DEL_DOMAIN_FAILED", {"message"=>"no such domain"})
    end
  end

  
  api :GET, "/v1/domain/whois", "Получить whois информацию"
  param :domain, String, :desc => "Домен", :required => true
  
  def whois
    client = Whois::Client.new
    show_response(client.lookup(@params['domain']))
  end

  api :GET, "/v1/domain/check_available", "Проверить доступность домена для регистрации(+ автоматом возвращает доступные варианты доменов с reg.ru)"
  param :domain, String, :desc => "Домен", :required => true
  error :code => 301, :desc => "CHECK_DOMAIN_FAILED", :meta => {:описание => "Неправильный домен"}
  
  def check_available
	if !@params['domain'].nil?
		result = Whois.whois(@params['domain'])
		if result.available? == false
			domain_word = @params['domain'].split('.').first
			reg_ru = RegApi2.domain.get_suggest(word: domain_word,
				use_hyphen: "1"
			)
			show_response({"available"=>result.available?, "choice" => reg_ru})
		else 
			show_response({"available"=>result.available?})
		end
	else
     error("Check domain failed", "CHECK_DOMAIN_FAILED", {"message"=>"invalid domain"})
	end
  end

   api :GET, "/v1/domain/get_nss", "Получить ns сервера домена"
   param :domain, String, :desc => "Домен", :required => true
  
  def get_nss
    result = Whois.whois(@params['domain'])
    show_response(result.nameservers)
  end
  
  
  api :GET, "/v1/domain/reg_ru_test", "Тестовое создание домена через API reg.ru"
   
  def reg_ru_test
    begin
      data = {:domain => @params['domain']}
      data[:verify_txt] = get_verify_txt_google(data)

		  reg_domain_reg_ru(data)
      set_records(data)

      insert_site_verify_google(data)
      create_domain_in_gapps(data)
      create_subscription_google(data)

		  show_response("good")
    rescue => e
      #TODO LOG ERROR 
      error("Reg domain failed", "REG_DOMAIN_FAILED", {"message"=>e.message})
    end
  end
end
