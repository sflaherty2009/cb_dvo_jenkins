name 'cb_dvo_jenkins'
maintainer 'Ray Crawford'
maintainer_email 'ray_crawford@trekbikes.com'
license 'all_rights'
description 'Installs/Configures jenkins resources with a focus on DVO Chef Pipeline needs.'
long_description 'See README.md'
version '0.1.8'
chef_version '>= 12.1' if respond_to?(:chef_version)
supports 'centos'

source_url 'https://bitbucket.org/trekbikes/cb_dvo_jenkins'
issues_url 'https://bitbucket.org/trekbikes/cb_dvo_jeknins/issues?status=new&status=open'

depends 'apt', '~> 6.1.4'
depends 'jenkins', '~> 5.0.5'
depends 'java', '~> 1.50.0'
depends 'firewall', '~> 2.6.2'
depends 'poise-python', '~> 1.6.0'