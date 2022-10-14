# set terminal pngcairo size 600,400
set output "finished_and_invalid_rate.eps"

set terminal postscript eps enhanced color font 'Times-Roman,18' size 9,10

# set multiplot layout 4,1 
set multiplot layout 1,1 

######################################

set title "Block time"

set grid ytics lc rgb "black" lw 1.5 lt 0.1
set grid xtics lc rgb "black" lw 1.5 lt 0.1


set xlabel "Block number"
set ylabel "Block time (sec)"

# set yrange [0 to 2500]
# set xtics ("200" 200, "400" 400, "600" 600, "800" 800, "1000" 1000, "1200" 1200, "1400" 1400, "1600" 1600, "2000" 2000, "2500" 2500)

set key at graph 0.15, 0.95

#csv settings:
set datafile separator ","

plot "block_logs/block_times_Rococo Local Testnet.csv" using 1:2 with linespoints lw 2 title "Relay-chain", \
    "block_logs/block_times_Renault Chain.csv" using 1:2 with linespoints lw 2 title "Renault", \
    "block_logs/block_times_Insurance Chain.csv" using 1:2 with linespoints lw 2 title "Insurance"
######################################

# set title "Renault chain"

# set grid ytics lc rgb "black" lw 1.5 lt 0.1
# set grid xtics lc rgb "black" lw 1.5 lt 0.1


# set xlabel "Block number"
# set ylabel "Block time (sec)"

# # set yrange [0 to 2500]
# # set xtics ("200" 200, "400" 400, "600" 600, "800" 800, "1000" 1000, "1200" 1200, "1400" 1400, "1600" 1600, "2000" 2000, "2500" 2500)

# set key at graph 0.15, 0.95

# #csv settings:
# set datafile separator ","

# plot "block_logs/block_times_Renault Chain.csv" using 1:2 with linespoints lw 2 title "5 nodes"

######################################

unset multiplot 