 resource "aws_vpc" "my-vpc" {
    cidr_block = var.cidr
 }

 resource "aws_subnet" "sub-1"{
    vpc_id     = aws_vpc.my-vpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true   
 }

  resource "aws_subnet" "sub-2"{
    vpc_id     = aws_vpc.my-vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = true  
 }

 resource "aws_internet_gateway" "IGT" {
    vpc_id = aws_vpc.my-vpc.id  
 }

 resource "aws_route_table" "RT" {
    vpc_id = aws_vpc.my-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.IGT.id
    }
 }

 resource "aws_route_table_association" "rta-1" {
   subnet_id = aws_subnet.sub-1.id
   route_table_id = aws_route_table.RT.id
 }

 resource "aws_route_table_association" "rta-2" {
   subnet_id = aws_subnet.sub-2.id
   route_table_id = aws_route_table.RT.id
 }

 resource "aws_security_group" "web-sg" {
  name   = "web"
  vpc_id = aws_vpc.my-vpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-sg"
  }
}

resource "aws_s3_bucket" "my-bucket" {
  bucket = "aseem-terraform-iaac-project-bucket"
}

resource "aws_instance" "web-server-1" {
    ami = "ami-04b4f1a9cf54c11d0"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.web-sg.id]
    subnet_id = aws_subnet.sub-1.id
    user_data = base64encode(file("userdata.sh"))
}

resource "aws_instance" "web-server-2" {
    ami = "ami-04b4f1a9cf54c11d0"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.web-sg.id]
    subnet_id = aws_subnet.sub-2.id
    user_data = base64encode(file("userdata1.sh"))
}

resource "aws_lb" "my-alb" {
    name = "my-alb"
    internal = false
    load_balancer_type = "application"

    security_groups = [aws_security_group.web-sg.id]
    subnets = [aws_subnet.sub-1.id, aws_subnet.sub-2.id]
}

resource "aws_lb_target_group" "tg" {
  name     = "myTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my-vpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.web-server-1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.web-server-2.id
  port             = 80
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.my-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type             = "forward"
  }
}

output "loadbalancerdns" {
  value = aws_lb.my-alb.dns_name
}