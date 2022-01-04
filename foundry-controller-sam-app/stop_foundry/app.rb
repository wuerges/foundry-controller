# require 'httparty'
require 'json'
require 'aws-sdk-ec2'

def run_me

  region = 'sa-east-1'

  ec2_client = Aws::EC2::Client.new(region: region)
  
  resp = ec2_client.stop_instances({ instance_ids: ['i-062b6c0d9bc25b166']})
  return resp
end

def lambda_handler(event:, context:)
  results = run_me

  {
    statusCode: 200,
    body: {
      message: "Results: #{results}",
      # location: response.body
    }.to_json
  }
end
