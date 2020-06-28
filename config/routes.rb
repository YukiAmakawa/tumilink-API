Rails.application.routes.draw do  
  post '/callback' => 'linebot#callback'

  namespace 'api' do
    resources :users

  end
end 