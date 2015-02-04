require 'rubygems'
require 'fog'


task :try_upload_aws => :environment do
  
  # create a connection
  puts "create connection"
  connection = Fog::Storage.new({
    :provider                 => 'AWS',
    :aws_access_key_id        => Figaro.env.s3_key ,
    :aws_secret_access_key    => Figaro.env.s3_secret 
  })

  # First, a place to contain the glorious details
  # puts "create directory"
  # directory = connection.directories.create(
  #   :key    =>  ENV['S3_BUCKET']    , # globally unique name
  #   :public => true
  # )
  # 
  directory = connection.directories.get( Figaro.env.s3_bucket  ) 
 
  # upload that resume
  puts "upload"
  file = directory.files.create(
    :key    => 'config.ru',
    :body   => File.open("#{Rails.root}/cleaning_result.csv"),
    :public => true
  )
  
  puts file.public_url
  
end

