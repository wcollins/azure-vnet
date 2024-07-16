terraform {
  cloud {
    organization = "netdevops"

    workspaces {
      name = "azure-vnet"
    }

  }
}