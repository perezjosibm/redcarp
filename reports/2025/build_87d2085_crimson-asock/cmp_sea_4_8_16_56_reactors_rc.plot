
set terminal pngcairo size 650,420 enhanced font 'Verdana,10'
set key box left Left noreverse title 'cmp-sea-4-8-16-56-reactors-rc'
set datafile missing '-'
set key outside horiz bottom center box noreverse noenhanced autotitle
set grid
set autoscale
set xtics border in scale 1,0.5 nomirror rotate by -45  autojustify
# Hockey stick graph:
set style function linespoints


set xlabel  "IOPS (thousand)"
set ylabel "Latency (ms)"
set y2label "Latency (ms)"
set ytics nomirror
set y2tics
set tics out
set autoscale y
set autoscale y2

# randread
set output '~/Work/cephdev/ceph-aprg/reports/2025/build_87d2085_crimson-asock/figures/cmp_sea_4_8_16_56_reactors_rc_randread_iops_vs_lat.png'
set title "cmp-sea-4-8-16-56-reactors-rc-randread"
plot  'data/1osd_4reactor_32fio_sea_rc/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_d/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread.dat' every ::1::5 index 0 using ($2/1e3):4 t '4_reactor' axes x1y1 w lp lc 1,\
 'data/1osd_8reactor_32fio_sea_rc/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_d/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread.dat' every ::1::5 index 0 using ($2/1e3):4 t '8_reactor' axes x1y1 w lp lc 2,\
 'data/1osd_16reactor_32fio_sea_rc/sea_1osd_16reactor_32fio_bal_osd_rc_1procs_randread_d/sea_1osd_16reactor_32fio_bal_osd_rc_1procs_randread.dat' every ::1::5 index 0 using ($2/1e3):4 t '16_reactor' axes x1y1 w lp lc 3,\
 'data/1osd_56reactor_32fio_sea_rc/sea_1osd_56reactor_32fio_bal_osd_rc_1procs_randread_d/sea_1osd_56reactor_32fio_bal_osd_rc_1procs_randread.dat' every ::1::5 index 0 using ($2/1e3):4 t '56_reactor' axes x1y1 w lp lc 4

# randwrite
set output '~/Work/cephdev/ceph-aprg/reports/2025/build_87d2085_crimson-asock/figures/cmp_sea_4_8_16_56_reactors_rc_randwrite_iops_vs_lat.png'
set title "cmp-sea-4-8-16-56-reactors-rc-randwrite"
plot  'data/1osd_4reactor_32fio_sea_rc/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_d/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite.dat' every ::1::5 index 0 using ($2/1e3):4 t '4_reactor' axes x1y1 w lp lc 1,\
 'data/1osd_8reactor_32fio_sea_rc/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_d/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite.dat' every ::1::5 index 0 using ($2/1e3):4 t '8_reactor' axes x1y1 w lp lc 2,\
 'data/1osd_16reactor_32fio_sea_rc/sea_1osd_16reactor_32fio_bal_osd_rc_1procs_randwrite_d/sea_1osd_16reactor_32fio_bal_osd_rc_1procs_randwrite.dat' every ::1::5 index 0 using ($2/1e3):4 t '16_reactor' axes x1y1 w lp lc 3,\
 'data/1osd_56reactor_32fio_sea_rc/sea_1osd_56reactor_32fio_bal_osd_rc_1procs_randwrite_d/sea_1osd_56reactor_32fio_bal_osd_rc_1procs_randwrite.dat' every ::1::5 index 0 using ($2/1e3):4 t '56_reactor' axes x1y1 w lp lc 4

# seqread
set output '~/Work/cephdev/ceph-aprg/reports/2025/build_87d2085_crimson-asock/figures/cmp_sea_4_8_16_56_reactors_rc_seqread_iops_vs_lat.png'
set title "cmp-sea-4-8-16-56-reactors-rc-seqread"
plot  'data/1osd_4reactor_32fio_sea_rc/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_seqread_d/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_seqread.dat' every ::1::5 index 0 using ($2/1e3):4 t '4_reactor' axes x1y1 w lp lc 1,\
 'data/1osd_8reactor_32fio_sea_rc/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_seqread_d/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_seqread.dat' every ::1::5 index 0 using ($2/1e3):4 t '8_reactor' axes x1y1 w lp lc 2,\
 'data/1osd_16reactor_32fio_sea_rc/sea_1osd_16reactor_32fio_bal_osd_rc_1procs_seqread_d/sea_1osd_16reactor_32fio_bal_osd_rc_1procs_seqread.dat' every ::1::5 index 0 using ($2/1e3):4 t '16_reactor' axes x1y1 w lp lc 3,\
 'data/1osd_56reactor_32fio_sea_rc/sea_1osd_56reactor_32fio_bal_osd_rc_1procs_seqread_d/sea_1osd_56reactor_32fio_bal_osd_rc_1procs_seqread.dat' every ::1::5 index 0 using ($2/1e3):4 t '56_reactor' axes x1y1 w lp lc 4

# seqwrite
set output '~/Work/cephdev/ceph-aprg/reports/2025/build_87d2085_crimson-asock/figures/cmp_sea_4_8_16_56_reactors_rc_seqwrite_iops_vs_lat.png'
set title "cmp-sea-4-8-16-56-reactors-rc-seqwrite"
plot  'data/1osd_4reactor_32fio_sea_rc/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_seqwrite_d/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_seqwrite.dat' every ::1::5 index 0 using ($2/1e3):4 t '4_reactor' axes x1y1 w lp lc 1,\
 'data/1osd_8reactor_32fio_sea_rc/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_seqwrite_d/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_seqwrite.dat' every ::1::5 index 0 using ($2/1e3):4 t '8_reactor' axes x1y1 w lp lc 2,\
 'data/1osd_16reactor_32fio_sea_rc/sea_1osd_16reactor_32fio_bal_osd_rc_1procs_seqwrite_d/sea_1osd_16reactor_32fio_bal_osd_rc_1procs_seqwrite.dat' every ::1::5 index 0 using ($2/1e3):4 t '16_reactor' axes x1y1 w lp lc 3,\
 'data/1osd_56reactor_32fio_sea_rc/sea_1osd_56reactor_32fio_bal_osd_rc_1procs_seqwrite_d/sea_1osd_56reactor_32fio_bal_osd_rc_1procs_seqwrite.dat' every ::1::5 index 0 using ($2/1e3):4 t '56_reactor' axes x1y1 w lp lc 4

