sudo apt update
sudo apt upgrade -y

#Jenkins Installation

sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
sudo apt install openjdk-17-jdk -y
sudo apt-get install jenkins -y
sudo systemctl enable jenkins
sudo systemctl status jenkins

# add jenkins user in sudoers file
jenkins ALL=(ALL) NOPASSWD:ALL

#Docker Installation

curl https://get.docker.com | bash
sudo usermod -aG docker jenkins
//if incase ubuntu user include this line-- sudo usermod -aG docker ubuntu
newgrp docker
sudo systemctl enable docker
#######################
sudo systemctl stop jenkins
sudo systemctl start jenkins

######Start Nexus as Docker Container################
mkdir nexus
chmod 777 nexus
docker run -d --name nexus -p 8081:8081 -v /home/ubuntu/nexus:/nexus-data sonatype/nexus3:latest

####in case if server is not up, check visudo file and add below lines
# ubuntu ALL=(ALL) NOPASSWD:ALL
# root ALL=(ALL) NOPASSWD:ALL

######Start SonarQube as Docker Container################
mkdir sonar
chmod 777 sonar
docker run -d --name sonar -p 9000:9000 -v /home/ubuntu/sonar:/opt/sonarqube/data \
                                        -v /home/ubuntu/sonar/extension:/opt/sonarqube/extension \
                                        -v /home/ubuntu/sonar/logs:/opt/sonarqube/logs \
                                        sonarqube:lts-community
#Trivy Install
sudo apt-get install wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy

#Install Aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

#switch to jenkins user
sudo su - jenkins

#EKSCTL Install
# for ARM systems, set ARCH to: `arm64`, `armv6` or `armv7`
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
# (Optional) Verify checksum
curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check
tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
sudo mv /tmp/eksctl /usr/local/bin

#Kubectl Install
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x ./kubectl 
  sudo mv ./kubectl /usr/local/bin

#Install EKS
eksctl create cluster \
  --name demo-cluster \
  --region us-east-1 \
  --version 1.28 \
  --nodegroup-name ng-high-ip \
  --node-type t3.small \
  --nodes 2 \  
  --nodes-min 1 \
  --nodes-max 2 \
  --max-pods-per-node 20 \
  --ssh-access \
  --ssh-public-key AWSHYD  # Replace with your SSH key name

  ---to integrate kubectl with jenkins run below command
  aws eks update-kubeconfig --region us-east-1 --name demo-cluster 

#Plugins Installed
Eclipse Temurin JDK
Pipeline Maven
Sonarqube Scanner
Docker
Docker Pipeline
Kubernetes

kubectl get deploy
kubectl get pods -o wide
kubectl get svc
