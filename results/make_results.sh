#!/bin/bash

echo "Ignore 'No such file or directory' errors"
./move_files.sh

echo "Making CSV files with stats"
python make_csv_with_stats.py

echo "Making gnuplot files"
gnuplot -p stats_cloud_tests.gnuplot

echo "Done!"