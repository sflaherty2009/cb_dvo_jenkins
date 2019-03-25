name 'cb_dvo_jenkins'
maintainer 'Trek DevOps'
maintainer_email 'devops@trekbikes.com'
license 'all_rights'
description 'Installs/Configures jenkins resources with a focus on DVO Chef Pipeline needs.'
long_description 'See README.md'
version '0.2.66'
chef_version '>= 12.1' if respond_to?(:chef_version)
supports 'centos'

source_url 'https://bitbucket.org/trekbikes/cb_dvo_jenkins'
issues_url 'https://bitbucket.org/trekbikes/cb_dvo_jeknins/issues?status=new&status=open'

depends 'apt', '~> 6.1.4'
depends 'jenkins', '~> 6.2.1'
depends 'java', '~> 1.50.0'
