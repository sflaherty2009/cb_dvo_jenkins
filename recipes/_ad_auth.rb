#
# Cookbook Name:: cb_dvo_jenkins
# Recipe:: _ad_auth.rb
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

#------------------------------------------------------------
require 'openssl'
require 'net/ssh'

# Install active directory plugin for use with authentication. 
plugins = {
  'active-directory' => '2.8',
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

# pull down data bag item used for creation of public/private key to allow chef user to bypass auth.
jenkins_keys = data_bag_item('jenkins', 'keys')

key = OpenSSL::PKey::RSA.new(jenkins_keys['private_key'])
private_key = key.to_pem
public_key = "#{key.ssh_type} #{[key.to_blob].pack('m0')}"

# If security was enabled in a previous chef run then set the private key in the run_state
# now as required by the Jenkins cookbook
ruby_block 'set jenkins private key' do
  block do
    node.run_state[:jenkins_private_key] = private_key
  end
  only_if { node.attribute?('security_enabled') }
end

# Add the admin user only if it has not been added already then notify the resource
# to configure the permissions for the admin user
jenkins_user 'admin' do
  public_keys [public_key]
  not_if { node.attribute?('security_enabled') }
  notifies :execute, 'jenkins_script[configure permissions]', :immediately
end

# Configure the permissions so that login is required and the admin user is an administrator
# after this point the private key will be required to execute jenkins scripts (including querying
# if users exist) so we notify the `set the security_enabled flag` resource to set this up.
# Also note that since Jenkins 1.556 the private key cannot be used until after the admin user
# has been added to the security realm
jenkins_script 'configure permissions' do
  command <<-EOH.gsub(/^ {4}/, '')
    import jenkins.model.*
    import hudson.security.*
    import hudson.plugins.active_directory.*
    import org.jenkinsci.plugins.*

    def instance = Jenkins.getInstance()
    String domain = 'trek.web'
    String site = ''
    String server = '10.14.1.4:3268'
    String bindName = 'domainjoiner@trek.web'
    String bindPassword = 'join1tN0w'
    adrealm = new ActiveDirectorySecurityRealm(domain, site, bindName, bindPassword, server)

    def strategy = new hudson.security.FullControlOnceLoggedInAuthorizationStrategy()
    strategy.setAllowAnonymousRead(false)
    instance.setAuthorizationStrategy(strategy)
    instance.setSecurityRealm(adrealm)
  EOH
  notifies :create, 'ruby_block[set the security_enabled flag]', :immediately
  action :nothing
end

# Set the security enabled flag and set the run_state to use the configured private key
ruby_block 'set the security_enabled flag' do
  block do
    node.run_state[:jenkins_private_key] = private_key
    node.set['security_enabled'] = true
    node.save
  end
  action :nothing
end
