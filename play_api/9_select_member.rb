require 'httparty'
require 'json'
 
BASE_URL = "http://localhost:3000"


response = HTTParty.post( "#{BASE_URL}/api2/users/sign_in" ,
  { 
    :body => {
    	:user_login => { :email => "willy@gmail.com", :password => "willy1234" }
    }
  })

server_response =  JSON.parse(response.body )

auth_token  = server_response["auth_token"]


response = HTTParty.get( "#{BASE_URL}/api2/members" ,
  :query => {
  	:auth_token => auth_token,
    :livesearch => 'leha'
  })

server_response =  JSON.parse(response.body )


selected_member = server_response["members"].first
selected_member_id = selected_member["id"]

response = HTTParty.get( "#{BASE_URL}/api2/savings?member_id=1755" ,
  :query => {
    :auth_token => auth_token
  })

server_response =  JSON.parse(response.body )


first_group_loan = server_response["savings"].first