pipeline {
  agent any
  options {
    buildDiscarder logRotator(daysToKeepStr: '30', numToKeepStr: '10')
  }
  stages {
    stage('build') {
      steps {
        sh './run.sh ti-linux-kernel-rt'
      }
    }
  }
  post {
    success {
      archiveArtifacts artifacts: 'build/bookworm/ti-linux-kernel-rt/*.deb, build/bookworm/ti-linux-kernel-rt/*.buildinfo, build/bookworm/ti-linux-kernel-rt/*.changes', fingerprint: true
    }
  }
}