#!/bin/bash

#echo "Enter the IP address of the phone: "
#read ip_address
adb devices
adb tcpip 5555

pass="Kseb@1234"
#!/bin/bash

# Check if arp-scan is installed
if ! [ -x "$(command -v arp-scan)" ]; then
  echo 'Error: arp-scan is not installed. Installing now...' >&2
echo $pass|  sudo -S apt-get install arp-scan
fi

# Scan the local network with arp-scan and find the IP address of the device with MAC address 22:d0:46:f7:88:68
ip_address=$(echo $pass |sudo -S arp-scan --localnet | grep "22:d0:46:f7:88:68" | awk '{print $1}')

# Check if an IP address was found
if [ -z "$ip_address" ]; then
  echo "Error: Device not found on network."
else
  echo "IP address of device with MAC address 22:d0:46:f7:88:68 is: $ip_address"
fi

ip_address=192.168.1.199
adb connect $ip_address:5555

device_status=$(adb devices | grep $ip_address | awk '{print $2}')

if [ "$device_status" == "device" ]; then
  echo "Phone connected using Wi-Fi for debugging."
else
  echo "Error connecting the phone using Wi-Fi. Please try again."
fi

