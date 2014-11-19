class Api::V1::EmailaccountsController < ApplicationController
  include EmailHelper
  
  def list
    authorize! :show, @emails
    emails = EmailAccount.where(["domain_id = ?", @params['domain_id']])
    show_response(emails.as_json(only: [:id, :email]))
  end

  def info
    authorize! :show, @email
    if current_user.domains.where(["id = ?", @params['domain_id']]).present?
      if EmailAccount.where(["id = ?", @params['email_id']]).present?
        email = EmailAccount.find( @params['email_id'])
        emails.as_json(email.as_json(only: [:id, :email]))
      else
        error("find email failed", "SHOW_EMAIL_FAILED", {"message"=>"no such email"})
      end
    else
       error("find email failed", "SHOW_EMAIL_FAILED", {"message"=>"domain not found"})
		end
  end

  def create
    authorize! :create, @email
    if current_user.domains.where(["id = ?", @params['domain_id']]).present?
      domain = current_user.domains.where(["id = ?", @params['domain_id']]).first
      email_name = "#{@params['email']}@#{domain['domain']}"
      email = EmailAccount.create(user_id: current_user['id'], domain_id: domain['id'], company_id: domain['company_id'], email: email_name)
      if !email.new_record?
        show_response(email.as_json(only: [:id, :email]))
      else
         error("Register email failed", "REG_EMAIL_FAILED", email.errors)
      end
    else
       error("Register email failed", "REG_EMAIL_FAILED", {"message"=>"domain not found"})
		end
  end

  def delete
    authorize! :destroy, @email
    if current_user.domains.where(["id = ?", @params['domain_id']]).present?
      if EmailAccount.where(["domain_id = ?", @params['domain_id']]).present?
        email = EmailAccount.find(@params['email_id'])
        email.destroy
        if email.destroyed?
           show_response({"message"=>"email successfully delete"})
        else
           error("Delete email failed", "DEL_EMAIL_FAILED", email.errors)
        end
      else
        error("Delete email failed", "DEL_EMAIL_FAILED", {"message"=>"no such email"})
		  end
    else
      error("Delete email failed", "DEL_EMAIL_FAILED", {"message"=>"no such domain"})
	  end
  end

  def update
    authorize! :update, @email
    if current_user.domains.where(["id = ?", @params['domain_id']]).present?
      if EmailAccount.where(["id = ?", @params['email_id']]).present?
       email = EmailAccount.find(@params['email_id'])
        if email.update_attributes(email: @params['email'])
          show_response({"message"=>"email successfully update"})
        else
          error("update email failed", "UPDATE_EMAIL_FAILED", email.errors)
        end
      else
        error("update email failed", "UPDATE_EMAIL_FAILED", {"message"=>"no such email"})
	    end
    else
      error("update email failed", "UPDATE_EMAIL_FAILED", {"message"=>"no such domain"})
    end
  end

  def test_gen
    data = {:firstname => @params["firstname"], :lastname => @params["lastname"], :phone => @params["phone"], :domain => @params["domain"]}
    emails = generate_email data
    show_response(emails)
  end

end
