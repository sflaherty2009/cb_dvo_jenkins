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

# allow for port 8080 for accessing jenkins web gui.
firewall_rule 'http/https' do
  protocol :tcp
  port     8080
  command   :allow
end

# open standard ssh port
firewall_rule 'ssh' do
  port     22
  command  :allow
end

firewall 'default' do
  enabled false
  action :nothing
end

#install jenkins with latest package. 
include_recipe 'apt'
# Install java version 8 
include_recipe 'java::default'
# Install jenkins master server
include_recipe 'jenkins::master'

# Jenkins user for running commands once auth is in place (otherwise chef run will fail).
ruby_block 'load_jenkins_credential' do
  block do
    require 'openssl'
    require 'net/ssh'

    key = ::OpenSSL::PKey::RSA.new ::File.read Chef::Config[:client_key]
    node.run_state[:jenkins_private_key] = key.to_pem # ~FC001
    jenkins = resources('jenkins_user[chef]') # ~FC001
    jenkins.public_keys ["#{key.ssh_type} #{[key.to_blob].pack('m0')}"] # ~FC001
  end
end

# create the chef jenkins user so chef cookbook can run once permission has been shut down with LDAP.
jenkins_user 'chef' do
  id "chef@#{Chef::Config[:node_name]}"
  full_name 'Chef'
end

## CREATE DIRECTORY FOR AUDIT LOGGING-------------------------

# this path is needed for use with the audit trail plugin.
%w[ /var/log/audit /var/log/audit/jenkins ].each do |path|
  directory path do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end
end

## JENKINS PLUGINS -------------------------------------------
# Install/update plugins needed
jenkins_plugins = %w(
  azure-commons
  azure-credentials
  azure-vm-agents
  active-directory
  apache-httpcomponents-client-4-api  
  bitbucket
  bouncycastle-api
  branch-api
  cloud-stats
  command-launcher
  credentials-binding
  credentials
  cloudbees-folder
  display-url-api
  ldap
  mailer
  matrix-project
  matrix-auth
  git-client
  git
  jsch
  junit
  linenumbers
  plain-credentials
  slack
  structs
  ssh-credentials
  ssh-slaves
  scm-api
  script-security
  workflow-api
  workflow-scm-step
  workflow-step-api
  mercurial
)

# run to install the plugins
jenkins_plugins.each do |plugin|
  jenkins_plugin plugin do
    notifies :execute, 'jenkins_script[Matrix_Authentication_configuration]', :delayed
    notifies :restart, 'service[jenkins]', :immediately
  end
end

# run twice first to install and then the second time to update the plugins 
jenkins_plugins.each do |plugin|
  jenkins_plugin plugin do
    notifies :execute, 'jenkins_script[Matrix_Authentication_configuration]', :delayed
    notifies :restart, 'service[jenkins]', :immediately
  end
end

#JENKINS CONFIGURATION -----------------------------------------

# Set up security settings for AD configuration.
jenkins_script 'Matrix_Authentication_configuration' do
  command <<-GROOVY.gsub(/^ {4}/, '')
      import jenkins.model.*
      import hudson.security.*
      import hudson.plugins.active_directory.*
      import org.jenkinsci.plugins.*
      
      def strategy = new hudson.security.GlobalMatrixAuthorizationStrategy()

      strategy.add(Jenkins.ADMINISTER, '#{resources('jenkins_user[chef]').id}')
      strategy.add(Jenkins.ADMINISTER, 'anonymous')

      Jenkins.instance.setAuthorizationStrategy(strategy)
    GROOVY
  action :nothing
end
