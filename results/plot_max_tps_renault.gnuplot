# set terminal postscript eps enhanced font "Times-Roman,20"
# set size ratio 0.5
# set output "max_tps_renault.eps"

# # set print "output.txt"
# set style data histograms
# set style histogram rowstacked
# set style fill solid border -1
# set boxwidth 0.9
# set xtics rotate by -45
# set ylabel "Max Output TPS"
# set xlabel "Input TPS"

# do for [file in system("ls block_logs/renault/big_tests_*.csv")] {
    
#     # set title sprintf("Input TPS: %s", system(sprintf("echo %s | awk -F'_' '{print $NF}' | awk -F'.' '{print $1}'", file)))

#     plot file using (stringcolumn(3) eq "max" ? $2 : 1/0):xtic(1) title columnheader(2) with histograms
# }


set terminal postscript eps enhanced color font 'Times-Roman,18' size 6,4
set output "max_tps_renault.eps"

# set style data histograms
# set style histogram rowstacked
set style fill solid border -1
set boxwidth 0.9

# set xtics rotate by -45
# set xtics border in scale 0,0 nomirror rotate by 90  offset character -1, -4, 0
# set xtics (10, 50, 100)
# set xtics (10, 50, 100, 200, 400, 600, 1000, 1500)

set yrange[0:150]
set grid y

set ylabel "Max Output TPS"
set xlabel "Input TPS"

set style fill transparent solid 0.7
# Input file contains comma-separated values fields
set datafile separator comma


plot 'renault_max_tps_values.csv' using 2:xtic(1) title "Renault max Output TPS" lc rgbcolor "blue" lt 1 with histograms, \
    'insurance_max_tps_values.csv' using 2:xtic(1) title "Insurance max Output TPS" lc rgbcolor "pink" lt 1 with histograms

