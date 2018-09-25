name 'cb_dvo_jenkins'
maintainer 'Trek DevOps'
maintainer_email 'devops@trekbikes.com'
license 'all_rights'
description 'Installs/Configures jenkins resources with a focus on DVO Chef Pipeline needs.'
long_description 'See README.md'
version '0.2.8'
chef_version '>= 12.1' if respond_to?(:chef_version)
supports 'centos'

source_url 'https://bitbucket.org/trekbikes/cb_dvo_jenkins'
issues_url 'https://bitbucket.org/trekbikes/cb_dvo_jeknins/issues?status=new&status=open'

depends 'apt', '~> 6.1.4'
depends 'jenkins', '~> 6.0.0'
depends 'java', '~> 1.50.0'
depends 'firewall', '~> 2.6.2'
depends 'poise-python', '~> 1.6.0'
depends 'chef-dk', '~> 3.1.0'
depends 'azurecli', '~> 0.1.2'
depends 'cb_dvo_docker'
depends 'cb_dvo_addStorage'
