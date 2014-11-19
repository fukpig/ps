class User < ActiveRecord::Base
   has_paper_trail 
   has_many :api_keys, dependent: :destroy
   has_many :domains, dependent: :destroy
   has_many :companies, dependent: :destroy
   has_one :user_role
   validates :cellphone, presence: true, uniqueness: true, length: { in: 6..40 },  format: { with: /\A[0-9]+\z/,
    message: "only allows numbers" }
   validates :device_token, presence: true

  def find_api_key ()
    self.api_keys.first_or_create
  end
end
