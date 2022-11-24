# 테라폼 처음 시작시 공급자 설정 & 테라폼 버전 설정
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.32.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

#리소스 그룹 생성
resource "azurerm_resource_group" "rg" {
  location = "Korea Central"
  name     = "RG-sang"
}

#보안 그룹 생성
resource "azurerm_network_security_group" "sg" {
  name                = "example-security-group"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

#가상네트워크 생성
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-sang"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

#서브넷 생성
resource "azurerm_subnet" "sub" {
  name                 = "sang-sub1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# 네트워크 인터페이스 생성
resource "azurerm_network_interface" "nic" {
  name                = "sang-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sub.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "sang-vm1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B2s"
  admin_username      = "sanghwan"
  admin_password      = "Itwork123!@#"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]
  disable_password_authentication = "false"

os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}


ddd