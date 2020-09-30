output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}


output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "subnet_0" {
  value       = module.vpc.public_subnets.0
}

output "subnet_1" {
  value       = module.vpc.public_subnets.1
}

output "subnet_2" {
  value       = module.vpc.public_subnets.2
}

output "alb_url" {
  value       = aws_alb.ecs-load-balancer.dns_name
}