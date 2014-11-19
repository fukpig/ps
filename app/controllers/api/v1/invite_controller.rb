class Api::V1::InviteController < ApplicationController
 
  def create
  	#TODO REFACT THIS IF`s
  	authorize! :create, @invite

  	begin
  	  check_existed_user @params['cellphone'], @params['domain_id']
  	  check_invite_himself @params['cellphone']
  	  domain_owner? @params['domain_id']
			invite = Invite.create(cellphone:  @params['cellphone'], inviter_id: current_user['id'], domain_id: @params['domain_id'])
		  if (User.where(["cellphone = ?", @params['cellphone']]).present?)
				create_invite invite
		  else 
		  	show_response({"isset"=>"false"})
		  end
		 rescue => e
		   error("Create invite failed", "CREATE_INVITE_FAILED", e.message)
		 end
  end

  def list
  	authorize! :show, @invites
	 	list = Array.new
	 	invites = Invite.where(["cellphone = ?", current_user.cellphone])
	 	invites.each do |invite|
	 		list << add_invite_to_list(invite) unless invite.accepted?
		end
	 	show_response(list)
  end

  def accept
  	authorize! :update, @invites
		if Invite.where(["cellphone = ? and id=?", current_user["cellphone"] , @params["invite_id"]]).present?
			invite = Invite.where(["cellphone = ? and id=?",current_user["cellphone"], @params["invite_id"]]).first
			if invite.update_attribute( :accepted, true ) 
				add_user_to_company invite["company_id"]
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



  def check_existed_user(cellphone, domain_id)
  	invite = Invite.where(["cellphone = ? and domain_id = ?", cellphone, domain_id]).first
  	raise StandardError.new(message:"invite already sended") unless invite
  end

  def check_invite_himself(cellphone)
		raise StandardError.new(message:"invalid cellphone") unless @params['cellphone'] != current_user.cellphone
  end

  def create_invite(invite)
  	if !invite.new_record?
			show_response({"isset"=>"true", "message"=>"invite has been added"})
		else
			raise StandardError.new(message:invite.errors) unless invite
		end
  end

  def add_invite_to_list(invite)
  	info = Hash.new
		domain = Domain.where(["id = ?", invite["domain_id"]]).first
		inviter = User.where(["id = ?", invite["inviter_id"]]).first
		info = { "id" => invite["id"], "domain_id" => invite["domain_id"], "domain"=> domain["domain"], "inviter_id" => invite["inviter_id"], "inviter_name" => inviter["name"]}
	end


	#TODO Перенести к юзерамкомпаниям
	def add_user_to_company(company_id)
		UserToCompanyRole.create(user_id: current_user["id"],role_id:2, company_id: company_id)
	end
end
