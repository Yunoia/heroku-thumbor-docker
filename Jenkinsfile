CURRENT_COMMIT_SHA_OUTPUT = "commit.sha"
HEROKU_STAGE_NAME = "protagonist-thumbor-stage/web"
HEROKU_PROD_NAME = "protagonist-thumbor/web"
OUTPUT_LATEST_TAG = "latest.tag"

pipeline {
    agent { node { label 'master' } }
    stages {
        stage('Notify start') {
            steps {
                notifyBuild('STARTED');
            }
        }
        stage('Build and push') {
            steps {
                script {
                    sh 'git pull'
                    def config = getConfing()
                    docker.withRegistry('https://registry.heroku.com', 'docker-credentials-api') {
                        docker.build("${config.appName}:${config.tag}").push(config.tag)
                    }
                }
            }
        }
    }
    post {
        failure {
            notifyBuild('FAILURE')
        }
        success {
            notifyBuild('SUCCESS')
        }
        aborted {
            notifyBuild('ABORTED')
        }
    }
}

def getConfing() {
    switch (env.BRANCH_NAME) {
        case "develop":
            return [
                    tag    : "${getVersion()}-develop-${getCommitSHA()}",
                    appName: HEROKU_STAGE_NAME,
            ]
        case "master":
            return [
                    tag    : "${getVersion()}",
                    appName: HEROKU_PROD_NAME,
            ]
        default:
            return null
    }

}

def getCommitSHA() {
    sh "git rev-parse --short HEAD >> ${CURRENT_COMMIT_SHA_OUTPUT}"
    def sha = readFile("commit.sha")
    sh "rm ${CURRENT_COMMIT_SHA_OUTPUT}"
    return sha.trim();
}

def getVersion() {
    sh "git describe --tags \$(git rev-list --tags --max-count=1) >> ${OUTPUT_LATEST_TAG}"
    def tag = readFile(OUTPUT_LATEST_TAG)
    sh "rm ${OUTPUT_LATEST_TAG}"
    return "v${tag?.trim()}"
}

def notifyBuild(String buildStatus = 'STARTED') {
    // build status of null means successful
    buildStatus = buildStatus ?: 'SUCCESS'

    // Default values
    def colorName = 'RED'
    def colorCode = '#FF0000'
    def subject = "${buildStatus}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
    def summary = "${subject} (${env.BUILD_URL})"

    // Override default values based on build status
    if (buildStatus == 'STARTED') {
        color = 'YELLOW'
        colorCode = '#FFFACD'
    } else if (buildStatus == 'SUCCESS') {
        color = 'GREEN'
        colorCode = '#32CD32'
    } else if (buildStatus == 'ABORTED') {
        color = 'GREY'
        colorCode = '#9f9f9f'
    } else {
        color = 'RED'
        colorCode = '#FF0000'
    }

    echo summary
    slackSend(failOnError: true, color: colorCode, message: summary)
}
