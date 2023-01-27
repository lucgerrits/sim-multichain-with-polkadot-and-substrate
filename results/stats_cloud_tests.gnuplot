set terminal postscript eps enhanced color font 'Times-Roman,18' size 6,7
set output "stats_cloud_tests.eps"

set multiplot layout 4,1 

set title "Input TPS vs Max Output TPS"

set style fill solid border -1
set boxwidth 0.9

set yrange[0:100]
set grid y

set ylabel "Max Output TPS"
set xlabel "Input TPS"

set style fill transparent solid 0.7
# Input file contains comma-separated values fields
set datafile separator comma


plot 'renault_stats_values.csv' using 2:xtic(1) title "Renault max Output TPS" lc rgbcolor "blue" lt 1 with histograms, \
    'insurance_stats_values.csv' using 2:xtic(1) title "Insurance max Output TPS" lc rgbcolor "pink" lt 1 with histograms


set title "Input TPS vs Avg Output TPS"

set style fill solid border -1
set boxwidth 0.9

set yrange[0:100]
set grid y

set ylabel "Avg Output TPS"
set xlabel "Input TPS"

set style fill transparent solid 0.7
# Input file contains comma-separated values fields
set datafile separator comma


plot 'renault_stats_values.csv' using 3:xtic(1) title "Renault avg Output TPS" lc rgbcolor "blue" lt 1 with histograms, \
    'insurance_stats_values.csv' using 3:xtic(1) title "Insurance avg Output TPS" lc rgbcolor "pink" lt 1 with histograms


set title "Input TPS vs Max Blocktime"

set style fill solid border -1
set boxwidth 0.9

set yrange[0:50]
set grid y

set ylabel "Max Blocktime"
set xlabel "Input TPS"

set style fill transparent solid 0.7
# Input file contains comma-separated values fields
set datafile separator comma


plot 'renault_stats_values.csv' using 4:xtic(1) title "Renault max Blocktime" lc rgbcolor "blue" lt 1 with histograms, \
    'insurance_stats_values.csv' using 4:xtic(1) title "Insurance max Blocktime" lc rgbcolor "pink" lt 1 with histograms


set title "Input TPS vs Avg Blocktime"

set style fill solid border -1
set boxwidth 0.9

set yrange[0:50]
set grid y

set ylabel "Avg Blocktime"
set xlabel "Input TPS"

set style fill transparent solid 0.7
# Input file contains comma-separated values fields
set datafile separator comma


plot 'renault_stats_values.csv' using 5:xtic(1) title "Renault avg Blocktime" lc rgbcolor "blue" lt 1 with histograms, \
    'insurance_stats_values.csv' using 5:xtic(1) title "Insurance avg Blocktime" lc rgbcolor "pink" lt 1 with histograms


unset multiplot 