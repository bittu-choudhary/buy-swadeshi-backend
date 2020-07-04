Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get 'data', to: 'brand#data'
  get 'product', to: 'brand#product'
  get 'company', to: 'brand#company'
  get 'category', to: 'brand#category'

end
