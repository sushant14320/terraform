terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 3.80, <= 4.28.0"
    }
      azapi = {
    source = "azure/azapi"
    version = "~>1.5"
  }

  }



}

provider "azurerm" {
  features {
    
  }
}

resource "azurerm_resource_group" "testrg" {
  name     = "TestRg"
  location = "East US"
}


resource "azurerm_virtual_network" "testvnet" {
  name                = var.vnetname
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.testrg.location
  resource_group_name = azurerm_resource_group.testrg.name
}

resource "azurerm_subnet" "testsubnet" {
  name                 = "testsubnet"
  resource_group_name  = azurerm_resource_group.testrg.name
  virtual_network_name = azurerm_virtual_network.testvnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "testnic" {
  name                = "nic"
  location            = azurerm_resource_group.testrg.location
  resource_group_name = azurerm_resource_group.testrg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.testsubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "testvm" {
  name                = var.vmname
  resource_group_name = azurerm_resource_group.testrg.name
  location            = azurerm_resource_group.testrg.location
  size                = "Standard_B1s"
  admin_username      = "newusr"
  network_interface_ids = [
    azurerm_network_interface.testnic.id,
  ]



  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

resource "azurerm_storage_account" "main_storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.testrg.name
  location                 = azurerm_resource_group.testrg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}