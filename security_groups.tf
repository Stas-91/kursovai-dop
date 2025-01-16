# Группа безопасности для веб-серверов
resource "yandex_vpc_security_group" "web_sg" {
  name        = "web-sg"
  network_id  = yandex_vpc_network.network-1.id

  ingress {
    description    = "Allow HTTP traffic from ALB"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = yandex_vpc_subnet.subnet-3.v4_cidr_blocks
  }

  ingress {
    description    = "Allow SSH from Bastion Host"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = yandex_vpc_subnet.subnet-4.v4_cidr_blocks 
  }

  ingress {
    description    = "Allow scraping metrics on port 9100"
    protocol       = "TCP"
    port           = 9100
    v4_cidr_blocks = yandex_vpc_subnet.subnet-1.v4_cidr_blocks
  }

  ingress {
    protocol          = "TCP"
    description       = "healthchecks"
    predefined_target = "loadbalancer_healthchecks"
    port              = 80
  }

  ingress {
    description    = "Allow scraping metrics on port 4040"
    protocol       = "TCP"
    port           = 4040
    v4_cidr_blocks = yandex_vpc_subnet.subnet-1.v4_cidr_blocks
  }

  egress {
    description    = "Allow outbound traffic"
    protocol       = "ANY"
    v4_cidr_blocks = var.is_production ? ["192.168.0.0/16"] : ["0.0.0.0/0"]
  }
}

# Группа безопасности для Elasticsearch
resource "yandex_vpc_security_group" "elasticsearch_sg" {
  name        = "elasticsearch-sg"
  network_id  = yandex_vpc_network.network-1.id

  ingress {
    description    = "Allow access to Elasticsearch on port 9200 from services"
    protocol       = "TCP"
    port           = 9200
    v4_cidr_blocks = concat(
      yandex_vpc_subnet.websub-1.v4_cidr_blocks,
      yandex_vpc_subnet.websub-2.v4_cidr_blocks,
      yandex_vpc_subnet.websub-3.v4_cidr_blocks,      
      yandex_vpc_subnet.subnet-3.v4_cidr_blocks
    )
  }

  ingress {
    description    = "Allow access to Elasticsearch on port 9300 from Kibana"
    protocol       = "TCP"
    port           = 9300
    v4_cidr_blocks = yandex_vpc_subnet.subnet-3.v4_cidr_blocks
  }

  ingress {
    description    = "Allow SSH from Bastion Host"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = yandex_vpc_subnet.subnet-4.v4_cidr_blocks 
  }

  egress {
    description    = "Allow outbound traffic"
    protocol       = "ANY"
    v4_cidr_blocks = var.is_production ? ["192.168.0.0/16"] : ["0.0.0.0/0"]
  }
}

# Группа безопасности для Kibana
resource "yandex_vpc_security_group" "kibana_sg" {
  name        = "kibana-sg"
  network_id  = yandex_vpc_network.network-1.id

  ingress {
    description    = "Allow HTTP access from any IP"
    protocol       = "TCP"
    port           = 5601
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Allow SSH from Bastion Host"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = yandex_vpc_subnet.subnet-4.v4_cidr_blocks 
  }

  egress {
    description    = "Allow outbound traffic"
    protocol       = "ANY"
    v4_cidr_blocks = var.is_production ? ["192.168.0.0/16"] : ["0.0.0.0/0"]
  }
}

# Группа безопасности для Prometheus
resource "yandex_vpc_security_group" "prometheus_sg" {
  name        = "prometheus-sg"
  network_id  = yandex_vpc_network.network-1.id

  ingress {
    description    = "Allow SSH from Bastion Host"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = yandex_vpc_subnet.subnet-4.v4_cidr_blocks 
  }

  ingress {
    description    = "Allow Grafana to connect to Prometheus on port 9090"
    protocol       = "TCP"
    port           = 9090
    v4_cidr_blocks = yandex_vpc_subnet.subnet-3.v4_cidr_blocks
  }

  ingress {
    description    = "Allow PostgreSQL access from adapter"
    protocol       = "TCP"
    port           = 6432 # порт PostgreSQL
    v4_cidr_blocks = concat(
      yandex_vpc_subnet.websub-1.v4_cidr_blocks,
      yandex_vpc_subnet.websub-2.v4_cidr_blocks
    )
  }

  ingress {
    description    = "Allow adapter HTTP access from Prometheus"
    protocol       = "TCP"
    port           = 9201 # порт адаптера
    v4_cidr_blocks = yandex_vpc_subnet.subnet-3.v4_cidr_blocks
  }  

  egress {
    description    = "Allow outbound traffic"
    protocol       = "ANY"
    v4_cidr_blocks = var.is_production ? ["192.168.0.0/16"] : ["0.0.0.0/0"]
  }
}

# Группа безопасности для Grafana
resource "yandex_vpc_security_group" "grafana_sg" {
  name        = "grafana-sg"
  network_id  = yandex_vpc_network.network-1.id

  ingress {
    description    = "Allow HTTP access from any IP"
    protocol       = "TCP"
    port           = 3000
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Allow SSH from Bastion Host"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = yandex_vpc_subnet.subnet-4.v4_cidr_blocks 
  }

  egress {
    description    = "Allow outbound traffic"
    protocol       = "ANY"
    v4_cidr_blocks = var.is_production ? ["192.168.0.0/16"] : ["0.0.0.0/0"]
  }
}

# Группа безопасности для Bastion Host
resource "yandex_vpc_security_group" "bastion_sg" {
  name        = "bastion-sg"
  network_id  = yandex_vpc_network.network-1.id

  ingress {
    description    = "Allow SSH from any IP"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"] # Доступ с любого IP
  }

  egress {
    description    = "Allow all outbound traffic"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"] # Всегда открыт для Bastion Host
  }
}

# Группа безопасности для PostgreSQL
resource "yandex_vpc_security_group" "postgresql_sg" {
  name        = "postgresql-sg"
  network_id  = yandex_vpc_network.network-1.id

  # Разрешение доступа к PostgreSQL
  ingress {
    description    = "Allow PostgreSQL access from application subnet"
    protocol       = "TCP"
    port           = 6432
    v4_cidr_blocks = concat(
      yandex_vpc_subnet.websub-1.v4_cidr_blocks,
      yandex_vpc_subnet.websub-2.v4_cidr_blocks,
      yandex_vpc_subnet.subnet-1.v4_cidr_blocks
    )    
  }

  egress {
    description    = "Allow outbound traffic"
    protocol       = "ANY"
    v4_cidr_blocks = var.is_production ? ["192.168.0.0/16"] : ["0.0.0.0/0"]
  }
}
