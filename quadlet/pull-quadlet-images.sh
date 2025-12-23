#!/bin/bash

# Folder tempat file quadlet disimpan
QUADLET_DIR="/opt/genieacs-project/quadlet"

echo "--- Memulai proses pre-pull image dari folder Quadlet ---"

# Mencari baris Image= di semua file .container dalam folder quadlet
images=$(grep -h "^Image=" $QUADLET_DIR/*.container | cut -d'=' -f2)

if [ -z "$images" ]; then
    echo "Tidak ditemukan definisi image dalam folder $QUADLET_DIR"
    exit 1
fi

for img in $images; do
    echo "Sedang menarik image: $img ..."
    sudo podman pull $img
    
    if [ $? -eq 0 ]; then
        echo "Berhasil menarik $img"
    else
        echo "Gagal menarik $img. Cek koneksi internet Anda."
    fi
    echo "-----------------------------------------------"
done

echo "Proses selesai. Sekarang menjalankan ulang systemd..."
sudo systemctl daemon-reload
sudo systemctl start genieacs-ui.service

echo "Status layanan:"
sudo systemctl status genieacs-ui.service --no-pager
