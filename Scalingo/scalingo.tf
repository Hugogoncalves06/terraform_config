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
  name   = "api-nodejs-ynov"
  region = "osc-fr1"
}

resource "scalingo_mongodb_addon" "mongo" {
  app_id = scalingo_app.api_nodejs.id
  plan   = "starter"
}

resource "scalingo_environment_variable" "api_nodejs_env" {
  app_id = scalingo_app.api_nodejs.id
  name   = "MONGODB_URI"
  value  = scalingo_mongodb_addon.mongo.uri
}

# API Python
resource "scalingo_app" "api_python" {
  name   = "api-python-ynov"
  region = "osc-fr1"
}

resource "scalingo_mysql_addon" "mysql" {
  app_id = scalingo_app.api_python.id
  plan   = "starter"
}

resource "scalingo_environment_variable" "api_python_env" {
  app_id = scalingo_app.api_python.id
  name   = "MYSQL_URL"
  value  = scalingo_mysql_addon.mysql.uri
} 