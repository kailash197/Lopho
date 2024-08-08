#!/bin/bash

# Define variables
PROJECT_DIR="/home/$(whoami)/Lopho"
CONTAINER_NAME="humble_container"
IMAGE_NAME="humble_machine"
CONTAINER_USER="vscode"
DATE_TAG=$(date +'%Y%m%d')
DOCKERFILE_PATH="$PROJECT_DIR/.devcontainer/Dockerfile"

# Change directory to the project directory
cd "$PROJECT_DIR" || { echo "Failed to change directory to $PROJECT_DIR"; exit 1; }


docker container prune -f # Clean up existing Docker containers
docker rm -f $CONTAINER_NAME # Remove specific container if exists

# Build the Docker image with the tag including the date
docker build \
  --build-arg timezone=$(cat /etc/timezone) \
  -f "$DOCKERFILE_PATH" \
  -t "$IMAGE_NAME:$DATE_TAG" .

# Display a message indicating the start of Docker run
echo "Docker Run"

# Run the Docker container
docker run -itd --privileged \
  --name "$CONTAINER_NAME" \
  --user "$CONTAINER_USER" \
  --network host \
  --ipc host \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e DISPLAY=$DISPLAY \
  "$IMAGE_NAME:$DATE_TAG"

# Start SITL in a new terminal
gnome-terminal -- bash -c \
  "docker exec -it $CONTAINER_NAME bash -c ' \
    echo \"Terminal SITL for \$(whoami)\"; \
    echo \"Starting SITL\"; \
    arducopter -S -I0 --home 43.502922,-80.467015,0,353 --model '+' --speedup 1 --defaults /home/\$(whoami)/ardupilot/Tools/autotest/default_params/copter.parm; \
    bash';"

# Start MAVROS in a new terminal
gnome-terminal -- bash -c \
  "docker exec -it $CONTAINER_NAME bash -c ' \
    echo \"Terminal MAVROS for \$(whoami)\"; \
    source /opt/ros/${ROS_DISTRO}/setup.bash; \
    ros2 launch mavros apm.launch fcu_url:=tcp://localhost gcs_url:=udp://@localhost:14550; \
    bash';"

# Start QGC in a new terminal
gnome-terminal -- bash -c \
  "docker exec -it $CONTAINER_NAME bash -c ' \
    echo \"Terminal QGC for \$(whoami)\"; \
    QGC';"

# Start a new terminal with an interactive bash session
gnome-terminal -- bash -c "docker exec -it $CONTAINER_NAME bash"

# Notes for additional configuration
echo "Commands to run:"
echo "  cd <folder containing Dockerfile>"
echo "  docker build -t $IMAGE_NAME:$DATE_TAG ."
echo "  docker run -it --user $CONTAINER_USER --network=host --ipc=host -v $PROJECT_DIR:/current_folder $IMAGE_NAME:$DATE_TAG"

# #!/bin/bash

# # Change directory to the project directory
# cd /home/$(whoami)/Lopho
# container_user=vscode

# # Get today's date in YYYYMMDD format
# date_tag=$(date +'%Y%m%d')

# # Build the Docker image with the tag including the date
# docker rm $(docker container ls -aq) -f
# docker rm humble_container -f
# docker build \
#   --build-arg timezone=$(cat /etc/timezone) \
#   -f /home/$(whoami)/Lopho/.devcontainer/Dockerfile \
#   -t humble_machine:$date_tag .
  
# # Display a message indicating the start of Docker run
# echo "Docker Run"

# # -v /tmp/.X11-unix:/tmp/.X11-unix: Shares X11 socket for GUI applications.
# docker run -itd --privileged \
#   --name humble_container \
#   --user $container_user \
#   --network host \
#   --ipc host \
#   -v /tmp/.X11-unix:/tmp/.X11-unix \
#   -e DISPLAY=$DISPLAY humble_machine:$date_tag
#   # -v $PWD:/Lopho \ 

# # Start SITL in a new terminal
# gnome-terminal -- bash -c \
#   "docker exec -it humble_container bash -c ' \
#     echo \"Terminal SITL for \$(whoami)\"; \
#     echo \"Starting SITL\"; \
#     arducopter -S -I0 --home 43.502922,-80.467015,0,353 --model '+' --speedup 1 --defaults /home/\$(whoami)/ardupilot/Tools/autotest/default_params/copter.parm; \
#     bash';"

