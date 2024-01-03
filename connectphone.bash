#!/bin/bash

#echo "Enter the IP address of the phone: "
#read ip_address
adb devices
adb tcpip 5555

pass="Kseb@150847"
#!/bin/bash

# Check if arp-scan is installed
if ! [ -x "$(command -v arp-scan)" ]; then
  echo 'Error: arp-scan is not installed. Installing now...' >&2
echo $pass|  brew install arp-scan
fi

# Scan the local network with arp-scan and find the IP address of the device with MAC address 22:d0:46:f7:88:68
ip_address=$(echo $pass |sudo -S arp-scan --localnet | grep "Xiaomi Communications" | awk '{print $1}')
sudo -S arp-scan --localnet
echo $ip_address;
# exit;
# Check if an IP address was found
if [ -z "$ip_address" ]; then
  echo "Error: Device not found on network."
  echo "enter ip"

  read ip_address;
# else


  
 fi




# echo $ip_address
adb connect $ip_address:5555
echo "wait"


adb devices;
device_status=$(adb devices | grep 'device' | awk '{print $1}')

#  echo $device_status;
#   exit;

if [ "$device_status" == "List cde43bc9" ]; then
  echo "Phone connected using Wi-Fi for debugging."
else
  echo "Error connecting the phone using Wi-Fi. Please try again."
fi

