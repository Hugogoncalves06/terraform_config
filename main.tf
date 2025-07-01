terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

resource "docker_network" "app_network" {
  name = "app-network"
}

# MongoDB
resource "docker_image" "mongo" {
  name         = "mongo:6.0"
  keep_locally = false
}

resource "docker_container" "mongo" {
  image = docker_image.mongo.image_id
  name  = "mongo"
  ports {
    internal = 27017
    external = 27017
  }
  env = [
    "MONGO_INITDB_DATABASE=blog-api"
  ]
  volumes {
    host_path      = "${abspath(path.module)}/mongo_data"
    container_path = "/data/db"
  }
  restart = "unless-stopped"
  networks_advanced {
    name = docker_network.app_network.name
  }
}

# MySQL
resource "docker_image" "mysql" {
  name         = "mysql:8.0"
  keep_locally = false
}

resource "docker_container" "mysql" {
  image = docker_image.mysql.image_id
  name  = "mysql"
  ports {
    internal = 3306
    external = 3306
  }
  env = [
    "MYSQL_DATABASE=users_db",
    "MYSQL_USER=admin",
    "MYSQL_PASSWORD=password",
    "MYSQL_ROOT_PASSWORD=password"
  ]
  volumes {
    host_path      = "${abspath(path.module)}/mysql_data"
    container_path = "/var/lib/mysql"
  }
  restart = "unless-stopped"
  networks_advanced {
    name = docker_network.app_network.name
    aliases = ["mysql"]
  }
  healthcheck {
    test         = ["CMD", "mysqladmin", "ping", "-h", "localhost", "-uadmin", "-ppassword"]
    interval     = "10s"
    timeout      = "5s"
    retries      = 5
    start_period = "30s"
  }
}

# API Node.js
resource "docker_image" "api_nodejs" {
  name         = "hugogoncalves06/ci_cd_nodejs_api_ynov:latest"
  keep_locally = false
}

resource "docker_container" "api_nodejs" {
  image = docker_image.api_nodejs.image_id
  name  = "api-nodejs"
  ports {
    internal = 8080
    external = 8080
  }
  env = [
    "NODE_ENV=development",
    "PORT=8080",
    "MONGODB_URI=mongodb://mongo:27017/blog-api",
    "JWT_SECRET=your-super-secret-jwt-key-change-in-production",
    "JWT_EXPIRES_IN=24h",
    "RATE_LIMIT_WINDOW_MS=900000",
    "RATE_LIMIT_MAX_REQUESTS=100"
  ]
  depends_on = [docker_container.mongo]
  networks_advanced {
    name = docker_network.app_network.name
  }
}

# API Python
resource "docker_image" "api_python" {
  name         = "hugogoncalves06/ci_cd_backend_flask_ynov:latest"
  keep_locally = false
}

resource "docker_container" "api_python" {
  image = docker_image.api_python.image_id
  name  = "api-python"
  ports {
    internal = 8000
    external = 8000
  }
  env = [
    "MYSQL_HOST=mysql",
    "MYSQL_USER=admin",
    "MYSQL_PASSWORD=password",
    "MYSQL_DATABASE=users_db",
    "FLASK_ENV=development"
  ]
  depends_on = [docker_container.mysql,docker_container.mongo]
  networks_advanced {
    name = docker_network.app_network.name
  }
  command = [
    "sh", "-c",
    "until mysqladmin ping -h$MYSQL_HOST -u$MYSQL_USER -p$MYSQL_PASSWORD --silent; do echo waiting for mysql; sleep 2; done; python hello.py"
  ]
  healthcheck {
    test         = ["CMD", "curl", "-f", "http://localhost:8000/health"]
    interval     = "10s"
    timeout      = "5s"
    retries      = 5
    start_period = "30s"
  }
}

# Frontend React
resource "docker_image" "frontend" {
  name         = "hugogoncalves06/ci_cd_frontend_react_ynov:latest"
  keep_locally = false
}

resource "docker_container" "frontend" {
  image = docker_image.frontend.image_id
  name  = "frontend"
  ports {
    internal = 3000
    external = 3000
  }
  env = [
    "REACT_APP_PYTHON_API=http://localhost:8000",
    "MYSQL_HOST=mysql",
    "MYSQL_DATABASE=users_db",
    "MYSQL_USER=admin"
  ]
  depends_on = [docker_container.api_python]
  networks_advanced {
    name = docker_network.app_network.name
  }
} 