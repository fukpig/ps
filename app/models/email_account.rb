class EmailAccount < ActiveRecord::Base
    belongs_to :user
    belongs_to :company
    belongs_to :domain

    validates :user_id, presence: true
    validates :company_id, presence: true
    validates :domain_id, presence: true
    validates :email, :presence => true, uniqueness: true, format: { with: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/,
    message: "not valid email" }
end
