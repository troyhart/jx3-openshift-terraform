output "aws_subnet_ids" {
    description = "Private subnet ids"
    value = [for s in data.aws_subnet.selected : s.id]
}