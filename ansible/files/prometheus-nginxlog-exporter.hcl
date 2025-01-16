listen {
  address = "0.0.0.0"
  port    = 4040
}

namespace "nginx" {
  source {
    files = [
      "/var/log/nginx/access.log"
    ]
  }

  format = "$remote_addr - $remote_user [$time_local] \"$request\" $status $body_bytes_sent \"$http_referer\" \"$http_user_agent\""
}
