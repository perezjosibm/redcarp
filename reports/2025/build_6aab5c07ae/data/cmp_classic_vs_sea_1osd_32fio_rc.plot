set terminal pngcairo size 650,420 enhanced font 'Verdana,10'
set key box left Left noreverse title 'OSD (build b1e4a2b)'
set datafile missing '-'
set key outside horiz bottom center box noreverse noenhanced autotitle
set grid
set autoscale
set xtics border in scale 1,0.5 nomirror rotate by -45  autojustify

# Unique build_6aab5c07ae
# Crimson comparison  Classic vs Seastore BE using the bal_OSD CPU allocation
# Target dir: 
# strategy
# Hockey stick graph:
set style function linespoints

set ylabel "Latency (ms)"
set xlabel "IOPS (thousand)"
set ytics nomirror
set y2tics
set tics out
#set autoscale y
set logscale y

# Randread
set output 'classic_vs_seastore_1osd_32fio_randread_iops_vs_lat.png'
set title "1osd-32fio-randread"
plot 'sea_1osd_dual_randread.dat' every ::1::5 index 0 using ($2/1e3):4 t 'Seastore-dual' w lp axes x1y1 lw 4 lc 2,\
 'sea_1osd_single_randread.dat'  every ::1::5 index 0 using ($2/1e3):4 t 'Seastore-single' w lp axes x1y1 lw 4 lc 3,\
 'classic_1osd_32fio_rc_1procs_randread.dat'  every ::1::5 index 0 using ($2/1e3):4 t 'Classic' w lp axes x1y1 lw 4 lc 4

# RandWrite
set output 'classic_vs_seastore_1osd_32fio_randwrite_iops_vs_lat.png'
set title "1osd-32fio-randwrite"
plot 'sea_1osd_dual_randwrite.dat'  every ::1::5 index 0 using ($2/1e3):4 t 'Seastore-dual' w lp axes x1y1 lw 4 lc 2,\
 'sea_1osd_single_randwrite.dat'  every ::1::5 index 0 using ($2/1e3):4 t 'Seastore-single' w lp axes x1y1 lw 4 lc 3,\
 'classic_1osd_32fio_rc_1procs_randwrite.dat'  every ::1::5 index 0 using ($2/1e3):4 t 'Classic' w lp axes x1y1 lw 4 lc 4

set xlabel "MBs (thousand)"
# SeqWrite
set output 'classic_vs_seastore_1osd_32fio_seqwrite_iops_vs_lat.png'
set title "1osd-32fio-seqwrite"
plot 'sea_1osd_dual_seqwrite.dat' every ::1::5  index 0 using ($2/1e3):4:5 t 'Seastore-dual' w yerr axes x1y1 lc 2,\
 '' every ::1::5  index 0 using ($2/1e3):4 notitle w lp lc 2 axes x1y1,\
 'sea_1osd_single_seqwrite.dat'  every ::1::5 index 0 using ($2/1e3):4:5 t 'Seastore-single' w yerr axes x1y1 lc 3,\
 '' every ::1::5  index 0 using ($2/1e3):4 notitle w lp lc 3 axes x1y1,\
 'classic_1osd_32fio_rc_1procs_seqwrite.dat'  every ::1::5 index 0 using ($2/1e3):4:5 t 'Classic' w yerr axes x1y1 lc 4,\
 '' every ::1::5  index 0 using ($2/1e3):4 notitle w lp lc 4 axes x1y1

# Seqread
#set logscale xy
set output 'classic_vs_seastore_1osd_32fio_seqread_iops_vs_lat.png'
set title "1osd-32fio-seqread"
plot 'sea_1osd_dual_seqread.dat'  every ::1::5 index 0 using ($2/1e3):4:5 t 'Seastore' w yerr axes x1y1 lc 2,\
 '' every ::1::5  index 0 using ($2/1e3):4 notitle w lp lc 2 axes x1y1,\
 'sea_1osd_single_seqread.dat'  every ::1::5 index 0 using ($2/1e3):4:5 t 'Seastore-single' w yerr axes x1y1 lc 3,\
 '' every ::1::5  index 0 using ($2/1e3):4 notitle w lp lc 3 axes x1y1,\
 'classic_1osd_32fio_rc_1procs_seqread.dat'  every ::1::5 index 0 using ($2/1e3):4:5 t 'Classic' w yerr axes x1y1 lc 4,\
 '' every ::1::5  index 0 using ($2/1e3):4 notitle w lp lc 4 axes x1y1

