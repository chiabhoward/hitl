import scenic
from scenic.simulators.carla import CarlaSimulator
import csv
import random
import argparse
import os

def add_arguments():
    parser = argparse.ArgumentParser()
    
    # Add arguments to the parser
    parser.add_argument('-i', '--input_scenario', type=str, required=True)
    parser.add_argument('-b', '--bad_behavior', action='store_true')
    parser.add_argument('-d', '--output_directory', type=str, default='./dataset')
    parser.add_argument('-r', '--record_directory', type=str, default='./record')
    parser.add_argument('-s', '--seed', type=int, default=0)

    return parser.parse_args()

def main():
    args = add_arguments()

    random.seed(args.seed)

    behavior_type = 'bad' if args.bad_behavior else 'good'
    scenario_dataset_dir = os.path.join(args.output_directory, args.input_scenario, behavior_type)
    if not os.path.exists(scenario_dataset_dir):
        print(f'Output directory {scenario_dataset_dir} does not exist. Creating it...')
        os.makedirs(scenario_dataset_dir)

    output_filepath = os.path.join(scenario_dataset_dir, 'output'+str(args.seed)+'.csv')

    input_scenic = args.input_scenario + '_' + behavior_type + '.scenic'
    output_record_path = os.path.join(args.record_directory, args.input_scenario, behavior_type) if args.record_directory else ''

    scenario = scenic.scenarioFromFile(input_scenic,
                                    model='scenic.simulators.carla.model',
                                    mode2D=True)
    scene, _ = scenario.generate()
    simulator = CarlaSimulator(carla_map = 'Town01',
                            record=output_record_path,
                            map_path='../Scenic/assets/maps/CARLA/Town01.xodr',
                            scenario_number=args.seed,)
    simulation = simulator.simulate(scene)

    if simulation: # 'simulate' can return None if simulation fails
        result = simulation.records

        time_data = list(range(len(result['egoPos'])))
        ego_pos_data = [(data[1][0], data[1][1], data[1][2]) for data in result['egoPos']]
        traffic_light_pos_data = [(data[1][0], data[1][1], data[1][2]) for data in result['trafficLightPos']]
        traffic_light_status_data = [(data[1],) for data in result['trafficLight']]

        features = ['time', 'ego_x', 'ego_y', 'ego_z', 'traffic_light_x', 'traffic_light_y', 'traffic_light_z', 'traffic_light_status']
        trace_data = [(t,) + ed + tlpd + tlsd for t, ed, tlpd, tlsd in zip(time_data, ego_pos_data, traffic_light_pos_data, traffic_light_status_data)]

        with open(output_filepath, mode='w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(features)
            writer.writerows(trace_data)

if __name__ == '__main__':
    main()




