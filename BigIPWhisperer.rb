#!/usr/bin/env ruby
# author: dfosborne2

# Just a collection of methods to provision a BigIP. 
# More will be added along the way...

require 'rest-client'
require 'json'

class BigIpTalk
    def initialize(address=None, user=None, password=None)
      @bigip = RestClient::Resource.new(
          "https://#{address}/mgmt/tm/", 
          :user => user, 
          :password => password, 
          :headers => { :content_type => 'application/json' }
      )
    end
    
    # post changes made
    def save
      payload =  {:command => "save"}
      result = @bigip["sys/config"].post payload.to_json
    end
        
    # chk for node:
    def check_node name
      result = @bigip["ltm/node/#{name}"].get{|response, request, result| response }
    end
    #
    # Make a node
    def make_node name, address
      payload = {
        :kind => 'tm:ltm:node',
        :name => name,
        :address => address,
        :monitor => 'default'
      }
      result = @bigip['ltm/node'].post payload.to_json
 
    end
 
    def check_pool pool_name
      result = @bigip["ltm/pool/#{pool_name}"].get{|response, request, result| response }
    end
 
    def check_health_monitor monitor=None, parent=None
      if parent
        result = @bigip["ltm/monitor/#{parent}/#{monitor}"].get{|response, request, result| response }
    
      else
        result = @bigip["ltm/monitor/#{monitor}"].get{|response, request, result| response }
      end
    end
 
    def make_health_monitor payload=None, parent=None
      if parent
        result = @bigip["ltm/monitor/#{parent}"].post payload.to_json
      else
        result = @bigip["ltm/monitor"].post payload.to_json
      end
    end
 
 
    # create/delete methods
    def make_pool members, pool_name=None, monitor_name=None
        # convert member format
        members.collect { |member| { :kind => 'ltm:pool:members', :name => member} }
 
        payload = {
            :kind => 'tm:ltm:pool:poolstate',
            :name => pool_name,
            :description => "Auto-configured by Chef on #{Time.now.getutc}",
            :loadBalancingMode => 'least-connections-member',
            :monitor => monitor_name,
            :members => members
        }
        
       result = @bigip['ltm/pool'].post payload.to_json      
    end
    
    def get_pool_membership pool_name=None, member_name=None
      result = JSON.parse(@bigip["ltm/pool/#{pool_name}/members/"].get)
      result.each do |k, v|
         if k['items']
           v.any? { |hash| hash['name'].include?(member_name) }
         end
      end
    end
      
              
    def add_node2pool member_name=None, pool_name=None
       payload = { :name => member_name }
       result = @bigip["ltm/pool/#{pool_name}/members"].post payload.to_json
     end        
  
#End class  
end
