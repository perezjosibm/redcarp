# Comparison (same build_6aab5c07ae) between single and dual reactor per physical core.

set terminal pngcairo size 650,420 enhanced font 'Verdana,10'
set key box left Left noreverse title 'OSD (build 6aab5c07ae)'
set datafile missing '-'
set key outside horiz bottom center box noreverse noenhanced autotitle
set grid
set autoscale
set xtics border in scale 1,0.5 nomirror rotate by -45  autojustify

# Unique build 6aab5c07ae
# Crimson comparison  Classic vs Seastore BE using the bal_OSD CPU allocation
# Target dir: classic_vs_sea_b1e4a2b
# strategy: Hockey stick response latency graph
set style function linespoints

set ylabel "Latency (ms)"
set xlabel "IOPS (thousand)"
set ytics nomirror
set y2tics
set tics out
set autoscale y

# Randread
set output 'figures/seastore_1osd_32fio_randread_iops_vs_lat.png'
set title "1osd-32fio-randread (single vs dual reactor per physical core)"
plot 'data/sea_1osd_single_randread.dat' every ::1::5 index 0 using ($2/1e3):4:5 t 'Seastore-single' w yerr axes x1y1 lc 2,\
 ''  every ::1::5 index 0 using ($2/1e3):4 notitle w lp lc 2 axes x1y1,\
 'data/sea_1osd_dual_randread.dat'  every ::1::5 index 0 using ($2/1e3):4:5 t 'Seastore-dual' w yerr axes x1y1 lc 3,\
 '' every ::1::5  index 0 using ($2/1e3):4 notitle w lp lc 3 axes x1y1

# RandWrite
set output 'figures/seastore_1osd_32fio_randwrite_iops_vs_lat.png'
set title "1osd-32fio-randwrite (single vs dual reactor per physical core)"
plot 'data/sea_1osd_single_randwrite.dat'  every ::1::5 index 0 using ($2/1e3):4:5 t 'Seastore-single' w yerr axes x1y1 lc 2,\
 ''  every ::1::5 index 0 using ($2/1e3):4 notitle w lp lc 2 axes x1y1,\
 'data/sea_1osd_dual_randwrite.dat'  every ::1::5 index 0 using ($2/1e3):4:5 t 'Seastore-dual' w yerr axes x1y1 lc 3,\
 '' every ::1::5  index 0 using ($2/1e3):4 notitle w lp lc 3 axes x1y1

set xlabel "MBs (thousand)"
# SeqWrite
set output 'figures/seastore_1osd_32fio_seqwrite_iops_vs_lat.png'
set title "1osd-32fio-seqwrite (single vs dual reactor per physical core)"
plot 'data/sea_1osd_single_seqwrite.dat' every ::1::5  index 0 using ($2/1e3):4:5 t 'Seastore-single' w yerr axes x1y1 lc 2,\
 '' every ::1::5  index 0 using ($2/1e3):4 notitle w lp lc 2 axes x1y1,\
 'data/sea_1osd_dual_seqwrite.dat'  every ::1::5 index 0 using ($2/1e3):4:5 t 'Seastore-dual' w yerr axes x1y1 lc 3,\
 '' every ::1::5  index 0 using ($2/1e3):4 notitle w lp lc 3 axes x1y1

# Seqread
#set logscale xy
set output 'figures/seastore_1osd_32fio_seqread_iops_vs_lat.png'
set title "1osd-32fio-seqread (single vs dual reactor per physical core)"
plot 'data/sea_1osd_single_seqread.dat'  every ::1::5 index 0 using ($2/1e3):4:5 t 'Seastore-single' w yerr axes x1y1 lc 2,\
 '' every ::1::5  index 0 using ($2/1e3):4 notitle w lp lc 2 axes x1y1,\
 'data/sea_1osd_dual_seqread.dat'  every ::1::5 index 0 using ($2/1e3):4:5 t 'Seastore-dual' w yerr axes x1y1 lc 3,\
 '' every ::1::5  index 0 using ($2/1e3):4 notitle w lp lc 3 axes x1y1

