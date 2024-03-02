#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status
echo "Executing entrypoint.sh"
source /lopho_project/ros2_ws/install/setup.bash
source /opt/ros/${ROS_DISTRO}/setup.bash

# Start SITL in a new terminal
echo 'Starting SITL'
# arducopter -S -I0 --home 43.502922,-80.467015,0,353 --model '+' --speedup 1 --defaults /home/$(whoami)/ardupilot/Tools/autotest/default_params/copter.parm &
# sleep 5




# Start MAVROS in a new terminal
# echo 'Starting MAVROS'
# ros2 launch mavros apm.launch fcu_url:=tcp://localhost gcs_url:=udp://@localhost:14550 
# sleep 5

# # Start QGC in a new terminal
# QGC &
# sleep 5



# gnome-terminal -- bash -c \
#   "echo 'Starting QGC'; \
#   QGC; \
#   bash" &

exec "$@"
