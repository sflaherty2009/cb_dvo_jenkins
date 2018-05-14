#
# Cookbook Name:: dt_jenkins
# Recipe:: install_server
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

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

## JENKINS INSTALL -------------------------------------------

node.default['jenkins']['master']['jvm_options'] = '-Djenkins.install.runSetupWizard=false'
node.default['jenkins']['master']['install_method'] = 'war'
node.default['java']['jdk_version'] = '8'

# install jenkins with latest package.
include_recipe 'apt'
# Install java version 8
include_recipe 'java::default'
# Install jenkins master server
include_recipe 'jenkins::master'
# Install docker service
docker_installation 'default'
# Install git on machine for use with bitbucket pulls
yum_package 'git'
# Install git on machine for use with bitbucket pulls
yum_package 'sshpass'

# pull in private key from data bag contained within the cookbook (test/integration/data_bags/jenkins/keys.json)
jenkins_auth = data_bag_item('jenkins', 'keys')

# pull in credentials for use with azure credentialing.
azure_auth = data_bag_item('jenkins', 'credentials')

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
  'maven-plugin' => '3.1.2',
  'azure-commons' => '0.2.5',
  'ace-editor' => '1.1',
  'authentication-tokens' => '1.3',
  'azure-credentials' => '1.6.0',
  'azure-vm-agents' => '0.7.0',
  'apache-httpcomponents-client-4-api' => '4.5.5-2.0',
  'bitbucket' => '1.1.8',
  'bouncycastle-api' => '2.16.2',
  'branch-api' => '2.0.20',
  'blueocean' => '1.5.0',
  'blueocean-rest' => '1.5.0',
  'blueocean-web' => '1.5.0',
  'blueocean-commons' => '1.5.0',
  'blueocean-bitbucket-pipeline' => '1.5.0',
  'blueocean-config' => '1.5.0',
  'blueocean-dashboard' => '1.5.0',
  'blueocean-events' => '1.5.0',
  'blueocean-git-pipeline' => '1.5.0',
  'blueocean-github-pipeline' => '1.5.0',
  'blueocean-i18n' => '1.5.0',
  'blueocean-jira' => '1.5.0',
  'blueocean-jwt' => '1.5.0',
  'blueocean-core-js' => '1.5.0',
  'blueocean-personalization' => '1.5.0',
  'blueocean-pipeline-api-impl' => '1.5.0',
  'blueocean-pipeline-editor' => '1.5.0',
  'pipeline-milestone-step' => '1.3.1',
  'blueocean-autofavorite' => '1.2.2',
  'blueocean-display-url' => '2.2.0',
  'blueocean-rest-impl' => '1.5.0',
  'blueocean-pipeline-scm-api' => '1.5.0',
  'cloudbees-bitbucket-branch-source' => '2.2.11',
  'cloudbees-folder' => '6.4',
  'cloud-stats' => '0.18',
  'command-launcher' => '1.2',
  'credentials-binding' => '1.16',
  'credentials' => '2.1.16',
  'conditional-buildstep' => '1.3.6',
  'display-url-api' => '2.2.0',
  'docker-workflow' => '1.15.1',
  'docker-commons' => '1.11',
  'durable-task' => '1.22',
  'mailer' => '1.21',
  'matrix-project' => '1.13',
  'matrix-auth' => '2.2',
  'favorite' => '2.3.1',
  'git-client' => '2.7.1',
  'git' => '3.8.0',
  'github' => '1.29.0',
  'github-branch-source' => '2.3.4',
  'github-api' => '1.90',
  'git-server' => '1.7',
  'handy-uri-templates-2-api' => '2.1.6-1.0',
  'htmlpublisher' => '1.16',
  'javadoc' => '1.4',
  'jackson2-api' => '2.8.11.1',
  'jira' => '2.5.2',
  'jsch' => '0.1.54.2',
  'junit' => '1.24',
  'jquery-detached' => '1.2.1',
  'jenkins-design-language' => '1.5.0',
  'linenumbers' => '1.2',
  'pipeline-model-definition' => '1.2.9',
  'pipeline-model-extensions' => '1.2.9',
  'pipeline-model-api' => '1.2.9',
  'pipeline-graph-analysis' => '1.6',
  'pipeline-model-declarative-agent' => '1.1.1',
  'pipeline-stage-tags-metadata' => '1.2.9',
  'plain-credentials' => '1.4',
  'pubsub-light' => '1.12',
  'run-condition' => '1.0',
  'slack' => '2.3',
  'structs' => '1.14',
  'ssh-credentials' => '1.13',
  'ssh-slaves' => '1.26',
  'scm-api' => '2.2.7',
  'script-security' => '1.44',
  'sse-gateway' => '1.15',
  'token-macro' => '2.5',
  'variant' => '1.1',
  'workflow-api' => '2.27',
  'workflow-scm-step' => '2.6',
  'workflow-step-api' => '2.14',
  'workflow-cps' => '2.53',
  'workflow-basic-steps' => '2.7',
  'workflow-durable-task-step' => '2.19',
  'workflow-job' => '2.21',
  'workflow-support' => '2.18',
  'workflow-multibranch' => '2.18',
  'workflow-cps-global-lib' => '2.9',
  'mercurial' => '2.3',
  'parameterized-trigger' => '2.35.2',
  'pipeline-stage-step' => '2.3',
  'pipeline-build-step' => '2.7',
  'pipeline-input-step' => '2.8',
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

