# Proxmox Cloudinit Setup

Proxmox上でCloudinitに対応したUbuntuイメージをセットアップするためのスクリプト

## 使い方

1. ProxmoxのNodeにSSHでログイン(VMではない)して、以下のコマンドを実行する
```bash
sudo apt-get install wget
wget https://raw.githubusercontent.com/csenet/proxmox-cloudinit/refs/heads/main/setup.sh
chmod +x setup.sh
./setup.sh 9000 noble 4096 # QEMU VM ID, Ubuntu CodeName, Memory Size
```
2. VMをデプロイする
```
bash
wget https://raw.githubusercontent.com/csenet/proxmox-cloudinit/refs/heads/main/deploy.sh
chmod +x deploy.sh
./deploy 9000 
```


## UbuntuのバージョンとCodeNameの指定対応

| Ubuntu Version | CodeName |
|:--------------:|:--------:|
| 24.04.1 LTS | noble |
| 22.04.5 LTS | jammy |
| 20.04.6 LTS | focal |
| 18.04.6 LTS | bionic |

## 参考
- https://pve.proxmox.com/wiki/Cloud-Init_Support