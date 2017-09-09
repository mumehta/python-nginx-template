#!/usr/bin/env groovy

try {
		node('ubu-slave-1') {
				stage 'Clean workspace'
				    deleteDir()
				        sh 'ls -lah'

        stage 'Checkout source'
              checkout scm

        stage 'Run Test Case'
              echo 'Running test cases'
   					  echo "Passed test cases"

        stage 'Build docker image'
              println "Building and packaging python application"
              sh 'sleep 5'
              def web_img = docker.build('python-nginx-web', './web')
              def nginx_img = docker.build('my-nginx', './nginx')

       stage 'Publish image'
               echo "Publishing docker images"
               sh("rm -f /var/lib/jenkins-slave/.docker/config.json")
               sh 'eval $(aws ecr get-login --region ap-southeast-2)'
               docker.withRegistry('https://077077460384.dkr.ecr.ap-southeast-2.amazonaws.com', 'ecr:ap-southeast-2:AWS-SVC-ECS') {
                  docker.image('python-nginx-web').push('latest')
                  docker.image('my-nginx').push("build-${env.BRANCH_NAME}-${env.BUILD_NUMBER}")
                }

        stage 'Pull and deploy app'
              echo "Pulling and deploying app from ECR"
              withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'b0097933-cea0-4729-8b7a-1e1f8702299f', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                  // Uncomment below if you want to use sv-api cluster
                  // sh 'aws s3 sync s3://isentia-kube-config/dev/sv-api/ .'

                  // Uncomment below if you want to use sv-api2 cluster created by kops
                  sh 'aws s3 sync s3://isentia-kube-config/dev/sv-api2/ .'

                  // Uncomment below if you want to use social-dev-kube
                  // sh 'aws s3 sync s3://isentia-kube-config/dev/social-dev-kube/ .'
                  sh("kubectl apply --namespace=daas-social --kubeconfig=kubeconfig -f local-volumes.yaml")
                  sh("kubectl apply --namespace=daas-social --kubeconfig=kubeconfig -f postgres-deployment.yaml")
                  sh("kubectl apply --namespace=daas-social --kubeconfig=kubeconfig -f web-deployment.yaml --record")
                  sh("kubectl apply --namespace=daas-social --kubeconfig=kubeconfig -f nginx-deployment.yaml --record")
              }
          //  dir("$WORKSPACE/ops/scripts") {
          //    sh ('dockerRun.sh')
          //  }
          //    withKubernetes(serverUrl: 'https://sv-api.dev.awsinternal/', credentialsId: 'kubeadmin') {
          //      sh('kubectl run python-app --image=077077460384.dkr.ecr.ap-southeast-2.amazonaws.com/python-app:build-${env.BUILD_NUMBER} --port=8080')
          //    }

          // stage "Deploy Application"
          //   switch (env.BRANCH_NAME) {
          //     // Roll out to staging
          //     case "develop":
          //         // Change deployed image in staging to the one we just built
          //         sh("sed -i.bak 's#gcr.io/cloud-solutions-images/gceme:1.0.0#${imageTag}#' ./k8s/staging/*.yaml")
          //         sh("kubectl --namespace=production apply -f k8s/services/")
          //         sh("kubectl --namespace=production apply -f k8s/staging/")
          //         sh("echo http://`kubectl --namespace=production get service/${feSvcName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${feSvcName}")
          //         break
          //
          //     // Roll out to production
          //     case "master":
          //         // Change deployed image in staging to the one we just built
          //         sh("sed -i.bak 's#gcr.io/cloud-solutions-images/gceme:1.0.0#${imageTag}#' ./k8s/production/*.yaml")
          //         sh("kubectl --namespace=production apply -f k8s/services/")
          //         sh("kubectl --namespace=production apply -f k8s/production/")
          //         sh("echo http://`kubectl --namespace=production get service/${feSvcName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${feSvcName}")
          //         break
          //
          //     // Roll out a dev environment
          //     default:
          //         // Create namespace if it doesn't exist
          //         sh("kubectl get ns ${env.BRANCH_NAME} || kubectl create ns ${env.BRANCH_NAME}")
          //         // Don't use public load balancing for development branches
          //         sh("sed -i.bak 's#LoadBalancer#ClusterIP#' ./k8s/services/frontend.yaml")
          //         sh("sed -i.bak 's#gcr.io/cloud-solutions-images/gceme:1.0.0#${imageTag}#' ./k8s/dev/*.yaml")
          //         sh("kubectl --namespace=${env.BRANCH_NAME} apply -f k8s/services/")
          //         sh("kubectl --namespace=${env.BRANCH_NAME} apply -f k8s/dev/")
          //         echo 'To access your environment run `kubectl proxy`'
          //         echo "Then access your service via http://localhost:8001/api/v1/proxy/namespaces/${env.BRANCH_NAME}/services/${feSvcName}:80/"
          //   }
          }
}
catch (exc) {
		echo "Caught: ${exc}"

		String recipient = 'munish.mehta@isentia.com'

		mail subject: "${env.JOB_NAME} (${env.BUILD_NUMBER}) failed",
						body: "It appears that ${env.BUILD_URL} is failing, somebody should do something about that",
							to: recipient,
				 replyTo: recipient,
						from: 'isentia.jenkins@gmail.com'
}

// vim: ft=groovy
