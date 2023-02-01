######################################## output tps ##################################################
set terminal postscript eps enhanced color font 'Times-Roman,20' size 6,7
set output "stats_cloud_output_tps.eps"

set multiplot layout 3,1 

set title "1 Collator - Input TPS vs Avg Output TPS"

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

plot './block_logs/renault_1_collator_stats_values.csv' using 3:7:xtic(1) title "Renault avg Output TPS" lc rgbcolor "blue" lt 1, \
    '' using 0:0:xtic(1):12 with labels font ",15" offset -1,0 tc rgb "red" rotate left notitle, \
    './block_logs/insurance_1_collator_stats_values.csv' using 3:7:xtic(1) title "Insurance avg Output TPS" lc rgbcolor "pink" lt 1, \
    '' using 0:0:12:xtic(1) with labels font ",15" offset 1,0 tc rgb "red" rotate left notitle


set title "2 Collators - Input TPS vs Avg Output TPS"

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

plot './block_logs/renault_2_collator_stats_values.csv' using 3:7:xtic(1) title "Renault avg Output TPS" lc rgbcolor "blue" lt 1, \
    '' using 0:0:xtic(1):12 with labels font ",15" offset -1,0 tc rgb "red" rotate left notitle, \
    './block_logs/insurance_2_collator_stats_values.csv' using 3:7:xtic(1) title "Insurance avg Output TPS" lc rgbcolor "pink" lt 1, \
    '' using 0:0:12:xtic(1) with labels font ",15" offset 1,0 tc rgb "red" rotate left notitle

set title "3 Collators - Input TPS vs Avg Output TPS"

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

plot './block_logs/renault_3_collator_stats_values.csv' using 3:7:xtic(1) title "Renault avg Output TPS" lc rgbcolor "blue" lt 1, \
    '' using 0:0:xtic(1):12 with labels font ",15" offset -1,0 tc rgb "red" rotate left notitle, \
    './block_logs/insurance_3_collator_stats_values.csv' using 3:7:xtic(1) title "Insurance avg Output TPS" lc rgbcolor "pink" lt 1, \
    '' using 0:0:12:xtic(1) with labels font ",15" offset 1,0 tc rgb "red" rotate left notitle


unset multiplot 


######################################## blocktime ##################################################


set terminal postscript eps enhanced color font 'Times-Roman,18' size 6,7
set output "stats_cloud_blocktime.eps"

set multiplot layout 3,1 


set title "1 Collator - Input TPS vs Avg Blocktime"

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

plot './block_logs/renault_1_collator_stats_values.csv' using 5:9:xtic(1) title "Renault avg Blocktime" lc rgbcolor "blue" lt 1, \
    './block_logs/insurance_1_collator_stats_values.csv' using 5:9:xtic(1) title "Insurance avg Blocktime" lc rgbcolor "pink" lt 1


set title "2 Collators - Input TPS vs Avg Blocktime"

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

plot './block_logs/renault_2_collator_stats_values.csv' using 5:9:xtic(1) title "Renault avg Blocktime" lc rgbcolor "blue" lt 1, \
    './block_logs/insurance_2_collator_stats_values.csv' using 5:9:xtic(1) title "Insurance avg Blocktime" lc rgbcolor "pink" lt 1

set title "3 Collators - Input TPS vs Avg Blocktime"

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

plot './block_logs/renault_3_collator_stats_values.csv' using 5:9:xtic(1) title "Renault avg Blocktime" lc rgbcolor "blue" lt 1, \
    './block_logs/insurance_3_collator_stats_values.csv' using 5:9:xtic(1) title "Insurance avg Blocktime" lc rgbcolor "pink" lt 1



unset multiplot 


######################################## test time ##################################################


set terminal postscript eps enhanced color font 'Times-Roman,18' size 6,7
set output "stats_cloud_test_time.eps"

set multiplot layout 3,1 


set title "1 Collator - Input TPS vs test time"

set style data histogram
set style histogram cluster gap 1
set style fill solid 0.5
set boxwidth 0.9
set xtics format "" nomirror
set grid ytics
# set style histogram errorbars linewidth 1 
# set errorbars linecolor black
set bars front

set yrange[0:800]
set grid y

set ylabel "test time"
set xlabel "Input TPS"

set datafile separator comma

plot './block_logs/renault_1_collator_stats_values.csv' using 13:xtic(1) title "Renault test time" lc rgbcolor "blue" lt 1, \
    './block_logs/insurance_1_collator_stats_values.csv' using 13:xtic(1) title "Insurance test time" lc rgbcolor "pink" lt 1


set title "2 Collators - Input TPS vs test time"

set style data histogram
set style histogram cluster gap 1
set style fill solid 0.5
set boxwidth 0.9
set xtics format "" nomirror
set grid ytics
# set style histogram errorbars linewidth 1 
# set errorbars linecolor black
set bars front

set yrange[0:800]
set grid y

set ylabel "test time"
set xlabel "Input TPS"

set datafile separator comma

plot './block_logs/renault_2_collator_stats_values.csv' using 13:xtic(1) title "Renault test time" lc rgbcolor "blue" lt 1, \
    './block_logs/insurance_2_collator_stats_values.csv' using 13:xtic(1) title "Insurance test time" lc rgbcolor "pink" lt 1

set title "3 Collators - Input TPS vs test time"

set style data histogram
set style histogram cluster gap 1
set style fill solid 0.5
set boxwidth 0.9
set xtics format "" nomirror
set grid ytics
# set style histogram errorbars linewidth 1 
# set errorbars linecolor black
set bars front

set yrange[0:800]
set grid y

set ylabel "test time"
set xlabel "Input TPS"

set datafile separator comma

plot './block_logs/renault_3_collator_stats_values.csv' using 13:xtic(1) title "Renault test time" lc rgbcolor "blue" lt 1, \
    './block_logs/insurance_3_collator_stats_values.csv' using 13:xtic(1) title "Insurance test time" lc rgbcolor "pink" lt 1



unset multiplot 