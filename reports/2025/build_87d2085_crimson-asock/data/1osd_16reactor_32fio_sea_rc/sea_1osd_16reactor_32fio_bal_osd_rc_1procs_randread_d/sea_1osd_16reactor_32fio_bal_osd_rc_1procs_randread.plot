
set terminal pngcairo size 650,420 enhanced font 'Verdana,10'
set key box left Left noreverse title 'Iodepth'
set datafile missing '-'
set key outside horiz bottom center box noreverse noenhanced autotitle
set grid
set autoscale
set xtics border in scale 1,0.5 nomirror rotate by -45  autojustify
# Hockey stick graph:
set style function linespoints

set ylabel "Latency (ms)"
set xlabel "IOPS (thousand)"
set y2label "CPU"
set ytics nomirror
set y2tics
set tics out
set autoscale y
set autoscale y2
set output 'sea_1osd_16reactor_32fio_bal_osd_rc_1procs_randread_iops_vs_lat_vs_cpu.png'
set title "sea-1osd-16reactor-32fio-bal-osd-rc-1procs-randread"
plot 'sea_1osd_16reactor_32fio_bal_osd_rc_1procs_randread.dat' index 0 using ($2/1e3):4:5 t '1 q-depth' w yerr axes x1y1 lc 1,\
 '' index 0 using ($2/1e3):4 notitle w lp lc 1 axes x1y1,\
 '' index 0 using ($2/1e3):8 w lp axes x1y2 t 'OSD_cpu',\
 '' index 0 using ($2/1e3):10 w lp axes x1y2 t 'FIO_cpu'
