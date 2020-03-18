locals {
  sku_name = var.waf_enabled ? "WAF_v2" : "Standard_v2"
  sku_tier = var.waf_enabled ? "WAF_v2" : "Standard_v2"

  gateway_ip_configuration_name  = "${var.name}-gwipconf"
  backend_address_pool_name      = "${var.name}-beap"
  frontend_port_name             = "${var.name}-feport"
  frontend_ip_configuration_name = "${var.name}-feip"
  http_setting_name              = "${var.name}-be-htst"
  listener_name                  = "${var.name}-httplstn"
  request_routing_rule_name      = "${var.name}-rqrt"

  logs    = ["ApplicationGatewayAccessLog", "ApplicationGatewayPerformanceLog", "ApplicationGatewayFirewallLog"]
  metrics = ["AllMetrics"]
}

resource "azurerm_public_ip" "appgw" {
  count               = var.enabled ? 1 : 0
  name                = "${var.name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Application Gateway
resource "azurerm_application_gateway" "appgw" {
  count               = var.enabled ? 1 : 0
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  enable_http2        = true
  zones               = var.zones

  sku {
    name = local.sku_name
    tier = local.sku_tier
  }

  autoscale_configuration {
    min_capacity = var.capacity.min
    max_capacity = var.capacity.max
  }

  gateway_ip_configuration {
    name      = local.gateway_ip_configuration_name
    subnet_id = var.subnet_id
  }

  frontend_ip_configuration {
    name                 = "${local.frontend_ip_configuration_name}-public"
    public_ip_address_id = azurerm_public_ip.appgw[0].id
  }

  dynamic "frontend_ip_configuration" {
    for_each = var.private_ip_address != "" ? list(1) : []
    content {
      name                          = "${local.frontend_ip_configuration_name}-private"
      private_ip_address_allocation = "Static"
      private_ip_address            = var.private_ip_address
      subnet_id                     = var.subnet_id
    }
  }

  frontend_port {
    name = "${local.frontend_port_name}-80"
    port = 80
  }

  frontend_port {
    name = "${local.frontend_port_name}-443"
    port = 443
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
    cookie_based_affinity = "Disabled"
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = "${local.frontend_ip_configuration_name}-public"
    frontend_port_name             = "${local.frontend_port_name}-80"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  ssl_policy {
    policy_type = "Predefined"
    policy_name = var.ssl_policy_name
  }

  dynamic "waf_configuration" {
    for_each = var.waf_enabled ? list(1) : []
    content {
      enabled                  = var.waf_enabled
      firewall_mode            = var.waf_configuration != null ? var.waf_configuration.firewall_mode : "Prevention"
      rule_set_type            = var.waf_configuration != null ? var.waf_configuration.rule_set_type : "OWASP"
      rule_set_version         = var.waf_configuration != null ? var.waf_configuration.rule_set_version : "3.0"
      file_upload_limit_mb     = var.waf_configuration != null ? var.waf_configuration.file_upload_limit_mb : 100
      max_request_body_size_kb = var.waf_configuration != null ? var.waf_configuration.max_request_body_size_kb : 128
    }
  }

  dynamic "custom_error_configuration" {
    for_each = var.custom_error
    iterator = ce
    content {
      status_code           = ce.value.status_code
      custom_error_page_url = ce.value.error_page_url
    }
  }

  // Ignore most changes as they should be managed by AKS ingress controller
  lifecycle {
    ignore_changes = [
      backend_address_pool,
      backend_http_settings,
      frontend_port,
      http_listener,
      probe,
      request_routing_rule,
      url_path_map,
      ssl_certificate,
      redirect_configuration,
      autoscale_configuration,
    ]
  }
}

resource "azurerm_web_application_firewall_policy" "appgw" {
  count               = var.enabled && length(var.custom_policies) > 0 ? 1 : 0
  name                = format("%swafpolicy", lower(replace(var.name, "/[[:^alnum:]]/", "")))
  resource_group_name = var.resource_group_name
  location            = var.location

  dynamic "custom_rules" {
    for_each = var.custom_policies
    iterator = cp
    content {
      name      = cp.value.name
      priority  = (cp.key + 1) * 10
      rule_type = cp.value.rule_type
      action    = cp.value.action

      dynamic "match_conditions" {
        for_each = cp.value.match_conditions
        iterator = mc
        content {
          dynamic "match_variables" {
            for_each = mc.value.match_variables
            iterator = mv
            content {
              variable_name = mv.value.match_variable
              selector      = mv.value.selector
            }
          }
          operator           = mc.value.operator
          negation_condition = mc.value.negation_condition
          match_values       = mc.value.match_values
        }
      }
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "diag" {
  count                      = var.enabled && var.enable_diagnostic ? 1 : 0
  name                       = "${azurerm_application_gateway.appgw[0].name}-diag"
  target_resource_id         = azurerm_application_gateway.appgw[0].id
  log_analytics_workspace_id = var.log_analytics_id

  dynamic "log" {
    for_each = local.logs
    content {
      category = log.value
      enabled  = true
      retention_policy {
        enabled = true
        days    = 30
      }
    }
  }
  dynamic "metric" {
    for_each = local.metrics
    content {
      category = metric.value
      enabled  = true
      retention_policy {
        enabled = true
        days    = 30
      }
    }
  }
}
