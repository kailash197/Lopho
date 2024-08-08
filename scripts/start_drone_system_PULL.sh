#!/bin/bash

echo "This code doesn't work yet. The docker pull fails."
exit 1

# Define variables
PROJECT_DIR="/home/$(whoami)/Lopho"
CONTAINER_NAME="humble_container"
IMAGE_NAME="kkhadk343/humble_lopho:MAVROS_Subscriber_Node"
CONTAINER_USER="vscode"
DATE_TAG=$(date +'%Y%m%d')
DOCKERFILE_PATH="$PROJECT_DIR/.devcontainer/Dockerfile"

# Change directory to the project directory
cd "$PROJECT_DIR" || { echo "Failed to change directory to $PROJECT_DIR"; exit 1; }

# Clean up existing Docker containers
docker container prune -f

# Remove specific container if it exists
docker rm -f $CONTAINER_NAME

# Pull the Docker image from Docker Hub
docker login
docker pull "$IMAGE_NAME"

# Run the Docker container from the pulled image
docker run -itd --privileged \
  --name "$CONTAINER_NAME" \
  --user "$CONTAINER_USER" \
  --network host \
  --ipc host \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e DISPLAY=$DISPLAY \
  "$IMAGE_NAME"

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
echo "  docker pull $IMAGE_NAME"
echo "  docker run -it --user $CONTAINER_USER --network=host --ipc=host -v $PROJECT_DIR:/current_folder $IMAGE_NAME"
