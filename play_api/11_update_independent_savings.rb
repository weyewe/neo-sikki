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


# delete  the savings entry under scrutiny
a = Member.find_by_id 1755
a.savings_entries.where(:is_confirmed => false ).all.each {|x| x.delete_object }


# create new savings_entry 
response = HTTParty.post( "#{BASE_URL}/api2/savings?member_id=1755" ,
  :query => {
    :auth_token => auth_token
  },
  :body => {
    :savings_entry => {  
      :amount        =>  BigDecimal( '500000' ),
      :member_id =>  1755, 
      :direction =>   1 # 1 for addition, 2 for withdrawal
    }
  }

)

# update the shit
server_response =  JSON.parse(response.body )

savings_id = server_response["savings_entries"].first["id"]


response = HTTParty.put( "#{BASE_URL}/api2/savings/#{savings_id}?member_id=1755" ,
  :query => {
    :auth_token => auth_token
  },
  :body => {
    :savings_entry => {  
      :amount        =>  BigDecimal( '5500' ),
      :member_id =>  1755, 
      :direction =>   1 # 1 for addition, 2 for withdrawal
    }
  }

)

server_response =  JSON.parse(response.body )