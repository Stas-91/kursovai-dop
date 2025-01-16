resource "null_resource" "run_ansible_webserv1" {
  # triggers = {
  #   always_run = timestamp() # Триггер с текущим временем
  # }  
  provisioner "local-exec" {
    command = <<EOT
      cd ./ansible &&
      ansible-playbook ansible_web.yml \
      --extra-vars "bastion_server=${yandex_compute_instance.vm["bastion_host"].network_interface.0.nat_ip_address} \
      ansible_host=${yandex_compute_instance.vm["webserv1"].network_interface.0.ip_address} \
      elastic_password=${var.elastic_passwd} \
      elastic_ip=${yandex_compute_instance.vm["elasticsearch"].network_interface.0.ip_address}"
    EOT
  }

  depends_on = [time_sleep.wait_x_seconds]
}

resource "null_resource" "run_ansible_prometheus" {
  triggers = {
    always_run = timestamp() # Триггер с текущим временем
  }    
  provisioner "local-exec" {
    command = <<EOT
      cd ./ansible &&
      ansible-playbook ansible_prometheus.yml \
      --extra-vars "bastion_server=${yandex_compute_instance.vm["bastion_host"].network_interface.0.nat_ip_address} \
      elastic_password=${var.elastic_passwd} \
      elastic_ip=${yandex_compute_instance.vm["elasticsearch"].network_interface.0.ip_address} \
      postgre_password=${var.postgre_passwd} \
      postgre_host=${yandex_mdb_postgresql_cluster.pg_cluster.host[0].fqdn} \
      vm_user=${var.user_vm} \
      subnets=${join(",", [yandex_vpc_subnet.websub-1.v4_cidr_blocks[0], yandex_vpc_subnet.websub-2.v4_cidr_blocks[0], yandex_vpc_subnet.websub-3.v4_cidr_blocks[0]])} \
      ansible_host=${yandex_compute_instance.vm["prometheus"].network_interface.0.ip_address}"
    EOT
  }

  depends_on = [time_sleep.wait_x_seconds]
}

resource "null_resource" "run_ansible_grafana" {
  # triggers = {
  #   always_run = timestamp() # Триггер с текущим временем
  # }    
  provisioner "local-exec" {
    command = <<EOT
      cd ./ansible &&
      ansible-playbook ansible_grafana.yml \
      --extra-vars "bastion_server=${yandex_compute_instance.vm["bastion_host"].network_interface.0.nat_ip_address} \
      ansible_host=${yandex_compute_instance.vm["grafana"].network_interface.0.ip_address} \
      grafana_password=${var.grafana_passwd} \
      elastic_password=${var.elastic_passwd} \
      elastic_ip=${yandex_compute_instance.vm["elasticsearch"].network_interface.0.ip_address} \
      prometheus_ip=${yandex_compute_instance.vm["prometheus"].network_interface.0.ip_address}"
    EOT
  }

  depends_on = [time_sleep.wait_x_seconds]
}

resource "null_resource" "run_ansible_elastic" {
  # triggers = {
  #   always_run = timestamp() # Триггер с текущим временем
  # }    
  provisioner "local-exec" {
    command = <<EOT
      cd ./ansible &&
      ansible-playbook ansible_elastic.yml \
      --extra-vars "bastion_server=${yandex_compute_instance.vm["bastion_host"].network_interface.0.nat_ip_address} \
      elastic_password=${var.elastic_passwd} \
      elastic_ip=${yandex_compute_instance.vm["elasticsearch"].network_interface.0.ip_address} \
      ansible_host=${yandex_compute_instance.vm["elasticsearch"].network_interface.0.ip_address}"
    EOT
  }

  depends_on = [time_sleep.wait_x_seconds]
}

resource "null_resource" "run_ansible_kibana" {
  # triggers = {
  #   always_run = timestamp() # Триггер с текущим временем
  # }    
  provisioner "local-exec" {
    command = <<EOT
      cd ./ansible && \
      ansible-playbook ansible_kibana.yml \
      --extra-vars "bastion_server=${yandex_compute_instance.vm["bastion_host"].network_interface.0.nat_ip_address} \
      ansible_host=${yandex_compute_instance.vm["kibana"].network_interface.0.ip_address} \
      elastic_password=${var.elastic_passwd} \      
      elastic_ip=${yandex_compute_instance.vm["elasticsearch"].network_interface.0.ip_address}"
    EOT
  }

  depends_on = [time_sleep.wait_x_seconds]
}