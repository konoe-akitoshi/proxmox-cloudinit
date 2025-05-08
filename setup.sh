# VM Templateをセットアップするスクリプト
# wget https://raw.githubusercontent.com/csenet/proxmox-cloudinit/refs/heads/main/setup-template.sh
# ./setup.sh <VM_ID> <UBUNTU_CODE_NAME>

# Check arguments shoud be 3 or 4
if [ "$#" -ne 3 ] && [ "$#" -ne 4 ]; then
  echo "Invalid number of arguments"
  echo "Usage: ./setup.sh <VM_ID> <UBUNTU_CODE_NAME> <MEMORY_SIZE> [<DISK_POOL>]"
  echo "Example: ./setup.sh 9000 noble 4096"
  exit 1
fi

VM_ID=$1 # QEMU VM ID
UBUNTU_CODE_NAME=$2 # Ubuntu Code Name
MEMORY_SIZE=$3 # Memory Size
DISK_POOL=$4 # Disk Pool optional
if [ -z "$DISK_POOL" ]; then
  DISK_POOL="local-lvm"
fi

# Check if libguestfs-tools is installed
if ! command -v virt-customize &> /dev/null; then
  echo "Error: libguestfs-tools is not installed"
  echo "Please install it first with: apt-get install libguestfs-tools"
  exit 1
fi

# Check if image exists
if [ ! -f /root/${UBUNTU_CODE_NAME}-server-cloudimg-amd64.img ]; then
  echo "Image not found Downloading..."
  # download the latest Ubuntu Cloud Image
  wget https://cloud-images.ubuntu.com/${UBUNTU_CODE_NAME}/current/${UBUNTU_CODE_NAME}-server-cloudimg-amd64.img
fi

# Install qemu-guest-agent in the image
echo "Installing qemu-guest-agent in the image..."
virt-customize -a /root/${UBUNTU_CODE_NAME}-server-cloudimg-amd64.img --install qemu-guest-agent --selinux-relabel

# create a new VM with VirtIO SCSI controller
qm create ${VM_ID} --memory ${MEMORY_SIZE} --net0 virtio,bridge=vmbr0 --scsihw virtio-scsi-pci --cores 2 --sockets 1 --name ubuntu-${UBUNTU_CODE_NAME}-template --machine q35
# import the downloaded disk to the DISK_POOL storage, attaching it as a SCSI drive
qm set ${VM_ID} --scsi0 ${DISK_POOL}:0,discard=on,format=qcow2,import-from=/root/${UBUNTU_CODE_NAME}-server-cloudimg-amd64.img
# Add Cloud init CD-ROM
qm set ${VM_ID} --ide2 ${DISK_POOL}:cloudinit
# Set disk size to 20G
qm resize ${VM_ID} scsi0 20G
# Set boot order
qm set ${VM_ID} --boot order=scsi0
# add serial
qm set ${VM_ID} --serial0 socket --vga serial0
# Set EFI disk
qm set ${VM_ID} --efidisk0 ${DISK_POOL}:1,format=qcow2,efitype=4m,pre-enrolled-keys=1
# convert to template
qm template ${VM_ID}

echo "VM Template is ready"
