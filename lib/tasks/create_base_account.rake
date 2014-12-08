require 'rubygems'
require 'pg'
require 'active_record'
require 'csv'



task :create_base_account => :environment do
  Account.create_base_objects
end
 
 

