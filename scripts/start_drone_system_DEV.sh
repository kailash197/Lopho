#!/bin/bash

# Change directory to the project directory
cd /home/$(whoami)/Lopho

# Get today's date in YYYYMMDD format
date_tag=$(date +'%Y%m%d')

# Build the Docker image with the tag including the date
docker rm $(docker container ls -aq) -f
docker rm humble_container -f
docker build -t humble_machine:$date_tag /home/$(whoami)/Lopho/.devcontainer/

# Display a message indicating the start of Docker run
echo "Docker Run"
docker run -itd --privileged --name humble_container --user vscode --network host --ipc host -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=$DISPLAY -v $PWD:/Lopho humble_machine:20240301

# Start SITL in a new terminal
gnome-terminal -- bash -c \
  "docker exec -it humble_container bash -c ' \
    echo \"Terminal SITL for \$(whoami)\"; \
    echo \"Starting SITL\"; \
    cd simulation; \
    arducopter -S -I0 --home 43.502922,-80.467015,0,353 --model '+' --speedup 1 --defaults /home/\$(whoami)/ardupilot/Tools/autotest/default_params/copter.parm; \
    bash';"

gnome-terminal -- bash -c \
  "docker exec -it humble_container bash -c ' \
    echo \"Terminal MAVROS for \$(whoami)\"; \
    source /Lopho/ros2_ws/install/setup.bash ; \
    source /opt/ros/${ROS_DISTRO}/setup.bash; \
    ros2 launch mavros apm.launch fcu_url:=tcp://localhost gcs_url:=udp://@localhost:14550; \
    bash';"

gnome-terminal -- bash -c \
  "docker exec -it humble_container bash -c ' \
    echo \"Terminal QGC for \$(whoami)\"; \
    QGC';" 

gnome-terminal -- bash -c \
  "docker exec -it humble_container bash" 