#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status
cd /home/$(whoami)

git clone https://github.com/kailash197/Lopho.git -b master
cd Lopho/ros2_ws

# source underlay
source /opt/ros/${ROS_DISTRO}/setup.bash
rosdep install -i --from-path ./src --rosdistro ${ROS_DISTRO} -y 
# This option tells rosdep to install dependencies for packages located in the Lopho/ros2_ws/src directory.

colcon build
source install/setup.bash
colcon test

exec "$@"
