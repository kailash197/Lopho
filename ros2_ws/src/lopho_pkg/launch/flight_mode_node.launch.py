#! /usr/bin/python3
from launch import LaunchDescription
from launch_ros.actions import Node

def generate_launch_description():
    return LaunchDescription([
        Node(
            package='lopho_pkg',
            executable='flight_mode_node',
            output='screen',
        )
    ])
