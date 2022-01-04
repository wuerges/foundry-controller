# require 'httparty'
require 'json'
require 'aws-sdk-route53'
require 'aws-sdk-ec2'

def get_instance_info(ec2_client, instance_id)
  response = ec2_client.describe_instances(
    instance_ids: [instance_id]
  )
  instance = response.reservations[0].instances[0]

  return { :launch_time => instance[:launch_time], :ipv_6_address=> instance[:ipv_6_address], :state => instance[:state][:name] }
end

def get_hosted_zone_params(route53_client, target_hosted_zone_id, target_record)

  resp = route53_client.test_dns_answer({
    hosted_zone_id: target_hosted_zone_id, # required
    record_name: target_record, # required
    record_type: "A", # required, accepts SOA, A, TXT, NS, CNAME, MX, NAPTR, PTR, SRV, SPF, AAAA, CAA, DS
  })
  
  return { :record_name => resp[:record_name], :record_data => resp[:record_data] }
end

# Full example call:
def run_me
  region = 'sa-east-1'

  ec2_client = Aws::EC2::Client.new(region: region)
  route53_client = Aws::Route53::Client.new(region: region) 
  
  instance_info = get_instance_info(ec2_client, 'i-062b6c0d9bc25b166')
  hosted_zone_info = get_hosted_zone_params(route53_client, 'Z06031063HJSRMN2Z5VCQ', 'kapparpg.wu.dev.br')

  return { instance_info: instance_info.to_json , hosted_zone_info: hosted_zone_info.to_json }
end

def lambda_handler(event:, context:)
  results = run_me

  {
    statusCode: 200,
    headers: {
      "Access-Control-Allow-Headers" => "Content-Type",
      "Access-Control-Allow-Origin" => "*",
      "Access-Control-Allow-Methods" => "GET"
    },
    body: results.to_json
  }
end
