dependency "subnet" {
  config_path = "../subnet"
}

# Internal
dependency "resource_group" {
  config_path = "../../resource_group"
}

# Common
dependency "application_insights" {
  config_path = "../../../tdeploy/application_insights"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  # source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_app_service?ref=v2.1.18"
  source = "/Users/pasqualedevita/Documents/github/io-infrastructure-modules-new/azurerm_app_service"

  after_hook "check_slots" {
    commands     = ["apply"]
    execute      = ["echo", "Remember to do check also the app_service slots!"]
    run_on_error = true
  }
}

inputs = {
  name                = "tdeploy"
  resource_group_name = dependency.resource_group.outputs.resource_name

  app_service_plan_info = {
    kind             = "Linux"
    sku_tier         = "PremiumV2"
    sku_size         = "P1v2"
    reserved         = true
    per_site_scaling = false
  }

  app_enabled         = true
  client_cert_enabled = false
  https_only          = false

  linux_fx_version = "NODE|10-lts"
  app_command_line = "node /home/site/wwwroot/src/server.js"
  #health_check_path = "/info"
  #health_check_maxpingfailures = 5
  
  application_insights_instrumentation_key = dependency.application_insights.outputs.instrumentation_key

  app_settings = {
    WEBSITE_NODE_DEFAULT_VERSION = "10.14.1"
    WEBSITE_RUN_FROM_PACKAGE     = "1"

    // ENVIRONMENT
    NODE_ENV = "production"

    FETCH_KEEPALIVE_ENABLED = "true"
    // see https://github.com/MicrosoftDocs/azure-docs/issues/29600#issuecomment-607990556
    // and https://docs.microsoft.com/it-it/azure/app-service/app-service-web-nodejs-best-practices-and-troubleshoot-guide#scenarios-and-recommendationstroubleshooting
    // FETCH_KEEPALIVE_SOCKET_ACTIVE_TTL should not exceed 120000 (app service socket timeout)
    FETCH_KEEPALIVE_SOCKET_ACTIVE_TTL = "110000"
    // (FETCH_KEEPALIVE_MAX_SOCKETS * number_of_node_processes) should not exceed 160 (max sockets per VM)
    FETCH_KEEPALIVE_MAX_SOCKETS         = "128"
    FETCH_KEEPALIVE_MAX_FREE_SOCKETS    = "10"
    FETCH_KEEPALIVE_FREE_SOCKET_TIMEOUT = "30000"
    FETCH_KEEPALIVE_TIMEOUT             = "60000"
  }

  app_settings_secrets = {
    key_vault_id = "dummy"
    map = {}
  }

  subnet_id = dependency.subnet.outputs.id
}