## ACCOUNTS -------------------------------------------------

# Add the admin user only if it has not been added already
jenkins_user 'admin' do
  password    'Tr3kbikes!1'
  public_keys [public_key]
  not_if { node.attribute?('security_enabled') }
  notifies :execute, 'jenkins_script[configure permissions]', :immediately
end

include_recipe 'cb_dvo_jenkins::_users'

# Configure the permissions so that login is required and the admin user is an administrator
# after this point the private key will be required to execute jenkins scripts (including querying
# if users exist) so we notify the `set the security_enabled flag` resource to set this up.
# Also note that since Jenkins 1.556 the private key cannot be used until after the admin user
# has been added to the security realm
# Full control once logged into box. Will need to loop back for granual access if needed in future iterations.
jenkins_script 'configure permissions' do
  command <<-EOH.gsub(/^ {4}/, '')
    import jenkins.model.*
    import hudson.security.*
    def instance = Jenkins.getInstance()
    def hudsonRealm = new HudsonPrivateSecurityRealm(false)
    instance.setSecurityRealm(hudsonRealm)
    def strategy = new hudson.security.FullControlOnceLoggedInAuthorizationStrategy()
    strategy.setAllowAnonymousRead(false)
    instance.setAuthorizationStrategy(strategy)
    instance.save()
  EOH
  notifies :create, 'ruby_block[set the security_enabled flag]', :immediately
  action :nothing
end

# Granular permissions for Jenkins instance. Removed due to speed and need. 
# jenkins_script 'configure permissions' do
#   command <<-EOH.gsub(/^ {4}/, '')
#     import jenkins.model.*
#     import hudson.security.*
#     def instance = Jenkins.getInstance()
#     def hudsonRealm = new HudsonPrivateSecurityRealm(false)
#     instance.setSecurityRealm(hudsonRealm)
#     def strategy = new GlobalMatrixAuthorizationStrategy()
#     strategy.add(Jenkins.ADMINISTER, "admin")
#     strategy.add(Jenkins.ADMINISTER, "nlocke")
#     strategy.add(Jenkins.ADMINISTER, "deasland")
#     strategy.add(Jenkins.ADMINISTER, "sflaherty")
#     strategy.add(Jenkins.ADMINISTER, "tdwight")
#     strategy.add(Jenkins.ADMINISTER, "tuser")
#     instance.setAuthorizationStrategy(strategy)
#     instance.save()
#   EOH
#   # notifies :create, 'ruby_block[set the security_enabled flag]', :immediately
#   action :execute
# end

