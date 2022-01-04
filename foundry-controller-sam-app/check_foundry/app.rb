# require 'httparty'
require 'json'
require 'aws-sdk-route53'
require 'aws-sdk-ec2'

def get_instance_ip(ec2_client, instance_id)
  response = ec2_client.describe_instances(
    instance_ids: [instance_id]
  )
  return response.reservations[0].instances[0].public_ip_address
end

def get_hosted_zone_params(route53_client, target_hosted_zone_id, target_record)
  resp = route53_client.get_hosted_zone({
    id: target_hosted_zone_id, 
  })  
  return resp
end

# Full example call:
def run_me
  region = 'sa-east-1'

  ec2_client = Aws::EC2::Client.new(region: region)
  route53_client = Aws::Route53::Client.new(region: region) 
  
  ip_of_instance = get_instance_ip(ec2_client, 'i-062b6c0d9bc25b166')
  hosted_zone_info = get_hosted_zone_params(route53_client, 'Z06031063HJSRMN2Z5VCQ', 'kapparpg.wu.dev.br')

  return { ip_of_instance: ip_of_instance, update_ip_of_record: hosted_zone_info }
end

def lambda_handler(event:, context:)
  results = run_me

  {
    statusCode: 200,
    body: {
      message: "#{results}",
      # location: response.body
    }.to_json
  }
end
