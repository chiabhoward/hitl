param map = localPath('../Scenic/assets/maps/CARLA/Town01.xodr')
param carla_map = 'Town01'
# param record = '~/record'
model scenic.simulators.carla.model

# Define constants
BICYCLE_MIN_SPEED = 1.5
SAFETY_DISTANCE = 10

# Define behaviors
behavior TestVehicleBehavior(trajectory):
    do FollowTrajectoryBehavior(trajectory = trajectory)

behavior BicycleBehavior(speed=3, threshold=15):
    do CrossingBehavior(ego, speed, threshold)

# Define spatial relations
intersec = Uniform(*network.intersections)
startLane = Uniform(*intersec.incomingLanes)
maneuver = Uniform(*startLane.maneuvers)
testVehicle_trajectory = [maneuver.startLane, maneuver.connectingLane, maneuver.endLane]

spot = new OrientedPoint in maneuver.startLane.centerline
ego = new Car at spot,
    with blueprint "vehicle.lincoln.mkz_2017",
    with behavior TestVehicleBehavior(trajectory = testVehicle_trajectory)

# Record the ego's position during the simulation
record ego.position as egoPos

spotBicycle = new OrientedPoint in maneuver.endLane.centerline,
    facing roadDirection
bicycle = new Bicycle at spotBicycle offset by 3.5@0,
    with heading 90 deg relative to spotBicycle.heading,
    with behavior BicycleBehavior(BICYCLE_MIN_SPEED, 15),
    with regionContainedIn None

# Record the bicycle's position during the simulation
record bicycle.position as bicPos

require 10 <= (distance to intersec) <= 15
require 10 <= (distance from bicycle to intersec) <= 15
terminate when (distance to spot) > 50