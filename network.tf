# Сеть
resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

# Подсети
resource "yandex_vpc_subnet" "websub-1" {
  name           = "websub1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.15.0/28"]
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_subnet" "websub-2" {
  name           = "websub2"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.16.0/28"]
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_subnet" "websub-3" {
  name           = "websub3"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.17.0/28"]
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/28"]
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_subnet" "subnet-3" {
  name           = "subnet3"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.12.0/28"]
}

resource "yandex_vpc_subnet" "subnet-4" {
  name           = "subnet4"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.13.0/28"]
}

# NAT-шлюз
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "nat-gateway"
  shared_egress_gateway {}
}

# Таблица маршрутов
resource "yandex_vpc_route_table" "rt" {
  name       = "my-route-table"
  network_id = yandex_vpc_network.network-1.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

resource "yandex_dns_recordset" "dns_a_record" {
  name    = "kursovai-devops.ru." 
  zone_id = "dns1d6apfmtfchc2o7jo" # Идентификатор зоны DNS

  type = "A" # Тип записи
  ttl  = 300 # Время жизни записи в секундах

  data = [
      yandex_alb_load_balancer.my-load-balancer.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
    ]

  depends_on = [yandex_alb_load_balancer.my-load-balancer]
}
