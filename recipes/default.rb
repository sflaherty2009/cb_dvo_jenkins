#
# Cookbook Name:: cb_dvo_jenkins
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Choose the version of jenkins server we want installed on our instance
node.default['jenkins']['master']['version'] = '2.46.3'

# Call the default server installation.
include_recipe 'cb_dvo_jenkins::server'

# install the vm agent for creating jenkins agent servers.
include_recipe 'cb_dvo_jenkins::_vm_agent'

# TO DO 
# Will need to setup AD with proper information before adding it to default recipe.
# Need to determine the plugins currently being used with our Jenkins implementation
