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
      script {
        env.DEBSUITE = sh(script: '. ./debian_version.sh && echo $DEBSUITE', returnStdout: true).trim()
        echo "Pipeline succeeded with DEBIAN suite: ${env.DEBSUITE}"
      }
      archiveArtifacts artifacts: 'build/${env.DEBSUITE}/ti-linux-kernel-rt/*.deb, build/${env.DEBSUITE}/ti-linux-kernel-rt/*.buildinfo, build/${env.DEBSUITE}/ti-linux-kernel-rt/*.changes, build/${env.DEBSUITE}/ti-linux-kernel-rt/ti-linux-kernel-rt*/arch/arm64/boot/dts/ti/k3-am642-sk.*, build/${env.DEBSUITE}/ti-linux-kernel-rt/ti-linux-kernel-rt*/arch/arm64/boot/dts/ti/k3-am642-evm.*', fingerprint: true
    }
  }
}