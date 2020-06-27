module Api
  class UsersController < ApplicationController
    def show 
      user = User.find(params[:id])
      contents = user.contents
      render json: {
        status: 200,
        response: {
          user: user,
          contents: user.contents
        }
      }
    end
  end
end
