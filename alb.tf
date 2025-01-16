# Балансировщик L-7
resource "yandex_alb_backend_group" "my-backend-group" {
  name = "my-backend-group"

  http_backend {
    name             = "my-backend"
    weight           = 1
    port             = 80
    target_group_ids = [yandex_compute_instance_group.web_servers.application_load_balancer.0.target_group_id] # Используем новую Target Group

    healthcheck {
      timeout  = "5s"
      interval = "10s"
      http_healthcheck {
        path = "/"
      }
    }
  }

  depends_on = [yandex_compute_instance_group.web_servers]
}

resource "yandex_alb_http_router" "my-router" {
  name = "my-http-router"
}

resource "yandex_alb_virtual_host" "my-virtual-host" {
  name           = "my-virtual-host"
  http_router_id = yandex_alb_http_router.my-router.id

  route {
    name        = "default-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.my-backend-group.id
      }
    }
  }

  depends_on = [
    yandex_alb_http_router.my-router,
    yandex_alb_backend_group.my-backend-group
  ]
}

resource "yandex_alb_load_balancer" "my-load-balancer" {
  name = "my-load-balancer"

  network_id = yandex_vpc_network.network-1.id

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.subnet-3.id
    }
  }

  # HTTPS listener
  listener {
    name = "https-listener"
    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [443]
    }

  tls {
    default_handler {
      http_handler {
      http_router_id = yandex_alb_http_router.my-router.id
      }
      certificate_ids = ["fpqqcftm1vqtumplb4rl"] # ID вашего сертификата
    }
  }
  }

  timeouts {
    create = "20m"  # Увеличиваем таймаут для создания до 20 минут
    update = "20m"  # Таймаут для обновления
    delete = "15m"  # Таймаут для удаления
  }

  depends_on = [
    yandex_alb_backend_group.my-backend-group,
    yandex_alb_http_router.my-router
  ]
}

output "external_IP_address_of_the_load_balancer" {
  value = yandex_alb_load_balancer.my-load-balancer.listener[0].endpoint[0].address[0].external_ipv4_address
  description = "External IP address of the load balancer"
}