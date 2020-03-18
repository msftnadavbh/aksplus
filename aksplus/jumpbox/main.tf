resource "azurerm_public_ip" "jumpbox" {
  count               = var.enabled ? 1 : 0
  name                = "JUMPBOX-${var.suffix}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "jumpbox" {
  count = var.enabled ? 1 : 0

  name                = "JUMPBOX-${var.suffix}-nsg"
  resource_group_name = var.resource_group_name
  location            = var.location

  security_rule {
    name                       = "SSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "jumpbox" {
  count               = var.enabled ? 1 : 0
  name                = "JUMPBOX-${var.suffix}-nic"
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.jumpbox[0].id
  }
}

resource "azurerm_network_interface_security_group_association" "jumpbox" {
  count = var.enabled ? 1 : 0
  network_interface_id      = azurerm_network_interface.jumpbox[0].id
  network_security_group_id = azurerm_network_security_group.jumpbox[0].id
}

resource "azurerm_linux_virtual_machine" "jumpbox" {
  count                           = var.enabled ? 1 : 0
  name                            = "JUMPBOX-${var.suffix}"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_public_key
  }
  disable_password_authentication = true
  network_interface_ids = [
    azurerm_network_interface.jumpbox[0].id,
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  custom_data = base64encode(file("${path.module}/custom_data"))
}
