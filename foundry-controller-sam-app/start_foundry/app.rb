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

def update_ip_of_record(route53_client, target_hosted_zone_id, target_record, target_ip)
  
  resp = route53_client.change_resource_record_sets({
    change_batch: {
      changes: [
        {
          action: "UPSERT", 
          resource_record_set: {
            name: target_record, 
            resource_records: [
              {
                value: target_ip, 
              }, 
            ], 
            ttl: 300, 
            type: "A", 
          }, 
        }, 
      ], 
      comment: "Web server for foundry-vtt", 
    }, 
    hosted_zone_id: target_hosted_zone_id, 
  })

  return resp
end

# Full example call:
def run_me
  region = 'sa-east-1'

  ec2_client = Aws::EC2::Client.new(region: region)
  route53_client = Aws::Route53::Client.new(region: region) 
  
  resp = ec2_client.start_instances({ instance_ids: ['i-062b6c0d9bc25b166']})
  
  ip_of_instance = get_instance_ip(ec2_client, 'i-062b6c0d9bc25b166')

  resp = ip_of_instance ? 
    update_ip_of_record(route53_client, 'Z06031063HJSRMN2Z5VCQ', 'kapparpg.wu.dev.br', ip_of_instance) : 
    nil
  return { ip_of_instance: ip_of_instance, update_ip_of_record: resp }
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