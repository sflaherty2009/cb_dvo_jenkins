#
# Cookbook Name:: cb_dvo_jenkins
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Call the default server installation.
include_recipe 'cb_dvo_jenkins::server'

# TO DO
# Will need to setup LDAP with proper information before adding it to default recipe.
# !!!! secure all passwords in encrypted databags !!!!
# Add authentication to our bitbucket server to Jenkins build.
# Figure out a way around the access to the Jenkins server CLI access.

# DONE
# Need to determine the plugins currently being used with our Jenkins implementation
# Get job builder added to recipe.
