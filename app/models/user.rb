class User < ApplicationRecord
  has_many :user_contents, dependent: :destroy
  has_many :contents, through: :user_contents
end
