terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
    null = {
      source = "hashicorp/null"
    }
    time = {
      source  = "hashicorp/time"
    }        
  }
}

provider "yandex" {
  token     = var.yandex_cloud_token
  cloud_id  = "b1g8kve3609ag8bp327e"
  folder_id = "b1g8kve3609ag8bp327e"
  zone      = "ru-central1-a"
}

# Локальные значения для создания ВМ------------------------------
locals {
  vm_config = {
    bastion_host  = { subnet = yandex_vpc_subnet.subnet-4.id, zone = "ru-central1-a", nat = true,  sg = [yandex_vpc_security_group.bastion_sg.id] }
    webserv1      = { subnet = yandex_vpc_subnet.websub-1.id, zone = "ru-central1-a", nat = false, sg = [yandex_vpc_security_group.web_sg.id] }
    prometheus    = { subnet = yandex_vpc_subnet.subnet-1.id, zone = "ru-central1-a", nat = false, sg = [yandex_vpc_security_group.prometheus_sg.id] }
    grafana       = { subnet = yandex_vpc_subnet.subnet-3.id, zone = "ru-central1-a", nat = true,  sg = [yandex_vpc_security_group.grafana_sg.id] }
    elasticsearch = { subnet = yandex_vpc_subnet.subnet-1.id, zone = "ru-central1-a", nat = false, sg = [yandex_vpc_security_group.elasticsearch_sg.id] }
    kibana        = { subnet = yandex_vpc_subnet.subnet-3.id, zone = "ru-central1-a", nat = true,  sg = [yandex_vpc_security_group.kibana_sg.id] }
  }
}

# Виртуальные машины --------------------------------------------
resource "yandex_compute_instance" "vm" {
  for_each = local.vm_config

  name = each.key

  resources {
    cores  = var.cores
    memory = var.memory
    core_fraction = 100       # Гарантированная доля vCPU    
  }

  scheduling_policy {
    preemptible = true        # Указание, что ВМ прерываемая
  }  

  boot_disk {
    initialize_params {
      image_id = var.image_id
    }
  }

  network_interface {
    subnet_id  = each.value.subnet   # Подсеть
    nat        = each.value.nat      # NAT
    # ip_address = each.value.ip       # Статический IP
    security_group_ids  = each.value.sg       # Группы безопасности
  }

  metadata = {
    user-data = templatefile("./meta/user-data.yaml.tmpl", {
      user_vm = var.user_vm
    })
  }

  zone = each.value.zone # Зона

  depends_on = []
}

resource "time_sleep" "wait_x_seconds" {
  create_duration = "120s"

  depends_on = [yandex_compute_instance.vm]
}

# snapshot дисков всех ВМ ---------------------------------------
resource "yandex_compute_snapshot_schedule" "daily_snapshot" {
  name = "daily-snapshot-schedule"

  schedule_policy {
    expression = "0 0 * * *" # Ежедневно в полночь
  }

  snapshot_count = 7 # Хранить не более 7 снимков для каждого диска

  snapshot_spec {
    description = "Daily snapshot created by Terraform"
    labels = {
      created_by = "terraform"
    }
  }

  # Указываем диски для создания снимков
  disk_ids = [
    for vm in yandex_compute_instance.vm : vm.boot_disk[0].disk_id
  ]

  depends_on = [yandex_compute_instance.vm]
}


# Выходные данные --------------------------------------------
output "internal_ip_addresses" {
  value = { for name, instance in yandex_compute_instance.vm : name => instance.network_interface.0.ip_address }
}

output "external_ip_addresses" {
  value = { for name, instance in yandex_compute_instance.vm : name => instance.network_interface.0.nat_ip_address }
}
