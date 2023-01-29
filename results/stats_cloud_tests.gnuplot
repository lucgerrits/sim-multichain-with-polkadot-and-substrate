set terminal postscript eps enhanced color font 'Times-Roman,20' size 6,6
set output "stats_cloud_2_collator_tests.eps"

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

plot 'renault_2_collator_stats_values.csv' using 3:7:xtic(1) title "Renault avg Output TPS" lc rgbcolor "blue" lt 1, \
    '' using 0:0:xtic(1):12 with labels font ",15" offset -1,0 tc rgb "red" rotate left notitle, \
    'insurance_2_collator_stats_values.csv' using 3:7:xtic(1) title "Insurance avg Output TPS" lc rgbcolor "pink" lt 1, \
    '' using 0:0:12:xtic(1) with labels font ",15" offset 1,0 tc rgb "red" rotate left notitle



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

set yrange[0:40]
set grid y

set ylabel "Avg Blocktime"
set xlabel "Input TPS"

set datafile separator comma

plot 'renault_2_collator_stats_values.csv' using 5:9:xtic(1) title "Renault avg Blocktime" lc rgbcolor "blue" lt 1, \
    'insurance_2_collator_stats_values.csv' using 5:9:xtic(1) title "Insurance avg Blocktime" lc rgbcolor "pink" lt 1


unset multiplot 


##########################################################################################


set terminal postscript eps enhanced color font 'Times-Roman,18' size 6,6
set output "stats_cloud_1_collator_tests.eps"

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

plot 'renault_1_collator_stats_values.csv' using 3:7:xtic(1) title "Renault avg Output TPS" lc rgbcolor "blue" lt 1, \
    '' using 0:0:xtic(1):12 with labels font ",15" offset -1,0 tc rgb "red" rotate left notitle, \
    'insurance_1_collator_stats_values.csv' using 3:7:xtic(1) title "Insurance avg Output TPS" lc rgbcolor "pink" lt 1, \
    '' using 0:0:12:xtic(1) with labels font ",15" offset 1,0 tc rgb "red" rotate left notitle



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

set yrange[0:40]
set grid y

set ylabel "Avg Blocktime"
set xlabel "Input TPS"

set datafile separator comma

plot 'renault_1_collator_stats_values.csv' using 5:9:xtic(1) title "Renault avg Blocktime" lc rgbcolor "blue" lt 1, \
    'insurance_1_collator_stats_values.csv' using 5:9:xtic(1) title "Insurance avg Blocktime" lc rgbcolor "pink" lt 1


unset multiplot 