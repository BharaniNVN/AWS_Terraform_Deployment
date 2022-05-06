# loadbalancer /main.tf #

resource "aws_lb" "loadbalancer" {
  name            = "terrafrom-lb"
  subnets         = var.public_subnets
  security_groups = [var.public_sg]
  idle_timeout    = 400
}

resource "aws_lb_target_group" "target_group" {
  name     = "terrafrom-lb-${substr(uuid(), 0, 3)}"
  port     = var.tg_port     #80
  protocol = var.tg_protocol #http
  vpc_id   = var.vpc_id
  lifecycle {
    ignore_changes = [name]
    create_before_destroy = true
  }
  health_check {
    healthy_threshold   = var.lb_healthy_threshold   #2
    unhealthy_threshold = var.lb_unhealthy_threshold #2
    timeout             = var.lb_timeout             #3
    interval            = var.lb_interval

  }

}

resource "aws_lb_listener" "terraform-lb-listner" {
  load_balancer_arn = aws_lb.loadbalancer.arn
  port              = var.listner_port     #80
  protocol          = var.listner_protocol #http
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}
