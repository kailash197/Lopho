#! /usr/bin/python3
# Dependencies
from dronekit import VehicleMode,  Command
import time
# import socket
# import exception
# import math
# import argparse
from pymavlink import mavutil
from library import connectMyCopter, arm_and_takeoff



# Main executable
vehicle = connectMyCopter()

#now launch the drone into guided mode,  arm and takeoff to 30m height
arm_and_takeoff(vehicle, 5) # height in meters

# Change the flight mode to "LAND"
vehicle.mode = VehicleMode("LAND")

# Wait for the vehicle to land (optional)
# This loop will continuously check the vehicle's mode until it changes to "LAND"
print(vehicle.mode)
while vehicle.mode.name != "LAND":
	print("Waiting for the vehicle mode to land...")
	print(vehicle.mode)
	time.sleep(1)
print(vehicle.mode)
while True:
    print("Altitude: ", vehicle.location.global_relative_frame.alt)
    if vehicle.location.global_relative_frame.alt <= 0.1:  # Adjust the threshold as needed
        print("Vehicle has landed.")
        break
    time.sleep(1)
print(vehicle.mode)
print("Exiting program")

vehicle.close()