# JENKINS CONFIGURATION -----------------------------------------

# install azurecli for use with azure infrastructure commands.
include_recipe 'cb_dvo_jenkins::_azure_cli'

# Turns on Cross site request forgery protection.
jenkins_script 'csrf protection' do
  command <<-EOH.gsub(/^ {4}/, '')
    import hudson.security.csrf.DefaultCrumbIssuer
    import jenkins.model.Jenkins
    def instance = Jenkins.instance
    instance.setCrumbIssuer(new DefaultCrumbIssuer(true))
    instance.save()
  EOH
  action :execute
end

jenkins_script 'jenkins protocol hardening' do
  command <<-EOH.gsub(/^ {4}/, '')
    // Harden Jenkins and remove all the nagging warnings in the web interface
    import jenkins.model.Jenkins
    import jenkins.security.s2m.*
    Jenkins jenkins = Jenkins.getInstance()
    // Enable Agent to master security subsystem
    jenkins.injector.getInstance(AdminWhitelistRule.class).setMasterKillSwitch(false);
    // Disable jnlp
    jenkins.setSlaveAgentPort(-1);
    // Disable old Non-Encrypted protocols
    HashSet<String> newProtocols = new HashSet<>(jenkins.getAgentProtocols());
    newProtocols.removeAll(Arrays.asList(
            "JNLP3-connect", "JNLP2-connect", "JNLP-connect", "CLI-connect", "CLI2-connect"
    ));
    jenkins.setAgentProtocols(newProtocols);
    jenkins.save()
  EOH
  action :execute
end

# Set the security enabled flag and set the run_state to use the configured private key
ruby_block 'set the security_enabled flag' do
  block do
    node.run_state[:jenkins_private_key] = private_key # ~FC001
    node.normal['security_enabled'] = true
    node.save
  end
  action :nothing
end

group 'docker' do
  action :modify
  members 'jenkins'
  append true
end

# CONFIGURE FOR KNIFE COMMANDS
# create file for holding knife
directory '/var/lib/jenkins/.chef' do
  recursive true
  owner 'jenkins'
  group 'jenkins'
  mode '0765'
  action :create
end

# Set the knife.rb file for use with chef commands.
template '/var/lib/jenkins/.chef/knife.rb' do
  source 'knife.rb.erb'
  owner 'jenkins'
  group 'jenkins'
  mode '0744'
end

# Create .pem file used by knife configuration.
cookbook_file '/var/lib/jenkins/.chef/dvo_jenkins.pem' do
  source 'dvo_jenkins.pem'
  owner 'jenkins'
  group 'jenkins'
  mode '0644'
end

# CONFIGURE FOR ATTACHMENT TO AZURE
# create file for holding azure credentials
directory '/var/lib/jenkins/.azure' do
  recursive true
  owner 'jenkins'
  group 'jenkins'
  mode '0765'
  action :create
end

template '/var/lib/jenkins/.azure/credentials' do
  source 'credentials.erb'
  owner 'jenkins'
  group 'jenkins'
  variables(
    :prod_sub => azure_auth['production']['subscription'],
    :prod_client_id => azure_auth['production']['client_id'],
    :prod_client_secret => azure_auth['production']['client_secret'],
    :prod_tenant_id => azure_auth['production']['tenant_id'],
    :non_prod_sub => azure_auth['non_prod']['subscription'],
    :non_prod_client_id => azure_auth['non_prod']['client_id'],
    :non_prod_client_secret => azure_auth['non_prod']['client_secret'],
    :non_prod_tenant_id => azure_auth['non_prod']['tenant_id']
  )
  mode '0644'
end

# CONFIGURE NUMBER OF EXECUTORS
# Set the number of executors on the master server to zero, run jobs off agents
jenkins_script 'master_executors' do
  command <<-GROOVY.gsub(/^ {4}/, '')
    import jenkins.model.*
    def instance = Jenkins.getInstance()
    instance.setNumExecutors(4)
    instance.save()
  GROOVY
end
