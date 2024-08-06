Welcome to Lopho

Entry Point:
  /home/{user}/Lopho/scripts/start_drone_system_DEV.sh
  i. Does some cleanup.
  ii. Builds a container humble_machine:$date_tag using a dockerfile (path: /home/{user}/Lopho/.devcontainer/Dockerfile)
  iii. Run the docker container (humble_container) in privileged mode and attaches following terminals:
    a. Main terminal stand-by
    b. Starts SITL simulation
    c. Starts MAVROS
    d. Start QGC
  
