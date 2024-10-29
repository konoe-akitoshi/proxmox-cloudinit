# VM TemplateからVMを作成するスクリプト
# ./deploy.sh <VM_ID> <VM_NAME> <GITHUB_ACCOUNT> <PASSWORD> <NETWORK> <VLAN_TAG>

TEMPLATE_VM_ID=$1
VM_ID=$1
VM_NAME=$2
GITHUB_ACCOUNT=$3
PASSWORD=$4
NETWORK=$5
VLAN_TAG=$6


# Check arguments and show usage
if [ $# -lt 5 ]; then
  echo "Invalid number of arguments"
  echo "Usage: ./deploy.sh <TEMPLATE_VM_ID> <VM_ID> <VM_NAME> <GITHUB_ACCOUNT> <PASSWORD> <NETWORK> (<VLAN_TAG>)"
  echo "Example: ./deploy.sh 9000 100 test csenet password123 ip=192.168.200.10/24,gw=192.168.200.1 200"
  exit 1
fi

apply_ssh_keys() {
  # Get the public key from GitHub
  wget https://github.com/${GITHUB_ACCOUNT}.keys
  # Ensure the file exists
  if [ ! -f ./${GITHUB_ACCOUNT}.keys ]; then
    echo "Failed to download the public key from GitHub"
    exit 1
  fi
  # Apply each key to VM
  qm set ${VM_ID} --sshkey ./${GITHUB_ACCOUNT}.keys
}

# Create a new VM from the template
qm clone ${TEMPLATE_VM_ID} ${VM_ID} --name ${VM_NAME} --full true

# Set password
qm set ${VM_ID} --cipassword ${PASSWORD}

# Set network
qm set ${VM_ID} --ipconfig0 ip=${NETWORK}

# add vlan tag if VLAN_TAG is set
if [ -n "$VLAN_TAG" ]; then
  qm set ${VM_ID} --net0 virtio,bridge=vmbr0,tag=${VLAN_TAG}
fi
