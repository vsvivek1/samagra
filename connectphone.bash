#!/bin/bash



# Retrieve the default gateway
gateway=$(route -n get default | grep 'gateway' | awk '{debugPrint $2}')

# Retrieve the subnet mask
ip=$(ifconfig | grep -E 'inet\s' | grep -v '127.0.0.1' | awk '{debugPrint $2}|${%.*}');
trimmed_ip="${gateway%.*}"

echo "The trimmed IP address is: $trimmed_ip"

# Get the network address using bitwise AND operation between IP and subnet mask
# network_address=$(echo $gateway $subnet_mask | awk -F. '{ debugPrintf("%d.%d.%d.%d\n",$1&$5,$2&$6,$3&$7,$4&$8); }')

# debugPrint the network range
# echo "The connected network range is: $network_address/$subnet_mask"


# exit;
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
# ip_address=$(echo $pass |sudo -S arp-scan --localnet | grep "Xiaomi Communications" | awk '{debugPrint $1}')
# sudo -S arp-scan --localnet
echo $ip_address;
# exit;
# Check if an IP address was found
if [ -z "$ip_address" ]; then
  echo "Error: Device not found on network."
  echo "Enter Last digits of ip :"

  read last;
 ip_address="$trimmed_ip.$last"
 echo $ip_address;
# else


  
 fi




# echo $ip_address
adb connect $ip_address:5555
echo "wait"


adb devices;
device_status=$(adb devices | grep 'device' | awk '{debugPrint $1}')

#  echo $device_status;
#   exit;

if [ "$device_status" == "List cde43bc9" ]; then
  echo "Phone connected using Wi-Fi for debugging."
else
  echo "Error connecting the phone using Wi-Fi. Please try again."
fi

