#
# Cookbook Name:: cb_dvo_jenkins
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Call the default server installation.
include_recipe 'cb_dvo_jenkins::server'

# install the vm agent for creating jenkins agent servers.
include_recipe 'cb_dvo_jenkins::_vm_agent'

# install the jenkins job builder on the master jenkins server. 
include_recipe 'cb_dvo_jenkins::_jenkins_job_builder'

# TO DO 
# Will need to setup LDAP with proper information before adding it to default recipe.
# secure all passwords in encrypted databags.
# Add authentication to our bitbucket server to Jenkins build.

# DONE 
# Need to determine the plugins currently being used with our Jenkins implementation
# Get job builder added to recipe. 