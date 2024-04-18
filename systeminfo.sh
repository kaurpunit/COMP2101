#!/bin/bash

# Source the function library file
. reportfunctions.sh


# Check for root permission
if [[ $EUID -ne 0 ]]; then
  errormessage "This script must be run as root."
  exit 1
fi

# Display help message and exit
if [[ "$1" == "-h" ]]; then
  echo "Usage: $0 [-h] [-v] [-system] [-disk] [-network]"
  echo ""
  echo "  -h                 Display this help message and exit"
  echo "  -v                 Run the script verbosely, showing any errors to the user instead of sending them to the logfile"
  echo "  -system           Run only the computerreport, osreport, cpureport, ramreport, and videoreport"
  echo "  -disk             Run only the diskreport"
  echo "  -network          Run only the networkreport"
  exit 0
fi

# Handle errors verbosely or silently
if [[ "$1" == "-v" ]]; then
  verbose=true
else
  verbose=false
fi

# Set the default behavior to print out a full system report
report_all=true

# Check for specific report options
if [[ "$1" == "-system" ]]; then
  report_cpu=true
  report_computer=true
  report_os=true
  report_ram=true
  report_video=true
  report_all=false
elif [[ "$1" == "-disk" ]]; then
  report_disk=true
  report_all=false
elif [[ "$1" == "-network" ]]; then
  report_network=true
  report_all=false
fi

# Generate the report(s)
if [[ $report_all == true ]]; then
  cpureport
  computerreport
  osreport
  ramreport
  videoreport
  diskreport
  networkreport
else
  if [[ $report_cpu == true ]]; then
    cpureport
  fi
  if [[ $report_computer == true ]]; then
    computerreport
  fi
  if [[ $report_os == true ]]; then
    osreport
  fi
  if [[ $report_ram == true ]]; then
    ramreport
  fi
  if [[ $report_video == true ]]; then
    videoreport
  fi
  if [[ $report_disk == true ]]; then
    diskreport
  fi
  if [[ $report_network == true ]]; then
    networkreport
  fi
fi

exit 0
