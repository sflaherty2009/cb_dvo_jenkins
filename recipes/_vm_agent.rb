#
# Cookbook Name:: cb_dvo_jenkins
# Recipe:: _vm_agent
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

# Recipe used for automatically deploying azure agents on server utilization
# underscore placed in front of recipe name because it should not be run standalone.

# Add credentials for use with accessing azure vms
jenkins_password_credentials 'jenkins_azure' do
  id          'jenkins_azure'
  description 'access to jenkin agent boxes'
  password    node['agent_password']
end

# Set the number of executors on the master server to zero, run jobs off agents
jenkins_script 'master_executors' do
  command <<-GROOVY.gsub(/^ {4}/, '')
    import jenkins.model.*

    def instance = Jenkins.getInstance()
    instance.setNumExecutors(0)
    instance.save()
  GROOVY
end

# Add credentials for use with spinning up azure vms
jenkins_script 'az_creds' do
  command <<-GROOVY.gsub(/^ {4}/, '')
    import com.cloudbees.plugins.credentials.*
    import com.cloudbees.plugins.credentials.common.*
    import com.cloudbees.plugins.credentials.domains.*
    import com.cloudbees.plugins.credentials.impl.*
    import jenkins.model.*
    import hudson.security.*
    import hudson.plugins.active_directory.*
    import org.jenkinsci.plugins.*
    import com.microsoft.azure.util.AzureCredentials

    def azureCredential = new AzureCredentials(
      CredentialsScope.GLOBAL,
      '#{node['credentialId']}',
      'Azure Service Principal',
      '#{node['subscriptionId']}',
      '#{node['aadClientId']}',
      '#{node['aadClientSecret']}',
      'https://login.microsoftonline.com/#{node['tenantId']}/oauth2',
      '',
      '',
      '',
      ''
    )
    SystemCredentialsProvider.getInstance().getStore().addCredentials(Domain.global(), azureCredential)
  GROOVY
end

# Run groovy script to setup vm_agent configuration of jenkins slaves.
jenkins_script 'vm_agent_linux' do
  command <<-GROOVY.gsub(/^ {4}/, '')
    import com.microsoft.azure.vmagent.builders.*
    import jenkins.model.*

    def myCloud = new AzureVMCloudBuilder()
        .withCloudName("myAzure")
        .withAzureCredentialsId("#{node['credentialId']}")
        .withNewResourceGroupName("azl_jenkins_agent")
        .addNewTemplate()
            .withName("ubuntu")
            .withLabels("ubuntu")
            .withLocation("East US")
            .withVirtualMachineSize("Standard_DS2_v2")
            .addNewBuiltInImage()
                .withBuiltInImageName("Ubuntu 16.14 LTS")
                .withInstallGit(true)
                .withInstallMaven(true)
                .withInstallDocker(true)
            .endBuiltInImage()
            .withAdminCredential("jenkins_azure")
        .endTemplate()
        .build();
    Jenkins.getInstance().clouds.add(myCloud);
    GROOVY
end
