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
# Install some plugins needed, but not installed on jenkins2 by default
jenkins_plugins = %w(
  bitbucket
  active-directory
  audit-trail
  matrix-project
  matrix-auth
  jobConfigHistory
  git-client
  git
  gitlab-plugin
  scm-sync-configuration
  linenumbers
  slack
  credentials
  junit
  mailer
  mercurial
  workflow-step-api
  workflow-scm-step
  plain-credentials
  scm-api
  script-security
  ssh-credentials
  structs
  display-url-api
  antisamy-markup-formatter
  ssh-slaves
  ec2
)

jenkins_plugins.each do |plugin|
  jenkins_plugin plugin do
    notifies :execute, 'jenkins_command[safe-restart]', :delayed
    notifies :execute, 'jenkins_script[Matrix_Authentication_configuration]', :delayed
  end
end

# jenkins command for a safe restart.
jenkins_command 'safe-restart' do
  action :nothing
end

#JENKINS CONFIGURATION -----------------------------------------

# Run Jenkins script to get the list of latest plugins. Only do this daily.
jenkins_script 'get list of latest plugins' do
  command <<-eos.gsub(/^\s+/, '')
    pm = jenkins.model.instance.pluginManager
    pm.doCheckUpdatesServer()
  eos

  not_if do
    update_frequency = 86_400 # daily
    update_file = '/var/lib/jenkins/updates/default.json'
    ::File.exists?(update_file) &&
      ::File.mtime(update_file) > Time.now - update_frequency
  end
end

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

# TODO create variable for active-directory
# TODO create variable for jenkins installation.
# template "/var/lib/jenkins/config.xml" do
#   source 'config.xml.erb'
#   mode '0644'
# end
