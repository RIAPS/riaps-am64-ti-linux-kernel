pipeline {
  agent any
  environment {
    // Define an env variable for the directory where artifacts will be copied to on the host
    HOST_OUTPUT_DIR = "${WORKSPACE}/build"
  }
  options {
    buildDiscarder logRotator(daysToKeepStr: '60', numToKeepStr: '30')
  }
  stages {
    stage('Prepare Environment') {
      steps {
        // Pull the required Docker images
        sh 'docker pull multiarch/qemu-user-static'
        sh 'docker pull ghcr.io/texasinstruments/debian-arm64:latest'
      }
    }
    stage('Set Up QEMU Emulation') {
      steps {
        // Set up QEMU user-mode emulation
        sh 'docker run --rm --privileged multiarch/qemu-user-static --reset -p yes'
      }
    }
    stage('Run ARM64 Container') {
      steps {
        script {
          // Start ARM64 Debian container
          def arm64Container = sh(script: 'docker run --rm -id ghcr.io/texasinstruments/debian-arm64:latest', returnStdout: true).trim()

          // Clone the git repository into the container and navigate to the directory
          sh "docker exec ${arm64Container} bash -c 'git clone https://github.com/RIAPS/riaps-am64-ti-linux-kernel.git /tmp/riaps-am64-ti-linux-kernel'"
          sh "docker exec ${arm64Container} bash -c 'cd /tmp/riaps-am64-ti-linux-kernel && ./run.sh ti-linux-kernel-rt'"

          // Prepare the output directory on the host
          sh "mkdir -p ${HOST_OUTPUT_DIR}"

          // Source debian_version.sh to get the DEBIAN_SUITE environment variable
          sh "docker exec ${arm64Container} bash -c 'source /tmp/riaps-am64-ti-linux-kernel/debian_version.sh'"
    
          // Use the DEBIAN_SUITE environment variable in the docker cp command
          def debianSuite = sh(script: "docker exec ${arm64Container} bash -c 'echo \$deb_suite'", returnStdout: true).trim()
          sh "docker cp ${arm64Container}:/tmp/riaps-am64-ti-linux-kernel/build/${debianSuite}/ti-linux-kernel-rt/*.deb ${HOST_OUTPUT_DIR}"
          sh "docker cp ${arm64Container}:/tmp/riaps-am64-ti-linux-kernel/build/${debianSuite}/ti-linux-kernel-rt/*.buildinfo ${HOST_OUTPUT_DIR}"
          sh "docker cp ${arm64Container}:/tmp/riaps-am64-ti-linux-kernel/build/${debianSuite}/ti-linux-kernel-rt/*.changes ${HOST_OUTPUT_DIR}"
          sh "docker cp ${arm64Container}:/tmp/riaps-am64-ti-linux-kernel/build/${debianSuite}/ti-linux-kernel-rt/ti-linux-kernel-rt*/arch/arm64/boot/dts/ti/k3-am642-sk.* ${HOST_OUTPUT_DIR}"
        }
      }
    }
  }
  post {
    success {
      // Archive the artifacts after a successful build
      archiveArtifacts artifacts: "${HOST_OUTPUT_DIR}/*", fingerprint: true
    }
    always {
      // Clean up and provide a message that the pipeline has completed
      echo 'The pipeline has completed'
    }
    failure {
      // Provide a message if the pipeline fails
      echo 'The pipeline failed'
    }
  }
}