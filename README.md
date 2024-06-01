# USING TERRAFORM IAC TOOL TO AUTOMATE AWS CLOUD SOLUTION FOR 2 COMPANY WEBSITES - CONTINUATION

This is a countinuation of [Project-16](https://github.com/Olaminiyi/Project-16).

We will continue to reference the infrastracture

![alt text](<images/new image.png>)

In this Project, we will continue creating the resources for the AWS setup. The resources to be created include:

- 4 Private subnets
- 1 Internet Gateway
- 1 NAT Gateway
- 1 Elastic IP
- 2 Route tables
- IAM roles
- Security Groups
- Target Group for Nginx, WordPress and Tooling
- Certificate from AWS certificate manager
- External Application Load Balancer and Internal Application Load Balancer.
- Launch template for Bastion, Tooling, Nginx and WordPress
- Auto Scaling Group (ASG) for Bastion, Tooling, Nginx and WordPress
- Elastic Filesystem
- Relational Database (RDS)

### CREATE 4 PRIVATE SUBNETS AND TAGGING

we've already created 2 public subnets, we are going to create 4 private subnet according to our diagram

### Tagging
Tags all the resources you have created so far. Explore how to use format() and count functions to automatically tag subnets with its respective number.

we are going to use the `merge` and `format function` of terraform add and format tag name to our dynamically generated VPC's, it merge our variable name(already declared) with variable count that returns the number of VPC generated and use the `%s` to format how the name is placed

![alt text](images/17.1.png)
![alt text](images/17.2.png)

### Networking

Private subnets & best practices
- Create 4 private subnets keeping in mind following principles:
- Make sure you use variables or length() function to determine the number of AZs
- Use variables and cidrsubnet() function to allocate vpc_cidr for subnets
- Keep variables and resources in separate files for better code structure and readability
  
### creating private subnet
we have to increase the count index of cirdr to +2 so it won't overlap. you can increase either that of publc or private.

We will create 4 subnets by updating the main.tf with the following code.
```
resource "aws_subnet" "private" {
  count                   = var.preferred_number_of_private_subnets == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_private_subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 2)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    var.tags,
    {
      Name = format("%s-PrivateSubnet-%s", var.name, count.index)
    },
  )

}
```

![alt text](images/17.3.png)

***The next resource to create is the NAT Gateway**
- created a new file called nat-gw.tf

![alt text](images/17.4.png)

- created elastic ip and natgateway there

![alt text](images/17.5.png)

- created a new file called internet-gw.tf

![alt text](images/17.6.png)

- added environment to the var.tf and tfvars for nat.gtw tags

***create route table**
- we need to create 2 route tables 
- create a file called routes.tf
- we will create the following resources in the file
- create private route table

![alt text](images/17.7.png)

- create route for the private route table and attatch a nat gateway to it

![alt text](images/17.8.png)

We need to creat a route also: it determine the path that traffic goes in and out of a subnet. Associate all private subnets to the private route table

![alt text](images/17.9.png)

- create route table for the public subnets

![alt text](images/17.10.png)

- create route for the public route table and attach the internet gateway

![alt text](images/17.11.png)

- associate all public subnets to the public route table

![alt text](images/17.12.png)

![alt text](images/17.13.png)

let's run Terraform init, plan and apply and check if our resources are created without any error

![alt text](images/17.50.png)

![alt text](images/17.51.png)

![alt text](images/17.52.png)

![alt text](images/17.53.png)

![alt text](images/17.54.png)

![alt text](images/17.55.png)
  
### The next resource to create is certificate manager
- create a file called cert.tf
- we will do the create the following in the file
- Create the certificate using a wildcard for all the domains created in olami.uk

![alt text](images/17.14.png)

- call the hosted zone
> [!NOTE]
> YOU MUST HAVE CREATED THIS HOSTED ZONE MANUALLY ON THE AWS CONSOLE

![alt text](images/17.15.png)

- select validation method

![alt text](images/17.16.png)

- validate the certificate through DNS method

![alt text](images/17.17.png)

- create records for tooling

![alt text](images/17.18.png)

- create records for wordpress

![alt text](images/17.19.png)
    

### The next resource we need to create is the security group
- create a file called security.tf
- we will configure the following in the file
- create security group for alb, to allow acess from any where for HTTP and HTTPS traffic

![alt text](images/17.20.png)

- create security group for bastion, to allow access into the bastion host from you IP

![alt text](images/17.21.png)

- create security group for nginx reverse proxy, to allow access only from the extaernal load balancer and bastion instance

![alt text](images/17.22.png)

- create security group for internal load balancer (ialb), to have acces only from nginx reverser proxy server
![alt text](images/17.23.png)

- create security group for webservers, to have access only from the internal load balancer and bastion instance

![alt text](images/17.24.png)

- create security group for datalayer to alow traffic from websever on nfs and mysql port and bastiopn host on mysql port  

![alt text](images/17.25.png)
    

### The next step is to create the Application Load balancer
- create a file called alb.tf
- we will create the following in the file       
- create External Load balancer for reverse proxy nginx

![alt text](images/17.26.png)

- create a target group for the external load balancer

![alt text](images/17.27.png)

- create a listener for the load balancer

![alt text](images/17.28.png)

- create Internal Load Balancers for webservers

![alt text](images/17.29.png)

- create target group  for wordpress

![alt text](images/17.30.png)

- create target group for tooling

![alt text](images/17.31.png)

- create a single listener for wordpress which is default

![alt text](images/17.32.png)

- create a rule to route traffic to tooling when the host header changes

![alt text](images/17.33.png)


### AWS Identity and Access Management

We want to pass an IAM role our EC2 instances to give them access to some specific resources, so we need to do the following:
- Create AssumeRole: Assume Role uses `Security Token Service (STS)` `API` that returns a set of temporary security credentials that you can use to access AWS resources that you might not normally have access to. These temporary credentials consist of an `access key ID`, a `secret access key`, and a `security token`. Typically, you use `AssumeRole` within your account or for `cross-account access`.

- lets create a file called roles.tf
- a roles is like a container that holds policy such that any resources assume that can perfom some action define by that policy

![alt text](images/17.34.png)


### The next resource to create is the Launch templates for webservers

- to get ami; try to lauch an ubuntu server and copy the ami (free tier ami)

![alt text](images/17.35.png)

- we are creating lauch template and autoscaling group in a file. we will do for 2 resources in a file
- create a file called asg-bastion-nginx.tf (autoscaling group and launch template for both bastion & nginx)
- we will create the following in the file

- create sns topic for all the auto scaling groups

![alt text](images/17.36.png)

- create notification for all the auto scaling groups

![alt text](images/17.37.png)

- create a random_shuffle resouce for terraform to pick an az and place the autoscaling group there

![alt text](images/17.38.png)

-  create a launch template for bastion

![alt text](images/17.39.png)

- create Autoscaling for bastion  hosts

![alt text](images/17.40.png)

- create a launch template for nginx

![alt text](images/17.41.png)

- create Autoscslaling group for reverse proxy nginx 

![alt text](images/17.42.png)

- attach autoscaling group of nginx to external load balancer

![alt text](images/17.43.png)

create a file called asg-webserver.tf (autoscaling group and launch template for both tooling & wordpress)
- we will create the following in the file
- create launch template for wordpress

![alt text](images/17.44.png)

- Autoscaling for wordpress application

![alt text](images/17.45.png)

- attaching autoscaling group of  wordpress application to internal loadbalancer

![alt text](images/17.46.png)

- launch template for toooling

![alt text](images/17.47.png)

- Autoscaling for tooling

![alt text](images/17.48.png)

- attaching autoscaling group of tooling application to internal loadbalancer

![alt text](images/17.49.png)       

- create a file called bastion.sh
- create a file called nginx.sh
- create a file called tooling.sh
- create a file called wordpress.sh

### output concept
output is a way of printing something out in terraform
- creat a file called outputs.tf

### create Elastic File system
- create a file called efs.tf

### creating RDS
- create a file called rds.tf


> [!IMPORTANT]
> for the creation of the resources in different region, I changed the region to us-west-2 permanently. The second error regarding the certificate, I didn't know i have to create the certificate manually first which i did later. After that, there was an error related to RDS creation, about the subnet in the availability zone not have capacity for creation of vpc and the t2 micro type database. I just interchanged the subnets of efs with rds subnets and it was resolved and created successfully.


### use the command below to generate dependency graph
```
terraform graph -type=plan | dot -Tpng > graph.png
```  
```
terraform graph | dot -Tpng > graph.png
```


