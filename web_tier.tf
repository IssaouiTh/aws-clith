resource "aws_lb" "public" {
  name               = "td-alb-public-lucas"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_public.id]
  subnets            = local.public_subnet_ids
}

resource "aws_lb_target_group" "web" {
  name     = "td-tg-web-lucas"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 15
    timeout             = 5
  }
}

resource "aws_lb_listener" "public_http" {
  load_balancer_arn = aws_lb.public.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

resource "aws_instance" "web" {
  count                  = length(var.azs)
  ami                    = data.aws_ami.debian.id
  instance_type          = "t3.micro"
  subnet_id              = local.web_subnet_ids[count.index]
  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = templatefile("${path.module}/scripts/web.sh", {
    internal_alb_dns = aws_lb.internal.dns_name
  })

  tags = { Name = "td-web-${count.index}" }
}

resource "aws_lb_target_group_attachment" "web" {
  count            = length(var.azs)
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}
