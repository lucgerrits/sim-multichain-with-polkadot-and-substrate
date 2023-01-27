set terminal postscript eps enhanced color font 'Times-Roman,18' size 6,5
set output "stats_cloud_tests.eps"

set multiplot layout 2,1 

set title "Input TPS vs Avg Output TPS"

set style data histogram
set style histogram cluster gap 1
set style fill solid 0.5
set boxwidth 0.9
set xtics format "" nomirror
set grid ytics
set style histogram errorbars linewidth 1 
set errorbars linecolor black
set bars front

set yrange[0:80]
set grid y

set ylabel "Avg Output TPS"
set xlabel "Input TPS"

set datafile separator comma

plot 'renault_stats_values.csv' using 3:7:xtic(1) title "Renault avg Output TPS" lc rgbcolor "blue" lt 1, \
    'insurance_stats_values.csv' using 3:7:xtic(1) title "Insurance avg Output TPS" lc rgbcolor "pink" lt 1



set title "Input TPS vs Avg Blocktime"

set style data histogram
set style histogram cluster gap 1
set style fill solid 0.5
set boxwidth 0.9
set xtics format "" nomirror
set grid ytics
set style histogram errorbars linewidth 1 
set errorbars linecolor black
set bars front

set yrange[0:30]
set grid y

set ylabel "Avg Blocktime"
set xlabel "Input TPS"

set datafile separator comma

plot 'renault_stats_values.csv' using 5:9:xtic(1) title "Renault avg Blocktime" lc rgbcolor "blue" lt 1, \
    'insurance_stats_values.csv' using 5:9:xtic(1) title "Insurance avg Blocktime" lc rgbcolor "pink" lt 1


unset multiplot 