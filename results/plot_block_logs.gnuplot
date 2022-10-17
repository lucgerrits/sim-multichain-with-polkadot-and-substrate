# set terminal pngcairo size 600,400
set output "block_logs.eps"
set terminal postscript eps enhanced color font 'Times-Roman,18' size 9,9

# set multiplot layout 4,1 
set multiplot layout 2,1 

block_start=0
block_stop=150
block_time_stop=60
extrinsic_cnt_stop=5
######################################

set title "Block time for each chain"

set grid ytics lc rgb "black" lw 1.5 lt 0.1
set grid xtics lc rgb "black" lw 1.5 lt 0.1


set xlabel "Block number"
set ylabel "Block time (sec)"

set yrange [0:block_time_stop]
set xrange [block_start:block_stop]

#csv settings:
set datafile separator ","

plot "block_logs/block_times_Rococo Local Testnet.csv" using 1:2 with linespoints lw 2 title "Relay-chain", \
    "block_logs/block_times_Renault Chain.csv" using 1:2 with linespoints lw 2 title "Renault", \
    "block_logs/block_times_Insurance Chain.csv" using 1:2 with linespoints lw 2 title "Insurance"
######################################

set title "Extrinsic count for each chain"

set grid ytics lc rgb "black" lw 1.5 lt 0.1
set grid xtics lc rgb "black" lw 1.5 lt 0.1


set xlabel "Block number"
set ylabel "Extrinsic count"

set yrange [0:extrinsic_cnt_stop]
set xrange [block_start:block_stop]

#csv settings:
set datafile separator ","

plot "block_logs/extrinsic_cnt_Rococo Local Testnet.csv" using 1:2 with linespoints lw 2 title "Relay-chain", \
    "block_logs/extrinsic_cnt_Renault Chain.csv" using 1:2 with linespoints lw 2 title "Renault", \
    "block_logs/extrinsic_cnt_Insurance Chain.csv" using 1:2 with linespoints lw 2 title "Insurance"
######################################

unset multiplot 