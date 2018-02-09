# Choose the version of jenkins server we want installed on our instance
default['jenkins']['master']['version'] = '2.46.3'

# azure cli account.
default['credentialId'] = '1a1acf95-2753-406a-a048-706bbbb1300a'
default['subscriptionId'] = '9fbf7025-df40-4908-b7fb-a3a2144cee91'
default['aadClientId'] = 'e79ed5bc-5413-4eb0-b8ae-5114c9843a6e'
default['aadClientSecret'] = '/TwccqeAqW4VUXmZwP3lwiLjokslMW18434HX/BFpzU='
default['tenantId'] = '9dcd6c72-99eb-423d-b4d9-794d81eef415'

# jenkins agent credentials
default['agent_password'] = 'ThisIsAPassword#1'

# Jenkins Job Builder
default['jenkins_job_builder']['user'] = 'nobody'
default['jenkins_job_builder']['group'] = value_for_platform_family(
  %w(debian) => 'nogroup',
  %w(rhel fedora suse) => 'nobody'
)
# Username and password for a user with admin permissions
default['jenkins_job_builder']['username'] = 'srv_jenkins_build'
default['jenkins_job_builder']['password'] = 'vbMD2m6bQCkUol9HRHBmmuY7'
# not sure if I have this variable right or not.
default['jenkins_job_builder']['url'] = 'http://localhost:8080'
# external url for the jenkins server.
default['jenkins']['server']['url'] = 'http://jenkins-test:8080'

default['azurecli']['azure']['python']['version'] = '2'
default['azurecli']['azure']['python']['provider'] = :system
