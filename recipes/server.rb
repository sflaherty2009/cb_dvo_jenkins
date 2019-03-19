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

## ACCOUNTS/SECURITY -------------------------------------------------
# ad_auth recipe needs to go first in order to appropriately set the Jenkins permissions for rest of the runs.
include_recipe 'cb_dvo_jenkins::_ad_auth'

## PLUG-INS -------------------------------------------------

# list of plugins needed for the chef jenkins server.
plugins = {
  'azure-commons' => '0.2.8',
  'ace-editor' => '1.1',
  'ant' => '1.9',
  'authentication-tokens' => '1.3',
  'azure-credentials' => '1.6.0',
  'azure-vm-agents' => '0.9.0',
  'apache-httpcomponents-client-4-api' => '4.5.5-3.0',
  'basic-branch-build-strategies' => '1.1.1',
  'bitbucket' => '1.1.8',
  'bitbucket-pullrequest-builder' => '1.4.30',
  'bouncycastle-api' => '2.17',
  'branch-api' => '2.1.2',
  'blueocean' => '1.13.2',
  'blueocean-rest' => '1.13.2',
  'blueocean-web' => '1.13.2',
  'blueocean-commons' => '1.13.2',
  'blueocean-bitbucket-pipeline' => '1.13.2',
  'blueocean-config' => '1.13.2',
  'blueocean-dashboard' => '1.13.2',
  'blueocean-events' => '1.13.2',
  'blueocean-git-pipeline' => '1.13.2',
  'blueocean-github-pipeline' => '1.13.2',
  'blueocean-i18n' => '1.13.2',
  'blueocean-jira' => '1.13.2',
  'blueocean-jwt' => '1.13.2',
  'blueocean-core-js' => '1.13.2',
  'blueocean-personalization' => '1.13.2',
  'blueocean-pipeline-api-impl' => '1.13.2',
  'blueocean-pipeline-editor' => '1.13.2',
  'pipeline-milestone-step' => '1.3.1',
  'blueocean-autofavorite' => '1.2.3',
  'blueocean-display-url' => '2.2.0',
  'blueocean-rest-impl' => '1.13.2',
  'blueocean-pipeline-scm-api' => '1.13.2',
  'cloudbees-bitbucket-branch-source' => '2.4.2',
  'cloudbees-folder' => '6.7',
  'cloud-stats' => '0.21',
  'command-launcher' => '1.3',
  'credentials-binding' => '1.18',
  'credentials' => '2.1.18',
  'conditional-buildstep' => '1.3.6',
  'display-url-api' => '2.3.0',
  'docker-workflow' => '1.17',
  'docker-commons' => '1.13',
  'durable-task' => '1.29',
  'favorite' => '2.3.2',
  'git-client' => '2.7.6',
  'git' => '3.9.3',
  'github' => '1.29.4',
  'github-branch-source' => '2.4.2',
  'github-api' => '1.95',
  'git-server' => '1.7',
  'groovy' => '2.2',
  'handy-uri-templates-2-api' => '2.1.7-1.0',
  'htmlpublisher' => '1.18',
  'javadoc' => '1.5',
  'jackson2-api' => '2.9.8',
  'jira' => '3.0.5',
  'jsch' => '0.1.55',
  'junit' => '1.27',
  'jquery-detached' => '1.2.1',
  'jenkins-design-language' => '1.13.2',
  'jdk-tool' => '1.2',
  'linenumbers' => '1.2',
  'mercurial' => '2.5',
  'mailer' => '1.23',
  'matrix-project' => '1.14',
  'matrix-auth' => '2.3',
  'maven-plugin' => '3.2',
  'pipeline-model-definition' => '1.3.6',
  'pipeline-model-extensions' => '1.3.6',
  'pipeline-model-api' => '1.3.6',
  'pipeline-graph-analysis' => '1.9',
  'pipeline-model-declarative-agent' => '1.1.1',
  'pipeline-stage-tags-metadata' => '1.3.6',
  'parameterized-trigger' => '2.35.2',
  'pipeline-stage-step' => '2.3',
  'pipeline-build-step' => '2.7',
  'pipeline-input-step' => '2.10',
  'plain-credentials' => '1.5',
  'pubsub-light' => '1.12',
  'run-condition' => '1.2',
  'slack' => '2.19',
  'structs' => '1.17',
  'ssh-credentials' => '1.15',
  'trilead-api' => '1.0.1',
  'ssh-slaves' => '1.29.4',
  'scm-api' => '2.3.0',
  'script-security' => '1.55',
  'sse-gateway' => '1.17',
  'token-macro' => '2.7',
  'variant' => '1.2',
  'workflow-api' => '2.33',
  'workflow-scm-step' => '2.7',
  'workflow-step-api' => '2.19',
  'workflow-cps' => '2.64',
  'workflow-basic-steps' => '2.14',
  'workflow-durable-task-step' => '2.29',
  'workflow-job' => '2.32',
  'workflow-support' => '3.2',
  'workflow-multibranch' => '2.21',
  'workflow-cps-global-lib' => '2.13',
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

directory '/standard/build' do
  recursive true
  owner 'jenkins'
  group 'jenkins'
  mode '0765'
  action :create
end

# ADD SERVICE ACCOUNTS
# Moved credentials recipe to end of server execution, Jenkins needs to be restarted before credentials are created.
include_recipe 'cb_dvo_jenkins::_credentials'
include_recipe 'cb_dvo_jenkins::_jenkins_jobs'
