# VM Templateをセットアップするスクリプト
# wget https://raw.githubusercontent.com/csenet/proxmox-cloudinit/setup-template.sh
# ./setup-template.sh <VM_ID> <UBUNTU_CODE_NAME>

VM_ID=$1 # VM ID
UBUNTU_CODE_NAME=$2

apt-get install cloud-init
# イメージをダウンロード
wget https://cloud-images.ubuntu.com/${UBUNTU_CODE_NAME}/current/${UBUNTU_CODE_NAME}-server-cloudimg-amd64.img
exit 0
# create a new VM with VirtIO SCSI controller
qm create ${VM_ID} --memory 4096 --net0 virtio,bridge=vmbr0 --scsihw virtio-scsi-pci
# import the downloaded disk to the local-lvm storage, attaching it as a SCSI drive
qm set ${VM_ID} --scsi0 local-lvm:0,import-from=/root/${UBUNTU_CODE_NAME}-server-cloudimg-amd64.img
# Add Cluod init CD-ROM
qm set ${VM_ID} --ide2 local-lvm:cloudinit
# Set boot order
qm set ${VM_ID} --boot order=scsi0
# add serial
qm set ${VM_ID} --serial0 socket --vga serial0
qm template ${VM_ID}