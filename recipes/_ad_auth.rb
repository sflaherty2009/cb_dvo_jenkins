#
# Cookbook Name:: cb_dvo_jenkins
# Recipe:: _ad_auth.rb
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

# WILL NEED TO TEST THIS AND VERIFY IT WORKS APPROPRIATLEY.
# node.run_state[:jenkins_username] = 'chef'
# node.run_state[:jenkins_password] = 'Tr#kB1k3s'

# Once active-directory plugin has been installed setup AD with the neccessary components for attaching to the domain. (domain name, AD server IP and port, admin account and password)
jenkins_script 'AD_configuration' do
  command <<-GROOVY.gsub(/^ {4}/, '')
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
    instance.setSecurityRealm(adrealm)
  GROOVY
end
