# set terminal pngcairo size 600,400
set output "plot_tps_parachains.eps"
set terminal postscript eps enhanced color font 'Times-Roman,18' size 9,5

# set multiplot layout 4,1 
set multiplot layout 1,1 

block_start=0
block_stop=100
######################################

set title "TPS for each chain"

set grid ytics lc rgb "black" lw 1.5 lt 0.1
set grid xtics lc rgb "black" lw 1.5 lt 0.1


set xlabel "Block number"
set ylabel "TPS"

# set yrange [0:500]
# set xrange [block_start:block_stop]

#csv settings:
set datafile separator ","

plot "block_logs/block_stats_Renault Chain.csv" using 1:5 with linespoints lw 2 title "Renault", \
    "block_logs/block_stats_Insurance Chain.csv" using 1:5 with linespoints lw 2 title "Insurance"
    
######################################

unset multiplot 