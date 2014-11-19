class Api::V1::GroupsController < ApplicationController
  def list
    authorize! :show, @groups
    groups = Group.where(["domain_id = ?", @params['domain_id']])
    show_response(groups.as_json(only: [:id, :email]))
  end

  #TO_DO MANY_TO_MANY
  def create
    authorize! :create, @group
    if current_user.domains.where(["id = ?", @params['domain_id']]).present?
      domain = current_user.domains.where(["id = ?", @params['domain_id']]).first
      email_name = "#{@params['email']}@#{domain['domain']}"
      email = EmailAccount.create(user_id: current_user['id'], domain_id: domain['id'], company_id: domain['company_id'], email: email_name)
      group = Group.create(domain_id: domain['id'], email: email_name)
      if !email.new_record? && !group.new_record?
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


end