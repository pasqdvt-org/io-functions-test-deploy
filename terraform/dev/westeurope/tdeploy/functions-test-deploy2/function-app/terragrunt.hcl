dependency "subnet" {
  config_path = "../subnet"
}

# Internal
dependency "resource_group" {
  config_path = "../../resource_group"
}

dependency "application_insights" {
  config_path = "../../application_insights"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_function_app?ref=v2.1.10"
}

inputs = {
  name                = "tdeploy2"
  resource_group_name = dependency.resource_group.outputs.resource_name

  application_insights_instrumentation_key = dependency.application_insights.outputs.instrumentation_key

  resources_prefix = {
    function_app     = "fn3"
    app_service_plan = "fn3"
    storage_account  = "fn3"
  }

  pre_warmed_instance_count = 0

  runtime_version = "~3"

  app_service_plan_info = {
    kind     = "elastic"
    sku_tier = "ElasticPremium"
    sku_size = "EP1"
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME     = "node"
    WEBSITE_NODE_DEFAULT_VERSION = "10.14.1"
    WEBSITE_RUN_FROM_PACKAGE     = "1"
    NODE_ENV                     = "production"

    SLOT_TASK_HUBNAME = "ProductionTaskHub"
    
    # WEBSITE_SWAP_WARMUP_PING_PATH = "/healthcheck/ok"
    # WEBSITE_SWAP_WARMUP_PING_STATUSES = "200"
  }

  app_settings_secrets = {
    key_vault_id = "dummy"
    map          = {}
  }

  allowed_subnets = [
    dependency.subnet.outputs.id
  ]

  subnet_id       = dependency.subnet.outputs.id
}