FROM osrf/ros:humble-desktop-full

ARG timezone
ENV TZ=${timezone}

# Add vscode user with same UID and GID as your host system
# (copied from https://code.visualstudio.com/remote/advancedcontainers/add-nonroot-user#_creating-a-nonroot-user)
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && mkdir /home/${USERNAME}/.config \
    && chown ${USER_UID}:${USER_GID} /home/${USERNAME}/.config \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && rm -rf /var/lib/apt/lists/*

# Switch from root to user
USER $USERNAME

# Add user to video group to allow access to webcam
RUN sudo usermod --append --groups video $USERNAME

# Update all packages
RUN sudo apt update && sudo apt upgrade -y

# Rosdep update
RUN rosdep update

# Source the ROS setup file
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc
# RUN mkdir -p ardupilot_ws/src \
#     && cd ardupilot_ws \
#     && catkin init \
#     && cd src

# # Install Gazebo ROS package
RUN sudo apt-get update \
    && sudo apt-get install -y lsb-release wget gnupg libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
    && sudo wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" \ 
    | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null \
    && sudo apt-get update \
    && sudo apt-get install -y gz-harmonic \
    # sudo apt-get install -y ros-${ROS_DISTRO}-ros-gz 
    && sudo rm -rf /var/lib/apt/lists/*

RUN sudo apt-get update \
    && sudo apt-get install libgz-sim8-dev rapidjson-dev -y \
    && sudo rm -rf /var/lib/apt/lists/*
ENV GZ_VERSION=harmonic

WORKDIR /home/${USERNAME}/
# https://github.com/ArduPilot/ardupilot_gazebo
RUN git clone https://github.com/ArduPilot/ardupilot_gazebo \
    && mkdir /home/${USERNAME}/ardupilot_gazebo/build \
    && cd /home/${USERNAME}/ardupilot_gazebo/build \
    && cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    && make -j4

ENV GZ_SIM_SYSTEM_PLUGIN_PATH=/home/${USERNAME}/ardupilot_gazebo/build:$GZ_SIM_SYSTEM_PLUGIN_PATH
ENV GZ_SIM_RESOURCE_PATH=/home/${USERNAME}/ardupilot_gazebo/models:/home/${USERNAME}/ardupilot_gazebo/worlds:$GZ_SIM_RESOURCE_PATH
# test
# in termainal: gz sim -v4 -r iris_runway.sdf
# in another terminal: sim_vehicle.py -v ArduCopter -f gazebo-iris --model JSON --map --console

# Install dependencies
RUN sudo apt-get update \
    && sudo apt-get install -y git python3-dev python3-opencv python3-matplotlib python3-lxml \ 
    && sudo rm -rf /var/lib/apt/lists/*

RUN sudo ln -s /usr/bin/python3 /usr/bin/python
ENV PATH="$PATH:/home/${USERNAME}/.local/bin/"

# RUN sudo apt-get install -y python3-wxgtk4.0 didnot run
# RUN sudo apt-get install -y python3-pygame

# Install pip, pexpect, future, pyyaml and mavproxy
WORKDIR /home/${USERNAME}/
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
    && python get-pip.py \
    && python -m pip install pexpect future PyYAML MAVProxy


# # # Clone ArduPilot repository
RUN git clone -b Copter-4.5 https://github.com/ArduPilot/ardupilot.git

# Build ArduPilot
WORKDIR /home/${USERNAME}/ardupilot/
RUN git submodule update --init --recursive \
    && ./waf configure --board sitl \
    && ./waf copter

# Add path to sim_vehicle.py
ENV PATH="$PATH:/home/${USERNAME}/ardupilot/Tools/autotest/"

# Add path to arducopter SITL
ENV PATH="$PATH:/home/${USERNAME}/ardupilot/build/sitl/bin"

# Install Q Ground Control
WORKDIR /home/${USERNAME}/QGC/
RUN sudo usermod -a -G dialout $USERNAME \
    && sudo apt-get update \
    # && sudo apt-get remove modemmanager -y \ no package to removes
    && sudo apt install gstreamer1.0-plugins-bad gstreamer1.0-libav gstreamer1.0-gl -y \
    && sudo apt install libqt5gui5 -y \
    && sudo apt install libfuse2 -y \
    && sudo apt-get install fuse -y \
    && sudo rm -rf /var/lib/apt/lists/*
RUN wget https://d176tv9ibo4jno.cloudfront.net/latest/QGroundControl.AppImage \
    && chmod +x QGroundControl.AppImage \
    && sudo cp ./QGroundControl.AppImage /usr/local/bin/QGC

# Install MAVROS
WORKDIR /home/${USERNAME}/temp
RUN sudo apt-get update \
    && sudo apt-get install ros-humble-mavros ros-humble-mavros-extras gnome-terminal tree -y \
    && wget https://raw.githubusercontent.com/mavlink/mavros/master/mavros/scripts/install_geographiclib_datasets.sh \
    && sudo chmod +x install_geographiclib_datasets.sh \
    && sudo ./install_geographiclib_datasets.sh \
    && sudo rm -rf /var/lib/apt/lists/*

# Set up entrypoint (optional)
WORKDIR /home/${USERNAME}/Lopho
COPY --chown=${USERNAME}:${USERNAME} . /home/${USERNAME}/Lopho/

# Build ROS workspace, packages and nodes via entrypoint.sh
COPY ./.devcontainer/entrypoint.sh /entrypoint.sh
RUN sudo chmod +x /entrypoint.sh
RUN /entrypoint.sh
RUN echo "source /home/${USERNAME}/Lopho/install/setup.bash" >> ~/.bashrc \
    && echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> ~/.bashrc \
    && echo "source /usr/share/colcon_cd/function/colcon_cd.sh" >> ~/.bashrc \
    && echo "export _colcon_cd_root=/opt/ros/humble/" >> ~/.bashrc

WORKDIR /home/${USERNAME}/Lopho
CMD ["bash"]
