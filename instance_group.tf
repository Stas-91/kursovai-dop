resource "null_resource" "stop_webserv1" {
  provisioner "local-exec" {
    command = "yc compute instance stop ${yandex_compute_instance.vm["webserv1"].name}"
  }
  depends_on = [null_resource.run_ansible_webserv1]
}

resource "time_sleep" "wait_after_stop" {
  create_duration = "90s" # Время ожидания (например, 90 секунд)

    depends_on = [null_resource.stop_webserv1]
}

resource "yandex_compute_snapshot" "web_snapshot" {
  name       = "web-snapshot"
  source_disk_id = yandex_compute_instance.vm["webserv1"].boot_disk.0.disk_id

  depends_on = [time_sleep.wait_after_stop]
}

resource "yandex_compute_instance_group" "web_servers" {
  name = "web-servers"
  service_account_id  = "ajeqbt6qjjjli508c1ap"  

  instance_template {
    platform_id = "standard-v3"
    resources {
      cores  = 2
      memory = 2  # 2 ГБ памяти
      core_fraction = 20       # Гарантированная доля vCPU 20%  
    }

    scheduling_policy {
      preemptible = true        # Указание, что ВМ прерываемая
    }      

    boot_disk {
      initialize_params {
        snapshot_id = yandex_compute_snapshot.web_snapshot.id
        size        = 8  # Размер диска в гигабайтах
      }
    }

    network_interface {
      subnet_ids = [
        yandex_vpc_subnet.websub-1.id,
        yandex_vpc_subnet.websub-2.id,
        yandex_vpc_subnet.websub-3.id
      ]
      nat = false  # NAT отключен
    }

    metadata = {
      user-data = templatefile("./meta/web-data-group.yaml.tmpl", {
        user_vm = var.user_vm
      })
    }

  }

  scale_policy {
    fixed_scale {
      size = 3  # Количество инстансов в группе
    }
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 2
  }

  health_check {
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    http_options {
      path = "/"
      port = 80
    }
  }

  allocation_policy {
    zones = [
      "ru-central1-a",
      "ru-central1-b",
      "ru-central1-d"
    ]
  }

  application_load_balancer {
    target_group_name        = "web-target-group"
    target_group_description = "Target group for web servers"
  }

  depends_on = [yandex_compute_snapshot.web_snapshot]
}
