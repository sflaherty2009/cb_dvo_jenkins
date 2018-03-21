node{
    stage ("Repo Pull"){
        if (fileExists("/data/cookbooks/${env.JOB_NAME}")) {
            sh "cd /data/cookbooks/${env.JOB_NAME}; git pull"
            if (fileExists("/data/cookbooks/${env.JOB_NAME}/Berksfile.lock")){
                sh """
                    source /etc/profile
                    cd /data/cookbooks/${env.JOB_NAME}
                    berks update
                """
            }
            else{
                sh "mkdir -p mkdir /data/cookbooks/${env.JOB_NAME}/.berkshelf"
                sh "echo '{\"ssl\": {\"verify\": false}}' > /data/cookbooks/${env.JOB_NAME}/.berkshelf/config.json; echo -e \"source :chef_server\nsource 'https://supermarket.chef.io'\n\nmetadata\" > /data/cookbooks/${env.JOB_NAME}/Berksfile"
                sh """
                    cd /data/cookbooks/${env.JOB_NAME}
                    berks install
                """
            }
        } else {
            sh "git clone https://TrekDevOps:WQrULM66cGyPyB@bitbucket.org/trekbikes/${env.JOB_NAME}.git /data/cookbooks/${env.JOB_NAME}"
            sh "mkdir -p mkdir /data/cookbooks/${env.JOB_NAME}/.berkshelf"
            sh "echo '{\"ssl\": {\"verify\": false}}' > /data/cookbooks/${env.JOB_NAME}/.berkshelf/config.json; echo -e \"source :chef_server\nsource 'https://supermarket.chef.io'\n\nmetadata\" > /data/cookbooks/${env.JOB_NAME}/Berksfile"
            sh """
                cd /data/cookbooks/${env.JOB_NAME}
                berks install
            """
        }
    }
    stage("lint testing"){
        sh "foodcritic /data/cookbooks/${env.JOB_NAME} --epic-fail any"
    }
    stage("syntax testing"){
        sh "rubocop /data/cookbooks/${env.JOB_NAME}"
    }
    stage("testing cookbook"){
        sh "cd /data/cookbooks/${env.JOB_NAME}; kitchen test"
    }
    stage("push to chef server"){
       sh """
        source /etc/profile
        cd /data/cookbooks/${env.JOB_NAME}
        berks upload
       """
    }
}

// TO DO 
// Add Kitchen.yml replacement for cookbook when it is run. 
// Figure out a way to do restart with test-kitchen. 