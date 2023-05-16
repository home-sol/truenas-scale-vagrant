variable "disk_size" {
  type    = string
  default = 16 * 1024
}

variable "iso_url" {
  type    = string
  default = "https://download.truenas.com/TrueNAS-SCALE-Bluefin/22.12.2/TrueNAS-SCALE-22.12.2.iso"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:73a86e1ea163d5cd70dd2133b70fdea47ed7bba1a39c8d489110c8d8949562cf"
}

variable "vm_name" {
  type = string
}

locals {
  boot_steps = [
    ["<enter>", "select Start TrueNAS Scale Installation"],
    ["<wait1m>", "wait for the boot to finish"],
    ["<enter><wait3s>", "select 1 Install/Upgrade"],
    ["<tab><enter><wait3s>", "ignore insufficient RAM error"],
    [" <enter><wait3s>", "choose destination media"],
    ["<enter><wait3s>", "proceed with the installation"],
    ["2<enter><wait3s>", "select 2 Root user (not recommended)"],
    ["root<tab><wait3s>", "set the password"],
    ["root<enter><wait3s>", "confirm the password"],
    ["<wait5m>", "wait for the installation to finish"],
    ["<enter><wait3s>", "accept the installation finished prompt"],
    ["3<enter>", "select 3 Reboot System"],
    ["<wait5m>", "wait for the reboot to finish"],
    ["6<enter><wait3s>", "select 6 Open TrueNAS CLI Shell"],
    ["service ssh update rootlogin=true<enter><wait3s>", "enable root login"],
    ["service update id_or_name=ssh enable=true<enter><wait3s>", "automatically start the ssh service on boot"],
    ["service start service=ssh<enter><wait3s>q<wait3s>", "start the ssh service"],
    ["exit<enter><wait15s>", "exit the TrueNAS CLI Shell"],
    ["7<enter><wait3s>", "select 7 Open Linux Shell"],
    ["wget http://ftp.us.debian.org/debian/pool/main/l/linux/hyperv-daemons_5.10.178-3_amd64.deb<enter><wait1m>", "download hyperv-daemon package"],
    ["sudo dpkg -i hyperv-daemons_5.10.178-3_amd64.deb<enter><wait15s>", "install hyperv-daemon package"],
    ["exit<enter><wait15s>", "exit the Linux CLI Shell"],
  ]
  boot_command = flatten([for step in local.boot_steps : [step[0]]])
}


source "hyperv-iso" "truenas-scale-amd64" {
  cpus             = 2
  memory           = 2 * 1024
  iso_checksum     = var.iso_checksum
  iso_url          = var.iso_url
  switch_name      = "Default Switch"
  headless         = false
  boot_wait        = "5s"
  boot_command     = local.boot_command
  vm_name          = "truenas-scale-amd64"
  disk_size        = var.disk_size
  ssh_username = "root"
  ssh_password = "root"
  ssh_timeout  = "60m"
  
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
}


build {
  sources = [
    "source.hyperv-iso.truenas-scale-amd64"
  ]

  provisioner "shell" {
    inline = [
      "cat /etc/os-release",
    ]
  }
}