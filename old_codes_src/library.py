import argparse
import time
from dronekit import VehicleMode, connect

def connectMyCopter():
	parser = argparse.ArgumentParser(description='commands')
	parser.add_argument('--connect')
	args = parser.parse_args()

	connection_string = args.connect
	if not connection_string:
		import dronekit_sitl
		sitl = dronekit_sitl.start_default()
		connection_string = sitl.connection_string()
	
	vehicle = connect(connection_string,  wait_ready=True)
	return vehicle


def arm_and_takeoff(vehicle, target_height):
	while not vehicle.is_armable:
		print("Initializing vehicle ...")
		time.sleep(1)
	print("Vehicle is armable now. ")

	vehicle.mode = VehicleMode("GUIDED")
	while vehicle.mode != 'GUIDED':
		print("Waiting for drone to enter GUIDED mode")
		time.sleep(1)
	print(vehicle.mode)
	
	vehicle.armed = True
	while not vehicle.armed:
		print("Waiting for vehicle to become armed")
		time.sleep(1)
	print("Vehicle Armed")

	vehicle.simple_takeoff(target_height)  # height in meters
	while True:
		print(f"Current Altitude: {vehicle.location.global_relative_frame.alt}")
		if vehicle.location.global_relative_frame.alt >= 0.95 * target_height:
			break
		time.sleep(1)
	print("Target altitude reached")
	return None