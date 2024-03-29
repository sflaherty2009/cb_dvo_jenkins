# DEFAULT
# Choose the version of jenkins server we want installed on our instance
default['jenkins']['master']['version'] = '2.107.3'
# external url for the jenkins server.
default['jenkins']['server']['url'] = 'http://jenkins-test:8080'
# update port to run on 80 as opposed to 8080
default['jenkins']['master']['host'] = 'localhost'
default['jenkins']['master']['port'] = '8080'
default['jenkins']['master']['endpoint'] = "http://#{node['jenkins']['master']['host']}:#{node['jenkins']['master']['port']}"
# update timeout to 480 seconds
default['jenkins']['executor']['timeout'] = 480
