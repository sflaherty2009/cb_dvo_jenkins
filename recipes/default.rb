#
# Cookbook Name:: cb_dvo_jenkins
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Call the default server installation.
include_recipe 'cb_dvo_jenkins::server'
include_recipe 'poise-python'

# TO DO
# add yum install of jq

# DONE
# Need to determine the plugins currently being used with our Jenkins implementation
# Get job builder added to recipe.
# add chefdk installation (TEST)
# add parameter plugin (TEST)
# add awscli
# refactor user additions (secure passwords in encrypted databags)
# cleanup attributes/default
# Move azure credentials to encrypted databag

# FUTURE
# Add back in Azure Agent plugin and Jenkins Slave instances.
# Loop back in future and add in granual level access for users.
# NOTE Will have to remove AD authentication until groovy can work appropriately to add and remove users/groups or will allow for local user access as well.
## When adding AD authentication method to Jenkins box you loose the ability to use local accounts
# This breaks chef's ability to log back into box.
# AD authentication plugin cannot add permissions to jenkins box for AD users.
# In order to use this plugin manual steps would need to be taken.
# https://issues.jenkins-ci.org/browse/JENKINS-29162
# https://github.com/jenkinsci/active-directory-plugin/blob/master/src/main/java/hudson/plugins/active_directory/ActiveDirectorySecurityRealm.java
