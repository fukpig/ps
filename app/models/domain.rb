class Domain < ActiveRecord::Base
    belongs_to :user

    has_many :groups, dependent: :destroy

    validates :domain, presence: true, uniqueness: true, format: { with: /[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,6}\z/,
    message: "not valid domain"}
end
