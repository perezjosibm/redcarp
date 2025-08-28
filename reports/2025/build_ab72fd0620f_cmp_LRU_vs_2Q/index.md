# **Crimson Seastore: performance comparison cache pin algorithms LRU vs. 2Q** -- progress report

---
<!-- ![image](figures/ceph_362px.png) -->
<img src="figures/ceph_362px.png" width="148">


| **Author**: |

  José Juan Palacios Pérez\
  Ceph IBM,\
  Manchester UK
  date: 2025-08-28

| **Abstract:**

  In this brief report we show the performance comparisonm between the
  two Seastore cache pinboard algorithms, namely LRU and 2Q. We used the
  following configurations:

  - we used a single RBD volume of size 2 GB (which is the default size
    of the cache per reactor).

  - We ranged the number of Seastar reactors as 1, 4, and 8 (to show
    scalability).

  - We used the same ceph dev build from main branch (hash ab72fd0620f)
    for all test runs.

  - All configurations used balanced OSD algorithm on a single NUMA
    socket (this is to be consistent with previous tests).

  - We used three random distributions via FIO options, namely: normal
    (Gaussian), zoned, and Zipfian.

  Our preliminary conclusions:

  - The performance of the two pinboard cache algorithms do not show a
    significant difference, either in throughput or latency, nor in CPU
    resource utilisation.

  - As expected from previous tests, Crimson SeaStore on random
    workloads scales well with the number of reactors.
---

