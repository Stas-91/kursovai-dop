variable "user_vm" {
  description = "User name for VM and some values for hardcoded data"
  type        = string
  default     = "stas"
}

variable "elastic_passwd" {
  type        = string
  description = "password for elastic"
}

variable "grafana_passwd" {
  type        = string
  description = "password for Grafana"
}

variable "postgre_passwd" {
  type        = string
  description = "password for PostgreSQL"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for VMs"
}

# Переменные для создания ВМ
variable "cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Amount of memory (in GB)"
  type        = number
  default     = 2
}

variable "image_id" {
  description = "ID of the image to use for the VM"
  type        = string
  default     = "fd8s3qh62qn5sqoemni6"
}

# Переменная для управления средой
variable "is_production" {
  description = "Flag to determine if the environment is production"
  default     = false
}

# Переменные для Yandex аккаунта
variable "yandex_cloud_token" {
  type        = string
  description = "Token for accessing Yandex Cloud"
}
