# Cookbook Name:: cb_dvo_jenkins
# Recipe:: jenkins_job_builder
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

# Jenkins user used for jenkins build jobs
jenkins_password_credentials node['jenkins_job_builder']['username'] do
  id node['jenkins_job_builder']['username']
  password node['jenkins_job_builder']['password']
end

# install python version 2.7 for running jenkins job builder.
python_runtime 'jenkins' do
  version '2'
  options pip_version: true
end

# Will re-install on every converge unless you add a not_if/only_if.
# Install the jenkins-job-builder package through pip
python_package 'jenkins-job-builder'

# set the owner of the jenkins-job folder to the jenkins-job-builder user.
directory '/etc/jenkins_jobs' do
  owner node['jenkins_job_builder']['user']
  group node['jenkins_job_builder']['group']
  mode '0750'
end

# modify the jenkins_job.ini with the jenkins job-builder user and url for our jenkins server.
template '/etc/jenkins_jobs/jenkins_jobs.ini' do
  source 'jenkins_jobs.ini.erb'
  owner node['jenkins_job_builder']['user']
  group node['jenkins_job_builder']['group']
  mode '0640'
  variables(
    username: node['jenkins_job_builder']['username'],
    password: node['jenkins_job_builder']['password'],
    url: node['jenkins_job_builder']['url'],
    external_url: node['jenkins']['server']['url']
  )
end
