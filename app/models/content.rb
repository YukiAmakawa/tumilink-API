class Content < ApplicationRecord
  has_many :user_contents, dependent: :destroy
  has_many :users, through: :user_contents
end
