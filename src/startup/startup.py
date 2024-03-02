import subprocess
from enum import Enum
import socket
import sys
import re
import subprocess

class DevicetoMAC(Enum):
    LOPHO = "dc:a6:32:3a:21:5a"
    SPECTRE = "00:28:f8:04:e2:fa"
    GALAXY = "48:eb:62:6d:2d:6e"
    IPAD = "b8:e6:0c:c2:73:bf"
    # Add more DEVICE to MAC mappings as needed

    def mac_to_device(mac):
        for item in DevicetoMAC:
            if item.value == mac: return item.name
        return "UNKNOWN"
    
def get_arp_scan_results():
    arp_scan_results = subprocess.run(['arp-scan', '--local'], stdout=subprocess.PIPE)
    arp_scan_output = arp_scan_results.stdout.decode('utf-8').split('\n')
    local_ip = get_local_ip_address()
    local_mac = get_wireless_mac()
    results = {'UNKNOWN':[]}
    device = DevicetoMAC.mac_to_device(local_mac)
    if device != 'UNKNOWN':
        results[device] = local_ip
    else:
        results[device].append(local_ip)
        
    for line in arp_scan_output[2:]:
        values = line.strip().split()
        if len(values) >= 2:
            ip, mac = values[0], values[1]            
            device = DevicetoMAC.mac_to_device(mac)
            if device != 'UNKNOWN':
                results[device] = ip
            else:
                results[device].append(ip)
        else:
            # Handle other cases as necessary
            pass
    return results

def get_wireless_mac():
    ifconfig_output = subprocess.check_output(["ifconfig"]).decode("utf-8")
    skip_lines = True
    for line in ifconfig_output.split("\n"):
        if "wlp1s0" in line or 'wlan' in line:
            skip_lines = False
        if skip_lines:
            continue
        match = re.search(r"\w\w:\w\w:\w\w:\w\w:\w\w:\w\w", line)
        if match:
            return match.group(0)
    return None


def get_local_ip_address():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect(("8.8.8.8", 80))
    local_ip = s.getsockname()[0]
    s.close()
    return local_ip

if __name__=='__main__':
    system_ips = dict()
    remaining_devices = set({DevicetoMAC.LOPHO.name, DevicetoMAC.GALAXY.name, DevicetoMAC.SPECTRE.name})
    while True:
        scan_ips = get_arp_scan_results()
        if DevicetoMAC.LOPHO.name in remaining_devices and DevicetoMAC.LOPHO.name in scan_ips:
            system_ips[DevicetoMAC.LOPHO.name] = scan_ips[DevicetoMAC.LOPHO.name]
            remaining_devices.remove(DevicetoMAC.LOPHO.name)
        if DevicetoMAC.GALAXY.name in remaining_devices and DevicetoMAC.GALAXY.name in scan_ips:
            system_ips[DevicetoMAC.GALAXY.name] = scan_ips[DevicetoMAC.GALAXY.name]
            remaining_devices.remove(DevicetoMAC.GALAXY.name)
        if DevicetoMAC.SPECTRE.name in remaining_devices and DevicetoMAC.SPECTRE.name in scan_ips:
            system_ips[DevicetoMAC.SPECTRE.name] = scan_ips[DevicetoMAC.SPECTRE.name]
            remaining_devices.remove(DevicetoMAC.SPECTRE.name)
        if len(remaining_devices) == 0:
            print(f"All IPs acquired: {system_ips}")
            break

    # Open a new terminal emulator and run mavproxy
    if socket.gethostname() == 'raspberrypi':
        mavproxy_command = f'mavproxy.py --master=/dev/serial0 --baudrate 921600 --aircraft MyCopter '
    else:
        print(f'Please run mavproxy in Raspberry Pi not in {socket.gethostname()}')
        sys.exit(1)

    out1 = f'--out udp:{system_ips[DevicetoMAC.SPECTRE.name]}:14550 '
    out2 = f'--out udp:{system_ips[DevicetoMAC.GALAXY.name]}:14550 '
    out3 = f'--out udp:127.0.0.1:14550'

    command = mavproxy_command + out1 + out2 + out3
    subprocess.Popen(["x-terminal-emulator", "-e", f"bash -c '{command}; bash'"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    print("done")


# mavproxy.py --master=/dev/serial0 --baudrate 921600 --aircraft MyCopter --out udp:10.0.0.114:14550 --out udp:10.0.0.5:14550 --out udp:127.0.0.1:14550  