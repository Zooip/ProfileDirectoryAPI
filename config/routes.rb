Rails.application.routes.draw do
  get 'home/home'

  use_doorkeeper
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  match 'login', to: 'user_sessions#new', via: [:get], as: :user_sessions
  match 'login', to: 'user_sessions#create', via: [:post]
  match 'logout', to: 'user_sessions#destroy', via: [:get,:delete]

  namespace :api, constraints: { format: 'json' } do
    namespace :v1 do
      jsonapi_resources :profiles do
        jsonapi_relationships
        #resources :connection_aliases 
      end
      jsonapi_resources :oauth_applications do
        jsonapi_related_resource :owner, controller: 'profiles'
        jsonapi_links :owner

        member do
          post 'reset_secret'
        end
      end
      jsonapi_resources :phone_numbers do
        jsonapi_relationships
        #resources :connection_aliases 
      end
    end
  end

  # You can have the root of your site routed with "root"
   root 'home#home'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
