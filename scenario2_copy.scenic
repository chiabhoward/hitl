param map = localPath('../Scenic/assets/maps/CARLA/Town01.xodr')
param carla_map = 'Town01'
# param record = '~/record'
model scenic.simulators.carla.model

AV_speed = 1.5 # mph to m/s conversion: 30 mph = 13.41 m/s and 5 mph = 2.24 m/s
pickup_speed = 1 # mph to m/s conversion: 30 mph = 13.41 m/s and 5 mph = 2.24 m/s
brake_distance = 10 # meters

intersec = Uniform(*network.intersections)
startLane = Uniform(*intersec.incomingLanes)
maneuver = Uniform(*startLane.maneuvers)
trajectory = [maneuver.startLane, maneuver.connectingLane, maneuver.endLane]

behavior AVBehavior(trajectory):
    try:
        do FollowTrajectoryBehavior(target_speed = AV_speed, trajectory = trajectory)
    
    interrupt when (distance to pickup) < brake_distance:
        take SetBrakeAction(1.0)

behavior AVBadBehavior(trajectory):
    do FollowTrajectoryBehavior(target_speed = AV_speed, trajectory = trajectory)
    
behavior PickupBehavior(trajectory):
    do FollowTrajectoryBehavior(target_speed = pickup_speed, trajectory = trajectory)

spot = new OrientedPoint in maneuver.startLane.centerline

ego = new Car at spot,
    facing roadDirection,
    with behavior AVBehavior(trajectory = trajectory)

spotPickup = new OrientedPoint at (0, 10, 0) relative to ego

pickup = new Car at spotPickup,
    facing roadDirection,
    with behavior PickupBehavior(trajectory = trajectory)  

record pickup.position as puPos

require ego can see pickup
terminate when (distance to spot) > 50 or (distance to pickup) < 1 or (distance to pickup) > 50