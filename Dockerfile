# Build arguments
ARG ROS_DISTRO=noetic

# Define Base image
FROM osrf/ros:${ROS_DISTRO}-desktop-full

# Restate the arg to make it available in later stage
ARG ROS_DISTRO

# Add aliases
WORKDIR /root
ADD .bash_aliases .bash_aliases
RUN echo "$(<.bash_aliases)" >> .bashrc

# Ad the source code to the correct folder
WORKDIR /home/ws/
ADD ./GeneralCode/ROS/hiperlab_common/ ./src/hiperlab_common/
ADD ./GeneralCode/ROS/hiperlab_components/ ./src/hiperlab_components/
ADD ./GeneralCode/ROS/hiperlab_rostools/ ./src/hiperlab_rostools/
ADD ./GeneralCode/ROS/hiperlab_hardware/ ./src/hiperlab_hardware/
ADD ./GeneralCode/Common/ ./src/hiperlab_common/src/
ADD ./GeneralCode/Components/ ./src/hiperlab_components/src/

# Install Catkin
# Install additional ros packages and other libraries
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq && apt-get install -y \
    python3-catkin-tools \
    && rm -rf /var/lib/apt/lists/* 

# Source ROS and compile package
RUN . /opt/ros/${ROS_DISTRO}/setup.sh && catkin build hiperlab_common
RUN . /opt/ros/${ROS_DISTRO}/setup.sh && catkin build hiperlab_components
RUN . /opt/ros/${ROS_DISTRO}/setup.sh && catkin build hiperlab_rostools
RUN . /opt/ros/${ROS_DISTRO}/setup.sh && catkin build hiperlab_hardware

RUN echo "source /home/ws/devel/setup.bash" >> /etc/bash.bashrc

# Set ros master URI
ENV ROS_MASTER_URI=http://169.254.21.103:11311
# Source the profile to set ROS_IP
ADD ./set_ros_ip.sh /
RUN echo "source /set_ros_ip.sh" >> ~/.bashrc

CMD ["bash"]
