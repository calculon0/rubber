require 'rubber/cloud/fog'
require 'rubber/cloud/fog_storage'

module Rubber
  module Cloud

    class Rackspace < Fog

      def initialize(env, capistrano)
        super(env, capistrano)
        credentials = Rubber::Util.symbolize_keys(env.credentials)
        @storage_provider = ::Fog::Storage.new(credentials)
        credentials[:version] = :v2
        @compute_provider = ::Fog::Compute.new(credentials)
      end

      def create_instance(ami, ami_type, security_groups, availability_zone, instance_alias)
        response = @compute_provider.servers.bootstrap(:name => instance_alias,
                                                    :image_id => ami,
                                                    :flavor_id => ami_type,
                                                    :groups => security_groups,
                                                    :public_key_path => env.key_file.to_s + ".pub",
                                                    :private_key_path => env.key_file)
        instance_id = response.id
        return instance_id
      end

      def describe_instances(instance_id=nil)
        instances = []
        if instance_id
          response = []
          response << @compute_provider.servers.get(instance_id)
        else
          response = @compute_provider.servers.all
        end
        #{response = @compute_provider.servers.all(opts)}

        response.each do |item|
          instance = {}
          instance[:id] = item.id
          instance[:type] = item.flavor_id
          #instance[:external_host] = item.dns_name
          instance[:external_host] = ""
          #instance[:external_ip] = item.public_ip_address
          instance[:external_ip] = item.ipv4_address
          #instance[:internal_host] = item.private_dns_name
          instance[:internal_host] = ""
          #instance[:internal_ip] = item.private_ip_address
          if item.addresses.empty?
            instance[:internal_ip] = ""
          else
            instance[:internal_ip] = item.addresses["private"].first["addr"]
          end
          instance[:state] = item.state
          #instance[:zone] = item.availability_zone
          instance[:zone] = ""
          #instance[:platform] = item.platform || 'linux'
          instance[:platform] = 'linux'
          #instance[:root_device_type] = item.root_device_type
          instance[:root_device_type] = ""
          instances << instance
        end
        return instances
      end

      def create_security_group(group_name, group_description)

      end

      def describe_security_groups(group_name=nil)
        []
      end

      def add_security_group_rule(group_name, protocol, from_port, to_port, source)

      end

      def create_tags(resource_id, tags)

      end
    end
  end

end