- [Summary performance scaling Seastore LRU vs
  2Q](#summary-performance-scaling-seastore-lru-vs-2q){#toc-summary-performance-scaling-seastore-lru-vs-2q}
  - [randwrite_zoned](#randwrite_zoned){#toc-randwrite_zoned}
  - [randwrite_zipf](#randwrite_zipf){#toc-randwrite_zipf}
  - [randwrite_norm](#randwrite_norm){#toc-randwrite_norm}
  - [randread_zoned](#randread_zoned){#toc-randread_zoned}
  - [randread_zipf](#randread_zipf){#toc-randread_zipf}
  - [randread_norm](#randread_norm){#toc-randread_norm}
- [Comparison of LRU and 2Q via flamegraphs](#comparison-of-lru-and-2q-via-flamegraphs){#toc-comparison-of-lru-and-2q-via-flamegraphs}


<!-- ::::: titlepage -->
<!-- :::: minipage -->
<!-- ::: center -->

# Summary performance scaling Seastore LRU vs 2Q

In this Chapter we show the performance comparison between the two
pinboard cache algorithms, LRU and 2Q. As in previous reports, we ran
long duration tests to produce response latency curves.

1.  We used a single OSD, running within a single NUMA socket, we only
    increased the number of reactors as indicated. We used the balanced
    OSD algorithm for the reactors affinity. We used the default cache
    size of 2 GB per reactor for Seastore.

2.  We used a single RBD image of 2GB size. All FIO processes were
    pinned to the other NUMA socket, so that the OSD processes were not
    affected by the FIO processes.

3.  We disabled RBD coalescing (eventhough we did not run sequential
    workloads for this test).

We first compare the two algorithms on each workloads, summarising the
random distribution used. To make the test valid, it is important to
ensure that the highest IO intensity of the distribution fits within the
cache.

For each workload comparison, we show the CPU utilisation (from the
Linux top command) for the two main threads in the OSD process, the
reactor and the crimson-osd thread.[^1] For multiple reactors, we
coalesce the data from all reactors, showing the average along the time
duration of the test.

## randwrite_zoned

This random distribution exercises IO over the storage defined zones (in
LBA) according to the parameters chosen, in our case as follows:

- 60% of accesses should be to the first 10% (of the total storage
  space, in LBA)

- 30% of accesses should be to the next 20%

- 8% of accesses should be to the next 30%

- 2% of accesses should be to the next 40%.

![cmp-sea-LRU-vs-2Q-rc -
randwrite_zoned](figures/cmp_sea_LRU_vs_2Q_rc_randwrite_zoned_iops_vs_lat.png){#fig:cmp_sea_LRU_vs_2Q_rc_randwrite_zoned
width="80%"}

<figure id="figure:1-reactor-cpu-randwrite_zoned">
<div class="minipage">
<img
src="figures/OSD_sea_1osd_1reactor_LRU_randwrite_zoned_top_cpu.png" />
</div>
<div class="minipage">
<img
src="figures/OSD_sea_1osd_1reactor_2Q_randwrite_zoned_top_cpu.png" />
</div>
<figcaption>Top CPU utilization - LRU (left) vs 2Q (right) -
randwrite_zoned, 1 reactor</figcaption>
</figure>

<figure id="figure:4-reactor-cpu-randwrite_zoned">
<div class="minipage">
<img
src="figures/OSD_sea_1osd_4reactor_LRU_randwrite_zoned_top_cpu.png" />
</div>
<div class="minipage">
<img
src="figures/OSD_sea_1osd_4reactor_2Q_randwrite_zoned_top_cpu.png" />
</div>
<figcaption>Top CPU utilization - LRU (left) vs 2Q (right) -
randwrite_zoned, 4 reactor</figcaption>
</figure>

<figure id="figure:8-reactor-cpu-randwrite_zoned">
<div class="minipage">
<img
src="figures/OSD_sea_1osd_8reactor_LRU_randwrite_zoned_top_cpu.png" />
</div>
<div class="minipage">
<img
src="figures/OSD_sea_1osd_8reactor_2Q_randwrite_zoned_top_cpu.png" />
</div>
<figcaption>Top CPU utilization - LRU (left) vs 2Q (right) -
randwrite_zoned, 8 reactor</figcaption>
</figure>

## randwrite_zipf

This random distribution was chosen to exercise IO as follows:

    Generating Zipf distribution with 0.768780 input and 2 GiB size and 4096 block_size.

       Rows           Hits %         Sum %           # Hits          Size
    -----------------------------------------------------------------------
    Top  16.67%      56.93%          56.93%           298480          1.14G
    |->  33.33%      13.88%          70.81%            72775        284.28M
    |->  50.00%       8.38%          79.19%            43946        171.66M
    |->  66.67%       6.94%          86.13%            36364        142.05M
    |->  83.33%       6.94%          93.07%            36364        142.05M
    |-> 100.00%       6.93%         100.00%            36359        142.03M
    -----------------------------------------------------------------------
    Total                                             524288

![cmp-sea-LRU-vs-2Q-rc -
randwrite_zipf](figures/cmp_sea_LRU_vs_2Q_rc_randwrite_zipf_iops_vs_lat.png){#fig:cmp_sea_LRU_vs_2Q_rc_randwrite_zipf
width="80%"}

<figure id="figure:1-reactor-cpu-randwrite_zipf">
<div class="minipage">
<img
src="figures/OSD_sea_1osd_1reactor_LRU_randwrite_zipf_top_cpu.png" />
</div>
<div class="minipage">
<img
src="figures/OSD_sea_1osd_1reactor_2Q_randwrite_zipf_top_cpu.png" />
</div>
<figcaption>Top CPU utilization - LRU (left) vs 2Q (right) -
randwrite_zipf, 1 reactor</figcaption>
</figure>

<figure id="figure:4-reactor-cpu-randwrite_zipf">
<div class="minipage">
<img
src="figures/OSD_sea_1osd_4reactor_LRU_randwrite_zipf_top_cpu.png" />
</div>
<div class="minipage">
<img
src="figures/OSD_sea_1osd_4reactor_2Q_randwrite_zipf_top_cpu.png" />
</div>
<figcaption>Top CPU utilization - LRU (left) vs 2Q (right) -
randwrite_zipf, 4 reactor</figcaption>
</figure>

<figure id="figure:8-reactor-cpu-randwrite_zipf">
<div class="minipage">
<img
src="figures/OSD_sea_1osd_8reactor_LRU_randwrite_zipf_top_cpu.png" />
</div>
<div class="minipage">
<img
src="figures/OSD_sea_1osd_8reactor_2Q_randwrite_zipf_top_cpu.png" />
</div>
<figcaption>Top CPU utilization - LRU (left) vs 2Q (right) -
randwrite_zipf, 8 reactor</figcaption>
</figure>

## randwrite_norm

This is the traditional Gaussian distribution, using a generated mean
and standard deviation 0.6.

![cmp-sea-LRU-vs-2Q-rc -
randwrite_norm](figures/cmp_sea_LRU_vs_2Q_rc_randwrite_norm_iops_vs_lat.png){#fig:cmp_sea_LRU_vs_2Q_rc_randwrite_norm
width="80%"}

<figure id="figure:1-reactor-cpu-randwrite_norm">
<div class="minipage">
<img
src="figures/OSD_sea_1osd_1reactor_LRU_randwrite_norm_top_cpu.png" />
</div>
<div class="minipage">
<img
src="figures/OSD_sea_1osd_1reactor_2Q_randwrite_norm_top_cpu.png" />
</div>
<figcaption>Top CPU utilization - LRU (left) vs 2Q (right) -
randwrite_norm, 1 reactor</figcaption>
</figure>

<figure id="figure:4-reactor-cpu-randwrite_norm">
<div class="minipage">
<img
src="figures/OSD_sea_1osd_4reactor_LRU_randwrite_norm_top_cpu.png" />
</div>
<div class="minipage">
<img
src="figures/OSD_sea_1osd_4reactor_2Q_randwrite_norm_top_cpu.png" />
</div>
<figcaption>Top CPU utilization - LRU (left) vs 2Q (right) -
randwrite_norm, 4 reactor</figcaption>
</figure>

<figure id="figure:8-reactor-cpu-randwrite_norm">
<div class="minipage">
<img
src="figures/OSD_sea_1osd_8reactor_LRU_randwrite_norm_top_cpu.png" />
</div>
<div class="minipage">
<img
src="figures/OSD_sea_1osd_8reactor_2Q_randwrite_norm_top_cpu.png" />
</div>
<figcaption>Top CPU utilization - LRU (left) vs 2Q (right) -
randwrite_norm, 8 reactor</figcaption>
</figure>

## randread_zoned

![cmp-sea-LRU-vs-2Q-rc -
randread_zoned](figures/cmp_sea_LRU_vs_2Q_rc_randread_zoned_iops_vs_lat.png){#fig:cmp_sea_LRU_vs_2Q_rc_randread_zoned
width="80%"}

<figure id="figure:1-reactor-cpu-randread_zoned">
<div class="minipage">
<img
src="figures/OSD_sea_1osd_1reactor_LRU_randread_zoned_top_cpu.png" />
</div>
<div class="minipage">
<img
src="figures/OSD_sea_1osd_1reactor_2Q_randread_zoned_top_cpu.png" />
</div>
<figcaption>Top CPU utilization - LRU (left) vs 2Q (right) -
randread_zoned, 1 reactor</figcaption>
</figure>

<figure id="figure:4-reactor-cpu-randread_zoned">
<div class="minipage">
<img
src="figures/OSD_sea_1osd_4reactor_LRU_randread_zoned_top_cpu.png" />
</div>
<div class="minipage">
<img
src="figures/OSD_sea_1osd_4reactor_2Q_randread_zoned_top_cpu.png" />
</div>
<figcaption>Top CPU utilization - LRU (left) vs 2Q (right) -
randread_zoned, 4 reactor</figcaption>
</figure>

<figure id="figure:8-reactor-cpu-randread_zoned">
<div class="minipage">
<img
src="figures/OSD_sea_1osd_8reactor_LRU_randread_zoned_top_cpu.png" />
</div>
<div class="minipage">
<img
src="figures/OSD_sea_1osd_8reactor_2Q_randread_zoned_top_cpu.png" />
</div>
<figcaption>Top CPU utilization - LRU (left) vs 2Q (right) -
randread_zoned, 8 reactor</figcaption>
</figure>

## randread_zipf

![cmp-sea-LRU-vs-2Q-rc -
randread_zipf](figures/cmp_sea_LRU_vs_2Q_rc_randread_zipf_iops_vs_lat.png){#fig:cmp_sea_LRU_vs_2Q_rc_randread_zipf
width="80%"}

<figure id="figure:1-reactor-cpu-randread_zipf">
<div class="minipage">
<img
src="figures/OSD_sea_1osd_1reactor_LRU_randread_zipf_top_cpu.png" />
</div>
<div class="minipage">
<img
src="figures/OSD_sea_1osd_1reactor_2Q_randread_zipf_top_cpu.png" />
</div>
<figcaption>Top CPU utilization - LRU (left) vs 2Q (right) -
randread_zipf, 1 reactor</figcaption>
</figure>

<figure id="figure:4-reactor-cpu-randread_zipf">
<div class="minipage">
<img
src="figures/OSD_sea_1osd_4reactor_LRU_randread_zipf_top_cpu.png" />
</div>
<div class="minipage">
<img
src="figures/OSD_sea_1osd_4reactor_2Q_randread_zipf_top_cpu.png" />
</div>
<figcaption>Top CPU utilization - LRU (left) vs 2Q (right) -
randread_zipf, 4 reactor</figcaption>
</figure>

<figure id="figure:8-reactor-cpu-randread_zipf">
<div class="minipage">
<img
src="figures/OSD_sea_1osd_8reactor_LRU_randread_zipf_top_cpu.png" />
</div>
<div class="minipage">
<img
src="figures/OSD_sea_1osd_8reactor_2Q_randread_zipf_top_cpu.png" />
</div>
<figcaption>Top CPU utilization - LRU (left) vs 2Q (right) -
randread_zipf, 8 reactor</figcaption>
</figure>

## randread_norm

![cmp-sea-LRU-vs-2Q-rc -
randread_norm](figures/cmp_sea_LRU_vs_2Q_rc_randread_norm_iops_vs_lat.png){#fig:cmp_sea_LRU_vs_2Q_rc_randread_norm
width="80%"}

<figure id="figure:1-reactor-cpu-randread_norm">
<div class="minipage">
<img
src="figures/OSD_sea_1osd_1reactor_LRU_randread_norm_top_cpu.png" />
</div>
<div class="minipage">
<img
src="figures/OSD_sea_1osd_1reactor_2Q_randread_norm_top_cpu.png" />
</div>
<figcaption>Top CPU utilization - LRU (left) vs 2Q (right) -
randread_norm, 1 reactor</figcaption>
</figure>

<figure id="figure:4-reactor-cpu-randread_norm">
<div class="minipage">
<img
src="figures/OSD_sea_1osd_4reactor_LRU_randread_norm_top_cpu.png" />
</div>
<div class="minipage">
<img
src="figures/OSD_sea_1osd_4reactor_2Q_randread_norm_top_cpu.png" />
</div>
<figcaption>Top CPU utilization - LRU (left) vs 2Q (right) -
randread_norm, 4 reactor</figcaption>
</figure>

<figure id="figure:8-reactor-cpu-randread_norm">
<div class="minipage">
<img
src="figures/OSD_sea_1osd_8reactor_LRU_randread_norm_top_cpu.png" />
</div>
<div class="minipage">
<img
src="figures/OSD_sea_1osd_8reactor_2Q_randread_norm_top_cpu.png" />
</div>
<figcaption>Top CPU utilization - LRU (left) vs 2Q (right) -
randread_norm, 8 reactor</figcaption>
</figure>

[^1]: We do not show the memory utilisation since its mostly remains
    constant, and does not add much to the analysis.

## Comparison of LRU and 2Q via flamegraphs

This section compares the performance of LRU and 2Q cache pinboard algorithms in a single OSD visualized through flamegraphs generated from different workloads and I/O depths.

| randwrite_zoned (1 reactor) | LRU | 2Q |
|-------------------------|-----|----|
| 1 | [sea_1osd_1reactor_randwrite_zoned_1](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_1io_4k_randwrite_zoned_p0.fg.svg) | [sea_1osd_1reactor_randwrite_zoned_1](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_1io_4k_randwrite_zoned_p0.fg.svg) |
| 2 | [sea_1osd_1reactor_randwrite_zoned_2](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_2io_4k_randwrite_zoned_p0.fg.svg) | [sea_1osd_1reactor_randwrite_zoned_2](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_2io_4k_randwrite_zoned_p0.fg.svg) |
| 4 | [sea_1osd_1reactor_randwrite_zoned_4](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_4io_4k_randwrite_zoned_p0.fg.svg) | [sea_1osd_1reactor_randwrite_zoned_4](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_4io_4k_randwrite_zoned_p0.fg.svg) |
| 8 | [sea_1osd_1reactor_randwrite_zoned_8](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_8io_4k_randwrite_zoned_p0.fg.svg) | [sea_1osd_1reactor_randwrite_zoned_8](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_8io_4k_randwrite_zoned_p0.fg.svg) |
| 16 | [sea_1osd_1reactor_randwrite_zoned_16](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_16io_4k_randwrite_zoned_p0.fg.svg) | [sea_1osd_1reactor_randwrite_zoned_16](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_16io_4k_randwrite_zoned_p0.fg.svg) |
| 24 | [sea_1osd_1reactor_randwrite_zoned_24](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_24io_4k_randwrite_zoned_p0.fg.svg) | [sea_1osd_1reactor_randwrite_zoned_24](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_24io_4k_randwrite_zoned_p0.fg.svg) |
| 32 | [sea_1osd_1reactor_randwrite_zoned_32](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_32io_4k_randwrite_zoned_p0.fg.svg) | [sea_1osd_1reactor_randwrite_zoned_32](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_32io_4k_randwrite_zoned_p0.fg.svg) |
| 40 | [sea_1osd_1reactor_randwrite_zoned_40](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_40io_4k_randwrite_zoned_p0.fg.svg) | [sea_1osd_1reactor_randwrite_zoned_40](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_40io_4k_randwrite_zoned_p0.fg.svg) |
| 52 | [sea_1osd_1reactor_randwrite_zoned_52](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_52io_4k_randwrite_zoned_p0.fg.svg) | [sea_1osd_1reactor_randwrite_zoned_52](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_52io_4k_randwrite_zoned_p0.fg.svg) |
| 64 | [sea_1osd_1reactor_randwrite_zoned_64](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_64io_4k_randwrite_zoned_p0.fg.svg) | [sea_1osd_1reactor_randwrite_zoned_64](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_64io_4k_randwrite_zoned_p0.fg.svg) |

| randwrite_zoned (4 reactor) | LRU | 2Q |
|-------------------------|-----|----|
| 1 | [sea_1osd_4reactor_randwrite_zoned_1](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_1io_4k_randwrite_zoned_p0.fg.svg) | [sea_1osd_4reactor_randwrite_zoned_1](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_1io_4k_randwrite_zoned_p0.fg.svg) |
| 2 | [sea_1osd_4reactor_randwrite_zoned_2](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_2io_4k_randwrite_zoned_p0.fg.svg) | [sea_1osd_4reactor_randwrite_zoned_2](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_2io_4k_randwrite_zoned_p0.fg.svg) |
| 4 | [sea_1osd_4reactor_randwrite_zoned_4](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_4io_4k_randwrite_zoned_p0.fg.svg) | [sea_1osd_4reactor_randwrite_zoned_4](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_4io_4k_randwrite_zoned_p0.fg.svg) |
| 8 | [sea_1osd_4reactor_randwrite_zoned_8](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_8io_4k_randwrite_zoned_p0.fg.svg) | [sea_1osd_4reactor_randwrite_zoned_8](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_8io_4k_randwrite_zoned_p0.fg.svg) |
| 16 | [sea_1osd_4reactor_randwrite_zoned_16](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_16io_4k_randwrite_zoned_p0.fg.svg) | [sea_1osd_4reactor_randwrite_zoned_16](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_16io_4k_randwrite_zoned_p0.fg.svg) |
| 24 | [sea_1osd_4reactor_randwrite_zoned_24](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_24io_4k_randwrite_zoned_p0.fg.svg) | [sea_1osd_4reactor_randwrite_zoned_24](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_24io_4k_randwrite_zoned_p0.fg.svg) |
| 32 | [sea_1osd_4reactor_randwrite_zoned_32](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_32io_4k_randwrite_zoned_p0.fg.svg) | [sea_1osd_4reactor_randwrite_zoned_32](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_32io_4k_randwrite_zoned_p0.fg.svg) |
| 40 | [sea_1osd_4reactor_randwrite_zoned_40](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_40io_4k_randwrite_zoned_p0.fg.svg) | [sea_1osd_4reactor_randwrite_zoned_40](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_40io_4k_randwrite_zoned_p0.fg.svg) |
| 52 | [sea_1osd_4reactor_randwrite_zoned_52](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_52io_4k_randwrite_zoned_p0.fg.svg) | [sea_1osd_4reactor_randwrite_zoned_52](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_52io_4k_randwrite_zoned_p0.fg.svg) |
| 64 | [sea_1osd_4reactor_randwrite_zoned_64](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_64io_4k_randwrite_zoned_p0.fg.svg) | [sea_1osd_4reactor_randwrite_zoned_64](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_64io_4k_randwrite_zoned_p0.fg.svg) |

| randwrite_zoned (8 reactor) | LRU | 2Q |
|-------------------------|-----|----|
| 1 | [sea_1osd_8reactor_randwrite_zoned_1](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_1io_4k_randwrite_zoned_p0.fg.svg) | [sea_1osd_8reactor_randwrite_zoned_1](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_1io_4k_randwrite_zoned_p0.fg.svg) |
| 2 | [sea_1osd_8reactor_randwrite_zoned_2](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_2io_4k_randwrite_zoned_p0.fg.svg) | [sea_1osd_8reactor_randwrite_zoned_2](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_2io_4k_randwrite_zoned_p0.fg.svg) |
| 4 | [sea_1osd_8reactor_randwrite_zoned_4](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_4io_4k_randwrite_zoned_p0.fg.svg) | [sea_1osd_8reactor_randwrite_zoned_4](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_4io_4k_randwrite_zoned_p0.fg.svg) |
| 8 | [sea_1osd_8reactor_randwrite_zoned_8](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_8io_4k_randwrite_zoned_p0.fg.svg) | [sea_1osd_8reactor_randwrite_zoned_8](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_8io_4k_randwrite_zoned_p0.fg.svg) |
| 16 | [sea_1osd_8reactor_randwrite_zoned_16](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_16io_4k_randwrite_zoned_p0.fg.svg) | [sea_1osd_8reactor_randwrite_zoned_16](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_16io_4k_randwrite_zoned_p0.fg.svg) |
| 24 | [sea_1osd_8reactor_randwrite_zoned_24](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_24io_4k_randwrite_zoned_p0.fg.svg) | [sea_1osd_8reactor_randwrite_zoned_24](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_24io_4k_randwrite_zoned_p0.fg.svg) |
| 32 | [sea_1osd_8reactor_randwrite_zoned_32](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_32io_4k_randwrite_zoned_p0.fg.svg) | [sea_1osd_8reactor_randwrite_zoned_32](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_32io_4k_randwrite_zoned_p0.fg.svg) |
| 40 | [sea_1osd_8reactor_randwrite_zoned_40](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_40io_4k_randwrite_zoned_p0.fg.svg) | [sea_1osd_8reactor_randwrite_zoned_40](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_40io_4k_randwrite_zoned_p0.fg.svg) |
| 52 | [sea_1osd_8reactor_randwrite_zoned_52](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_52io_4k_randwrite_zoned_p0.fg.svg) | [sea_1osd_8reactor_randwrite_zoned_52](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_52io_4k_randwrite_zoned_p0.fg.svg) |
| 64 | [sea_1osd_8reactor_randwrite_zoned_64](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_64io_4k_randwrite_zoned_p0.fg.svg) | [sea_1osd_8reactor_randwrite_zoned_64](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_64io_4k_randwrite_zoned_p0.fg.svg) |

| randwrite_zipf (1 reactor) | LRU | 2Q |
|-------------------------|-----|----|
| 1 | [sea_1osd_1reactor_randwrite_zipf_1](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_1io_4k_randwrite_zipf_p0.fg.svg) | [sea_1osd_1reactor_randwrite_zipf_1](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_1io_4k_randwrite_zipf_p0.fg.svg) |
| 2 | [sea_1osd_1reactor_randwrite_zipf_2](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_2io_4k_randwrite_zipf_p0.fg.svg) | [sea_1osd_1reactor_randwrite_zipf_2](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_2io_4k_randwrite_zipf_p0.fg.svg) |
| 4 | [sea_1osd_1reactor_randwrite_zipf_4](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_4io_4k_randwrite_zipf_p0.fg.svg) | [sea_1osd_1reactor_randwrite_zipf_4](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_4io_4k_randwrite_zipf_p0.fg.svg) |
| 8 | [sea_1osd_1reactor_randwrite_zipf_8](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_8io_4k_randwrite_zipf_p0.fg.svg) | [sea_1osd_1reactor_randwrite_zipf_8](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_8io_4k_randwrite_zipf_p0.fg.svg) |
| 16 | [sea_1osd_1reactor_randwrite_zipf_16](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_16io_4k_randwrite_zipf_p0.fg.svg) | [sea_1osd_1reactor_randwrite_zipf_16](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_16io_4k_randwrite_zipf_p0.fg.svg) |
| 24 | [sea_1osd_1reactor_randwrite_zipf_24](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_24io_4k_randwrite_zipf_p0.fg.svg) | [sea_1osd_1reactor_randwrite_zipf_24](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_24io_4k_randwrite_zipf_p0.fg.svg) |
| 32 | [sea_1osd_1reactor_randwrite_zipf_32](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_32io_4k_randwrite_zipf_p0.fg.svg) | [sea_1osd_1reactor_randwrite_zipf_32](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_32io_4k_randwrite_zipf_p0.fg.svg) |
| 40 | [sea_1osd_1reactor_randwrite_zipf_40](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_40io_4k_randwrite_zipf_p0.fg.svg) | [sea_1osd_1reactor_randwrite_zipf_40](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_40io_4k_randwrite_zipf_p0.fg.svg) |
| 52 | [sea_1osd_1reactor_randwrite_zipf_52](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_52io_4k_randwrite_zipf_p0.fg.svg) | [sea_1osd_1reactor_randwrite_zipf_52](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_52io_4k_randwrite_zipf_p0.fg.svg) |
| 64 | [sea_1osd_1reactor_randwrite_zipf_64](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_64io_4k_randwrite_zipf_p0.fg.svg) | [sea_1osd_1reactor_randwrite_zipf_64](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_64io_4k_randwrite_zipf_p0.fg.svg) |

| randwrite_zipf (4 reactor) | LRU | 2Q |
|-------------------------|-----|----|
| 1 | [sea_1osd_4reactor_randwrite_zipf_1](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_1io_4k_randwrite_zipf_p0.fg.svg) | [sea_1osd_4reactor_randwrite_zipf_1](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_1io_4k_randwrite_zipf_p0.fg.svg) |
| 2 | [sea_1osd_4reactor_randwrite_zipf_2](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_2io_4k_randwrite_zipf_p0.fg.svg) | [sea_1osd_4reactor_randwrite_zipf_2](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_2io_4k_randwrite_zipf_p0.fg.svg) |
| 4 | [sea_1osd_4reactor_randwrite_zipf_4](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_4io_4k_randwrite_zipf_p0.fg.svg) | [sea_1osd_4reactor_randwrite_zipf_4](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_4io_4k_randwrite_zipf_p0.fg.svg) |
| 8 | [sea_1osd_4reactor_randwrite_zipf_8](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_8io_4k_randwrite_zipf_p0.fg.svg) | [sea_1osd_4reactor_randwrite_zipf_8](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_8io_4k_randwrite_zipf_p0.fg.svg) |
| 16 | [sea_1osd_4reactor_randwrite_zipf_16](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_16io_4k_randwrite_zipf_p0.fg.svg) | [sea_1osd_4reactor_randwrite_zipf_16](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_16io_4k_randwrite_zipf_p0.fg.svg) |
| 24 | [sea_1osd_4reactor_randwrite_zipf_24](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_24io_4k_randwrite_zipf_p0.fg.svg) | [sea_1osd_4reactor_randwrite_zipf_24](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_24io_4k_randwrite_zipf_p0.fg.svg) |
| 32 | [sea_1osd_4reactor_randwrite_zipf_32](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_32io_4k_randwrite_zipf_p0.fg.svg) | [sea_1osd_4reactor_randwrite_zipf_32](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_32io_4k_randwrite_zipf_p0.fg.svg) |
| 40 | [sea_1osd_4reactor_randwrite_zipf_40](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_40io_4k_randwrite_zipf_p0.fg.svg) | [sea_1osd_4reactor_randwrite_zipf_40](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_40io_4k_randwrite_zipf_p0.fg.svg) |
| 52 | [sea_1osd_4reactor_randwrite_zipf_52](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_52io_4k_randwrite_zipf_p0.fg.svg) | [sea_1osd_4reactor_randwrite_zipf_52](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_52io_4k_randwrite_zipf_p0.fg.svg) |
| 64 | [sea_1osd_4reactor_randwrite_zipf_64](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_64io_4k_randwrite_zipf_p0.fg.svg) | [sea_1osd_4reactor_randwrite_zipf_64](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_64io_4k_randwrite_zipf_p0.fg.svg) |

| randwrite_zipf (8 reactor) | LRU | 2Q |
|-------------------------|-----|----|
| 1 | [sea_1osd_8reactor_randwrite_zipf_1](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_1io_4k_randwrite_zipf_p0.fg.svg) | [sea_1osd_8reactor_randwrite_zipf_1](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_1io_4k_randwrite_zipf_p0.fg.svg) |
| 2 | [sea_1osd_8reactor_randwrite_zipf_2](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_2io_4k_randwrite_zipf_p0.fg.svg) | [sea_1osd_8reactor_randwrite_zipf_2](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_2io_4k_randwrite_zipf_p0.fg.svg) |
| 4 | [sea_1osd_8reactor_randwrite_zipf_4](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_4io_4k_randwrite_zipf_p0.fg.svg) | [sea_1osd_8reactor_randwrite_zipf_4](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_4io_4k_randwrite_zipf_p0.fg.svg) |
| 8 | [sea_1osd_8reactor_randwrite_zipf_8](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_8io_4k_randwrite_zipf_p0.fg.svg) | [sea_1osd_8reactor_randwrite_zipf_8](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_8io_4k_randwrite_zipf_p0.fg.svg) |
| 16 | [sea_1osd_8reactor_randwrite_zipf_16](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_16io_4k_randwrite_zipf_p0.fg.svg) | [sea_1osd_8reactor_randwrite_zipf_16](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_16io_4k_randwrite_zipf_p0.fg.svg) |
| 24 | [sea_1osd_8reactor_randwrite_zipf_24](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_24io_4k_randwrite_zipf_p0.fg.svg) | [sea_1osd_8reactor_randwrite_zipf_24](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_24io_4k_randwrite_zipf_p0.fg.svg) |
| 32 | [sea_1osd_8reactor_randwrite_zipf_32](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_32io_4k_randwrite_zipf_p0.fg.svg) | [sea_1osd_8reactor_randwrite_zipf_32](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_32io_4k_randwrite_zipf_p0.fg.svg) |
| 40 | [sea_1osd_8reactor_randwrite_zipf_40](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_40io_4k_randwrite_zipf_p0.fg.svg) | [sea_1osd_8reactor_randwrite_zipf_40](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_40io_4k_randwrite_zipf_p0.fg.svg) |
| 52 | [sea_1osd_8reactor_randwrite_zipf_52](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_52io_4k_randwrite_zipf_p0.fg.svg) | [sea_1osd_8reactor_randwrite_zipf_52](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_52io_4k_randwrite_zipf_p0.fg.svg) |
| 64 | [sea_1osd_8reactor_randwrite_zipf_64](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_64io_4k_randwrite_zipf_p0.fg.svg) | [sea_1osd_8reactor_randwrite_zipf_64](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_64io_4k_randwrite_zipf_p0.fg.svg) |

| randwrite_norm (1 reactor) | LRU | 2Q |
|-------------------------|-----|----|
| 1 | [sea_1osd_1reactor_randwrite_norm_1](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_1io_4k_randwrite_norm_p0.fg.svg) | [sea_1osd_1reactor_randwrite_norm_1](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_1io_4k_randwrite_norm_p0.fg.svg) |
| 2 | [sea_1osd_1reactor_randwrite_norm_2](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_2io_4k_randwrite_norm_p0.fg.svg) | [sea_1osd_1reactor_randwrite_norm_2](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_2io_4k_randwrite_norm_p0.fg.svg) |
| 4 | [sea_1osd_1reactor_randwrite_norm_4](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_4io_4k_randwrite_norm_p0.fg.svg) | [sea_1osd_1reactor_randwrite_norm_4](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_4io_4k_randwrite_norm_p0.fg.svg) |
| 8 | [sea_1osd_1reactor_randwrite_norm_8](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_8io_4k_randwrite_norm_p0.fg.svg) | [sea_1osd_1reactor_randwrite_norm_8](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_8io_4k_randwrite_norm_p0.fg.svg) |
| 16 | [sea_1osd_1reactor_randwrite_norm_16](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_16io_4k_randwrite_norm_p0.fg.svg) | [sea_1osd_1reactor_randwrite_norm_16](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_16io_4k_randwrite_norm_p0.fg.svg) |
| 24 | [sea_1osd_1reactor_randwrite_norm_24](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_24io_4k_randwrite_norm_p0.fg.svg) | [sea_1osd_1reactor_randwrite_norm_24](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_24io_4k_randwrite_norm_p0.fg.svg) |
| 32 | [sea_1osd_1reactor_randwrite_norm_32](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_32io_4k_randwrite_norm_p0.fg.svg) | [sea_1osd_1reactor_randwrite_norm_32](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_32io_4k_randwrite_norm_p0.fg.svg) |
| 40 | [sea_1osd_1reactor_randwrite_norm_40](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_40io_4k_randwrite_norm_p0.fg.svg) | [sea_1osd_1reactor_randwrite_norm_40](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_40io_4k_randwrite_norm_p0.fg.svg) |
| 52 | [sea_1osd_1reactor_randwrite_norm_52](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_52io_4k_randwrite_norm_p0.fg.svg) | [sea_1osd_1reactor_randwrite_norm_52](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_52io_4k_randwrite_norm_p0.fg.svg) |
| 64 | [sea_1osd_1reactor_randwrite_norm_64](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_64io_4k_randwrite_norm_p0.fg.svg) | [sea_1osd_1reactor_randwrite_norm_64](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_64io_4k_randwrite_norm_p0.fg.svg) |

| randwrite_norm (4 reactor) | LRU | 2Q |
|-------------------------|-----|----|
| 1 | [sea_1osd_4reactor_randwrite_norm_1](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_1io_4k_randwrite_norm_p0.fg.svg) | [sea_1osd_4reactor_randwrite_norm_1](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_1io_4k_randwrite_norm_p0.fg.svg) |
| 2 | [sea_1osd_4reactor_randwrite_norm_2](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_2io_4k_randwrite_norm_p0.fg.svg) | [sea_1osd_4reactor_randwrite_norm_2](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_2io_4k_randwrite_norm_p0.fg.svg) |
| 4 | [sea_1osd_4reactor_randwrite_norm_4](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_4io_4k_randwrite_norm_p0.fg.svg) | [sea_1osd_4reactor_randwrite_norm_4](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_4io_4k_randwrite_norm_p0.fg.svg) |
| 8 | [sea_1osd_4reactor_randwrite_norm_8](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_8io_4k_randwrite_norm_p0.fg.svg) | [sea_1osd_4reactor_randwrite_norm_8](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_8io_4k_randwrite_norm_p0.fg.svg) |
| 16 | [sea_1osd_4reactor_randwrite_norm_16](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_16io_4k_randwrite_norm_p0.fg.svg) | [sea_1osd_4reactor_randwrite_norm_16](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_16io_4k_randwrite_norm_p0.fg.svg) |
| 24 | [sea_1osd_4reactor_randwrite_norm_24](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_24io_4k_randwrite_norm_p0.fg.svg) | [sea_1osd_4reactor_randwrite_norm_24](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_24io_4k_randwrite_norm_p0.fg.svg) |
| 32 | [sea_1osd_4reactor_randwrite_norm_32](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_32io_4k_randwrite_norm_p0.fg.svg) | [sea_1osd_4reactor_randwrite_norm_32](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_32io_4k_randwrite_norm_p0.fg.svg) |
| 40 | [sea_1osd_4reactor_randwrite_norm_40](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_40io_4k_randwrite_norm_p0.fg.svg) | [sea_1osd_4reactor_randwrite_norm_40](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_40io_4k_randwrite_norm_p0.fg.svg) |
| 52 | [sea_1osd_4reactor_randwrite_norm_52](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_52io_4k_randwrite_norm_p0.fg.svg) | [sea_1osd_4reactor_randwrite_norm_52](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_52io_4k_randwrite_norm_p0.fg.svg) |
| 64 | [sea_1osd_4reactor_randwrite_norm_64](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_64io_4k_randwrite_norm_p0.fg.svg) | [sea_1osd_4reactor_randwrite_norm_64](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_64io_4k_randwrite_norm_p0.fg.svg) |

| randwrite_norm (8 reactor) | LRU | 2Q |
|-------------------------|-----|----|
| 1 | [sea_1osd_8reactor_randwrite_norm_1](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_1io_4k_randwrite_norm_p0.fg.svg) | [sea_1osd_8reactor_randwrite_norm_1](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_1io_4k_randwrite_norm_p0.fg.svg) |
| 2 | [sea_1osd_8reactor_randwrite_norm_2](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_2io_4k_randwrite_norm_p0.fg.svg) | [sea_1osd_8reactor_randwrite_norm_2](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_2io_4k_randwrite_norm_p0.fg.svg) |
| 4 | [sea_1osd_8reactor_randwrite_norm_4](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_4io_4k_randwrite_norm_p0.fg.svg) | [sea_1osd_8reactor_randwrite_norm_4](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_4io_4k_randwrite_norm_p0.fg.svg) |
| 8 | [sea_1osd_8reactor_randwrite_norm_8](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_8io_4k_randwrite_norm_p0.fg.svg) | [sea_1osd_8reactor_randwrite_norm_8](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_8io_4k_randwrite_norm_p0.fg.svg) |
| 16 | [sea_1osd_8reactor_randwrite_norm_16](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_16io_4k_randwrite_norm_p0.fg.svg) | [sea_1osd_8reactor_randwrite_norm_16](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_16io_4k_randwrite_norm_p0.fg.svg) |
| 24 | [sea_1osd_8reactor_randwrite_norm_24](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_24io_4k_randwrite_norm_p0.fg.svg) | [sea_1osd_8reactor_randwrite_norm_24](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_24io_4k_randwrite_norm_p0.fg.svg) |
| 32 | [sea_1osd_8reactor_randwrite_norm_32](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_32io_4k_randwrite_norm_p0.fg.svg) | [sea_1osd_8reactor_randwrite_norm_32](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_32io_4k_randwrite_norm_p0.fg.svg) |
| 40 | [sea_1osd_8reactor_randwrite_norm_40](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_40io_4k_randwrite_norm_p0.fg.svg) | [sea_1osd_8reactor_randwrite_norm_40](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_40io_4k_randwrite_norm_p0.fg.svg) |
| 52 | [sea_1osd_8reactor_randwrite_norm_52](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_52io_4k_randwrite_norm_p0.fg.svg) | [sea_1osd_8reactor_randwrite_norm_52](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_52io_4k_randwrite_norm_p0.fg.svg) |
| 64 | [sea_1osd_8reactor_randwrite_norm_64](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_64io_4k_randwrite_norm_p0.fg.svg) | [sea_1osd_8reactor_randwrite_norm_64](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randwrite_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_64io_4k_randwrite_norm_p0.fg.svg) |

| randread_zoned (1 reactor) | LRU | 2Q |
|-------------------------|-----|----|
| 1 | [sea_1osd_1reactor_randread_zoned_1](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_1io_4k_randread_zoned_p0.fg.svg) | [sea_1osd_1reactor_randread_zoned_1](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_1io_4k_randread_zoned_p0.fg.svg) |
| 2 | [sea_1osd_1reactor_randread_zoned_2](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_2io_4k_randread_zoned_p0.fg.svg) | [sea_1osd_1reactor_randread_zoned_2](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_2io_4k_randread_zoned_p0.fg.svg) |
| 4 | [sea_1osd_1reactor_randread_zoned_4](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_4io_4k_randread_zoned_p0.fg.svg) | [sea_1osd_1reactor_randread_zoned_4](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_4io_4k_randread_zoned_p0.fg.svg) |
| 8 | [sea_1osd_1reactor_randread_zoned_8](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_8io_4k_randread_zoned_p0.fg.svg) | [sea_1osd_1reactor_randread_zoned_8](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_8io_4k_randread_zoned_p0.fg.svg) |
| 16 | [sea_1osd_1reactor_randread_zoned_16](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_16io_4k_randread_zoned_p0.fg.svg) | [sea_1osd_1reactor_randread_zoned_16](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_16io_4k_randread_zoned_p0.fg.svg) |
| 24 | [sea_1osd_1reactor_randread_zoned_24](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_24io_4k_randread_zoned_p0.fg.svg) | [sea_1osd_1reactor_randread_zoned_24](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_24io_4k_randread_zoned_p0.fg.svg) |
| 32 | [sea_1osd_1reactor_randread_zoned_32](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_32io_4k_randread_zoned_p0.fg.svg) | [sea_1osd_1reactor_randread_zoned_32](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_32io_4k_randread_zoned_p0.fg.svg) |
| 40 | [sea_1osd_1reactor_randread_zoned_40](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_40io_4k_randread_zoned_p0.fg.svg) | [sea_1osd_1reactor_randread_zoned_40](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_40io_4k_randread_zoned_p0.fg.svg) |
| 52 | [sea_1osd_1reactor_randread_zoned_52](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_52io_4k_randread_zoned_p0.fg.svg) | [sea_1osd_1reactor_randread_zoned_52](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_52io_4k_randread_zoned_p0.fg.svg) |
| 64 | [sea_1osd_1reactor_randread_zoned_64](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_64io_4k_randread_zoned_p0.fg.svg) | [sea_1osd_1reactor_randread_zoned_64](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_64io_4k_randread_zoned_p0.fg.svg) |

| randread_zoned (4 reactor) | LRU | 2Q |
|-------------------------|-----|----|
| 1 | [sea_1osd_4reactor_randread_zoned_1](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_1io_4k_randread_zoned_p0.fg.svg) | [sea_1osd_4reactor_randread_zoned_1](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_1io_4k_randread_zoned_p0.fg.svg) |
| 2 | [sea_1osd_4reactor_randread_zoned_2](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_2io_4k_randread_zoned_p0.fg.svg) | [sea_1osd_4reactor_randread_zoned_2](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_2io_4k_randread_zoned_p0.fg.svg) |
| 4 | [sea_1osd_4reactor_randread_zoned_4](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_4io_4k_randread_zoned_p0.fg.svg) | [sea_1osd_4reactor_randread_zoned_4](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_4io_4k_randread_zoned_p0.fg.svg) |
| 8 | [sea_1osd_4reactor_randread_zoned_8](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_8io_4k_randread_zoned_p0.fg.svg) | [sea_1osd_4reactor_randread_zoned_8](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_8io_4k_randread_zoned_p0.fg.svg) |
| 16 | [sea_1osd_4reactor_randread_zoned_16](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_16io_4k_randread_zoned_p0.fg.svg) | [sea_1osd_4reactor_randread_zoned_16](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_16io_4k_randread_zoned_p0.fg.svg) |
| 24 | [sea_1osd_4reactor_randread_zoned_24](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_24io_4k_randread_zoned_p0.fg.svg) | [sea_1osd_4reactor_randread_zoned_24](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_24io_4k_randread_zoned_p0.fg.svg) |
| 32 | [sea_1osd_4reactor_randread_zoned_32](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_32io_4k_randread_zoned_p0.fg.svg) | [sea_1osd_4reactor_randread_zoned_32](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_32io_4k_randread_zoned_p0.fg.svg) |
| 40 | [sea_1osd_4reactor_randread_zoned_40](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_40io_4k_randread_zoned_p0.fg.svg) | [sea_1osd_4reactor_randread_zoned_40](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_40io_4k_randread_zoned_p0.fg.svg) |
| 52 | [sea_1osd_4reactor_randread_zoned_52](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_52io_4k_randread_zoned_p0.fg.svg) | [sea_1osd_4reactor_randread_zoned_52](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_52io_4k_randread_zoned_p0.fg.svg) |
| 64 | [sea_1osd_4reactor_randread_zoned_64](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_64io_4k_randread_zoned_p0.fg.svg) | [sea_1osd_4reactor_randread_zoned_64](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_64io_4k_randread_zoned_p0.fg.svg) |

| randread_zoned (8 reactor) | LRU | 2Q |
|-------------------------|-----|----|
| 1 | [sea_1osd_8reactor_randread_zoned_1](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_1io_4k_randread_zoned_p0.fg.svg) | [sea_1osd_8reactor_randread_zoned_1](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_1io_4k_randread_zoned_p0.fg.svg) |
| 2 | [sea_1osd_8reactor_randread_zoned_2](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_2io_4k_randread_zoned_p0.fg.svg) | [sea_1osd_8reactor_randread_zoned_2](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_2io_4k_randread_zoned_p0.fg.svg) |
| 4 | [sea_1osd_8reactor_randread_zoned_4](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_4io_4k_randread_zoned_p0.fg.svg) | [sea_1osd_8reactor_randread_zoned_4](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_4io_4k_randread_zoned_p0.fg.svg) |
| 8 | [sea_1osd_8reactor_randread_zoned_8](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_8io_4k_randread_zoned_p0.fg.svg) | [sea_1osd_8reactor_randread_zoned_8](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_8io_4k_randread_zoned_p0.fg.svg) |
| 16 | [sea_1osd_8reactor_randread_zoned_16](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_16io_4k_randread_zoned_p0.fg.svg) | [sea_1osd_8reactor_randread_zoned_16](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_16io_4k_randread_zoned_p0.fg.svg) |
| 24 | [sea_1osd_8reactor_randread_zoned_24](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_24io_4k_randread_zoned_p0.fg.svg) | [sea_1osd_8reactor_randread_zoned_24](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_24io_4k_randread_zoned_p0.fg.svg) |
| 32 | [sea_1osd_8reactor_randread_zoned_32](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_32io_4k_randread_zoned_p0.fg.svg) | [sea_1osd_8reactor_randread_zoned_32](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_32io_4k_randread_zoned_p0.fg.svg) |
| 40 | [sea_1osd_8reactor_randread_zoned_40](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_40io_4k_randread_zoned_p0.fg.svg) | [sea_1osd_8reactor_randread_zoned_40](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_40io_4k_randread_zoned_p0.fg.svg) |
| 52 | [sea_1osd_8reactor_randread_zoned_52](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_52io_4k_randread_zoned_p0.fg.svg) | [sea_1osd_8reactor_randread_zoned_52](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_52io_4k_randread_zoned_p0.fg.svg) |
| 64 | [sea_1osd_8reactor_randread_zoned_64](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_64io_4k_randread_zoned_p0.fg.svg) | [sea_1osd_8reactor_randread_zoned_64](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zoned_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_64io_4k_randread_zoned_p0.fg.svg) |

| randread_zipf (1 reactor) | LRU | 2Q |
|-------------------------|-----|----|
| 1 | [sea_1osd_1reactor_randread_zipf_1](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_1io_4k_randread_zipf_p0.fg.svg) | [sea_1osd_1reactor_randread_zipf_1](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_1io_4k_randread_zipf_p0.fg.svg) |
| 2 | [sea_1osd_1reactor_randread_zipf_2](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_2io_4k_randread_zipf_p0.fg.svg) | [sea_1osd_1reactor_randread_zipf_2](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_2io_4k_randread_zipf_p0.fg.svg) |
| 4 | [sea_1osd_1reactor_randread_zipf_4](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_4io_4k_randread_zipf_p0.fg.svg) | [sea_1osd_1reactor_randread_zipf_4](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_4io_4k_randread_zipf_p0.fg.svg) |
| 8 | [sea_1osd_1reactor_randread_zipf_8](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_8io_4k_randread_zipf_p0.fg.svg) | [sea_1osd_1reactor_randread_zipf_8](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_8io_4k_randread_zipf_p0.fg.svg) |
| 16 | [sea_1osd_1reactor_randread_zipf_16](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_16io_4k_randread_zipf_p0.fg.svg) | [sea_1osd_1reactor_randread_zipf_16](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_16io_4k_randread_zipf_p0.fg.svg) |
| 24 | [sea_1osd_1reactor_randread_zipf_24](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_24io_4k_randread_zipf_p0.fg.svg) | [sea_1osd_1reactor_randread_zipf_24](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_24io_4k_randread_zipf_p0.fg.svg) |
| 32 | [sea_1osd_1reactor_randread_zipf_32](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_32io_4k_randread_zipf_p0.fg.svg) | [sea_1osd_1reactor_randread_zipf_32](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_32io_4k_randread_zipf_p0.fg.svg) |
| 40 | [sea_1osd_1reactor_randread_zipf_40](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_40io_4k_randread_zipf_p0.fg.svg) | [sea_1osd_1reactor_randread_zipf_40](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_40io_4k_randread_zipf_p0.fg.svg) |
| 52 | [sea_1osd_1reactor_randread_zipf_52](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_52io_4k_randread_zipf_p0.fg.svg) | [sea_1osd_1reactor_randread_zipf_52](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_52io_4k_randread_zipf_p0.fg.svg) |
| 64 | [sea_1osd_1reactor_randread_zipf_64](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_64io_4k_randread_zipf_p0.fg.svg) | [sea_1osd_1reactor_randread_zipf_64](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_64io_4k_randread_zipf_p0.fg.svg) |

| randread_zipf (4 reactor) | LRU | 2Q |
|-------------------------|-----|----|
| 1 | [sea_1osd_4reactor_randread_zipf_1](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_1io_4k_randread_zipf_p0.fg.svg) | [sea_1osd_4reactor_randread_zipf_1](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_1io_4k_randread_zipf_p0.fg.svg) |
| 2 | [sea_1osd_4reactor_randread_zipf_2](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_2io_4k_randread_zipf_p0.fg.svg) | [sea_1osd_4reactor_randread_zipf_2](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_2io_4k_randread_zipf_p0.fg.svg) |
| 4 | [sea_1osd_4reactor_randread_zipf_4](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_4io_4k_randread_zipf_p0.fg.svg) | [sea_1osd_4reactor_randread_zipf_4](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_4io_4k_randread_zipf_p0.fg.svg) |
| 8 | [sea_1osd_4reactor_randread_zipf_8](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_8io_4k_randread_zipf_p0.fg.svg) | [sea_1osd_4reactor_randread_zipf_8](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_8io_4k_randread_zipf_p0.fg.svg) |
| 16 | [sea_1osd_4reactor_randread_zipf_16](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_16io_4k_randread_zipf_p0.fg.svg) | [sea_1osd_4reactor_randread_zipf_16](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_16io_4k_randread_zipf_p0.fg.svg) |
| 24 | [sea_1osd_4reactor_randread_zipf_24](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_24io_4k_randread_zipf_p0.fg.svg) | [sea_1osd_4reactor_randread_zipf_24](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_24io_4k_randread_zipf_p0.fg.svg) |
| 32 | [sea_1osd_4reactor_randread_zipf_32](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_32io_4k_randread_zipf_p0.fg.svg) | [sea_1osd_4reactor_randread_zipf_32](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_32io_4k_randread_zipf_p0.fg.svg) |
| 40 | [sea_1osd_4reactor_randread_zipf_40](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_40io_4k_randread_zipf_p0.fg.svg) | [sea_1osd_4reactor_randread_zipf_40](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_40io_4k_randread_zipf_p0.fg.svg) |
| 52 | [sea_1osd_4reactor_randread_zipf_52](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_52io_4k_randread_zipf_p0.fg.svg) | [sea_1osd_4reactor_randread_zipf_52](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_52io_4k_randread_zipf_p0.fg.svg) |
| 64 | [sea_1osd_4reactor_randread_zipf_64](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_64io_4k_randread_zipf_p0.fg.svg) | [sea_1osd_4reactor_randread_zipf_64](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_64io_4k_randread_zipf_p0.fg.svg) |

| randread_zipf (8 reactor) | LRU | 2Q |
|-------------------------|-----|----|
| 1 | [sea_1osd_8reactor_randread_zipf_1](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_1io_4k_randread_zipf_p0.fg.svg) | [sea_1osd_8reactor_randread_zipf_1](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_1io_4k_randread_zipf_p0.fg.svg) |
| 2 | [sea_1osd_8reactor_randread_zipf_2](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_2io_4k_randread_zipf_p0.fg.svg) | [sea_1osd_8reactor_randread_zipf_2](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_2io_4k_randread_zipf_p0.fg.svg) |
| 4 | [sea_1osd_8reactor_randread_zipf_4](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_4io_4k_randread_zipf_p0.fg.svg) | [sea_1osd_8reactor_randread_zipf_4](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_4io_4k_randread_zipf_p0.fg.svg) |
| 8 | [sea_1osd_8reactor_randread_zipf_8](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_8io_4k_randread_zipf_p0.fg.svg) | [sea_1osd_8reactor_randread_zipf_8](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_8io_4k_randread_zipf_p0.fg.svg) |
| 16 | [sea_1osd_8reactor_randread_zipf_16](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_16io_4k_randread_zipf_p0.fg.svg) | [sea_1osd_8reactor_randread_zipf_16](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_16io_4k_randread_zipf_p0.fg.svg) |
| 24 | [sea_1osd_8reactor_randread_zipf_24](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_24io_4k_randread_zipf_p0.fg.svg) | [sea_1osd_8reactor_randread_zipf_24](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_24io_4k_randread_zipf_p0.fg.svg) |
| 32 | [sea_1osd_8reactor_randread_zipf_32](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_32io_4k_randread_zipf_p0.fg.svg) | [sea_1osd_8reactor_randread_zipf_32](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_32io_4k_randread_zipf_p0.fg.svg) |
| 40 | [sea_1osd_8reactor_randread_zipf_40](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_40io_4k_randread_zipf_p0.fg.svg) | [sea_1osd_8reactor_randread_zipf_40](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_40io_4k_randread_zipf_p0.fg.svg) |
| 52 | [sea_1osd_8reactor_randread_zipf_52](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_52io_4k_randread_zipf_p0.fg.svg) | [sea_1osd_8reactor_randread_zipf_52](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_52io_4k_randread_zipf_p0.fg.svg) |
| 64 | [sea_1osd_8reactor_randread_zipf_64](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_64io_4k_randread_zipf_p0.fg.svg) | [sea_1osd_8reactor_randread_zipf_64](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_zipf_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_64io_4k_randread_zipf_p0.fg.svg) |

| randread_norm (1 reactor) | LRU | 2Q |
|-------------------------|-----|----|
| 1 | [sea_1osd_1reactor_randread_norm_1](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_1io_4k_randread_norm_p0.fg.svg) | [sea_1osd_1reactor_randread_norm_1](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_1io_4k_randread_norm_p0.fg.svg) |
| 2 | [sea_1osd_1reactor_randread_norm_2](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_2io_4k_randread_norm_p0.fg.svg) | [sea_1osd_1reactor_randread_norm_2](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_2io_4k_randread_norm_p0.fg.svg) |
| 4 | [sea_1osd_1reactor_randread_norm_4](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_4io_4k_randread_norm_p0.fg.svg) | [sea_1osd_1reactor_randread_norm_4](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_4io_4k_randread_norm_p0.fg.svg) |
| 8 | [sea_1osd_1reactor_randread_norm_8](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_8io_4k_randread_norm_p0.fg.svg) | [sea_1osd_1reactor_randread_norm_8](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_8io_4k_randread_norm_p0.fg.svg) |
| 16 | [sea_1osd_1reactor_randread_norm_16](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_16io_4k_randread_norm_p0.fg.svg) | [sea_1osd_1reactor_randread_norm_16](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_16io_4k_randread_norm_p0.fg.svg) |
| 24 | [sea_1osd_1reactor_randread_norm_24](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_24io_4k_randread_norm_p0.fg.svg) | [sea_1osd_1reactor_randread_norm_24](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_24io_4k_randread_norm_p0.fg.svg) |
| 32 | [sea_1osd_1reactor_randread_norm_32](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_32io_4k_randread_norm_p0.fg.svg) | [sea_1osd_1reactor_randread_norm_32](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_32io_4k_randread_norm_p0.fg.svg) |
| 40 | [sea_1osd_1reactor_randread_norm_40](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_40io_4k_randread_norm_p0.fg.svg) | [sea_1osd_1reactor_randread_norm_40](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_40io_4k_randread_norm_p0.fg.svg) |
| 52 | [sea_1osd_1reactor_randread_norm_52](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_52io_4k_randread_norm_p0.fg.svg) | [sea_1osd_1reactor_randread_norm_52](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_52io_4k_randread_norm_p0.fg.svg) |
| 64 | [sea_1osd_1reactor_randread_norm_64](data/1osd_1reactor_2G_LRU_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_64io_4k_randread_norm_p0.fg.svg) | [sea_1osd_1reactor_randread_norm_64](data/1osd_1reactor_2G_2Q_32fio_sea/sea_1osd_1reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_1reactor_32fio_bal_osd_rc_1job_64io_4k_randread_norm_p0.fg.svg) |

| randread_norm (4 reactor) | LRU | 2Q |
|-------------------------|-----|----|
| 1 | [sea_1osd_4reactor_randread_norm_1](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_1io_4k_randread_norm_p0.fg.svg) | [sea_1osd_4reactor_randread_norm_1](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_1io_4k_randread_norm_p0.fg.svg) |
| 2 | [sea_1osd_4reactor_randread_norm_2](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_2io_4k_randread_norm_p0.fg.svg) | [sea_1osd_4reactor_randread_norm_2](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_2io_4k_randread_norm_p0.fg.svg) |
| 4 | [sea_1osd_4reactor_randread_norm_4](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_4io_4k_randread_norm_p0.fg.svg) | [sea_1osd_4reactor_randread_norm_4](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_4io_4k_randread_norm_p0.fg.svg) |
| 8 | [sea_1osd_4reactor_randread_norm_8](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_8io_4k_randread_norm_p0.fg.svg) | [sea_1osd_4reactor_randread_norm_8](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_8io_4k_randread_norm_p0.fg.svg) |
| 16 | [sea_1osd_4reactor_randread_norm_16](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_16io_4k_randread_norm_p0.fg.svg) | [sea_1osd_4reactor_randread_norm_16](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_16io_4k_randread_norm_p0.fg.svg) |
| 24 | [sea_1osd_4reactor_randread_norm_24](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_24io_4k_randread_norm_p0.fg.svg) | [sea_1osd_4reactor_randread_norm_24](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_24io_4k_randread_norm_p0.fg.svg) |
| 32 | [sea_1osd_4reactor_randread_norm_32](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_32io_4k_randread_norm_p0.fg.svg) | [sea_1osd_4reactor_randread_norm_32](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_32io_4k_randread_norm_p0.fg.svg) |
| 40 | [sea_1osd_4reactor_randread_norm_40](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_40io_4k_randread_norm_p0.fg.svg) | [sea_1osd_4reactor_randread_norm_40](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_40io_4k_randread_norm_p0.fg.svg) |
| 52 | [sea_1osd_4reactor_randread_norm_52](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_52io_4k_randread_norm_p0.fg.svg) | [sea_1osd_4reactor_randread_norm_52](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_52io_4k_randread_norm_p0.fg.svg) |
| 64 | [sea_1osd_4reactor_randread_norm_64](data/1osd_4reactor_2G_LRU_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_64io_4k_randread_norm_p0.fg.svg) | [sea_1osd_4reactor_randread_norm_64](data/1osd_4reactor_2G_2Q_32fio_sea/sea_1osd_4reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_4reactor_32fio_bal_osd_rc_1job_64io_4k_randread_norm_p0.fg.svg) |

| randread_norm (8 reactor) | LRU | 2Q |
|-------------------------|-----|----|
| 1 | [sea_1osd_8reactor_randread_norm_1](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_1io_4k_randread_norm_p0.fg.svg) | [sea_1osd_8reactor_randread_norm_1](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_1io_4k_randread_norm_p0.fg.svg) |
| 2 | [sea_1osd_8reactor_randread_norm_2](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_2io_4k_randread_norm_p0.fg.svg) | [sea_1osd_8reactor_randread_norm_2](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_2io_4k_randread_norm_p0.fg.svg) |
| 4 | [sea_1osd_8reactor_randread_norm_4](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_4io_4k_randread_norm_p0.fg.svg) | [sea_1osd_8reactor_randread_norm_4](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_4io_4k_randread_norm_p0.fg.svg) |
| 8 | [sea_1osd_8reactor_randread_norm_8](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_8io_4k_randread_norm_p0.fg.svg) | [sea_1osd_8reactor_randread_norm_8](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_8io_4k_randread_norm_p0.fg.svg) |
| 16 | [sea_1osd_8reactor_randread_norm_16](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_16io_4k_randread_norm_p0.fg.svg) | [sea_1osd_8reactor_randread_norm_16](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_16io_4k_randread_norm_p0.fg.svg) |
| 24 | [sea_1osd_8reactor_randread_norm_24](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_24io_4k_randread_norm_p0.fg.svg) | [sea_1osd_8reactor_randread_norm_24](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_24io_4k_randread_norm_p0.fg.svg) |
| 32 | [sea_1osd_8reactor_randread_norm_32](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_32io_4k_randread_norm_p0.fg.svg) | [sea_1osd_8reactor_randread_norm_32](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_32io_4k_randread_norm_p0.fg.svg) |
| 40 | [sea_1osd_8reactor_randread_norm_40](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_40io_4k_randread_norm_p0.fg.svg) | [sea_1osd_8reactor_randread_norm_40](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_40io_4k_randread_norm_p0.fg.svg) |
| 52 | [sea_1osd_8reactor_randread_norm_52](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_52io_4k_randread_norm_p0.fg.svg) | [sea_1osd_8reactor_randread_norm_52](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_52io_4k_randread_norm_p0.fg.svg) |
| 64 | [sea_1osd_8reactor_randread_norm_64](data/1osd_8reactor_2G_LRU_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_64io_4k_randread_norm_p0.fg.svg) | [sea_1osd_8reactor_randread_norm_64](data/1osd_8reactor_2G_2Q_32fio_sea/sea_1osd_8reactor_32fio_bal_osd_rc_1procs_randread_norm_d/sea_1osd_8reactor_32fio_bal_osd_rc_1job_64io_4k_randread_norm_p0.fg.svg) |



