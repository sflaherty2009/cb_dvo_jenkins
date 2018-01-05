# Choose the version of jenkins server we want installed on our instance
default['jenkins']['master']['version'] = '2.46.3'

# azure cli account.
default['credentialId'] = '1a1acf95-2753-406a-a048-706bbcc1300a'
default['subscriptionId'] = '9db13c96-62ad-4945-9579-74aeed296e48'
default['aadClientId'] = 'e9ddafc7-0849-465e-8eb6-ad3e1e7d0777'
default['aadClientSecret'] = '/TwccqeAqW4VUXmZwP3lwiLjokslMW18434HX/BFpzU='
default['tenantId'] = '9dcd6c72-99eb-423d-b4d9-794d81eef415'

# jenkins agent credentials
default['agent_password'] = 'ThisIsAPassword#1'

# Jenkins Job Builder
default['jenkins_job_builder']['user'] = 'nobody'
default['jenkins_job_builder']['group'] = value_for_platform_family(
  ['debian'] => "nogroup",
  ['rhel','fedora','suse'] => "nobody"
)
# Username and password for a user with admin permissions
default['jenkins_job_builder']['username'] = 'srv_jenkins_build'
default['jenkins_job_builder']['password'] = ['vbMD2m6bQCkUol9HRHBmmuY7']
# not sure if I have this variable right or not.
default['jenkins_job_builder']['url'] = 'http://localhost:8080'
# external url for the jenkins server. 
default['jenkins']['server']['url'] = 'http://192.168.56.14:8080'

