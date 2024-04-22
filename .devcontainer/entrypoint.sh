#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status
mkdir -p /home/$(whoami)/Lopho/ros2_ws/src

# source underlay
source /opt/ros/${ROS_DISTRO}/setup.bash

# build creates folder structure with ../ros_ws/src folder among others.
# colcon build --symlink-install 

# check for dependencies
# rosdep install -i --from-path src --rosdistro ${ROS_DISTRO} -y 

cd /home/$(whoami)/Lopho/ros2_ws/src
# to this folder clone package source files
git clone -b develop --recursive git@github.com:kailash197/Lopho.git ros2_ws/src/lopho_pkg


# go back to root folder & build package
cd /home/$(whoami)/Lopho/ros2_ws
# colcon build --packages-select lopho_pkg
# source install/local_setup.bash
# ros2 run lopho_pkg my_node

# TODO: Add git clone for different packages and node here



# source /home/${USERNAME}/Lopho/ros2_ws/install/setup.bash
# echo "source /home/${USERNAME}/Lopho/ros2_ws/install/setup.bash" >> ~/.bashrc
# echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> ~/.bashrc
# echo "source /usr/share/colcon_cd/function/colcon_cd.sh" >> ~/.bashrc
# echo "export _colcon_cd_root=/opt/ros/humble/" >> ~/.bashrc


# echo $(which source)
# touch "/home/$(whoami)/Lopho/masala.sdf"

exec "$@"
