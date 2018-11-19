Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :shipping_rates_per_methods do
      post :import, on: :collection
    end
    resources :cargo_shipping_rates_per_methods do
      post :import, on: :collection
    end
    resources :cities do
      post :import, on: :collection
    end
  end
end
