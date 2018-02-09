#
# Cookbook Name:: cb_dvo_jenkins
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Install jq for use with API calls for Statuspage.io (maintenancePage workflow)
package 'epel-release'
package 'jq'

# Call the default server installation.
include_recipe 'cb_dvo_jenkins::server'
include_recipe 'chef-dk'
include_recipe 'poise-python'

# TO DO
# Will need to setup LDAP with proper information before adding it to default recipe.
# !!!! secure all passwords in encrypted databags !!!!
# add awscli
# add chef.pem file
# figure out better way to do user additions

# DONE
# Need to determine the plugins currently being used with our Jenkins implementation
# Get job builder added to recipe.
# add chefdk installation (TEST)
# add parameter plugin (TEST)
# add yum install of jq (TEST)