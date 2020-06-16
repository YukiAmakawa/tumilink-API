class User < ApplicationRecord
  has_many :contents, through :user_content
  has_many :group_user, dependent: :destroy
end
