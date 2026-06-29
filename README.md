# Welcome

## Entry Point:
  /home/${USER}/Lopho/scripts/start_drone_system_DEV.sh
  i. Does some cleanup.
  ii. Builds a container humble_machine:$date_tag using a dockerfile (path: /home/${user}/Lopho/.devcontainer/Dockerfile)
  iii. Run the docker container (humble_container) in privileged mode and attaches following terminals:
    a. Main terminal stand-by
    b. Starts SITL simulation
    c. Starts MAVROS
    d. Start QGC


### Note:
* All ROS2 setup files are sourced towards the end of execution of the DockerFile.

### Build and run 
```bash
cd ~/Lopho && docker compose -f .devcontainer/docker-compose.yml build lopho-sim
xhost +local:docker
cd ~/Lopho && docker compose -f .devcontainer/docker-compose.yml run --remove-orphans lopho-sim
```

```bash
sudo apt-get update && sudo apt-get install -y docker-compose
```
