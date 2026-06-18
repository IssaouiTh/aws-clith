resource "aws_lb" "internal" {
  name               = "td-alb-internal-lucas"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_internal.id]
  subnets            = local.app_subnet_ids
}

resource "aws_lb_target_group" "app" {
  name     = "td-tg-app-lucas"
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

resource "aws_lb_listener" "internal_http" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_instance" "app" {
  count                  = length(var.azs)
  ami                    = data.aws_ami.debian.id
  instance_type          = "t3.micro"
  subnet_id              = local.app_subnet_ids[count.index]
  vpc_security_group_ids = [aws_security_group.app.id]

  user_data = templatefile("${path.module}/scripts/app.sh", {
    db_host     = data.aws_db_instance.postgres.address
    db_name     = local.rds_db_name
    db_user     = local.rds_creds.username
    db_password = local.rds_creds.password
  })

  tags = { Name = "td-app-${count.index}" }
}

resource "aws_lb_target_group_attachment" "app" {
  count            = length(var.azs)
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.app[count.index].id
  port             = 80
}
