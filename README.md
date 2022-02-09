# Use Terraform to deploy resilient AWS Infrastructure with multiple machines behind a load balancer

The Terraform creates a new VPC with 2-subnets in different zones and deploy 1 machine in each zone with an auto-scaling group and a load balancer. Putting the load balancer URL should  return the AWS machine id as output in the browser.

Created terraform scripts to deploy by simply changing the `awsaccountname` and  the `region` variables. You should need to change only `awsaccountnam` and `region` in tfvars file so  to deploy in our AWS infrastructure for testing. If additional steps are required to make it work  then please document those in a readme.

Deployment should do following things: 
- Create a VPC with your name in CIDR 17.1.0.0/25 with 2 subnets 
- Create a load balancer with 2 machines running in separate subnets for resiliency  behind an auto-scaling group to increase total number of machines to 5 
- Create EC2 machines with t3a.nano or t3a.micro and 8GB diskspace that use USER_DATA to deploy code that will return the machine-name (AWS instance id) when  called from ELB 
- Make the load balancer respond with machine-name (AWS instance id) of machine  responding to load balancer request i.e. when we put the ELB URL in browser the  browser should show name of the machine serving the request. If this is working correctly then refreshing multiple times should result in machine-name switching between the calls. 


## Steps to run: 
1. Configure aws cli (Enter AWS Access Key ID and Secret Access Key)- `aws configure`
2. update `awsaccountname` and `region` @ .auto.tfvars file
3. Run Terraform:
	`terraform init`
	`terraform plan`
	`terraform apply`