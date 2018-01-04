#
# Cookbook Name:: cb_dvo_jenkins
# Recipe:: _ad_auth
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

# NOT TESTED !!!
# underscore placed in front of recipe name because it should not be run standalone.

#TO DO Will need to substitute in AD information for proper connection to AD.
# Run groovy script to setup AD authentication for Jenkins server.
jenkins_script 'AD_configuration' do
    command <<-GROOVY.gsub(/^ {4}/, '')
        import jenkins.model.*
        import hudson.security.*
        import hudson.plugins.active_directory.*
        import org.jenkinsci.plugins.*
  
        def instance = Jenkins.getInstance()
        String domain = ''
        String site = ''
        String server = ''
        String bindName = '
        String bindPassword = '
        adrealm = new ActiveDirectorySecurityRealm(domain, site, bindName, bindPassword, server)
        instance.setSecurityRealm(adrealm)
      GROOVY
  end
  