#
# Cookbook Name:: dt_jenkins
# Recipe:: install_server
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

## JENKINS INSTALL -------------------------------------------

node.default['jenkins']['master']['jvm_options'] = '-Djenkins.install.runSetupWizard=false'
node.default['jenkins']['master']['install_method'] = 'war'
# node.default['jenkins']['master']['version'] = '2.46.3'
node.default['java']['jdk_version'] = '8'

## SECURITY --------------------------------------------------

# allow for port 8080 for accessing jenkins web gui.
firewall_rule 'http/https' do
  protocol :tcp
  port 8080
  command :allow
end

# open standard ssh port
firewall_rule 'ssh' do
  port 22
  command :allow
end

firewall 'default' do
  enabled false
  action :nothing
end

# install jenkins with latest package.
include_recipe 'apt'
# Install java version 8
include_recipe 'java::default'
# Install jenkins master server
include_recipe 'jenkins::master'

# pull in private key from data bag contained within the cookbook (test/integration/data_bags/jenkins/keys.jxon)
jenkins_auth = data_bag_item('jenkins', 'keys')

# add requirements to create the public key from the private key
require 'openssl'
require 'net/ssh'

# create our public key on the chef system itself so that no one can access the account or have access to the key.
key = OpenSSL::PKey::RSA.new(jenkins_auth['private_key'])
private_key = key.to_pem
public_key = "#{key.ssh_type} #{[key.to_blob].pack('m0')}"

# Set jenkins private key only if security is not enabled.
ruby_block 'set jenkins private key' do
  block do
    node.run_state[:jenkins_private_key] = private_key # ~FC001
  end
  only_if { node.attribute?('security_enabled') }
end

## PLUG-INS -------------------------------------------------

# list of plugins needed for the chef jenkins server.
plugins = {
  'azure-commons' => '0.2.4',
  'azure-credentials' => '1.4.0',
  'azure-vm-agents' => '0.6.0',
  'active-directory' => '2.6',
  'apache-httpcomponents-client-4-api' => '1.625.3',
  'bitbucket' => '1.1.8',
  'bouncycastle-api' => '2.16.2',
  'branch-api' => '2.0.18',
  'cloud-stats' => '0.16',
  'command-launcher' => '1.2',
  'credentials-binding' => '1.13',
  'credentials' => '2.1.16',
  'cloudbees-folder' => '6.3',
  'display-url-api' => '2.2.0',
  'ldap' => '1.18',
  'mailer' => '1.20',
  'matrix-project' => '1.12',
  'matrix-auth' => '2.2',
  'git-client' => '2.7.0',
  'git' => '3.7.0',
  'jsch' => '0.1.54.1',
  'junit' => '1.23',
  'linenumbers' => '1.2',
  'plain-credentials' => '1.4',
  'slack' => '2.3',
  'structs' => '1.10',
  'ssh-credentials' => '1.13',
  'ssh-slaves' => '1.25',
  'scm-api' => '2.2.6',
  'script-security' => '1.40',
  'workflow-api' => '2.24',
  'workflow-scm-step' => '2.6',
  'workflow-step-api' => '2.14',
  'mercurial' => '2.2'
}

# run each plugin once with the version given to it. Do not run dependencies. Notify restart on the service only if it's the last plugin.
plugins.each_with_index do |(plugin_name, plugin_version), index|
  jenkins_plugin plugin_name do
    version plugin_version
    install_deps false
    action :install
    # only restart on the final plugin
    if index == (plugins.size - 1)
      notifies :restart, 'runit_service[jenkins]', :immediately
    end
  end
end

## ADDITIONAL SERVER CONFIGURATION---------------------------

# configure the vm agent for creating jenkins agent servers.
include_recipe 'cb_dvo_jenkins::_vm_agent'

# install the jenkins job builder on the master jenkins server.
include_recipe 'cb_dvo_jenkins::_jenkins_job_builder'

## ACCOUNTS -------------------------------------------------

# Add the admin user only if it has not been added already then notify the resource
# to configure the permissions for the admin user
jenkins_user 'admin' do
  password    'Tr3kbikes!1'
  public_keys [public_key]
  not_if { node.attribute?('security_enabled') }
  notifies :execute, 'jenkins_script[configure permissions]', :immediately
end

include_recipe 'cb_dvo_jenkins::_users'

# JENKINS CONFIGURATION -----------------------------------------

# Configure the permissions so that login is required and the admin user is an administrator
# after this point the private key will be required to execute jenkins scripts (including querying
# if users exist) so we notify the `set the security_enabled flag` resource to set this up.
# Also note that since Jenkins 1.556 the private key cannot be used until after the admin user
# has been added to the security realm
jenkins_script 'configure permissions' do
  command <<-EOH.gsub(/^ {4}/, '')
    import jenkins.model.*
    import hudson.security.*
    def instance = Jenkins.getInstance()
    def hudsonRealm = new HudsonPrivateSecurityRealm(false)
    instance.setSecurityRealm(hudsonRealm)
    def strategy = new GlobalMatrixAuthorizationStrategy()
    strategy.add(Jenkins.ADMINISTER, "admin")
    strategy.add(Jenkins.ADMINISTER, "rcrawford")
    strategy.add(Jenkins.ADMINISTER, "nlocke")
    strategy.add(Jenkins.ADMINISTER, "deasland")
    strategy.add(Jenkins.ADMINISTER, "sflaherty")
    instance.setAuthorizationStrategy(strategy)
    instance.save()
  EOH
  notifies :create, 'ruby_block[set the security_enabled flag]', :immediately
  action :nothing
end

# Set the security enabled flag and set the run_state to use the configured private key
ruby_block 'set the security_enabled flag' do
  block do
    node.run_state[:jenkins_private_key] = private_key # ~FC001
    node.set['security_enabled'] = true
    node.save
  end
  action :nothing
end

# NOTE Will have to remove AD authentication until groovy can work appropriately to add and remove users/groups or will allow for local user access as well.
## When adding AD authentication method to Jenkins box you loose the ability to use local accounts
# This breaks chef's ability to log back into box.
# AD authentication plugin cannot add permissions to jenkins box for AD users.
# In order to use this plugin manual steps would need to be taken.
# https://issues.jenkins-ci.org/browse/JENKINS-29162
# https://github.com/jenkinsci/active-directory-plugin/blob/master/src/main/java/hudson/plugins/active_directory/ActiveDirectorySecurityRealm.java

# include_recipe 'cb_dvo_jenkins::_ad_auth'