## We wont be displaying these, instead will graph the reactor utilisations
#set y2label "CPU"
#set autoscale
#set xlabel "IOPS (thousand)"
#
## Randread
#set output 'classic_vs_seastore_1osd_32fio_randread_iops_vs_lat_osd_cpu.png'
#set title "1osd-32fio-randread-OSD-CPU"
#plot 'sea_1osd_28reactor_32fio_bal_osd_rc_1procs_randread.dat' index 0 using ($2/1e3):8 w lp axes x1y2 lc 2 t 'Seastore',\
# '' index 0 using ($2/1e3):4 notitle w p lc 2 axes x1y1,\
# 'classic_1osd_32fio_rc_1procs_randread.dat' index 0 using ($2/1e3):8 w lp axes x1y2 lc 3 t 'Classic',\
# '' index 0 using ($2/1e3):4 notitle w p lc 3 axes x1y1
#
#
#set output 'classic_vs_seastore_1osd_32fio_randread_iops_vs_lat_fio_cpu.png'
#set title "1osd-32fio-randread-FIO-CPU"
#plot 'sea_1osd_28reactor_32fio_bal_osd_rc_1procs_randread.dat' index 0 using ($2/1e3):10 w lp axes x1y2 lc 2 t 'Seastore',\
# '' index 0 using ($2/1e3):4 notitle w p lc 2 axes x1y1,\
# 'classic_1osd_32fio_rc_1procs_randread.dat' index 0 using ($2/1e3):10 w lp axes x1y2 lc 3 t 'Classic',\
# '' index 0 using ($2/1e3):4 notitle w p lc 3 axes x1y1
#
### Randwrite
#set output 'classic_vs_seastore_1osd_32fio_randwrite_iops_vs_lat_osd_cpu.png'
#set title "1osd-32fio-randwrite-OSD-CPU"
#plot 'sea_1osd_28reactor_32fio_bal_osd_rc_1procs_randwrite.dat' index 0 using ($2/1e3):8 w lp axes x1y2 lc 2 t 'Seastore',\
# '' index 0 using ($2/1e3):4 notitle w p lc 2 axes x1y1,\
# 'classic_1osd_32fio_rc_1procs_randwrite.dat' index 0 using ($2/1e3):8 w lp axes x1y2 lc 3 t 'Classic',\
# '' index 0 using ($2/1e3):4 notitle w p lc 3 axes x1y1
#
#
#set output 'classic_vs_seastore_1osd_32fio_randwrite_iops_vs_lat_fio_cpu.png'
#set title "1osd-32fio-randwrite-FIO-CPU"
#plot 'sea_1osd_28reactor_32fio_bal_osd_rc_1procs_randwrite.dat' index 0 using ($2/1e3):10 w lp axes x1y2 lc 2 t 'Seastore',\
# '' index 0 using ($2/1e3):4 notitle w p lc 2 axes x1y1,\
# 'classic_1osd_32fio_rc_1procs_randwrite.dat' index 0 using ($2/1e3):10 w lp axes x1y2 lc 3 t 'Classic',\
# '' index 0 using ($2/1e3):4 notitle w p lc 3 axes x1y1
#
### Seqread
#set output 'classic_vs_seastore_1osd_32fio_seqread_iops_vs_lat_osd_cpu.png'
#set title "1osd-32fio-seqread-OSD-CPU"
#plot 'sea_1osd_28reactor_32fio_bal_osd_rc_1procs_seqread.dat' index 0 using ($2/1e3):8 w lp axes x1y2 lc 2 t 'Seastore',\
# '' index 0 using ($2/1e3):4 notitle w p lc 2 axes x1y1,\
# 'classic_1osd_32fio_rc_1procs_seqread.dat' index 0 using ($2/1e3):8 w lp axes x1y2 lc 3 t 'Classic',\
# '' index 0 using ($2/1e3):4 notitle w p lc 3 axes x1y1
#
#set output 'classic_vs_seastore_1osd_32fio_seqread_iops_vs_lat_fio_cpu.png'
#set title "1osd-32fio-seqread-FIO-CPU"
#plot 'sea_1osd_28reactor_32fio_bal_osd_rc_1procs_seqread.dat' index 0 using ($2/1e3):10 w lp axes x1y2 lc 2 t 'Seastore',\
# '' index 0 using ($2/1e3):4 notitle w p lc 2 axes x1y1,\
# 'classic_1osd_32fio_rc_1procs_seqread.dat' index 0 using ($2/1e3):10 w lp axes x1y2 lc 3 t 'Classic',\
# '' index 0 using ($2/1e3):4 notitle w p lc 3 axes x1y1
#
### Seqwrite
#set output 'classic_vs_seastore_1osd_32fio_seqwrite_iops_vs_lat_osd_cpu.png'
#set title "1osd-32fio-seqwrite-OSD-CPU"
#plot 'sea_1osd_28reactor_32fio_bal_osd_rc_1procs_seqwrite.dat' index 0 using ($2/1e3):8 w lp axes x1y2 lc 2 t 'Seastore',\
# '' index 0 using ($2/1e3):4 notitle w p lc 2 axes x1y1,\
# 'classic_1osd_32fio_rc_1procs_seqwrite.dat' index 0 using ($2/1e3):8 w lp axes x1y2 lc 3 t 'Classic',\
# '' index 0 using ($2/1e3):4 notitle w p lc 3 axes x1y1
#
#set output 'classic_vs_seastore_1osd_32fio_seqwrite_iops_vs_lat_fio_cpu.png'
#set title "1osd-32fio-seqwrite-FIO-CPU"
#plot 'sea_1osd_28reactor_32fio_bal_osd_rc_1procs_seqwrite.dat' index 0 using ($2/1e3):10 w lp axes x1y2 lc 2 t 'Seastore',\
# '' index 0 using ($2/1e3):4 notitle w p lc 2 axes x1y1,\
# 'classic_1osd_32fio_rc_1procs_seqwrite.dat' index 0 using ($2/1e3):10 w lp axes x1y2 lc 3 t 'Classic',\
# '' index 0 using ($2/1e3):4 notitle w p lc 3 axes x1y1
#
#set y2label "MEM"
#set autoscale
#
### Randread
#set output 'classic_vs_seastore_1osd_32fio_randread_iops_vs_lat_osd_mem.png'
#set title "1osd-32fio-randread-OSD-MEM"
#plot 'sea_1osd_28reactor_32fio_bal_osd_rc_1procs_randread.dat' index 0 using ($2/1e3):9 w lp axes x1y2 lc 2 t 'Seastore',\
# '' index 0 using ($2/1e3):4 notitle w p lc 2 axes x1y1,\
# 'classic_1osd_32fio_rc_1procs_randread.dat' index 0 using ($2/1e3):9 w lp axes x1y2 lc 3 t 'Classic',\
# '' index 0 using ($2/1e3):4 notitle w p lc 3 axes x1y1
#
#set output 'classic_vs_seastore_1osd_32fio_randread_iops_vs_lat_fio_mem.png'
#set title "1osd-32fio-randread-FIO-MEM"
#plot 'sea_1osd_28reactor_32fio_bal_osd_rc_1procs_randread.dat' index 0 using ($2/1e3):11 w lp axes x1y2 lc 2 t 'Seastore',\
# '' index 0 using ($2/1e3):4 notitle w p lc 2 axes x1y1,\
# 'classic_1osd_32fio_rc_1procs_randread.dat' index 0 using ($2/1e3):11 w lp axes x1y2 lc 3 t 'Classic',\
# '' index 0 using ($2/1e3):4 notitle w p lc 3 axes x1y1
#
### Randwrite
#set output 'classic_vs_seastore_1osd_32fio_randwrite_iops_vs_lat_osd_mem.png'
#set title "1osd-32fio-randwrite-OSD-MEM"
#plot 'sea_1osd_28reactor_32fio_bal_osd_rc_1procs_randwrite.dat' index 0 using ($2/1e3):9 w lp axes x1y2 lc 2 t 'Seastore',\
# '' index 0 using ($2/1e3):4 notitle w p lc 2 axes x1y1,\
# 'classic_1osd_32fio_rc_1procs_randwrite.dat' index 0 using ($2/1e3):9 w lp axes x1y2 lc 3 t 'Classic',\
# '' index 0 using ($2/1e3):4 notitle w p lc 3 axes x1y1
#
#set output 'classic_vs_seastore_1osd_32fio_randwrite_iops_vs_lat_fio_mem.png'
#set title "1osd-32fio-randwrite-FIO-MEM"
#plot 'sea_1osd_28reactor_32fio_bal_osd_rc_1procs_randwrite.dat' index 0 using ($2/1e3):11 w lp axes x1y2 lc 2 t 'Seastore',\
# '' index 0 using ($2/1e3):4 notitle w p lc 2 axes x1y1,\
# 'classic_1osd_32fio_rc_1procs_randwrite.dat' index 0 using ($2/1e3):11 w lp axes x1y2 lc 3 t 'Classic',\
# '' index 0 using ($2/1e3):4 notitle w p lc 3 axes x1y1
#
#set xlabel "MBs (thousand)"
## Seqread
#set output 'classic_vs_seastore_1osd_32fio_seqread_iops_vs_lat_osd_mem.png'
#set title "1osd-32fio-seqread-OSD-MEM"
#plot 'sea_1osd_28reactor_32fio_bal_osd_rc_1procs_seqread.dat' index 0 using ($2/1e3):9 w lp axes x1y2 lc 2 t 'Seastore',\
# '' index 0 using ($2/1e3):4 notitle w p lc 2 axes x1y1,\
# 'classic_1osd_32fio_rc_1procs_seqread.dat' index 0 using ($2/1e3):9 w lp axes x1y2 lc 3 t 'Classic',\
# '' index 0 using ($2/1e3):4 notitle w p lc 3 axes x1y1
#
#set output 'classic_vs_seastore_1osd_32fio_seqread_iops_vs_lat_fio_mem.png'
#set title "1osd-32fio-seqread-FIO-MEM"
#plot 'sea_1osd_28reactor_32fio_bal_osd_rc_1procs_seqread.dat' index 0 using ($2/1e3):11 w lp axes x1y2 lc 2 t 'Seastore',\
# '' index 0 using ($2/1e3):4 notitle w p lc 2 axes x1y1,\
# 'classic_1osd_32fio_rc_1procs_seqread.dat' index 0 using ($2/1e3):11 w lp axes x1y2 lc 3 t 'Classic',\
# '' index 0 using ($2/1e3):4 notitle w p lc 3 axes x1y1
#
### Seqwrite
#set output 'classic_vs_seastore_1osd_32fio_seqwrite_iops_vs_lat_osd_mem.png'
#set title "1osd-32fio-seqwrite-OSD-MEM"
#plot 'sea_1osd_28reactor_32fio_bal_osd_rc_1procs_seqwrite.dat' index 0 using ($2/1e3):9 w lp axes x1y2 lc 2 t 'Seastore',\
# '' index 0 using ($2/1e3):4 notitle w p lc 2 axes x1y1,\
# 'classic_1osd_32fio_rc_1procs_seqwrite.dat' index 0 using ($2/1e3):9 w lp axes x1y2 lc 3 t 'Classic',\
# '' index 0 using ($2/1e3):4 notitle w p lc 3 axes x1y1
#
#set output 'classic_vs_seastore_1osd_32fio_seqwrite_iops_vs_lat_fio_mem.png'
#set title "1osd-32fio-seqwrite-FIO-MEM"
#plot 'sea_1osd_28reactor_32fio_bal_osd_rc_1procs_seqwrite.dat' index 0 using ($2/1e3):11 w lp axes x1y2 lc 2 t 'Seastore',\
# '' index 0 using ($2/1e3):4 notitle w p lc 2 axes x1y1,\
# 'classic_1osd_32fio_rc_1procs_seqwrite.dat' index 0 using ($2/1e3):11 w lp axes x1y2 lc 3 t 'Classic',\
# '' index 0 using ($2/1e3):4 notitle w p lc 3 axes x1y1
