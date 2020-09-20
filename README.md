# hybrid_cc_task_3
All the tasks will be performed by terraform.

Create a VPC and also enable DNS hostnames.

Create 2 Subnets in that VPC. One PUBLIC Subnet and One PRIVATE Subnet also add auto IP Assign in PUBLIC Subnet.

Create a public Facing Internet Gateway for connecting our VPC to the Internet World and attach it to our VPC.

Create a Route Table for Internet Gateway so that Instance can connect to Outside World, and associate it with our PUBLIC Subnet.

Launch an EC2 Instance with WordPress installed and allow Port 80 in Security Group so that the public or client can access our WordPress site and also attach the key to the instance for further login into the instance.

Launch an EC2 Instance with MySQL installed and allow Port 3306 in private subnet Security Group so our instance can communicate to WordPress instance and also attach the key to the instance for further login into the instance.

Note: WordPress instance has to be part of the public subnet so that our client can connect our site.

MySQL instance has to be part of a private subnet so that the outside world can’t connect to it.
