terraform {
   backend "azurerm" {
     resource_group_name  = "storage_acc"
     storage_account_name = "filestate"
     container_name       = "dev"
     key                  = "terraform.tfstate"
   }
}