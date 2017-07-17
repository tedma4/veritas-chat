Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :chats, only: [:index, :create, :destroy]
  resources :joined_chats, only: [:index]
  resources :device, only: [:create, :update]  
  get 'list_local_chats', to: "chats#list_local_chats"
  post "join_chat", to: "joined_chats#create"
  delete "leave_chat", to: "joined_chats#destroy"
  
  resources :messages, only: [:index, :create]

end
