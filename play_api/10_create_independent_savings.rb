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

server_response =  JSON.parse(response.body )

# a = Member.find_by_id 1755
# a.savings_entries.where(:is_confirmed => false ).all.each {|x| x.delete_object }

 # {"success"=>true, "savings_entries"=>[{"id"=>396389, "member_id"=>1755, "member_name"=>"Leha", "member_id_number"=>"1755", "direction"=>1, "direction_text"=>"Penambahan", "amount"=>"500000.0", "is_confirmed"=>false, "confirmed_at"=>nil}], "total"=>100} 
 

