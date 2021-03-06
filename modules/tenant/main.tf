terraform {
  required_version = ">= 0.15.5, <= 1.2.3"
}

# Setup Cognito Application UserPool + Invitation Email
resource "aws_cognito_user_pool" "pool" {
  name = "${var.stage}-SharedTenantPool"

  admin_create_user_config {
    allow_admin_create_user_only = true
    invite_message_template {
      email_subject = "Your temporary password for DevPie"
      email_message = <<EOF
      <b>Welcome to DevPie</b> <br>
      <br>
      You can log into the app <a href="https://${var.hostname}/manage/projects">here</a>.
      <br>
      Your username is: <b>{username}</b>
      <br>
      Your temporary password is: <b>{####}</b>
      <br>
EOF
      sms_message = "Username: {username}. Password: {####}"
    }
  }

  schema {
    attribute_data_type = "String"
    name                = "tenant-id"
    mutable             = false
  }

  schema {
    attribute_data_type = "String"
    name                = "company-name"
    mutable             = false
  }

  schema {
    attribute_data_type = "String"
    name                = "account-owner"
    mutable             = false
  }

  schema {
    attribute_data_type = "String"
    name                = "email"
    mutable             = true
  }

  schema {
    attribute_data_type = "String"
    name                = "full-name"
    mutable             = true
  }
}

# Setup Cognito UserPoolClient
resource "aws_cognito_user_pool_client" "client" {
  name = "${var.stage}-SharedTenantPoolClient"

  user_pool_id = aws_cognito_user_pool.pool.id

  generate_secret     = false
  explicit_auth_flows = ["ALLOW_ADMIN_USER_PASSWORD_AUTH", "ALLOW_CUSTOM_AUTH", "ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows = ["code", "implicit"]
  allowed_oauth_scopes = ["email", "openid", "phone", "profile"]
  callback_urls = ["https://${var.hostname}/auth-challenge"]
  prevent_user_existence_errors = "ENABLED"
}
