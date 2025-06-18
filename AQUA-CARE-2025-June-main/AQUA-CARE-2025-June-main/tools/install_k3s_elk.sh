#!/bin/bash
# filepath: scripts/install_k3s_auto.sh

set -e

# Update package list
sudo apt update
sleep 1

# Ensure Python venv module is installed
sudo apt install -y python3.12-venv
sleep 1

# Create Python virtual environment if not exists
if [ ! -d ".venv" ]; then
  python3 -m venv .venv
  sleep 1
fi

# 啟用虛擬環境
source .venv/bin/activate
sleep 1

# 升級 pip 並安裝 Ansible 及相關套件
pip install --upgrade pip
sleep 1
pip install ansible requests joblib tqdm
sleep 1

echo "Virtual environment and Ansible are ready."
sleep 1

# 1. 複製專案
cd AQUA-CARE-2025-June || { echo "找不到目錄"; exit 1; }
sleep 1

# 5. 執行 Ansible Playbook 安裝 k3s
echo "執行 Ansible Playbook 安裝 k3s..."
ansible-playbook -i ansible/inventories/hosts.ini ansible/playbooks/install_k3s.yaml
sleep 1

# 6. 重新載入 bash 設定
echo "重新載入 bash 設定..."
source ~/.bashrc
sleep 1

# 7. 顯示所有命名空間的 Pod 狀態
echo "查詢所有命名空間的 Pod 狀態..."
kubectl get po -A
sleep 1

echo "k3s 自動化安裝完成！"
sleep 1

# 8. 進入 elk 目錄並安裝 ELK 相關服務
cd "$(dirname "$0")/../elk" || { echo "找不到 elk 目錄"; exit 1; }
sleep 1

echo "使用 Helm 安裝 elasticsearch..."
helm install elasticsearch elastic/elasticsearch -f elasticsearch/values.yml
sleep 1

echo "使用 Helm 安裝 filebeat..."
helm install filebeat elastic/filebeat -f filebeat/values.yml
sleep 1

echo "使用 Helm 安裝 logstash..."
helm install logstash elastic/logstash -f logstash/values.yml
sleep 1

echo "使用 Helm 安裝 kibana..."
helm install kibana elastic/kibana -f kibana/values.yml
sleep 1

echo "ELK 服務安裝完成！"
sleep 1