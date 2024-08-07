#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status
cd /home/$(whoami)/Lopho
# source underlay

source /opt/ros/${ROS_DISTRO}/setup.bash
rosdep install -i --from-path ./ros2_ws/src --rosdistro ${ROS_DISTRO} -y 


# https://medium.com/@gabrielcruz_68416/clone-a-specific-folder-from-a-github-repository-f8949e7a02b4
cd /home/$(whoami)/Lopho
colcon build
colcon test

exec "$@"
