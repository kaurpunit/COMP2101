# Function to generate the CPU report
cpureport() {
  title "CPU Report"
  echo "CPU Manufacturer and Model: $(lscpu | grep 'Vendor ID' | awk '{print $3}')-$(lscpu | grep 'Model name' | awk '{print $3}')"
  echo "CPU Architecture: $(uname -m)"
  echo "CPU Core Count: $(lscpu | grep 'Core(s) per socket' | awk '{print $4}')"
  echo "CPU Maximum Speed: $(lscpu | grep 'CPU MHz' | awk '{print $3}') MHz"
  echo "CPU Cache Sizes: L1: $(lscpu | grep 'L1d cache' | awk '{print $5}'), L2: $(lscpu | grep 'L2 cache' | awk '{print $5}'), L3: $(lscpu | grep 'L3 cache' | awk '{print $5}')"
}

# Function to generate the computer report
computerreport() {
  title "Computer Report"
  echo "Computer Manufacturer: $(dmidecode -s system-manufacturer)"
  echo "Computer Description or Model: $(dmidecode -s system-product-name)"
  echo "Computer Serial Number: $(dmidecode -s system-serial-number)"
}

# Function to generate the OS report
osreport() {
  title "OS Report"
  echo "Linux Distro: $(cat /etc/os-release | grep '^NAME=' | awk -F'=' '{print $2}' | sed 's/"//g')"
  echo "Distro Version: $(cat /etc/os-release | grep '^VERSION_ID=' | awk -F'=' '{print $2}' | sed 's/"//g')"
}

# Function to generate the RAM report
ramreport() {
  title "RAM Report"
  echo "Total size of installed RAM: $(free -h | grep 'Mem' | awk '{print $2}')"
  echo "Installed memory components:"
  for i in $(lshw -class memory | grep 'product:' | awk '{print $2}'); do
    manufacturer=$(lshw -class memory | grep $i | grep 'vendor:' | awk '{print $2}')
    size=$(lshw -class memory | grep $i | grep 'size:' | awk '{print $2}')
    speed=$(lshw -class memory | grep $i | grep 'speed:' | awk '{print $2}')
    location=$(lshw -class memory | grep $i | grep 'location:' | awk '{print $2}')
    echo "Component manufacturer: $manufacturer"
    echo "Component model or product name: $i"
    echo "Component size: $size"
    echo "Component speed: $speed"
    echo "Component physical location: $location"
    echo ""
  done
}

# Function to generate the video report
videoreport() {
  title "Video Report"
  echo "Video card/chipset manufacturer: $(lspci | grep 'VGA compatible controller' | awk '{print $5}' | cut -d' ' -f1)"
  echo "Video card/chipset description or model: $(lspci | grep 'VGA compatible controller' | awk '{print $5}' | cut -d' ' -f2-)"
}

# Function to generate the disk report
diskreport() {
  title "Disk Report"
  echo "Installed disk drives:"
  for i in $(lsblk | grep 'disk' | awk '{print $1}'); do
    manufacturer=$(lsblk | grep $i | grep 'NAME' | awk '{print $1}' | xargs -I {} lsblk -d -n -o VENDOR,{} | awk '{print $1}')
    model=$(lsblk | grep $i | grep 'NAME' | awk '{print $1}' | xargs -I {} lsblk -d -n -o NAME,{} | awk '{print $1}')
    size=$(lsblk | grep $i | grep 'NAME' | awk '{print $1}' | xargs -I {} lsblk -n -o SIZE,{} | awk '{print $1}')
    echo "Drive manufacturer: $manufacturer"
    echo "Drive model: $model"
    echo "Drive size: $size"
    if [[ -n $(lsblk | grep $i | grep 'MOUNTPOINT') ]]; then
      mountpoint=$(lsblk | grep $i | grep 'MOUNTPOINT' | awk '{print $4}')
      filesystem=$(lsblk | grep $mountpoint | grep 'TYPE' | awk '{print $4}')
      free=$(df -h | grep $mountpoint | awk '{print $4}')
      size=$(df -h | grep $mountpoint | awk '{print $2}')
      echo "Partition number: $(lsblk | grep $i | grep 'NAME' | awk '{print $1}' | cut -d'-' -f1 | sed 's/[a-z]//g')"
      echo "Mount point: $mountpoint"
      echo "Filesystem size: $size"
      echo "Filesystem free space: $free"
    fi
    echo ""
  done
}

# Function to generate the network report
networkreport() {
  title "Network Report"
  echo "Installed network interfaces (including virtual devices):"
  for i in $(ip -o link show | awk -F ':' '{print $2}' | awk '{print $1}'); do
    manufacturer=$(ethtool -i $i | grep 'driver' | awk '{print $2}')
    model=$(ethtool -i $i | grep 'version' | awk '{print $2}')
    linkstate=$(ip -o link show | grep $i | awk '{print $9}' | cut -d'=' -f2)
    speed=$(ethtool $i | grep 'Speed:' | awk '{print $2}')
    ip=$(ip -o addr show $i | grep 'inet' | awk '{print $4}')
    bridge=$(ip -o link show | grep $i | awk '{print $1}' | cut -d'@' -f2)
    dns=$(cat /etc/resolv.conf | grep 'nameserver' | awk '{print $2}')
    search=$(cat /etc/resolv.conf | grep 'search' | awk '{print $2}')
    echo "Interface manufacturer: $manufacturer"
    echo "Interface model or description: $model"
    echo "Interface link state: $linkstate"
    echo "Interface current speed: $speed"
    if [[ -n $ip ]]; then
      echo "Interface IP addresses in CIDR format: $ip"
    fi
    if [[ -n $bridge ]]; then
      echo "Interface bridge master: $bridge"
    fi
    if [[ -n $dns ]]; then
      echo "DNS server(s) and search domain(s) if any are associated with the interface: $dns, $search"
    fi
    echo ""
  done
}

errormessage() {
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  local message="$timestamp: $1"
  
  if echo "$message" >> /var/log/systeminfo.log 2>/dev/null; then
    >&2 echo "$message"
  else
    >&2 echo "Error: Failed to write to log file /var/log/systeminfo.log"
  fi
}

# Function to display a title
title() {
  echo ""
  echo "--------------------------------------------------------------------------------"
  echo " $1"
  echo "--------------------------------------------------------------------------------"
}
