#
# Cookbook Name:: cb_dvo_jenkins
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Call the default server installation.
include_recipe 'cb_dvo_jenkins::server'
include_recipe 'chef-dk'
include_recipe 'poise-python'

# TO DO
# add awscli
# refactor user additions (secure passwords in encrypted databags)
# cleanup attributes/default
# Move azure credentials to encrypted databag
# add yum install of jq

# DONE
# Need to determine the plugins currently being used with our Jenkins implementation
# Get job builder added to recipe.
# add chefdk installation (TEST)
# add parameter plugin (TEST)

# FUTURE
# Add back in Azure Agent plugin and Jenkins Slave instances.
