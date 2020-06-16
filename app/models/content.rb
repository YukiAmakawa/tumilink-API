class Content < ApplicationRecord
  has_many :users, through :user_content
  has_many :group_user, dependent: :destroy
end
