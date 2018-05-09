# Choose the version of jenkins server we want installed on our instance
default['jenkins']['master']['version'] = '2.107.3'
# external url for the jenkins server.
default['jenkins']['server']['url'] = 'http://jenkins-test:8080'

# _VM_AGENT
# jenkins agent credentials
default['agent_password'] = 'ThisIsAPassword#1'

# _JENKINS_JOB_BUILDER
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
