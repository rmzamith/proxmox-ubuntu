packer {
  required_plugins {
    proxmox-iso = {
      version = "1.2.2"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "proxmox_node" {
  type = string
}

variable "proxmox_iso_storage_pool" {
  type = string
}

variable "proxmox_vm_storage_pool" {
  type = string
}

variable "proxmox_network_adapter_bridge" {
  type    = string
  default = "vmbr1"
}

variable "ssh_private_key_path" {
  type = string
}

source "proxmox-iso" "ubuntu-autoinstall" {
  node                     = "${var.proxmox_node}"
  insecure_skip_tls_verify = true
  boot_command = ["c",
    "linux /casper/vmlinuz --- autoinstall ds='nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/' ",
    "<enter><wait>",
    "initrd /casper/initrd<enter><wait>",
  "boot<enter>"]
  boot_wait               = "10s"
  boot                    = "order=scsi0;ide2;net0"
  http_directory          = "autoinstall"
  scsi_controller         = "virtio-scsi-single"
  sockets                 = 2
  cores                   = 2
  cpu_type                = "x86-64-v2-AES"
  memory                  = 4096
  ballooning_minimum      = 4096
  bios                    = "seabios"
  machine                 = "pc"
  os                      = "l26"
  qemu_agent              = true
  vm_id                   = 100
  vm_name                 = "Ubuntu-Server-2504-Template"
  cloud_init              = true
  cloud_init_storage_pool = "${var.proxmox_vm_storage_pool}"
  cloud_init_disk_type    = "ide"
  ssh_username            = "pve"
  ssh_private_key_file    = "${var.ssh_private_key_path}"
  ssh_timeout             = "120m"

  boot_iso {
    type                 = "ide"
    index                = "2"
    iso_url              = "https://ubuntu.cs.utah.edu/releases/plucky/ubuntu-25.04-live-server-amd64.iso"
    iso_checksum         = "sha256:8b44046211118639c673335a80359f4b3f0d9e52c33fe61c59072b1b61bdecc5"
    iso_target_path      = "test"
    iso_target_extension = "iso"
    unmount              = false
    iso_storage_pool     = "${var.proxmox_iso_storage_pool}"
  }

  disks {
    disk_size    = "64G"
    storage_pool = "${var.proxmox_vm_storage_pool}"
    type         = "scsi"
    io_thread    = true
    asyncio      = "io_uring"
    discard      = true
    cache_mode   = "none"
  }

  network_adapters {
    bridge   = "${var.proxmox_network_adapter_bridge}"
    model    = "virtio"
    firewall = true
  }
}

build {
  sources = ["sources.proxmox-iso.ubuntu-autoinstall"]
  
  provisioner "shell" {
    inline = [
      "sudo rm -f /etc/cloud/cloud-init.disabled",
      "sudo cloud-init clean --logs",
      "sudo rm -f /etc/cloud/cloud.cfg.d/99-installer.cfg",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo rm -f /var/lib/dbus/machine-id"
    ]
  }
}
