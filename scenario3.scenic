param map = localPath('../Scenic/assets/maps/CARLA/Town01.xodr')
param carla_map = 'Town01'
# param record = '~/record'
model scenic.simulators.carla.model

# Define constants
TRAFFIC_LIGHT_LOOKAHEAD_DISTANCE = 15

intersec = Uniform(*network.intersections)
startLane = Uniform(*intersec.incomingLanes)
maneuver = Uniform(*startLane.maneuvers)
testVehicle_trajectory = [maneuver.startLane, maneuver.connectingLane, maneuver.endLane]

behavior EgoBehaviorTL(trajectory):
    try:
        do FollowTrajectoryBehavior(trajectory = trajectory)
    interrupt when withinDistanceToRedYellowTrafficLight(self, TRAFFIC_LIGHT_LOOKAHEAD_DISTANCE):
        take SetBrakeAction(1.0)
    
spot = new OrientedPoint in maneuver.startLane.centerline
ego = new Car at spot,
    with behavior EgoBehaviorTL(trajectory = testVehicle_trajectory)

record ego.position as egoPos
record getClosestTrafficLightStatus(ego, 100) as trafficLight

# if ego._getClosestTrafficLight(100) is not None:
#     record ego._getClosestTrafficLight(100).get_transform().location as trafficLight
#     print("here")
# else:
#     record ego._getClosestTrafficLight(100) as trafficLight
#     print("there")

require 20 <= (distance to intersec) <= 25
terminate when (distance to spot) > 50