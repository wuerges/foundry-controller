# require 'httparty'
require 'json'
require 'aws-sdk-ec2'

def run_me
  region = 'sa-east-1'

  ec2_client = Aws::EC2::Client.new(region: region)
  
  ec2_client.stop_instances({ instance_ids: ['i-062b6c0d9bc25b166']})
end

def lambda_handler(event:, context:)
  run_me

  {
    statusCode: 200,
    headers: {
      "Access-Control-Allow-Headers" => "Content-Type",
      "Access-Control-Allow-Origin" => "*",
      "Access-Control-Allow-Methods" => "GET"
    },
    body: {}.to_json
  }
end
