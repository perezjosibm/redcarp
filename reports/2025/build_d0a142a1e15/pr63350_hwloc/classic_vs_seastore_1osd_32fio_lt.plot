# Extending this to compare build: classic vs seastore (_b1e4a2b) vs hwloc (pr _d0a142a1e15_pr63350)
set terminal pngcairo size 650,320 enhanced font 'Verdana,10'
#set term svg size 650,320 enhanced font 'Verdana,10'
#set key outside horiz bottom center box noreverse noenhanced autotitle
set key box right Left noreverse title 'OSD'
set datafile missing '-'
#set datafile separator ","
#set xtics border in scale 1,0.5 nomirror rotate by -45  autojustify
set style data histogram
set style fill solid border
set boxwidth 0.8 absolute
set style fill solid 1.00 border lt -1
set style histogram clustered gap 1 title textcolor lt -1
set bmargin 5
set tmargin 2
set style data histograms
set xtics border scale 1,0 nomirror autojustify norangelimit

set ylabel "IOPs"
set xlabel "Workload"
set grid
set key autotitle columnheader
absoluteBoxwidth = 0.8
dx = 1/6.0 * (1 - absoluteBoxwidth)/2.0
set yrange [0:*]
set offset 0,0,graph 0.05,0

set output 'classic_vs_seastore_1osd_32fio_rand_hwloc.png'
set title "Classic vs Crimson 4k Random workloads (Single OSD) PR63350"

$DataIOPS <<EOD
Workload Classic  Seastore SeastoreHwloc
randread4k  84027.49  138753.52 68695.43
randwrite4k 48125.57  27985.40  9829.34
EOD

plot $DataIOPS using 2:xtic(1) ls 1 ti 'Classic' axis x1y1, \
     '' using 3:xtic(1) ls 2 ti 'Seastore' axis x1y1, \
     '' using 4:xtic(1) ls 3 ti 'Seastore-hwloc' axis x1y1, \
    '' u ($0 - dx):2:2 with labels right offset -1,1 ,\
         '' u ($0 + dx):3:3 with labels left offset 1,1 ,\
         '' u ($0 + dx):4:4 with labels left offset 1,1

set output 'classic_vs_seastore_1osd_32fio_seq_hwloc.png'
set title "Classic vs Crimson 64k Sequential workloads (Single OSD) PR63350"

set ylabel "MBs"
$DataIOPS <<EOD
Workload Classic  Seastore SeastoreHwloc
seqread64k 2066.22  1692.33 3333.56
seqwrite64k 1664.70  1591.14 782.64
EOD
plot $DataIOPS using 2:xtic(1) ls 1 ti 'Classic' axis x1y1, \
     '' using 3:xtic(1) ls 2 ti 'Seastore' axis x1y1, \
     '' using 4:xtic(1) ls 3 ti 'Seastore-hwloc' axis x1y1, \
    '' u ($0 - dx):2:2 with labels right offset -1,1 ,\
         '' u ($0 + dx):3:3 with labels left offset 1,1 ,\
         '' u ($0 + dx):4:4 with labels left offset 1,1

set output 'classic_vs_seastore_1osd_32fio_lat_hwloc.png'
set ylabel "Latency (ms)"
set title "Classic vs Crimson 4k Random workloads (Single OSD) PR63350"
plot 'build_b1e4a2b/classic_1osd_32fio_lt.dat' using 5:xtic(1) ls 1 ti 'Classic' axis x1y1, \
     'build_b1e4a2b/seastore_1osd_32fio_lt.dat' using 5:xtic(1) ls 2 ti 'Seastore' axis x1y1, \
     'seastore_1osd_32fio_hwloc_lt.dat' using 5:xtic(1) ls 3 ti 'Seastore-hwloc' axis x1y1

# Need to extend parse-top.py with Classic thread names to get the following plot
# set output 'classic_vs_seastore_1osd_32fio_seq_cpu.png'
# set title "Classic vs Crimson 64k Sequential workloads (Single OSD)"
# plot 'classic_1osd_32fio_lt.dat' using 10:xtic(1) ls 1 ti 'Classic' axis x1y1, \
#      'seastore_1osd_32fio_lt.dat' using 10:xtic(1) ls 2 ti 'Seastore' axis x1y1
