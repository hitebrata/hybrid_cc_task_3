
// AWS prvider details


provider "aws" {
   profile = var.profile
   region  = var.aws_region
}

//Create VPC

resource "aws_vpc" "prod_vpc" {
    cidr_block = var.vpc_cidr
    instance_tenancy = var.instanceTenancy
    enable_dns_support = var.dnsSupport
    enable_dns_hostnames = var.dnsHostNames
tags = {
        Name = "prod_vpc"
    }
}
//Public Subnet
resource "aws_subnet" "pub_subnet" {
    depends_on = [aws_vpc.prod_vpc]
    vpc_id = aws_vpc.prod_vpc.id
    cidr_block = var.public_subnet_cidr
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone = var.pub_availabilityZone

    tags = {
        Name = "Public Subnet"
    }
}

// Private Subnet
resource "aws_subnet" "pvt_subnet" {
    depends_on = [aws_vpc.prod_vpc]
    vpc_id = aws_vpc.prod_vpc.id
    cidr_block = var.private_subnet_cidr
    availability_zone = var.pvt_availabilityZone

    tags = {
        Name = "Private Subnet"
    }
}
//Create Internet Gateway
resource "aws_internet_gateway" "prod_gateway" {
  depends_on = [aws_vpc.prod_vpc]
    vpc_id = aws_vpc.prod_vpc.id

tags = {
        Name = "prod-IG"
    }
}
/*
  Public Subnet aws_route_table
 */

resource "aws_route_table" "pub_routing_table" {
    depends_on = [aws_subnet.pub_subnet]
    vpc_id = aws_vpc.prod_vpc.id
    route{
        cidr_block = "0.0.0.0/0" //associated subnet can reach everywhere
        gateway_id = aws_internet_gateway.prod_gateway.id //CRT uses this IGW to reach internet
    }

    tags = {
        Name = "pub routing table"
    }
}
resource "aws_route_table_association" "pub_route_asction" {
    depends_on = [aws_route_table.pub_routing_table, aws_internet_gateway.prod_gateway]
    subnet_id = aws_subnet.pub_subnet.id
    route_table_id = aws_route_table.pub_routing_table.id
}
//  Create a Webserver_securitygroup
resource "aws_security_group" "web_sg" {
    depends_on = [aws_vpc.prod_vpc]
    name = "vpc_web"
    description = "Allow incoming HTTP connections."
    ingress {
        to_port = 22
        from_port = 22
        protocol = "tcp"
        cidr_blocks = var.ingress_cidr
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = var.ingress_cidr
}
    egress { # MySQL
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = var.egress_cidr
    }

    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = aws_vpc.prod_vpc.id

    tags = {
        Name = "WebServerSG"
    }
}

resource "aws_instance" "web" {
    depends_on = [aws_security_group.web_sg]
    ami = var.wordpressami
    instance_type = var.wpinstance
    key_name = var.aws_key_name
    vpc_security_group_ids = [ aws_security_group.web_sg.id ]
    subnet_id = aws_subnet.pub_subnet.id
    user_data = <<EOF
#!/bin/bash
sudo yum update -y
sudo yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
sudo yum install yum-utils -y
sudo yum-config-manager --enable remi-php72
sudo amazon-linux-extras install lamp-mariadb10.2-php7.2 -y
sudo yum install httpd  -y
sudo systemctl start httpd
sudo systemctl enable httpd
sudo wget http://wordpress.org/latest.tar.gz
sudo tar -xvzf latest.tar.gz -C /var/www/html
sudo chown -R apache /var/www/html/wordpress
sudo cat >> /etc/httpd/conf/httpd.conf << EOL
<VirtualHost *:80>
ServerAdmin tecmint@tecmint.com
DocumentRoot /var/www/html/wordpress
ServerName tecminttest.com
ServerAlias www.tecminttest.com
ErrorLog /var/log/httpd/tecminttest-error-log
CustomLog /var/log/httpd/tecminttest-acces-log common
</VirtualHost>
EOL
sudo systemctl restart httpd
EOF

    tags = {
        Name = "Web Server"
    }
}
// Create DataBase Sever securitygroup
resource "aws_security_group" "db_sg" {
    depends_on = [aws_vpc.prod_vpc]
    name = "vpc_db"
    description = "Allow incoming database connections."
    ingress { # MySQL
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = var.ingress_cidr
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = var.ingress_cidr
    }
    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = var.egress_cidr
    }
    vpc_id = aws_vpc.prod_vpc.id

    tags = {
        Name = "DBServerSG"
    }
}

resource "aws_instance" "db" {
    depends_on = [aws_security_group.db_sg]
    ami = var.mysqlami
    instance_type = var.mysqlinstance
    key_name = var.aws_key_name
    vpc_security_group_ids = [ aws_security_group.db_sg.id ]
    subnet_id = aws_subnet.pvt_subnet.id
    tags = {
        Name = "DB Server 1"
    }
    user_data = <<EOF
#!/bin/bash
/jet/bin/mysql -e "CREATE DATABASE wordpress;"
/jet/bin/mysql -e "CREATE USER 'dbus'@'%' IDENTIFIED BY 'Mysql@123';"
/jet/bin/mysql -e "GRANT ALL ON *.* TO 'dbus'@'%';"
/jet/bin/mysql -e "FLUSH PRIVILEGES;"
EOF
}
