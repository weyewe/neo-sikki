NeoSikki::Application.routes.draw do
  devise_for :users 
  root :to => 'home#extjs' , :method => :get 
  
  namespace :api do 
    devise_for :users
    
    post 'authenticate_auth_token', :to => 'sessions#authenticate_auth_token', :as => :authenticate_auth_token 
    put 'update_password' , :to => "passwords#update" , :as => :update_password
    
    get 'search_role' => 'roles#search', :as => :search_role 
    get 'search_group_loan_products' => 'group_loan_products#search', :as => :search_group_loan_product
    get 'search_group_loans' => 'group_loans#search', :as => :search_group_loan
    get 'search_members' => 'members#search', :as => :search_member
    get 'search_group_loan_memberships' => 'group_loan_memberships#search', :as => :search_group_loan_membership
    get 'search_group_loan_weekly_collections' => 'group_loan_weekly_collections#search', :as => :search_group_loan_weekly_collection
    
    resources :app_users
    resources :members
    resources :group_loans 
    resources :group_loan_products
    resources :group_loan_memberships
    resources :group_loan_weekly_collections
    resources :group_loan_weekly_uncollectibles 
    resources :group_loan_premature_clearance_payments
    
    resources :deceased_clearances 
    resources :group_loan_run_away_receivables 
     
  end
end
