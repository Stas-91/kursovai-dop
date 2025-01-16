# Кластер PostgreSQL
resource "yandex_mdb_postgresql_cluster" "pg_cluster" {
  name                = "pg-cluster"
  environment         = "PRODUCTION" # Окружение: PRODUCTION или PRESTABLE
  network_id          = yandex_vpc_network.network-1.id
  security_group_ids  = [ yandex_vpc_security_group.postgresql_sg.id ]
  deletion_protection = false

  config {
    version = "14" # Версия PostgreSQL

    resources {
      resource_preset_id = "s2.micro"    # Класс хоста
      disk_type_id       = "network-ssd" # Тип диска
      disk_size          = 20           # Размер хранилища в ГБ
    }

    pooler_config {
      pool_discard = false
      pooling_mode = "SESSION"
    }
  }

  # Первый хост
  host {
    zone             = "ru-central1-a"
    name             = "pg-host-a"
    subnet_id        = yandex_vpc_subnet.websub-1.id
    assign_public_ip = false
  }

  # Второй хост
  host {
    zone             = "ru-central1-b"
    name             = "pg-host-b"
    subnet_id        = yandex_vpc_subnet.websub-2.id
    assign_public_ip = false
  }
}

# Пользователь PostgreSQL
resource "yandex_mdb_postgresql_user" "pg_user" {
  cluster_id = yandex_mdb_postgresql_cluster.pg_cluster.id
  name       = "pguser"
  password   = var.postgre_passwd # Использование переменной для пароля
}

# База данных PostgreSQL
resource "yandex_mdb_postgresql_database" "pg_database" {
  cluster_id = yandex_mdb_postgresql_cluster.pg_cluster.id
  name       = "pgdatabase"
  owner      = yandex_mdb_postgresql_user.pg_user.name

  depends_on = [
    yandex_mdb_postgresql_user.pg_user
  ]
}
