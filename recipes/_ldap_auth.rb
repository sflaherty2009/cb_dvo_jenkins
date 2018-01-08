#
# Cookbook Name:: cb_dvo_jenkins
# Recipe:: _ad_auth
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

# NOT TESTED !!!
# underscore placed in front of recipe name because it should not be run standalone.

# TO DO Will need to substitute in AD information for proper connection to AD.
# Run groovy script to setup AD authentication for Jenkins server.
jenkins_script 'AD_configuration' do
  command <<-GROOVY.gsub(/^ {4}/, '')
    import jenkins.model.*
    import hudson.security.*
    import org.jenkinsci.plugins.*

    String server = 'ldap://1.2.3.4'
    String rootDN = 'dc=foo,dc=com'
    String userSearchBase = 'cn=users,cn=accounts'
    String userSearch = ''
    String groupSearchBase = ''
    String managerDN = 'uid=serviceaccount,cn=users,cn=accounts,dc=foo,dc=com'
    String managerPassword = 'password'
    boolean inhibitInferRootDN = false

    SecurityRealm ldap_realm = new LDAPSecurityRealm(server, rootDN, userSearchBase, userSearch, groupSearchBase, managerDN, managerPassword, inhibitInferRootDN)
    Jenkins.instance.setSecurityRealm(ldap_realm)
    Jenkins.instance.save()
  GROOVY
end
