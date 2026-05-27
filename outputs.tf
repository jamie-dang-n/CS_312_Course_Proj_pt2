output "get_minecraft_ip" {
  description = "Get the Minecraft server's public IP"
  value = <<-EOT
    TASK_ARN=$(aws ecs list-tasks --cluster ${module.ecs.cluster_name} --query 'taskArns[0]' --output text)
    ENI_ID=$(aws ecs describe-tasks --cluster ${module.ecs.cluster_name} --tasks $TASK_ARN \
      --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' --output text)
    aws ec2 describe-network-interfaces --network-interface-ids $ENI_ID \
      --query 'NetworkInterfaces[0].Association.PublicIp' --output text
  EOT
}