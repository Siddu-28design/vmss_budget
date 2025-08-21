data "azurerm_subscription" "current" {}


data "azurerm_resource_group" "vmss_rg" {
  name = "Siddu-VMSS-Demo"
}


resource "azurerm_virtual_network" "vmss_vnet" {
  name                = "vmss-siddu-vnet"
  address_space       = ["10.18.0.0/16"]
  location            = data.azurerm_resource_group.vmss_rg.location
  resource_group_name = data.azurerm_resource_group.vmss_rg.name
}


resource "azurerm_subnet" "vmss_subnet" {
  name                 = "vmss-siddu-subnet"
  resource_group_name  = data.azurerm_resource_group.vmss_rg.name
  virtual_network_name = azurerm_virtual_network.vmss_vnet.name
  address_prefixes     = ["10.18.1.0/24"]
}

resource "azurerm_public_ip" "vmss_public_ip" {
  name                = "vmss-siddu-public-ip"
  location            = data.azurerm_resource_group.vmss_rg.location
  resource_group_name = data.azurerm_resource_group.vmss_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "vmss_lb" {
  name                = "vmss-siddu-lb"
  location            = data.azurerm_resource_group.vmss_rg.location
  resource_group_name = data.azurerm_resource_group.vmss_rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.vmss_public_ip.id
  }
}


resource "azurerm_lb_backend_address_pool" "vmss_bap" {
  loadbalancer_id = azurerm_lb.vmss_lb.id
  name            = "VmBackendpool"
}

resource "azurerm_windows_virtual_machine_scale_set" "vmss" {
  name                = "siddu-new-vmss"
  computer_name_prefix = "winvmss" 
  resource_group_name = data.azurerm_resource_group.vmss_rg.name
  location            = data.azurerm_resource_group.vmss_rg.location
  sku                 = "Standard_B2s"
  instances           = 2
  admin_username      = "Siddu"
  admin_password      = "SidduNovember@1197"

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  network_interface {
    name    = "vmss-siddu-nic"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.vmss_subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.vmss_bap.id]
    }
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  upgrade_mode = "Manual"
}

resource "azurerm_consumption_budget_resource_group" "vmss_budget" {
  name              = "vmss-budget-alert"
  resource_group_id = data.azurerm_resource_group.vmss_rg.id
  amount            = 1 
  time_grain        = "Monthly"

  time_period {
    start_date = "2025-08-01T00:00:00Z"
    end_date   = "2026-08-01T00:00:00Z"
  }

  notification {
    enabled   = true
    threshold = 80
    operator  = "GreaterThan"

    contact_emails = [
      "siddusteli08353@gmail.com"
    ]
  }
}
