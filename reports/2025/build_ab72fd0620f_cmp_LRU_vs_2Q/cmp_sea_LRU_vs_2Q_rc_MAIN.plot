set terminal pngcairo size 650,420 enhanced font 'Verdana,10'
set key box left Left noreverse title 'cmp-sea-LRU-vs-2Q-rc'
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

# randwrite_zoned
set output './figures/cmp_sea_LRU_vs_2Q_rc_randwrite_zoned_iops_vs_lat.png'
set title "cmp-sea-LRU-vs-2Q-rc-randwrite_zoned"
plot  'data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zoned.dat' every ::1::5 index 0 using ($2/1e3):4 t '1_reactor_LRU' axes x1y1 w lp lc 1,\
 'data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zoned.dat' every ::1::5 index 0 using ($2/1e3):4 t '1_reactor_2Q' axes x1y1 w lp lc 2,\
 'data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zoned.dat' every ::1::5 index 0 using ($2/1e3):4 t '4_reactor_LRU' axes x1y1 w lp lc 3,\
 'data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zoned.dat' every ::1::5 index 0 using ($2/1e3):4 t '4_reactor_2Q' axes x1y1 w lp lc 4,\
 'data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zoned.dat' every ::1::5 index 0 using ($2/1e3):4 t '8_reactor_LRU' axes x1y1 w lp lc 5,\
 'data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zoned.dat' every ::1::5 index 0 using ($2/1e3):4 t '8_reactor_2Q' axes x1y1 w lp lc 6

# randwrite_zipf
set output 'data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zoned.dat_randwrite_zipf_iops_vs_lat.png'
set title "cmp-sea-LRU-vs-2Q-rc-randwrite_zipf"
plot  'data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zipf.dat' every ::1::5 index 0 using ($2/1e3):4 t '1_reactor_LRU' axes x1y1 w lp lc 1,\
 'data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zipf.dat' every ::1::5 index 0 using ($2/1e3):4 t '1_reactor_2Q' axes x1y1 w lp lc 2,\
 'data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zipf.dat' every ::1::5 index 0 using ($2/1e3):4 t '4_reactor_LRU' axes x1y1 w lp lc 3,\
 'data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zipf.dat' every ::1::5 index 0 using ($2/1e3):4 t '4_reactor_2Q' axes x1y1 w lp lc 4,\
 'data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zipf.dat' every ::1::5 index 0 using ($2/1e3):4 t '8_reactor_LRU' axes x1y1 w lp lc 5,\
 'data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zipf.dat' every ::1::5 index 0 using ($2/1e3):4 t '8_reactor_2Q' axes x1y1 w lp lc 6

# randwrite_norm
set output 'data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zipf.dat_randwrite_norm_iops_vs_lat.png'
set title "cmp-sea-LRU-vs-2Q-rc-randwrite_norm"
plot  'data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_norm.dat' every ::1::5 index 0 using ($2/1e3):4 t '1_reactor_LRU' axes x1y1 w lp lc 1,\
 'data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_norm.dat' every ::1::5 index 0 using ($2/1e3):4 t '1_reactor_2Q' axes x1y1 w lp lc 2,\
 'data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_norm.dat' every ::1::5 index 0 using ($2/1e3):4 t '4_reactor_LRU' axes x1y1 w lp lc 3,\
 'data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_norm.dat' every ::1::5 index 0 using ($2/1e3):4 t '4_reactor_2Q' axes x1y1 w lp lc 4,\
 'data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_norm.dat' every ::1::5 index 0 using ($2/1e3):4 t '8_reactor_LRU' axes x1y1 w lp lc 5,\
 'data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_norm.dat' every ::1::5 index 0 using ($2/1e3):4 t '8_reactor_2Q' axes x1y1 w lp lc 6

# randread_zoned
set output 'data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_norm.dat_randread_zoned_iops_vs_lat.png'
set title "cmp-sea-LRU-vs-2Q-rc-randread_zoned"
plot  'data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zoned.dat' every ::1::5 index 0 using ($2/1e3):4 t '1_reactor_LRU' axes x1y1 w lp lc 1,\
 'data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zoned.dat' every ::1::5 index 0 using ($2/1e3):4 t '1_reactor_2Q' axes x1y1 w lp lc 2,\
 'data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zoned.dat' every ::1::5 index 0 using ($2/1e3):4 t '4_reactor_LRU' axes x1y1 w lp lc 3,\
 'data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zoned.dat' every ::1::5 index 0 using ($2/1e3):4 t '4_reactor_2Q' axes x1y1 w lp lc 4,\
 'data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zoned.dat' every ::1::5 index 0 using ($2/1e3):4 t '8_reactor_LRU' axes x1y1 w lp lc 5,\
 'data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zoned.dat' every ::1::5 index 0 using ($2/1e3):4 t '8_reactor_2Q' axes x1y1 w lp lc 6

# randread_zipf
set output 'data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zoned.dat_randread_zipf_iops_vs_lat.png'
set title "cmp-sea-LRU-vs-2Q-rc-randread_zipf"
plot  'data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zipf.dat' every ::1::5 index 0 using ($2/1e3):4 t '1_reactor_LRU' axes x1y1 w lp lc 1,\
 'data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zipf.dat' every ::1::5 index 0 using ($2/1e3):4 t '1_reactor_2Q' axes x1y1 w lp lc 2,\
 'data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zipf.dat' every ::1::5 index 0 using ($2/1e3):4 t '4_reactor_LRU' axes x1y1 w lp lc 3,\
 'data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zipf.dat' every ::1::5 index 0 using ($2/1e3):4 t '4_reactor_2Q' axes x1y1 w lp lc 4,\
 'data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zipf.dat' every ::1::5 index 0 using ($2/1e3):4 t '8_reactor_LRU' axes x1y1 w lp lc 5,\
 'data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zipf.dat' every ::1::5 index 0 using ($2/1e3):4 t '8_reactor_2Q' axes x1y1 w lp lc 6

# randread_norm
set output 'data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zipf.dat_randread_norm_iops_vs_lat.png'
set title "cmp-sea-LRU-vs-2Q-rc-randread_norm"
plot  'data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_norm.dat' every ::1::5 index 0 using ($2/1e3):4 t '1_reactor_LRU' axes x1y1 w lp lc 1,\
 'data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_norm.dat' every ::1::5 index 0 using ($2/1e3):4 t '1_reactor_2Q' axes x1y1 w lp lc 2,\
 'data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_norm.dat' every ::1::5 index 0 using ($2/1e3):4 t '4_reactor_LRU' axes x1y1 w lp lc 3,\
 'data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_norm.dat' every ::1::5 index 0 using ($2/1e3):4 t '4_reactor_2Q' axes x1y1 w lp lc 4,\
 'data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_norm.dat' every ::1::5 index 0 using ($2/1e3):4 t '8_reactor_LRU' axes x1y1 w lp lc 5,\
 'data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_norm.dat' every ::1::5 index 0 using ($2/1e3):4 t '8_reactor_2Q' axes x1y1 w lp lc 6



