# Build arguments
ARG ROS_DISTRO=noetic

# Define Base image
FROM osrf/ros:${ROS_DISTRO}-desktop-full

# Restate the arg to make it available in later stage
ARG ROS_DISTRO

# Flag for whether to set ROS_MASTER_URI and ROS_IP; can be "real" or "sim"
ARG ROS_ENV="real" 

# Add alhttp://169.254.21.103:11311iases
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

# Install Catkin and additional ROS_ENVros packages and other libraries
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq && apt-get install -y \
    python3-catkin-tools \
    && rm -rf /var/lib/apt/lists/* 

# Source ROS and compile package
RUN . /opt/ros/${ROS_DISTRO}/setup.sh && catkin build hiperlab_common
RUN . /opt/ros/${ROS_DISTRO}/setup.sh && catkin build hiperlab_components
RUN . /opt/ros/${ROS_DISTRO}/setup.sh && catkin build hiperlab_rostools
RUN . /opt/ros/${ROS_DISTRO}/setup.sh && catkin build hiperlab_hardware

# Source the ros_ws in every new terminal
RUN echo "source /home/ws/devel/setup.bash" >> /etc/bash.bashrc

# Add the sourcing script to the profile to set ROS_IP
ADD ./set_ros_networking.sh /

# Only set the ros env variables if we're building for the real system
RUN if [ "$ROS_ENV" = "real" ]; then \
        # Set ros master URI
        echo "source /set_ros_networking.sh" >> /root/.bashrc;\
        echo "Compiling for the real system"; \
    elif [ "$ROS_ENV" = "sim" ]; then \
        echo "Compiling for simualation"; \
    else \
        echo "Unknown ROS_ENV flag"; \
    fi

CMD ["bash"]
