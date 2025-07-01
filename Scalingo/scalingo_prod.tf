terraform {
  required_providers {
    scalingo = {
      source  = "Scalingo/scalingo"
      version = "~> 1.0"
    }
  }
}

provider "scalingo" {
  api_token = var.scalingo_api_token
}

# API Node.js
resource "scalingo_app" "api_nodejs" {
  name   = "api-nodejs-prod"
  region = "osc-fr1"
}

resource "scalingo_mongodb_addon" "mongo" {
  app_id = scalingo_app.api_nodejs.id
  plan   = "business"
}

resource "scalingo_environment_variable" "api_nodejs_env_mongo" {
  app_id = scalingo_app.api_nodejs.id
  name   = "MONGODB_URI"
  value  = scalingo_mongodb_addon.mongo.uri
}
resource "scalingo_environment_variable" "api_nodejs_env_jwt" {
  app_id = scalingo_app.api_nodejs.id
  name   = "JWT_SECRET"
  value  = var.jwt_secret
}
resource "scalingo_environment_variable" "api_nodejs_env_port" {
  app_id = scalingo_app.api_nodejs.id
  name   = "PORT"
  value  = "8080"
}

# API Python
resource "scalingo_app" "api_python" {
  name   = "api-python-prod"
  region = "osc-fr1"
}

resource "scalingo_mysql_addon" "mysql" {
  app_id = scalingo_app.api_python.id
  plan   = "business"
}
resource "scalingo_environment_variable" "api_python_env_mysql" {
  app_id = scalingo_app.api_python.id
  name   = "MYSQL_URL"
  value  = scalingo_mysql_addon.mysql.uri
}
resource "scalingo_environment_variable" "api_python_env_flask" {
  app_id = scalingo_app.api_python.id
  name   = "FLASK_ENV"
  value  = "production"
}

# Frontend React
resource "scalingo_app" "frontend" {
  name   = "frontend-prod"
  region = "osc-fr1"
}
resource "scalingo_environment_variable" "frontend_env_api" {
  app_id = scalingo_app.frontend.id
  name   = "REACT_APP_PYTHON_API"
  value  = "https://${scalingo_app.api_python.default_url}"
}

variable "scalingo_api_token" {
  description = "API token for Scalingo"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT secret for Node.js API"
  type        = string
  sensitive   = true
} 