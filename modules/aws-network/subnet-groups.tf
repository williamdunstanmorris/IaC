resource "aws_db_subnet_group" "default" {
  name        = "db"
  description = "default db subnet group"
  subnet_ids  = aws_subnet.private.*.id
}

resource "aws_elasticache_subnet_group" "default" {
  name        = "elasticache"
  description = "default cache subnet group"
  subnet_ids  = aws_subnet.private.*.id
}