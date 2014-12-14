#!/usr/bin/env ruby
# Author: dfosborne2
# Sources/inspiration belonging to devcentral
# https://devcentral.f5.com/wiki/iControlREST.Ruby-Virtual-Server-and-Pool-Creation.ashx

## Known to work with at least BigIP LTM 11.5.1 ##

# Just a collection of methods to provision a BigIP. 
# More will be added along the way for futher provisioning as well as to
# monitor/administer. Please feel free to fork and add more/make better.

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
    def check_node(name)
      result = @bigip["ltm/node/#{name}"].get{|response, request, result| response }
    end
    #
    # Make a node
    def make_node(name, address)
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
 
    # Check a healthmonitor. In each case a parent is typically supplied even for the
    # case of builtins like 'http'. So args would be: (monitor='http, parent='http')
    # Added conditional in the case that parent is not needed
    def check_health_monitor(monitor=None, parent=None)
      if parent
        result = @bigip["ltm/monitor/#{parent}/#{monitor}"].get{|response, request, result| response }
    
      else
        result = @bigip["ltm/monitor/#{monitor}"].get{|response, request, result| response }
      end
    end
 
    # You need to supply the health monitor payload. Hint: You can create the
    # healthmonitor you wish by hand and then list it out with the check_health_monitor 
    # method above. You could check a builtin like http. See comments for the create
    # method above
    def create_health_monitor(payload=None, parent=None)
      if parent
        result = @bigip["ltm/monitor/#{parent}"].post payload.to_json
      else
        result = @bigip["ltm/monitor"].post payload.to_json
      end
    end
 
    # Create a pool. lbmethod is one of the builtins on your given BigIP version
    def create_pool(members, pool_name=None, monitor_name=None, lbmethod=None)
        # convert member format
        members.collect { |member| { :kind => 'ltm:pool:members', :name => member} }
 
        payload = {
            :kind => 'tm:ltm:pool:poolstate',
            :name => pool_name,
            :description => "Auto-configured on #{Time.now.getutc}",
            :loadBalancingMode => lbmethod,
            :monitor => monitor_name,
            :members => members
        }
        
       result = @bigip['ltm/pool'].post payload.to_json      
    end

    # Does a node (not a pool member) belong to a given pool?
    # Assumes that pool_name supplied actually exists, otherwise
    # rest-client exception handling takes over and should raise a 
    # 404 error
    
    def node_is_member?(pool_name=None, member_name=None)
      result = JSON.parse(@bigip["ltm/pool/#{pool_name}/members/"].get)
      result.each do |k, v|
         if k['items']
             return v.any? { |hash| hash['name'].include?(member_name) }
         end
      end
    end
      
              
    def add_node2pool member_name=None, pool_name=None
       payload = { :name => member_name }
       result = @bigip["ltm/pool/#{pool_name}/members"].post payload.to_json
     end        
  
#End class  
end
