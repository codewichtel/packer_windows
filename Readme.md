# Packer Windows 

### Generate an API User in Proxmox
Fill out vars in **providervars.pkr.hcl**

### Get an Windows Server 2022 Iso an Upload it to Proxmox

[Windows 2022 Server ISO]([https://](https://go.microsoft.com/fwlink/p/?LinkID=2195280&clcid=0x409&culture=en-us&country=US))

check the iso file var in **windows-server-2022.pkr.hcl**

### Get some software and drivers
`cd utils`
`chmod +x *`
`./getDrivers.sh` 
`./getSoftware.sh`

### init Packer
`packer init .`


### build Template
`packer build .`
