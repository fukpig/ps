class Group < ActiveRecord::Base
	has_and_belongs_to_many :email_accounts

	validates :email, :presence => true, uniqueness: true
end
