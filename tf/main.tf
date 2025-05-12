resource "proxmox_vm_qemu" "ubuntu_server_template" {  
  target_node = "pve"
  name        = "ubuntu-2504-server"
  desc        = "Ubuntu Server 25.04"
  vmid        = 500

  clone       = "Ubuntu-Server-2504-Template"
  agent       = 1

  memory      = 4096
  sockets     = 2
  cores       = 2
  cpu_type    = "x86-64-v2-AES"

  bios        = "seabios"
  onboot      = true
  boot        = "order=scsi0;ide2;net0"

  scsihw      = "virtio-scsi-single"

  disks {
    scsi {
      scsi0 { 
        disk { 
          size      = "64G"
          storage   = "local-lvm"
          cache     = "none"
          discard   = true
          iothread  = true
          asyncio   = "io_uring"
        }
      }
    }
    ide {
      ide0 {
        cloudinit {
          storage = "local-lvm"
        }
      }
      ide2 {
        cdrom {
          iso = ""
        }
      }
    }
  }

  network {
    id        = 0
    bridge    = "vmbr1"
    model     = "virtio"
    firewall  = true
  }
}

