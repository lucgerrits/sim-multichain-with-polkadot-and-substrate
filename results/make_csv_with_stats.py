import glob
import csv
import re
import statistics as stats


def extract_int_tps(string):
    parsed_string = re.findall(r'\d+tps', string)
    if len(parsed_string) == 0:
        return None
    parsed_int = int(re.findall(r'\d+', parsed_string[0])[0])
    return parsed_int


def generate_csv(prefix_path, test_name):
    # Get a list of all CSV files that start with "big_tests_" in the prefix path folder
    csv_files = glob.glob(
        f"./block_logs/{prefix_path}/big_tests_{test_name}_*.csv")

    # Create an empty list to store the results
    results = []

    # Iterate over the CSV files
    for file in csv_files:
        # Open the current file
        with open(file, 'r') as f:
            # Create a CSV reader object
            reader = csv.DictReader(f)
            # Initialize a variable to store the maximum "tps" value
            total_tx = 30000 if (extract_int_tps(file)*60*2) > 30000 else (extract_int_tps(file)*60*2)
            percentage_failed_tx = 0
            success_tx = 0
            failed_tx = 0
            max_tps = 0
            avg_tps = 0.0
            nb_blocks_used = 0
            max_blocktime = 0
            avg_blocktime = 0.0
            tps_list = []
            blocktime_list = []
            # Iterate over the rows of the current file
            for row in reader:
                # Update the maximum "tps" value if the current value is greater
                if float(row['tps']) > max_tps:
                    max_tps = round(float(row['tps']), 2)
                if int(row['transactions']) > 2:
                    success_tx += int(row['transactions']) - 2
                    avg_tps += float(row['tps'])
                    nb_blocks_used += 1
                    avg_blocktime += float(row['blocktime'])
                    tps_list.append(float(row['tps']))
                    blocktime_list.append(float(row['blocktime']))
                if float(row['blocktime']) > max_blocktime:
                    max_blocktime = round(float(row['blocktime']), 2)
            percentage_failed_tx = "{}%".format(round((1 - (success_tx/total_tx))*100, 2)) if round((1 - (success_tx/total_tx))*100, 2) > 0.1 else ""
            failed_tx = total_tx - success_tx
            avg_tps = round(avg_tps/nb_blocks_used, 2)
            avg_blocktime = round(avg_blocktime/nb_blocks_used, 2)
            # Append the current file's name TPS and maximum "tps" value to the results list
            tps_var = round(stats.pvariance(tps_list), 2)
            tps_std = round(stats.pstdev(tps_list), 2)
            blocktime_var = round(stats.pvariance(blocktime_list), 2)
            blocktime_std = round(stats.pstdev(blocktime_list), 2)
            results.append([extract_int_tps(file), max_tps, avg_tps, max_blocktime,
                           avg_blocktime, tps_var, tps_std, blocktime_var, blocktime_std, success_tx, failed_tx, percentage_failed_tx])

    # Write the results to a new CSV file
    with open(f'{prefix_path}_{test_name}_stats_values.csv', 'w', newline='') as f:
        results.sort(key=lambda x: x[0])
        writer = csv.writer(f)
        # writer.writerow(['Input TPS', 'Max Output TPS', 'Avg Output TPS', 'Max Block Time', 'Avg Block Time',
        #                 'TPS Variance', 'TPS Standard Deviation', 'Block Time Variance', 'Block Time Standard Deviation', 'Success TX', 'Failed TX', 'Percentage Failed TX'])
        writer.writerows(results)


generate_csv("renault", "1_collator")
generate_csv("insurance", "1_collator")
generate_csv("renault", "2_collator")
generate_csv("insurance", "2_collator")
generate_csv("renault", "3_collator")
generate_csv("insurance", "3_collator")