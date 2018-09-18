#
# Cookbook Name:: cb_dvo_jenkins
# Recipe:: _vm_agent
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

# Recipe used for automatically deploying azure agents on server utilization
# underscore placed in front of recipe name because it should not be run standalone.

jenkins_password_credentials 'jenkinsAdmin' do
  id          'jenkinsAdmin'
  description 'creds for use by jenkins agents'
  password    'TrekDevOpzR0ckz!'
  notifies :execute, 'jenkins_script[master_executors]', :immediately
end

azure_auth = data_bag_item('jenkins', 'credentials')

# Set the number of executors on the master server to zero, run jobs off agents
jenkins_script 'master_executors' do
  command <<-GROOVY.gsub(/^ {4}/, '')
    import jenkins.model.*

    def instance = Jenkins.getInstance()
    instance.setNumExecutors(0)
    instance.save()
  GROOVY
  notifies :execute, 'jenkins_script[az_creds]', :immediately
  action :nothing
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
      'azureCreds',
      'Azure Service Principal',
      '#{azure_auth['production']['subscription']}',
      '#{azure_auth['production']['client_id']}',
      '#{azure_auth['production']['client_secret']}',
      'https://login.microsoftonline.com/#{azure_auth['production']['tenant_id']}/oauth2',
      '',
      '',
      '',
      ''
    )
    SystemCredentialsProvider.getInstance().getStore().addCredentials(Domain.global(), azureCredential)
  GROOVY
  notifies :execute, 'jenkins_script[vm_agent_linux]', :immediately
  action :nothing
end

# Run groovy script to setup vm_agent configuration of jenkins slaves.
jenkins_script 'vm_agent_linux' do
  command <<-GROOVY.gsub(/^ {4}/, '')
  import com.microsoft.azure.vmagent.builders.*
  import com.cloudbees.plugins.credentials.*
  import com.cloudbees.plugins.credentials.common.*
  import com.cloudbees.plugins.credentials.domains.*
  import com.cloudbees.plugins.credentials.impl.*
  import jenkins.model.*
  import hudson.security.*
  import hudson.plugins.active_directory.*
  import org.jenkinsci.plugins.*
  import com.microsoft.azure.util.AzureCredentials

  def myCloud = new AzureVMCloudBuilder()
      .withCloudName("myAzure")
      .withAzureCredentialsId("azureCreds")
      .withNewResourceGroupName("azlJenkinsAgent")
      .addNewTemplate()
          .withName("azljenkinsagent")
          .withLabels("azljenkinsagent")
          .withLocation("East US")
          .withVirtualMachineSize("Standard_DS2_v2")
          .withNewStorageAccount("")
          .addNewBuiltInImage()
              .withBuiltInImageName("Ubuntu 16.04 LTS")
              .withInstallGit(true)
              .withInstallMaven(false)
              .withInstallDocker(true)
          .endBuiltInImage()
          .withAdminCredential("jenkinsAdmin")
      .endTemplate()
      .build();

    Jenkins.getInstance().clouds.add(myCloud);
    GROOVY
  action :nothing
end
