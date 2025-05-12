# Proxmox Ubuntu Server Template

## Requirements
- Proxmox server
- [GNU Make](https://www.gnu.org/software/make/)
- [Packer](https://developer.hashicorp.com/packer)
- [tfenv](https://github.com/tfutils/tfenv) (Only required if you want to spin a host using the template created with Packer)

## Preparation
It is required that a file named `.env` containing the Proxmox credentials and URL. The file needs to be structured as follows:
```
PM_API_TOKEN_ID=<user_id>
PM_API_TOKEN_SECRET=<user_token>
PM_API_URL=<proxmox_api_url>
PROXMOX_USERNAME=${PM_API_TOKEN_ID}
PROXMOX_TOKEN=${PM_API_TOKEN_SECRET}
PROXMOX_URL=${PM_API_URL}
```

Replace the variables in angle brackets (`< >`) with your proxmox values.

In [`packer/autoinstall/user-data`](#packer/autoinstall/user-data), the value of `autoinstall>identity>password` and `autoinstall>authorized-keys` (pub key to be imported to the template authorized keys) must be updated before you run the Packer build. For best practices, place the `user-data` file in a vault storage and load it locally during build time.

## Build

To build the Ubuntu Server template in Proxmox, run:
```
    $ make template
```
The `user` created in the VM template is `pve`. Password and authorized key will depend of what is defined in the `autoinstall` file.


To spin up a VM in proxmox running the created template, run: 
```
    $ make apply
```

### TODOs

- Currently Packer doesn't have a way to create files from a template in the local host where the build is being executed. I need to improve the way autoinstall user-data file is generated so that users can pass the [password](packer/autoinstall/user-data#L27) and [ssh public key](packer/autoinstall/user-data#L31) without exposing them.
