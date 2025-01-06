# Windows Server 2022 Packer Template for Proxmox
packer {
  required_plugins {
    proxmox = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
    windows-update = {
      version = "0.16.8"
      source = "github.com/rgl/windows-update"
    }
  }
}

source "proxmox-iso" "windows2022" {
  # Proxmox Host Connection
  proxmox_url               = var.proxmox_api_url
  insecure_skip_tls_verify  = true
  username                  = var.proxmox_api_token_id
  token                     = var.proxmox_api_token_secret
  node                      = "proxmox-01" # Replace with your Proxmox node's actual hostname  
  bios                      = "ovmf"
  machine                   = "q35"

  efi_config {
    efi_storage_pool        = "local-lvm"
    pre_enrolled_keys       = true
  }

  # Windows Server ISO File
  iso_file                  = "local:iso/SERVER_EVAL_x64FRE_en-us.iso"
  unmount_iso               = true


  additional_iso_files {
    device                  = "ide3"                             # Mount as another CD-ROM
    iso_file                = "local:iso/custom_support.iso"     # Path to VirtIO ISO
    unmount                 = true                               # Automatically unmount after build    
  }


  additional_iso_files {
    cd_files                = ["./drivers/*","./scripts/*","./software/qemu-ga-x86_64.msi","./software/virtio-win-gt-x64.msi"]
    cd_label                = "Unattend"
    iso_storage_pool        = "local"
    unmount                 = true
    device                  = "ide3"
  }


  # VM General Settings
  vm_name                   = "win2022-cloudbase-template"
  vm_id                     = 8001
  template_name             = "win2022-cloudbase-template"
  template_description      = "Windows Server 2022 Template"
  memory                    = 4096 
  cores                     = 4    
  cpu_type                  = "host"
  os                        = "win10"
  scsi_controller           = "virtio-scsi-pci"
  qemu_agent                = true

  # Network Configuration
  network_adapters {
    model                   = "virtio"
    bridge                  = "vmbr0" 
    vlan_tag                = 10
  }

  # Disk Configuration
  disks {
    storage_pool            = "local-lvm"
    type                    = "scsi"
    disk_size               = "40G"
    cache_mode              = "writeback"
    format                  = "raw"
  }

  # WinRM Configuration
  communicator              = "winrm"
  winrm_username            = "Administrator"
  winrm_password            = "Password"
  winrm_timeout             = "12h"
  winrm_use_ssl             = false    
  winrm_insecure            = true     

  
  # Boot Settings with click tourette
  boot_wait                 = "2s"
  boot_command              = ["<enter><enter><enter><enter><enter><enter><enter><enter><wait1><enter><enter><enter><enter><enter><enter><enter><enter><enter><enter><enter><enter><wait1><enter><enter><enter><enter><enter><enter><enter><enter><enter><enter>"]
}


build {
  name                      = "Proxmox Windows Server 2022 Build"
  sources                   = ["source.proxmox-iso.windows2022"]


  provisioner "windows-restart" {
  }

  provisioner "powershell" {
    script                  = "./scripts/performSecurityChanges.ps1"    
  }

  provisioner "windows-restart" {
  }

  #provisioner "windows-update" {
  #  search_criteria = "IsInstalled=0"
  #  filters = [
  #    "exclude:$_.Title -like '*Preview*'",
  #    "include:$true",
  #  ]
  #  update_limit = 25
  #}

  provisioner "powershell" {
    script                  = "./scripts/cloudbase.ps1"    
  }

  provisioner "file" {
    source                  = "./scripts/cloudbaseconfig/"
    destination             = "C://Program Files//Cloudbase Solutions//Cloudbase-Init//conf" 
  }

  provisioner "powershell" {
    inline                  = [
                              "Set-Service cloudbase-init -StartupType Manual",
                              "Stop-Service cloudbase-init -Force -Confirm:$false"
                              ]
  }

  provisioner "powershell" {   
    inline                  = [
                              "Set-Location -Path \"C:\\Program Files\\Cloudbase Solutions\\Cloudbase-Init\\conf\"",
                              "C:\\Windows\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /unattend:unattend.xml"
                              ]
  }
}