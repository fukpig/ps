class Api::V1::InviteController < ApplicationController
 
  def create
  	#TODO REFACT THIS IF`s
  	authorize! :create, @invite
	if !Invite.where(["cellphone = ? and domain_id = ?", @params['cellphone'], @params['domain_id']]).present?
	  if @params['cellphone'] != current_user.cellphone
		if current_user.domains.where(["id = ?", @params['domain_id']]).present?
		  invite = Invite.create(cellphone:  @params['cellphone'], inviter_id: current_user['id'], domain_id: @params['domain_id'])
		  if (User.where(["cellphone = ?", @params['cellphone']]).present?)
			if !invite.new_record?
			  show_response({"isset"=>"true", "message"=>"invite has been added"})
			else
			  error("Create invite failed", "CREATE_INVITE_FAILED", invite.errors)
			end
		  else 
		  	show_response({"isset"=>"false"})
		  end
		else
		  error("Create invite failed", "CREATE_INVITE_FAILED", {"message"=>"domain not found"})
		end
	  else 
   	    error("Create invite failed", "CREATE_INVITE_FAILED", {"message"=>"invalid cellphone"})
	  end
	else 
		error("Create invite failed", "CREATE_INVITE_FAILED", {"message"=>"invite already sended"})
	end
  end

  def list
  	 authorize! :show, @invites
	 data = Array.new
	 invites = Invite.where(["cellphone = ?", current_user.cellphone])
	 invites.each do |invite|
		if !invite.accepted?
		 info = Hash.new
		 domain = Domain.where(["id = ?", invite["domain_id"]]).first
		 inviter = User.where(["id = ?", invite["inviter_id"]]).first
		 info = { "id" => invite["id"], "domain_id" => invite["domain_id"], "domain"=> domain["domain"], "inviter_id" => invite["inviter_id"], "inviter_name" => inviter["name"]}
		 data << info
		end
	 end
	 show_response(data)
  end

  def accept
  	authorize! :update, @invites
	if Invite.where(["cellphone = ? and id=?", current_user["cellphone"] , @params["invite_id"]]).present?
		invite = Invite.where(["cellphone = ? and id=?",current_user["cellphone"], @params["invite_id"]]).first
		if invite.update_attribute( :accepted, true ) 
			UserToCompanyRole.create(user_id: current_user["id"],role_id:2, company_id: invite["company_id"])
			show_response({"message"=>"successfully added to company"})
		else 
			error("Accept invite failed", "ACCEPT_INVITE_FAILED", invite.errors)
		end
	else
		error("Accept invite failed", "ACCEPT_INVITE_FAILED", {"message"=>"no such invite"})
	end
  end
  
  def reject
  	authorize! :destroy, @invites
	if Invite.where(["cellphone = ? and id=?", current_user["cellphone"] , @params["invite_id"]]).present?
		invite = Invite.where(["cellphone = ? and id=?",current_user["cellphone"], @params["invite_id"]]).first
		if invite.destroyed?
			show_response({"message"=>"Invite successfully reject"})
		else 
			error("Reject invite failed", "REJECT_INVITE_FAILED", invite.errors)
		end
	else
		error("Reject invite failed", "REJECT_INVITE_FAILED", {"message"=>"no such invite"})
	end
  end
end
