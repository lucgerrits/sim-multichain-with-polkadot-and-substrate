# choose_test_prefix = "big_tests_"
# collator_format_1 = "1_collator" 
# collator_format_2 = "2_collator" 
# collator_format_3 = "3_collator" 

choose_test_prefix = "oh_yeay_" 
collator_format_1 = "1collator" 
collator_format_2 = "2collator" 
collator_format_3 = "3collator" 

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

set yrange[0:50]
set grid y

set ylabel "Avg Output TPS"
set xlabel "Input TPS"

set datafile separator comma
set key reverse left top Left

plot './block_logs/'.choose_test_prefix.'renault_'.collator_format_1.'_stats_values.csv' using 3:7:xtic(1) title "OEM" lc rgbcolor "blue" lt 1, \
    '' using 0:0:xtic(1):12 with labels font ",15" offset -1,0 tc rgb "red" rotate left notitle, \
    './block_logs/'.choose_test_prefix.'insurance_'.collator_format_1.'_stats_values.csv' using 3:7:xtic(1) title "Insurance" lc rgbcolor "pink" lt 1, \
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

set yrange[0:70]
set grid y

set ylabel "Avg Output TPS"
set xlabel "Input TPS"

set datafile separator comma
set key reverse left top Left

plot './block_logs/'.choose_test_prefix.'renault_'.collator_format_2.'_stats_values.csv' using 3:7:xtic(1) title "OEM" lc rgbcolor "blue" lt 1, \
    '' using 0:0:xtic(1):12 with labels font ",15" offset -1,0 tc rgb "red" rotate left notitle, \
    './block_logs/'.choose_test_prefix.'insurance_'.collator_format_2.'_stats_values.csv' using 3:7:xtic(1) title "Insurance" lc rgbcolor "pink" lt 1, \
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
set key reverse left top Left

plot './block_logs/'.choose_test_prefix.'renault_'.collator_format_3.'_stats_values.csv' using 3:7:xtic(1) title "OEM" lc rgbcolor "blue" lt 1, \
    '' using 0:0:xtic(1):12 with labels font ",15" offset -1,0 tc rgb "red" rotate left notitle, \
    './block_logs/'.choose_test_prefix.'insurance_'.collator_format_3.'_stats_values.csv' using 3:7:xtic(1) title "Insurance" lc rgbcolor "pink" lt 1, \
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

set yrange[0:70]
set grid y

set ylabel "Avg Blocktime (s)"
set xlabel "Input TPS"

set datafile separator comma
set key reverse left top Left

plot './block_logs/'.choose_test_prefix.'renault_'.collator_format_1.'_stats_values.csv' using 5:9:xtic(1) title "OEM" lc rgbcolor "blue" lt 1, \
    './block_logs/'.choose_test_prefix.'insurance_'.collator_format_1.'_stats_values.csv' using 5:9:xtic(1) title "Insurance" lc rgbcolor "pink" lt 1


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

set yrange[0:50]
set grid y

set ylabel "Avg Blocktime (s)"
set xlabel "Input TPS"

set datafile separator comma
set key reverse left top Left

plot './block_logs/'.choose_test_prefix.'renault_'.collator_format_2.'_stats_values.csv' using 5:9:xtic(1) title "OEM" lc rgbcolor "blue" lt 1, \
    './block_logs/'.choose_test_prefix.'insurance_'.collator_format_2.'_stats_values.csv' using 5:9:xtic(1) title "Insurance" lc rgbcolor "pink" lt 1

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

set yrange[0:30]
set grid y

set ylabel "Avg Blocktime (s)"
set xlabel "Input TPS"

set datafile separator comma
set key reverse left top Left

plot './block_logs/'.choose_test_prefix.'renault_'.collator_format_3.'_stats_values.csv' using 5:9:xtic(1) title "OEM" lc rgbcolor "blue" lt 1, \
    './block_logs/'.choose_test_prefix.'insurance_'.collator_format_3.'_stats_values.csv' using 5:9:xtic(1) title "Insurance" lc rgbcolor "pink" lt 1



unset multiplot 


######################################## test time ##################################################


set terminal postscript eps enhanced color font 'Times-Roman,18' size 6,7
set output "stats_cloud_test_time.eps"

set multiplot layout 3,1 


set title "1 Collator - Input TPS vs Test Time"

set style data histogram
set style histogram cluster gap 1
set style fill solid 0.5
set boxwidth 0.9
set xtics format "" nomirror
set grid ytics
# set style histogram errorbars linewidth 1 
# set errorbars linecolor black
set bars front

# set yrange[0:800]
set grid y
set autoscale y

set ylabel "Test Time (s)"
set xlabel "Input TPS"

set datafile separator comma
set key reverse left top Left

plot './block_logs/'.choose_test_prefix.'renault_'.collator_format_1.'_stats_values.csv' using 13:xtic(1) title "OEM" lc rgbcolor "blue" lt 1, \
    './block_logs/'.choose_test_prefix.'insurance_'.collator_format_1.'_stats_values.csv' using 13:xtic(1) title "Insurance" lc rgbcolor "pink" lt 1


set title "2 Collators - Input TPS vs Test Time"

set style data histogram
set style histogram cluster gap 1
set style fill solid 0.5
set boxwidth 0.9
set xtics format "" nomirror
set grid ytics
# set style histogram errorbars linewidth 1 
# set errorbars linecolor black
set bars front

# set yrange[0:800]
set grid y
set autoscale y

set ylabel "Test Time (s)"
set xlabel "Input TPS"

set datafile separator comma
set key reverse left top Left

plot './block_logs/'.choose_test_prefix.'renault_'.collator_format_2.'_stats_values.csv' using 13:xtic(1) title "OEM" lc rgbcolor "blue" lt 1, \
    './block_logs/'.choose_test_prefix.'insurance_'.collator_format_2.'_stats_values.csv' using 13:xtic(1) title "Insurance" lc rgbcolor "pink" lt 1

set title "3 Collators - Input TPS vs Test Time"

set style data histogram
set style histogram cluster gap 1
set style fill solid 0.5
set boxwidth 0.9
set xtics format "" nomirror
set grid ytics
# set style histogram errorbars linewidth 1 
# set errorbars linecolor black
set bars front

# set yrange[0:800]
set grid y
set autoscale y

set ylabel "Test Time (s)"
set xlabel "Input TPS"

set datafile separator comma
set key reverse left top Left

plot './block_logs/'.choose_test_prefix.'renault_'.collator_format_3.'_stats_values.csv' using 13:xtic(1) title "OEM" lc rgbcolor "blue" lt 1, \
    './block_logs/'.choose_test_prefix.'insurance_'.collator_format_3.'_stats_values.csv' using 13:xtic(1) title "Insurance" lc rgbcolor "pink" lt 1



unset multiplot 