output "rds_read_replica_endpoint" {
  value = [ for instance in aws_rds_cluster_instance.itsag1t5_rds_instance: instance.endpoint if instance.writer == false ]
}

output "rds_writer_endpoint" {
  value = [ for instance in aws_rds_cluster_instance.itsag1t5_rds_instance: instance.endpoint if instance.writer == true ]
}