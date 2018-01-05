#
# Cookbook Name:: cb_dvo_jenkins
# Recipe:: _ad_auth.rb
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

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
        String bindName = ''
        String bindPassword = ''
        adrealm = new ActiveDirectorySecurityRealm(domain, site, bindName, bindPassword, server)
        instance.setSecurityRealm(adrealm)
      GROOVY
  end

#   import jenkins.model.*
#   import hudson.security.*
#   import hudson.plugins.active_directory.*
#   import org.jenkinsci.plugins.*

#   def instance = Jenkins.getInstance()
#   String domain = 'docutap.local'
#   String site = ''
#   String server = 'sfsdwdtapdc001.docutap.local:3268'
#   String bindName = 'sv.ds.jnk.us-e1.dev@docutap.local'
#   String bindPassword = 'aUXJyLBvUi427cxEH4oUPv'
#   adrealm = new ActiveDirectorySecurityRealm(domain, site, bindName, bindPassword, server)
#   instance.setSecurityRealm(adrealm)
  