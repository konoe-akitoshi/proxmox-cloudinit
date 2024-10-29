# VM Templateをセットアップするスクリプト
# wget https://raw.githubusercontent.com/csenet/proxmox-cloudinit/refs/heads/main/setup-template.sh
# ./setup.sh <VM_ID> <UBUNTU_CODE_NAME>

# Check arguments
if [ $# -ne 3 ]; then
  echo "Invalid number of arguments"
  echo "Usage: ./setup.sh <VM_ID> <UBUNTU_CODE_NAME> <MEMORY_SIZE>"
  echo "Example: ./setup.sh 9000 noble 4096"
  exit 1
fi

VM_ID=$1 # QEMU VM ID
UBUNTU_CODE_NAME=$2 # Ubuntu Code Name
MEMORY_SIZE=$3 # Memory Size

apt-get install cloud-init
# download the latest Ubuntu Cloud Image
wget https://cloud-images.ubuntu.com/${UBUNTU_CODE_NAME}/current/${UBUNTU_CODE_NAME}-server-cloudimg-amd64.img
exit 0
# create a new VM with VirtIO SCSI controller
qm create ${VM_ID} --memory ${MEMORY_SIZE} --net0 virtio,bridge=vmbr0 --scsihw virtio-scsi-pci
# import the downloaded disk to the local-lvm storage, attaching it as a SCSI drive
qm set ${VM_ID} --scsi0 local-lvm:0,import-from=/root/${UBUNTU_CODE_NAME}-server-cloudimg-amd64.img
# Add Cluod init CD-ROM
qm set ${VM_ID} --ide2 local-lvm:cloudinit
# Set boot order
qm set ${VM_ID} --boot order=scsi0
# add serial
qm set ${VM_ID} --serial0 socket --vga serial0
# convert to template
qm template ${VM_ID}