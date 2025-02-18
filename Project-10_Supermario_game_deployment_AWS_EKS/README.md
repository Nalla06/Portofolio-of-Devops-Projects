# Project-10 Super Mario Game Deployment on AWS EKS


![supermario](https://imgur.com/rC4Qe8g.png)


## **Overview**

This project automates the deployment of the Super Mario game on an AWS EKS cluster using **Terraform, Ansible, and Jenkins**. The workflow provisions an EC2 instance, sets up an EKS cluster, and deploys the containerized Super Mario game on Kubernetes.

## **Project Architecture**

1. **Terraform** provisions an AWS EC2 instance and an EKS cluster.
2. **Ansible** installs necessary tools (AWS CLI, Terraform, kubectl, Helm) on EC2.
3. **Terraform** creates EKS cluster and provisions worker nodes.
4. **Kubernetes** deploys the Super Mario game using a YAML configuration.
5. **Jenkins** automates the entire process.

---

## **Prerequisites**

Ensure you have the following:

- AWS account with necessary IAM permissions
- Terraform installed on your local machine
- Ansible installed for automation
- Jenkins set up with required plugins (Terraform, Kubernetes)
- Docker image of Super Mario game available on DockerHub

---

## **Setup Instructions**

### **1. Clone the Repository**

```bash
git clone https://github.com/your-repo/super-mario-deployment.git
cd super-mario-deployment
```

### **2. Provision AWS EC2 Instance (Terraform)**

Terraform provisions an EC2 instance to act as the EKS manager.

```bash
terraform init
terraform apply -auto-approve
```

Take note of the **EC2 public IP** from the output.

---

### **3. Install Required Tools on EC2 (Ansible)**

Update the `inventory.ini` file with your EC2 instance details:

```ini
[eks_manager]
<EC2_PUBLIC_IP> ansible_ssh_user=ec2-user ansible_ssh_private_key_file=your-key.pem
```

Run the playbook to install necessary tools:

```bash
ansible-playbook -i inventory.ini install_tools.yml
```

---

### **4. Deploy AWS EKS Cluster (Terraform)**

Terraform provisions the AWS EKS cluster and worker nodes.

```bash
terraform apply -auto-approve
```

This will create:

- An EKS Cluster
- IAM Roles
- Worker Nodes

---

### **5. Deploy Super Mario Game on EKS**

Ensure `kubectl` is configured to connect to EKS:

```bash
aws eks update-kubeconfig --region us-east-1 --name super-mario-eks
```

Deploy the application:

```bash
kubectl apply -f mario-deployment.yml
```

Check deployment status:

```bash
kubectl get pods
kubectl get services
```

---

### **6. Automate Deployment with Jenkins**

1. Install Terraform and Kubernetes plugins in Jenkins.
2. Create a new pipeline job.
3. Add the following `Jenkinsfile` in the pipeline script:

```groovy
pipeline {
    agent any

    stages {
        stage('Provision Infrastructure') {
            steps {
                sh 'terraform init'
                sh 'terraform apply -auto-approve'
            }
        }

        stage('Deploy Super Mario on EKS') {
            steps {
                sh 'kubectl apply -f mario-deployment.yml'
            }
        }
    }
}
```

4. Trigger the job to automate deployment.

---

## **Testing the Deployment**

Get the external IP of the LoadBalancer service:

```bash
kubectl get services | grep mario-service
```

Access the game via the displayed external IP in a web browser.

---

## **Cleanup**

To delete the infrastructure:

```bash
terraform destroy -auto-approve
```

To delete Kubernetes resources:

```bash
kubectl delete -f mario-deployment.yml
```

---

## **Conclusion**

This project automates the deployment of the Super Mario game on AWS EKS using Terraform, Ansible, and Jenkins. With this setup, the process is fully automated and scalable.

🚀 Happy Deploying!

