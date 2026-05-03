# Bikin snapshot
function snap --description 'Membuat snapshot btrfs dengan snapper secara interaktif'
    read -P "Masukkan keterangan snapshot: " deskripsi
    if test -z "$deskripsi"
        echo "Error: Deskripsi tidak boleh kosong."
        return 1
    end
    echo "Membuat snapshot untuk config 'root'..."
    sudo snapper -c root create -d "$deskripsi"
    if test $status -eq 0
        echo "Snapshot berhasil dibuat."
    else
        echo "Gagal membuat snapshot."
    end
end

# Melihat list snapshot
function snap-list --description 'Menampilkan daftar snapshot snapper root'
    sudo snapper -c root list
end

# Hapus snapshot yang tidak diperlukan
function snap-del --description 'Menghapus snapshot snapper root berdasarkan nomor'
    if test (count $argv) -eq 0
        echo "Penggunaan: snap-del <nomor_snapshot>"
        return 1
    end
    set -l nomor $argv[1]
    read -P "Apakah Anda yakin ingin menghapus snapshot nomor $nomor? [y/N]: " konfirmasi
    if test "$konfirmasi" = "y" -o "$konfirmasi" = "Y"
        echo "Menghapus snapshot $nomor..."
        sudo snapper -c root delete $nomor
        if test $status -eq 0
            echo "Snapshot $nomor berhasil dihapus."
        else
            echo "Gagal menghapus snapshot $nomor."
        end
    else
        echo "Operasi dibatalkan."
    end
end

# Fix bug cpu throttle
function fixcpu --description 'Fix AMD Ryzen throttling by overriding power limits'
    echo "Mencoba melepaskan limitasi daya CPU..."
    
    # Menjalankan ryzenadj dengan parameter yang sudah kita uji
    sudo ryzenadj --stapm-limit=25000 --fast-limit=25000 --slow-limit=25000
    
    if test $status -eq 0
        echo "Berhasil! Memeriksa frekuensi CPU saat ini..."
        # Menampilkan frekuensi CPU saat ini sekilas
        grep "cpu MHz" /proc/cpuinfo | head -n 4
    else
        echo "Gagal menjalankan ryzenadj. Pastikan password sudo benar."
    end
end

# Buka samba share ke Public dir
function share-on
    sudo systemctl start smb nmb
    if test $status -eq 0
        notify-send 'Samba Server' 'Folder Public Aktif' -i network-server
        echo "Samba started successfully."
    end
end

# Tutup akses samba share
function share-off
    sudo systemctl stop smb nmb
    if test $status -eq 0
        notify-send 'Samba Server' 'Sharing Berhenti' -i network-offline
        echo "Samba stopped successfully."
    end
end

# Bersihkan riwayat clipboard
function clip-wipe --description 'Menghapus semua riwayat clipboard cliphist'
    cliphist wipe && notify-send "Clipboard" "History cleared!"
    if test $status -eq 0
        echo "Clipboard history wiped clean."
    end
end