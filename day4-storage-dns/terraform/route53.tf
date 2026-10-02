resource "aws_route53_zone" "private" {
  name = "lab.internal"

  vpc {
    vpc_id = aws_vpc.lab.id
  }

  tags = { Name = "phz-lab-internal" }
}

# Alias record → ALB
resource "aws_route53_record" "alb_alias" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "app.lab.internal"
  type    = "A"

  alias {
    name                   = aws_lb.lite.dns_name
    zone_id                = aws_lb.lite.zone_id
    evaluate_target_health = true
  }
}

# Enregistrement A classique → IP de l'instance EC2
resource "aws_route53_record" "instance_a" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "instance.lab.internal"
  type    = "A"
  ttl     = 60
  records = [aws_instance.lab.private_ip]
}