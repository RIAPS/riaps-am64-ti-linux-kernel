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
        env.DEB_SUITE = sh(script: '. ./debian_version.sh && echo $deb_suite', returnStdout: true).trim()
        echo "Pipeline succeeded with DEBIAN suite: ${env.DEB_SUITE}"
        def artifactsItems = "build/${env.DEB_SUITE}/ti-linux-kernel-rt/*.deb, build/${env.DEB_SUITE}/ti-linux-kernel-rt/*.buildinfo, build/${env.DEB_SUITE}/ti-linux-kernel-rt/*.changes, build/${env.DEB_SUITE}/ti-linux-kernel-rt/ti-linux-kernel-rt*/arch/arm64/boot/dts/ti/k3-am642-sk.*"
        archiveArtifacts artifacts: artifactsItems, fingerprint: true
      }
    }
  }
}