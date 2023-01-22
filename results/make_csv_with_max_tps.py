import glob
import csv
import re

def extract_int_tps(string):
    parsed_string = re.findall(r'\d+tps', string)
    if len(parsed_string) == 0:
        return None
    parsed_int = int(re.findall(r'\d+', parsed_string[0])[0])
    return parsed_int

def generate_csv(prefix_path):
    # Get a list of all CSV files that start with "big_tests_" in the prefix path folder
    csv_files = glob.glob(f"./block_logs/{prefix_path}/big_tests_*.csv")

    # Create an empty list to store the results
    results = []

    # Iterate over the CSV files
    for file in csv_files:
        # Open the current file
        with open(file, 'r') as f:
            # Create a CSV reader object
            reader = csv.DictReader(f)
            # Initialize a variable to store the maximum "tps" value
            max_tps = 0
            # Iterate over the rows of the current file
            for row in reader:
                # Update the maximum "tps" value if the current value is greater
                if float(row['tps']) > max_tps:
                    max_tps = round(float(row['tps']), 2)
            # Append the current file's name TPS and maximum "tps" value to the results list
            results.append([extract_int_tps(file), max_tps])

    # Write the results to a new CSV file
    with open(f'{prefix_path}_max_tps_values.csv', 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['Input TPS', 'Max Output TPS'])
        writer.writerows(results)

generate_csv("renault")
generate_csv("insurance")