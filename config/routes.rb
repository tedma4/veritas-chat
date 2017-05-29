Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :chats, only: [:index, :create, :destroy]
  resources :joined_chats, only: [:index]
  post "join_chat", to: "joined_chats#create"
  delete "leave_chat", to: "joined_chats#destroy"
  
  resources :messages, only: [:index, :create]

end
