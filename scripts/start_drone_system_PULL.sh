#!/bin/bash

# Define variables
PROJECT_DIR="/home/$(whoami)/Lopho"
CONTAINER_NAME="humble_container"
CONTAINER_USER="vscode"
DATE_TAG=$(date +'%Y%m%d')
DOCKERFILE_PATH="$PROJECT_DIR/.devcontainer/Dockerfile"
DOCKER_USER="kkhadka343"
DOCKER_KEY="Dockerp@ssword123"
DOCKER_REPO="$DOCKER_USER/humble_lopho"
DOCKER_REPO_TAG="MAVROS_Subscriber_Node"
IMAGE_NAME="$DOCKER_REPO:$DOCKER_REPO_TAG"

cd "$PROJECT_DIR" || { echo "Failed to change directory to $PROJECT_DIR"; exit 1; }

# Clean up existing Docker containers
docker container prune -f
# Remove specific container if it exists
docker rm -f $CONTAINER_NAME

# Check if image exists
if docker image inspect "${IMAGE_NAME}" > /dev/null 2>&1; then
  echo "Image ${IMAGE_NAME} already exists. Removing stale image..."
  docker image rm "$IMAGE_NAME"
else
  # Pull the Docker image from Docker Hub
  echo "Image ${IMAGE_NAME} not found."
fi
echo "Pulling from Docker Hub..."
echo "$DOCKER_KEY" | docker login --username "$DOCKER_USER" --password-stdin
docker pull "$IMAGE_NAME"
docker images

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
