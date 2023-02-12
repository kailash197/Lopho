sudo setcap cap_net_raw=ep $(readlink -f /usr/bin/python3)
/usr/bin/python3 /home/pi/Lopho/startup/startup.py >> /home/pi/Lopho/startup/startup.log 2>&1