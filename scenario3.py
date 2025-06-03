import scenic
from scenic.simulators.carla import CarlaSimulator
import csv
import random
import argparse
import os

def add_arguments():
    parser = argparse.ArgumentParser()
    
    # Add arguments to the parser
    parser.add_argument('-i', '--input_filename', type=str, default='example3.scenic')
    parser.add_argument('-d', '--output_directory', type=str, default='/')
    parser.add_argument('-o', '--output_filename', type=str, default='output.csv')
    parser.add_argument('-s', '--seed', type=int, default=0)

    return parser.parse_args()

def main():
    args = add_arguments()

    random.seed(args.seed)

    if not os.path.exists(args.output_directory):
        print(f"Output directory '{args.output_directory} does not exist. Creating it...")
        os.makedirs(args.output_directory)

    output_filepath = os.path.join(args.output_directory, args.output_filename)

    scenario = scenic.scenarioFromFile(args.input_filename,
                                    model='scenic.simulators.carla.model',
                                    mode2D=True)
    scene, _ = scenario.generate()
    simulator = CarlaSimulator(carla_map = 'Town01',
                            map_path='../Scenic/assets/maps/CARLA/Town01.xodr',)
    simulation = simulator.simulate(scene)

    if simulation: # 'simulate' can return None if simulation fails
        result = simulation.records

        time_data = list(range(len(result['egoPos'])))
        ego_data = [(data[1][0], data[1][1], data[1][2]) for data in result['egoPos']]
        traffic_light_data = [(data[1],) for data in result['trafficLight']]

        features = ['time', 'ego_x', 'ego_y', 'ego_z', 'traffic_light_status']
        trace_data = [(t,) + ed + bd for t, ed, bd in zip(time_data, ego_data, traffic_light_data)]

        with open(output_filepath, mode='w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(features)
            writer.writerows(trace_data)

if __name__ == '__main__':
    main()