# gnome-terminal -- bash -c \
#   "docker exec -it humble_container bash -c ' \
#     echo \"Terminal MAVROS for \$(whoami)\"; \
#     source /opt/ros/${ROS_DISTRO}/setup.bash; \
#     ros2 launch mavros apm.launch fcu_url:=tcp://localhost gcs_url:=udp://@localhost:14550; \
#     bash';"

# gnome-terminal -- bash -c \
#   "docker exec -it humble_container bash -c ' \
#     echo \"Terminal QGC for \$(whoami)\"; \
#     QGC';"

# # Start a new terminal
# gnome-terminal -- bash -c "docker exec -it humble_container bash" 




# Commands to run 
# cd <folder containing dockerfile> 
# docker build -t humble_machine .
# docker run -it --user ros --network=host --ipc=host -v $PWD:/current_folder humble_machine
# 
# LOCALE and TIMEZONE might be useful while creating own image starting bare ubuntu image.

# for display
# docker run -it --user ros --network=host --ipc=host -v $PWD:/current_folder -v /tmp/.X11-unix:/tmp/.X11-uniz:rw --env=DISPLAY humble_machine

# for device: I 
# cons: device should be plugged at start of container; can't replugges as devicename may change
# docker run -it --user ros --network=host --ipc=host -v $PWD:/current_folder -v /tmp/.X11-unix:/tmp/.X11-uniz:rw --env=DISPLAY --device=/dev/input/<devicename> humble_machine

# for device: II, using -v
# cons: mapping single device doesn't work; map folder only
# docker run -it --user ros --network=host --ipc=host -v $PWD:/current_folder -v /tmp/.X11-unix:/tmp/.X11-uniz:rw --env=DISPLAY -v /dev/input:/dev/input --device-cgroup-rule='c <major>:<minor> rmw' humble_machine
# major: device driver id major; can use * for all
# minor: device driver id minor; can use * for all
# rmw: read, make node, write
# --device-cgroup-rule='c 13:* rmw'

# Add devices: III
# docker run -it --user ros --network=host --ipc=host -v $PWD:/current_folder -v /tmp/.X11-unix:/tmp/.X11-uniz:rw --env=DISPLAY -v /dev:/dev --device-cgroup-rule='c *:* rmw' humble_machine

# Add Intel Realsense D435
# cybermonk@spectre:~$ lsusb | grep realsense
# cybermonk@spectre:~$ lsusb | grep -i realsense
# Bus 003 Device 004: ID 8086:0b07 Intel Corp. RealSense D435
# cybermonk@spectre:~$ ls -l /dev/bus/usb/003
# total 0
# crw-rw-r-- 1 root root 189, 256 Feb 11 11:30 001
# crw-rw-r-- 1 root root 189, 257 Feb 11 11:30 002
# crw-rw-r-- 1 root root 189, 258 Feb 11 11:30 003
# crw-rw-r-- 1 root root 189, 259 Feb 11 17:57 004
# cybermonk@spectre:~$ 
# docker run -it --user ros --network=host --ipc=host -v $PWD:/current_folder -v /tmp/.X11-unix:/tmp/.X11-uniz:rw --env=DISPLAY -v /dev/bus/usb:/dev/bus/usb --device-cgroup-rule='c 189:* rmw' humble_machine


# Add serial devices
# generally listed under tty, dialout group
# add user to dialout group to grant permission to access serial devices
# RUN usermod -aG dialout ${USERNAME}
# docker run -it --user ros --network=host --ipc=host -v $PWD:/current_folder -v /tmp/.X11-unix:/tmp/.X11-uniz:rw --env=DISPLAY -v /dev:/dev --privileged humble_machine
#
# Without using --privileged (don't use the BIG hammer if possible)
# docker run -it --user ros --network=host --ipc=host -v $PWD:/current_folder -v /tmp/.X11-unix:/tmp/.X11-uniz:rw --env=DISPLAY --device=/dev/tty<...> humble_machine