#!/usr/bin/fish

cd ~/Documents/windows11/

echo "Memulai podman-compose..."
podman-compose up -d

echo "Menunggu Windows siap..."

set log_file (mktemp)

podman-compose logs -f > $log_file &
set log_pid $last_pid

while true
    if grep -q "Windows started successfully" $log_file
        echo "Sistem terdeteksi siap!"
        # Matikan proses logs agar tidak 'stuck'
        kill $log_pid
        break
    end
    sleep 2 
end

rm $log_file

echo "Membuka RDP..."
sdl-freerdp3 /v:127.0.0.1 /u:aris /p:aris123 /cert:ignore /f /network:lan /gfx:avc444 /rfx /compression /video /drive:shared,/shared /scale:140