class Api::V1::GroupsController < ApplicationController
  def list
    authorize! :show, @groups
    groups = Group.where(["domain_id = ?", @params['domain_id']])
    show_response(groups.as_json(only: [:id, :email]))
  end

  def info
    if current_user.domains.where(["id = ?", @params['domain_id']]).present?
      group = Group.where(["id = ? AND domain_id = ?", @params['group_id'] ,@params['domain_id']]).first
      if group 
        show_response(group.email.as_json(only: [:id, :email]))
      else
        error("show group failed", "SHOW_GROUP_FAILED", {"message"=>"group not found"})
      end
    else
       error("show group failed", "SHOW_GROUP_FAILED", {"message"=>"domain not found"})
    end
  end

  def create
    authorize! :create, @group
    if current_user.domains.where(["id = ?", @params['domain_id']]).present?
      domain = current_user.domains.where(["id = ?", @params['domain_id']]).first
      email_name = "#{@params['email']}@#{domain['domain']}"
      group = Group.create(domain_id: domain['id'], email: email_name)
      if !group.new_record?
        show_response(group.as_json(only: [:id, :email]))
      else
         error("Register group failed", "CREATE_GROUP_FAILED", group.errors)
      end
    else
       error("Register group failed", "CREATE_GROUP_FAILED", {"message"=>"domain not found"})
		end
  end

  def delete
    authorize! :destroy, @email
    if current_user.domains.where(["id = ?", @params['domain_id']]).present?
      group = Group.where(["id = ? AND domain_id = ?", @params['group_id'] ,@params['domain_id']]).first
      if group
        group.destroy
        if group.destroyed?
           show_response({"message"=>"Group successfully delete"})
        else
           error("Delete group failed", "DEL_GROUP_FAILED", group.errors)
        end
      else
        error("Delete group failed", "DEL_GROUP_FAILED", {"message"=>"no such group"})
		  end
    else
      error("Delete group failed", "DEL_GROUP_FAILED", {"message"=>"no such domain"})
	  end
  end

  def add
    authorize! :create, @group
    group = Group.where(["id = ? AND domain_id = ?", @params['group_id'] ,@params['domain_id']]).first
    if group 
      if !@params['email_ids'].nil?
        info = []
        @params['email_ids'].each do |email_id|
          email = EmailAccount.find(email_id)
          if email && email["domain_id"] == @params['domain_id'].to_i
            if !email.groups.where(["email_account_id = ?", email_id]).first
              group.email_accounts << email
              group.save!
              info << {email_id => {"status"=>"ok", "message"=>"email added to group"}}
            else
              info << {email_id => {"status"=>"errors", "message"=>"email already added to group"}}
            end
          else 
            info << {email_id => {"status"=>"errors", "message"=>"no such email"}}
          end
        end
         show_response(info)
      else
        error("Add emails to group failed", "ADD_EMAILS_TO_GROUP_FAILED", {"message"=>"emails array empty"})
      end
     
    else
      error("Add emails to group failed", "ADD_EMAILS_TO_GROUP_FAILED", {"message"=>"no such domain or group"})
    end
  end

  def remove
    authorize! :create, @group
    group = Group.where(["id = ? AND domain_id = ?", @params['group_id'] ,@params['domain_id']]).first
    if group 
      if !@params['email_ids'].nil?
        info = []
        @params['email_ids'].each do |email_id|
          email = EmailAccount.find(email_id)
          if email && email["domain_id"] == @params['domain_id'].to_i
            group_email = group.email_accounts.find(email)
            if group_email
              group_email.delete
              info << {email_id => {"status"=>"ok", "message"=>"email removed from group"}}
            else
              info << {email_id => {"status"=>"errors", "message"=>"no such email in group"}}
            end
          else 
            info << {email_id => {"status"=>"errors", "message"=>"no such email"}}
          end
        end
         show_response(info)
      else
        error("Remove emails to group failed", "REMOVE_EMAILS_FROM_GROUP_FAILED", {"message"=>"emails array empty"})
      end
     
    else
      error("Remove emails to group failed", "REMOVE_EMAILS_FROM_GROUP_FAILED", {"message"=>"no such domain or group"})
    end

  end

end