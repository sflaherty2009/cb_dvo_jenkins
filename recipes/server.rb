#
# Cookbook Name:: dt_jenkins
# Recipe:: install_server
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

## JENKINS INSTALL -------------------------------------------

node.default['jenkins']['master']['jvm_options'] = '-Djenkins.install.runSetupWizard=false -Dorg.jenkinsci.plugins.durabletask.BourneShellScript.HEARTBEAT_CHECK_INTERVAL=300 -Djava.awt.headless=true'
node.default['jenkins']['master']['install_method'] = 'war'
node.default['java']['jdk_version'] = '8'

# install jenkins with latest package.
include_recipe 'apt'
# Install java version 8
include_recipe 'java::default'
# Install jenkins master server
include_recipe 'jenkins::master'
# Install git on machine for use with bitbucket pulls
yum_package %w(git sshpass)

# pull in credentials for use with azure credentialing.
azure_auth = data_bag_item('jenkins', 'credentials')

## ACCOUNTS/SECURITY -------------------------------------------------
# ad_auth recipe needs to go first in order to appropriately set the Jenkins permissions for rest of the runs.
include_recipe 'cb_dvo_jenkins::_ad_auth'

## PLUG-INS -------------------------------------------------

# list of plugins needed for the chef jenkins server.
plugins = {
  'maven-plugin' => '3.1.2',
  'azure-commons' => '0.2.8',
  'ace-editor' => '1.1',
  'ant' => '1.9',
  'authentication-tokens' => '1.3',
  'azure-credentials' => '1.6.0',
  'azure-vm-agents' => '0.7.5',
  'apache-httpcomponents-client-4-api' => '4.5.5-3.0',
  'basic-branch-build-strategies' => '1.1.1',
  'bitbucket' => '1.1.8',
  'bitbucket-pullrequest-builder' => '1.4.28',
  'bouncycastle-api' => '2.17',
  'branch-api' => '2.1.1',
  'blueocean' => '1.9.0',
  'blueocean-rest' => '1.9.0',
  'blueocean-web' => '1.9.0',
  'blueocean-commons' => '1.9.0',
  'blueocean-bitbucket-pipeline' => '1.9.0',
  'blueocean-config' => '1.9.0',
  'blueocean-dashboard' => '1.9.0',
  'blueocean-events' => '1.9.0',
  'blueocean-git-pipeline' => '1.9.0',
  'blueocean-github-pipeline' => '1.9.0',
  'blueocean-i18n' => '1.9.0',
  'blueocean-jira' => '1.9.0',
  'blueocean-jwt' => '1.9.0',
  'blueocean-core-js' => '1.9.0',
  'blueocean-personalization' => '1.9.0',
  'blueocean-pipeline-api-impl' => '1.9.0',
  'blueocean-pipeline-editor' => '1.9.0',
  'pipeline-milestone-step' => '1.3.1',
  'blueocean-autofavorite' => '1.2.2',
  'blueocean-display-url' => '2.2.0',
  'blueocean-rest-impl' => '1.9.0',
  'blueocean-pipeline-scm-api' => '1.9.0',
  'cloudbees-bitbucket-branch-source' => '2.2.15',
  'cloudbees-folder' => '6.7',
  'cloud-stats' => '0.20',
  'command-launcher' => '1.2',
  'credentials-binding' => '1.17',
  'credentials' => '2.1.18',
  'conditional-buildstep' => '1.3.6',
  'display-url-api' => '2.3.0',
  'docker-workflow' => '1.17',
  'docker-commons' => '1.13',
  'durable-task' => '1.28',
  'mailer' => '1.22',
  'matrix-project' => '1.13',
  'matrix-auth' => '2.3',
  'favorite' => '2.3.2',
  'git-client' => '2.7.4',
  'git' => '3.9.1',
  'github' => '1.29.3',
  'github-branch-source' => '2.4.1',
  'github-api' => '1.95',
  'git-server' => '1.7',
  'handy-uri-templates-2-api' => '2.1.6-1.0',
  'htmlpublisher' => '1.17',
  'javadoc' => '1.4',
  'jackson2-api' => '2.9.7.1',
  'jira' => '3.0.5',
  'jsch' => '0.1.54.2',
  'junit' => '1.26.1',
  'jquery-detached' => '1.2.1',
  'jenkins-design-language' => '1.9.0',
  'linenumbers' => '1.2',
  'pipeline-model-definition' => '1.3.3',
  'pipeline-model-extensions' => '1.3.3',
  'pipeline-model-api' => '1.3.3',
  'pipeline-graph-analysis' => '1.9',
  'pipeline-model-declarative-agent' => '1.1.1',
  'pipeline-stage-tags-metadata' => '1.3.3',
  'plain-credentials' => '1.4',
  'pubsub-light' => '1.12',
  'run-condition' => '1.2',
  'slack' => '2.3',
  'structs' => '1.17',
  'ssh-credentials' => '1.14',
  'trilead-api' => '1.0.0',
  'ssh-slaves' => '1.29.1',
  'scm-api' => '2.3.0',
  'script-security' => '1.48',
  'sse-gateway' => '1.16',
  'token-macro' => '2.5',
  'variant' => '1.1',
  'workflow-api' => '2.33',
  'workflow-scm-step' => '2.7',
  'workflow-step-api' => '2.16',
  'workflow-cps' => '2.60',
  'workflow-basic-steps' => '2.12',
  'workflow-durable-task-step' => '2.26',
  'workflow-job' => '2.29',
  'workflow-support' => '2.22',
  'workflow-multibranch' => '2.20',
  'workflow-cps-global-lib' => '2.12',
  'mercurial' => '2.4',
  'parameterized-trigger' => '2.35.2',
  'pipeline-stage-step' => '2.3',
  'pipeline-build-step' => '2.7',
  'pipeline-input-step' => '2.8',
  'versionnumber' => '1.9',
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

# JENKINS CONFIGURATION -----------------------------------------
include_recipe 'cb_dvo_jenkins::_vm_agent'

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

group 'docker' do
  action :modify
  members 'jenkins'
  append true
  notifies :restart, 'service[docker]', :immediately
end

service 'docker' do
  action :nothing
end

directory '/standard/build' do
  recursive true
  owner 'jenkins'
  group 'jenkins'
  mode '0765'
  action :create
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

# CONFIGURE FOR ATTACHMENT TO AZURE
# create file for holding azure credentials
directory '/var/lib/jenkins/.azure' do
  recursive true
  owner 'jenkins'
  group 'jenkins'
  mode '0765'
  action :create
end

# file '/var/run/docker.sock' do
#   mode '0777'
#   action :create
# end

template '/var/lib/jenkins/.azure/credentials' do
  source 'credentials.erb'
  owner 'jenkins'
  group 'jenkins'
  variables(
    prod_sub: azure_auth['production']['subscription'],
    prod_client_id: azure_auth['production']['client_id'],
    prod_client_secret: azure_auth['production']['client_secret'],
    prod_tenant_id: azure_auth['production']['tenant_id'],
    non_prod_sub: azure_auth['non_prod']['subscription'],
    non_prod_client_id: azure_auth['non_prod']['client_id'],
    non_prod_client_secret: azure_auth['non_prod']['client_secret'],
    non_prod_tenant_id: azure_auth['non_prod']['tenant_id']
  )
  mode '0644'
end

# ADD SERVICE ACCOUNTS
# Moved credentials recipe to end of server execution, Jenkins needs to be restarted before credentials are created.
include_recipe 'cb_dvo_jenkins::_credentials'
include_recipe 'cb_dvo_jenkins::_jenkins_jobs'
