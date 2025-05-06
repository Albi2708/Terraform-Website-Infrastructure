### --- Example of a web server --- ###

# moved to asg.ts
#resource "aws_instance" "web_server" {
#  ami                    = "ami-0c614dee691cbbf37"                 # amazon Linux 2023 AMI
#  instance_type          = "t2.micro"                              # free-tier eligible
#  user_data              = file("${path.module}/startup.sh")       # runs the script when the instance boots
#  vpc_security_group_ids = [aws_security_group.web_sg.id]
#  subnet_id              = aws_subnet.public_subnets[0].id
#  
#  tags = {
#    Name = "SimpleWebServer"
#  }
#}



### --- Security Group --- ###

# By default, EC2 instances block incoming HTTP traffic, so a security group is needed to allow access
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow HTTP inbound traffic from ALB"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]  # allow traffic from ALB only
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}