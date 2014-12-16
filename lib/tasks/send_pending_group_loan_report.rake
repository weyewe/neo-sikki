require 'rubygems'
require 'pg'
require 'active_record'
require 'csv'




task :send_pending_group_loan_report => :environment do
  UserMailer.pending_group_loan(["admin@gmail.com"]).deliver
end
