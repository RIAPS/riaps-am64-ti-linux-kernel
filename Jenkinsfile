pipeline {
  agent any
  environment {
    // Define an env variable for the directory where artifacts will be copied to on the host
    HOST_OUTPUT_DIR = "${WORKSPACE}/build_artifacts"
  }
  options {
    buildDiscarder logRotator(daysToKeepStr: '60', numToKeepStr: '30')
  }
  stages {
    stage('Prepare Environment') {
      steps {
        // Pull the required Docker images
        sh 'sudo docker pull multiarch/qemu-user-static'
        sh 'sudo docker load -i ~/RIAPS/riaps-ti-debian-arm64-bookworm-docker.tar'
        // Original docker pulled to create the above tar file
        // Added the RIAPS/riaps-am64-ti-linux-kernel and ti kernel repos to image
        // Note:  The ti kernel repo took over 9 hours to clone
        //sh 'sudo docker pull ghcr.io/texasinstruments/debian-arm64:latest'
      }
    }
    stage('Set Up QEMU Emulation') {
      steps {
        // Set up QEMU user-mode emulation
        sh 'sudo docker run --rm --privileged multiarch/qemu-user-static --reset -p yes'
      }
    }
    stage('Build TI ARM64 Kernel') {
      steps {
        script {
          // Start ARM64 Debian container
          env.RIAPS_ARM64_CONTAINER_ID = sh(script: 'sudo docker run --rm -id riaps/ghcr.io/texasinstruments/debian-arm64:bookworm', returnStdout: true).trim()

          // Update RIAPS repo for run ('run.sh' will update the ti kernel for the version desired)
          sh "sudo docker exec ${env.RIAPS_ARM64_CONTAINER_ID} bash -c 'cd /home/riaps/riaps-am64-ti-linux-kernel && git pull'"

          // Grab the Debian codename, release version and kernel version from the "debian_version.sh"
          def debianSuite = sh(script: "sudo docker exec ${env.RIAPS_ARM64_CONTAINER_ID} /bin/bash -c 'source /home/riaps/riaps-am64-ti-linux-kernel/debian_version.sh && echo \$deb_suite'", returnStdout: true).trim()
          echo "Debian Codename: ${debianSuite}"
          def relVersion = sh(script: "sudo docker exec ${env.RIAPS_ARM64_CONTAINER_ID} /bin/bash -c 'source /home/riaps/riaps-am64-ti-linux-kernel/debian_version.sh && echo \$rel_version'", returnStdout: true).trim()
          echo "Release Version: ${relVersion}"
          def kernelVersion = sh(script: "sudo docker exec ${env.RIAPS_ARM64_CONTAINER_ID} /bin/bash -c 'source /home/riaps/riaps-am64-ti-linux-kernel/debian_version.sh && echo \$kernel_version'", returnStdout: true).trim()
          echo "Kernel Version: ${kernelVersion}"

          // Create kernel image debian packages and build the device tree files
          sh "sudo docker exec ${env.RIAPS_ARM64_CONTAINER_ID} bash -c 'cd /home/riaps/riaps-am64-ti-linux-kernel && ./run.sh ti-linux-kernel-rt'"

          // Prepare the output directory on the host
          sh "mkdir -p ${HOST_OUTPUT_DIR}"

          // Use the DEBIAN_SUITE environment variable in the docker cp command
          sh "sudo docker cp ${env.RIAPS_ARM64_CONTAINER_ID}:/home/riaps/riaps-am64-ti-linux-kernel/build/${debianSuite}/ti-linux-kernel-rt/linux-headers-${kernelVersion}_${relVersion}_arm64.deb ${HOST_OUTPUT_DIR}"
          sh "sudo docker cp ${env.RIAPS_ARM64_CONTAINER_ID}:/home/riaps/riaps-am64-ti-linux-kernel/build/${debianSuite}/ti-linux-kernel-rt/linux-image-${kernelVersion}-dbg_${relVersion}_arm64.deb ${HOST_OUTPUT_DIR}"
          sh "sudo docker cp ${env.RIAPS_ARM64_CONTAINER_ID}:/home/riaps/riaps-am64-ti-linux-kernel/build/${debianSuite}/ti-linux-kernel-rt/linux-image-${kernelVersion}_${relVersion}_arm64.deb ${HOST_OUTPUT_DIR}"
          sh "sudo docker cp ${env.RIAPS_ARM64_CONTAINER_ID}:/home/riaps/riaps-am64-ti-linux-kernel/build/${debianSuite}/ti-linux-kernel-rt/linux-libc-dev_${relVersion}_arm64.deb ${HOST_OUTPUT_DIR}"
          sh "sudo docker cp ${env.RIAPS_ARM64_CONTAINER_ID}:/home/riaps/riaps-am64-ti-linux-kernel/build/${debianSuite}/ti-linux-kernel-rt/ti-linux-kernel-rt_${relVersion}_arm64.buildinfo ${HOST_OUTPUT_DIR}"
          sh "sudo docker cp ${env.RIAPS_ARM64_CONTAINER_ID}:/home/riaps/riaps-am64-ti-linux-kernel/build/${debianSuite}/ti-linux-kernel-rt/ti-linux-kernel-rt_${relVersion}_arm64.changes ${HOST_OUTPUT_DIR}"
          sh "sudo docker cp ${env.RIAPS_ARM64_CONTAINER_ID}:/home/riaps/riaps-am64-ti-linux-kernel/build/${debianSuite}/ti-linux-kernel-rt/ti-linux-kernel-rt_${relVersion}/arch/arm64/boot/dts/ti/k3-am642-sk.dts ${HOST_OUTPUT_DIR}"
          sh "sudo docker cp ${env.RIAPS_ARM64_CONTAINER_ID}:/home/riaps/riaps-am64-ti-linux-kernel/build/${debianSuite}/ti-linux-kernel-rt/ti-linux-kernel-rt_${relVersion}/arch/arm64/boot/dts/ti/k3-am642-sk.dtb ${HOST_OUTPUT_DIR}"
          sh "sudo chown -R jenkins:jenkins ${HOST_OUTPUT_DIR}"
        }
      }
    }
  }
  post {
    success {
      archiveArtifacts artifacts: "build_artifacts/*", fingerprint: true
    }
    always {
      script {
        // Stop docker used to build artifacts
        if (env.RIAPS_ARM64_CONTAINER_ID) {
          sh "sudo docker stop ${env.RIAPS_ARM64_CONTAINER_ID}"
          echo 'Docker container stopped: riaps/ghcr.io/texasinstruments/debian-arm64'
        }
      }
      echo 'The pipeline has completed'
    }
    failure {
      echo 'The pipeline failed'
    }
  }
}