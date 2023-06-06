mkfs -t xfs /dev/nvme1n1
mount /dev/nvme1n1 /mnt/nvme/
mount -t efs -o tls,accesspoint=fsap-019d4fb45c7a10684 fs-00e889f31f87e4e3b /mnt/efs
rclone sync /mnt/efs /mnt/nvme
chown -R ubuntu:minecraft /mnt/efs
chmod -R 770 /mnt/efs
chown -R ubuntu:minecraft /mnt/nvme
chmod -R 770 /mnt/nvme
sudo -u minecraft bash /home/minecraft/minecraft.sh
while true
do
sleep 500
rclone sync /mnt/nvme /mnt/efs
player_count=$(python3 /home/ubuntu/checkplayers.py)
if [ $player_count -eq 0 ]; then
shutdown -h now
fi
done

