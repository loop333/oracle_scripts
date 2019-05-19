with param as
(
 select to_date('19.05.2019 06:00:00', 'DD.MM.YYYY HH24:MI:SS') begin,
        to_date('19.05.2019 14:00:00', 'DD.MM.YYYY HH24:MI:SS') end
        from dual
)
select
 s.begin_interval_time t, sn.stat_name s, (ss2.value-ss1.value) v 
from
 param p, sys.wrm$_snapshot s, sys.wrh$_sysstat ss1, sys.wrh$_sysstat ss2, sys.wrh$_stat_name sn
where
 s.begin_interval_time < p.end and s.end_interval_time > p.begin
 and ss1.dbid = s.dbid and ss1.instance_number = s.instance_number and ss1.snap_id = s.snap_id-1
 and ss2.dbid = s.dbid and ss2.instance_number = s.instance_number and ss2.snap_id = s.snap_id
 and sn.dbid = ss1.dbid and sn.stat_id = ss1.stat_id
 and sn.dbid = ss2.dbid and sn.stat_id = ss2.stat_id
-- and sn.stat_name = 'DB time'
-- and sn.stat_name = 'application wait time'
-- and sn.stat_name = 'file io wait time'
-- and sn.stat_name = 'user I/O wait time'
 and sn.stat_name = 'physical read bytes'
-- and sn.stat_name = 'physical read total bytes'
-- and sn.stat_name = 'logical read bytes from cache'
-- and sn.stat_name = 'physical write total bytes
-- and sn.stat_name = 'physical write bytes
-- and lower(sn.stat_name) like '%wait%time%'
order by
 s.begin_interval_time, sn.stat_id

/*
commit wait performed
index fast full scans (full)
EHCC Normal Scan CUs Decompressed
exchange deadlocks
TBS Extension: bytes extended
cell smart IO session cache lookups
CPU used by this session
redo synch time overhead count (<32 msec)
gc current blocks served
non-idle wait count
securefile dedup prefix hash match
OS Integral unshared data size
enqueue conversions
HSC OLTP recursive compression
gc read waits
parse count (total)
immediate CR cleanouts (index blocks)
No. of XS Sessions Created
opened cursors cumulative
TBS Extension: files extended
cell CUs processed for uncompressed
db block gets direct
DBWR undo block writes
checkpoint clones created for ADG recovery
table scans (cache partitions)
gc read wait failures
tune down retentions in space pressure
parse count (hard)
cell num smartio automem buffer allocation attempts
securefile compressed bytes
SQL*Net roundtrips to/from client
bytes received via SQL*Net from client
physical writes from cache
total number of cf enq holders
commit cleanout failures: cannot pin
segment prealloc bytes
transaction lock foreground requests
java call heap used size
segment prealloc ops
parse time cpu
OS Signals received
segment prealloc time (ms)
java session heap live object count
spare statistic 1
spare statistic 9
bytes via SQL*Net vector to dblink
IMU undo allocation size
undo segment header was pinned
cell blocks processed by data layer
redo log space wait time
cell num smart IO sessions in rdbms block IO due to big payload
securefile rmv from dedup set
HSC OLTP Non Compressible Blocks
cell transactions found in commit cache
HSC OLTP negative compression
temp space allocated (bytes)
physical read partial requests
physical reads cache prefetch
securefile create dedup set
native hash arithmetic execute
segment total chunk allocation
Parallel operations downgraded 75 to 99 pct
gc current block pin time
gc current blocks received
number of map operations
cell writes to flash cache
cell statistics spare5
space was found by tune down
table scans (short tables)
redo blocks checksummed by FG (exclusive)
redo k-bytes read for recovery
EHCC CUs Compressed
user logouts cumulative
cell physical IO bytes saved during optimized file creation
prefetch clients - 2k
Batched IO block miss count
cell smart IO session cache hits
branch node splits
HSC Heap Segment Block Changes
total number of times SMON posted
segment prealloc ufs2cfs bytes
cell blocks processed by index layer
securefile add dedupd lob to set
consistent gets direct
Workload Replay: dbtime
redo subscn max counts
GTX processes stopped by autotune
gc cr block build time
parse count (describe)
java session heap object count max
index reclamation/extension switch
enqueue deadlocks
physical reads for flashback new
securefile dedup hash collision
commit nowait performed
EHCC Dump CUs Decompressed
gc blocks lost
PX local messages sent
session pga memory max
CR blocks created
physical read bytes
queue update without cp update
physical reads retry corrupt
HSC Compressed Segment Block Changes
EHCC Conventional DMLs
gc cr block flush time
redo write info find fail
HSC OLTP Drop Column
blocks decrypted
DX/BB enqueue lock foreground requests
ADG parselock X get attempts
session cursor cache count
CPU used when call started
prefetch clients - keep
OS CPU Qt wait time
SMON posted for undo segment shrink
java call heap total size max
user commits
blocks encrypted
cell num block IOs due to a file instant restore in progress
java call heap used size max
EHCC Total Rows for Decompression
Workload Replay: user calls
java call heap live object count
cell num smart IO sessions using passthru mode due to cellsrv
commit batch/immediate requested
cold recycle reads
DBWR object drop buffers written
EHCC Query High CUs Decompressed
IMU pool not allocated
recovery blocks skipped lost write checks
table fetch by rowid
spare statistic 3
securefile number of flushes
cell num bytes in passthru during predicate offload
root node splits
securefile direct read bytes
GTX processes spawned by autotune
cell blocks helped by minscn optimization
doubling up with imu segment
redo size for direct writes
EHCC Attempted Block Compressions
cell num smartio automem buffer allocation failures
recursive system API invocations
Block Cleanout Optim referenced
cell num smart IO sessions in rdbms block IO due to user
OS Block output operations
flashback cache read optimizations for block new
bytes via SQL*Net vector to client
Batched IO vector block count
commit cleanout failures: block lost
EHCC Rows Compressed
physical read IO requests
prefetch clients - 16k
commit immediate requested
workarea executions - onepass
OS Page reclaims
Batched IO slow jump count
securefile dedup fits inline
pinned buffers inspected
OS Maximum resident set size
HSC OLTP Space Saving
space was not found by tune down
Workload Replay: time gain
redo KB read
session stored procedure space
db block changes
read-only violation count
CCursor + sql area evicted
free buffer inspected
OS Block input operations
db block gets from cache (fastpath)
redo synch time (usec)
frame signature mismatch
chained rows rejected by cell
background timeouts
flashback log write bytes
physical writes direct temporary tablespace
segment dispenser load empty
HSC OLTP positive compression
max cf enq hold time
securefile destroy dedup set
table scans (long tables)
local undo segment hints helped
No. of Namespaces Created
transaction tables consistent reads - undo records applied
gc force cr disk read
db corrupt blocks detected
gc cr blocks served
cleanouts and rollbacks - consistent read gets
application wait time
cell commit cache queries
shared io pool buffer get failure
cell scans
No. of Decrypt ops
parse count (failures)
cell IO uncompressed bytes
No. of Principal Invalidations
ges messages sent
securefile direct write ops
Batched IO same unit count
OS System time used
queue splits
chained rows processed by cell
RowCR - row contention
physical writes
redo write broadcast ack time
cell num smart IO sessions in rdbms block IO due to no cell mem
IMU ktichg flush
cell CUs processed for compressed
DBWR checkpoint buffers written
Workload Capture: user calls
redo size
No. of XS Sessions Attached
SMON posted for txn recovery for other instances
cell blocks processed by cache layer
EHCC Total Pieces for Decompression
flashback direct read optimizations for block new
Workload Capture: errors
gc read wait timeouts
leaf node 90-10 splits
file io wait time
EHCC Query Low CUs Decompressed
Workload Capture: user logins
java call heap live size max
buffer is pinned count
table scans (rowid ranges)
switch current to new buffer
physical write total IO requests
global enqueue gets sync
dirty buffers inspected
EHCC Decompressed Length Decompressed
securefile dedup wapp cache miss
gc current block receive time
commit batch performed
messages received
transaction tables consistent read rollbacks
table scan rows gotten
prefetch clients - 8k
commit txn count during cleanout
gc remote grants
table fetch continued row
leaf node splits
No. of Roles Enabled or Disabled
DX/BB enqueue lock background get time
parse time elapsed
PX local messages recv'd
redo synch writes
index crx upgrade (found)
cell physical IO bytes saved during optimized RMAN file restore
redo buffer allocation retries
prefetched blocks aged out before use
undo change vector size
db block gets
TBS Extension: tasks created
No. of Principal Cache Misses
drop segment calls in space pressure
global enqueue releases
Heap Segment Array Inserts
commit wait/nowait performed
index fast full scans (rowid ranges)
session logical reads in local numa group
cell num smart IO sessions using passthru mode due to timezone
redo synch time overhead count (<128 msec)
cell num smart IO sessions in rdbms block IO due to open fail
prefetch clients - default
cell statistics spare6
bytes sent via SQL*Net to dblink
commit cleanout failures: buffer being written
index fast full scans (direct read)
EHCC Rowid CUs Decompressed
java call heap total size
java session heap used size
physical read flash cache hits
session connect time
summed dirty queue length
flash cache insert skip: not current
consistent gets - examination
java session heap used size max
DBWR checkpoints
Batched IO zero block count
EHCC Analyze CUs Decompressed
gc cr block receive time
cell statistics spare3
DBWR parallel query checkpoint buffers written
global undo segment hints helped
serializable aborts
Batched IO double miss count
gc kbytes saved
EHCC Pieces Buffered for Decompression
spare statistic 7
cell num smart IO sessions using passthru mode due to user
session uga memory
java call heap object count max
cell partial writes in flash cache
EHCC CU Row Pieces Compressed
OS Socket messages sent
DX/BB enqueue lock foreground wait time
index crx upgrade (prefetch)
IMU commits
redo blocks checksummed by LGWR
TBS Extension: tasks executed
native hash arithmetic fail
redo writes
java session heap live size max
gc claim blocks lost
OS Swaps
LOB table id lookup cache misses
bytes received via SQL*Net from dblink
redo log space requests
logical read bytes from cache
cluster key scan block gets
physical read total multi block requests
securefile allocation chunks
segment chunks allocation from disepnser
hot buffers moved to head of LRU
process last non-idle time
EHCC CUs Decompressed
cell simulated physical IO bytes returned by predicate offload
user logons cumulative
commit cleanout failures: write disabled
redo k-bytes read for terminal recovery
local undo segment hints were stale
IMU undo retention flush
sorts (memory)
IMU Flushes
redo ordering marks
SMON posted for undo segment recovery
OS Socket messages received
redo synch time overhead count (<2 msec)
DBWR lru scans
redo write broadcast ack count
DBWR transaction table writes
Workload Capture: size (in bytes) of recording
EHCC DML CUs Decompressed
consistent gets from cache (fastpath)
HSC OLTP Compressed Blocks
EHCC Turbo Scan CUs Decompressed
redo entries for lost write detection
prefetch warmup blocks flushed out before use
cell blocks helped by commit cache
Workload Replay: time loss
total number of slots
Workload Capture: unsupported user calls
IMU CR rollbacks
Workload Capture: user calls flushed
cell physical IO bytes saved by storage index
java session heap live size
scheduler wait time
physical reads
securefile inode write time
Heap Segment Array Updates
java call heap gc count
gc blocks corrupt
physical read total bytes optimized
RowCR attempts
opened cursors current
enqueue waits
Number of RANDOM redactions
DBWR fusion writes
heap block compress
EHCC Archive CUs Compressed
commit batch requested
Number of PARTIAL redactions
prefetch clients - 32k
cell num bytes in block IO during predicate offload
cell overwrites in flash cache
Cached Commit SCN referenced
DX/BB enqueue lock background gets
redo blocks written
gc cr block send time
HSC IDL Compressed Blocks
OS Integral shared text size
Parallel operations not downgraded
IMU- failed to get a private strand
SQL*Net roundtrips to/from dblink
OS Voluntary context switches
enqueue timeouts
java call heap live size
cluster wait time
workarea memory allocated
enqueue requests
Workload Replay: deadlocks resolved
background checkpoints completed
execute count
Commit SCN cached
securefile reject deduplication
OTC commit optimization attempts
physical read requests optimized
physical write requests optimized
messages sent
shared hash latch upgrades - no wait
physical write total bytes
non-idle wait time
commit cleanout failures: hot backup in progress
java call heap collected count
sorts (disk)
EHCC Used on ZFS Tablespace
PX remote messages recv'd
securefile dedup flush too low
enqueue releases
flash cache insert skip: corrupt
physical reads direct (lob)
PX remote messages sent
queue position update
physical read total bytes
cleanout - number of ktugct calls
RowCR - resume
physical reads direct
IMU recursive-transaction flush
physical writes non checkpoint
redo synch time overhead count (>=128 msec)
remote Oradebug requests
EHCC Analyzer Calls
recovery array reads
index crx upgrade (positioned)
bytes via SQL*Net vector from client
HSC OLTP compression block checked
EHCC Decompressed Length Compressed
cell num smart file creation sessions using rdbms block IO mode
DBWR tablespace checkpoint buffers written
HSC OLTP inline compression
recursive calls
physical reads direct temporary tablespace
logons cumulative
immediate (CURRENT) block cleanout applications
Batched IO (bound) vector count
buffer is not pinned count
recovery blocks read for lost write detection
redo blocks read for recovery
lob writes
failed probes on index block reclamation
physical writes direct
queue single row
Misses for writing mapping
spare statistic 10
spare statistic 6
Number of FORMAT_PRESERVING redactions
gc current block send time
DFO trees parallelized
IMU bind flushes
redo synch long waits
sql area purged
gcs messages sent
pinned cursors current
DBWR revisited being-written buffer
calls to kcmgcs
securefile bytes encrypted
index fetch by key
no work - consistent read gets
Workload Replay: network time
change write time
consistent gets from cache
commit wait requested
segment dispenser load tasks
min active SCN optimization applied on CR
EHCC Block Compressions
gc cr blocks received
user calls
redo KB read (memory)
cell smart IO session cache soft misses
global enqueue gets async
cell CUs sent compressed
physical write IO requests
cleanouts only - consistent read gets
IMU contention
No. of User Callbacks Executed
Number of NONE redactions
data blocks consistent reads - undo records applied
cell flash cache read hits
commit cleanouts
flash cache inserts
OS Integral unshared stack size
cell physical IO interconnect bytes
java call heap live object count max
shared io pool buffer get success
bytes sent via SQL*Net to client
redo synch time overhead count (<8 msec)
write clones created in background
segment dispenser allocations
recovery array read time
queue qno pages
cell smart IO session cache hwm
cell statistics spare1
session logical reads in remote numa group
securefile uncompressed bytes
Workload Capture: user txns
spare statistic 5
background checkpoints started
cell physical IO bytes eligible for predicate offload
cell statistics spare4
recursive aborts on index block reclamation
logons current
Number of REGEXP redactions
commit cleanout failures: callback failure 
redo KB read for transport
redo write time
physical reads prefetch warmup
flashback log writes
calls to get snapshot scn: kcmgss
physical write bytes
rollbacks only - consistent read gets
flash cache eviction: buffer pinned
auto extends on undo tablespace
current blocks converted for CR
session logical reads
queue flush
cell physical IO bytes sent directly to DB node to balance CPU 
segment prealloc tasks
workarea executions - optimal
EHCC Archive CUs Decompressed
sql area evicted
securefile direct read ops
cell num fast response sessions
EHCC Query Low CUs Compressed
prefetch warmup blocks aged out before use
prefetch clients - 4k
cell smart IO session cache hard misses
gc read wait time
cell physical IO interconnect bytes returned by smart scan
cell blocks processed by txn layer
Parallel operations downgraded 50 to 75 pct
Workload Capture: unreplayable user calls
flash cache insert skip: exists
rows fetched via callback
flash cache eviction: aged out
physical writes direct (lob)
global undo segment hints were stale
queries parallelized
OS Involuntary context switches
immediate (CR) block cleanout applications
Batched IO (full) vector count
recovery blocks read
Parallel operations downgraded 25 to 50 pct
user I/O wait time
chained rows skipped by cell
physical read total IO requests
gc kbytes sent
OS Page faults
table scans (direct read)
EHCC Compressed Length Decompressed
spare statistic 8
java session heap gc count
No. of Encrypt ops
active txn count during cleanout
shared hash latch upgrades - wait
EHCC Query High CUs Compressed
deferred (CURRENT) block cleanout applications
Batched IO single block count
free buffer requested
bytes via SQL*Net vector from dblink
cell index scans
securefile direct write bytes
recovery block gets from cache
EHCC Columns Decompressed
redo synch polls
RowCR hits
HSC OLTP Compression skipped rows
redo wastage
global enqueue CPU used by this session
java call heap object count
redo entries
transaction lock background get time
commit immediate performed
spare statistic 4
flash cache insert skip: DBWR overloaded
gc blocks compressed
EHCC Rows Not Compressed
no buffer to keep pinned count
Workload Capture: dbtime
Clusterwide global transactions spanning RAC nodes
physical write total multi block requests
commit cleanouts successfully completed
cluster key scans
redo write info find
java call heap collected bytes
index scans kdiixs1
securefile allocation bytes
SMON posted for dropping temp segment
rollback changes - undo records applied
number of map misses
flash cache insert skip: not useful
total number of undo segments dropped
lob reads
OS User time used
OTC commit optimization failure - setup
flash cache eviction: invalidated
DB time
total cf enq hold time
gc local grants
spare statistic 12
user rollbacks
session cursor cache hits
Batched IO buffer defrag count
cell num fast response sessions continuing to smart scan
commit nowait requested
commit batch/immediate performed
Parallel operations downgraded 1 to 25 pct
IMU mbu flush
in call idle wait time
securefile bytes deduplicated
securefile bytes cleartext
Batched IO (space) vector count
securefile inode ioreap time
cell statistics spare2
table scan blocks gotten
global enqueue get time
securefile dedup callback oper final
java session heap live object count max
sorts (rows)
EHCC Total Columns for Decompression
DML statements parallelized
cell simulated physical IO bytes eligible for predicate offload
java session heap collected count
commit wait/nowait requested
workarea executions - multipass
db corrupt blocks recovered
ADG parselock X get successes
spare statistic 2
EHCC Check CUs Decompressed
deferred CUR cleanouts (index blocks)
redo size for lost write detection
session uga memory max
redo synch poll writes
concurrency wait time
consistent changes
Number of read IOs issued
queue ocp pages
EHCC Used on Pillar Tablespace
DBWR thread checkpoint buffers written
cell CUs sent head piece
gc reader bypass grants
redo KB read (memory) for transport
Batched IO vector read count
IMU Redo allocation size
securefile bytes non-transformed
redo synch time overhead (usec)
java session heap collected bytes
transaction lock background gets
Requests to/from client
steps of tune down ret. in space pressure
transaction rollbacks
file io service time
SMON posted for instance recovery
recursive cpu usage
redo write broadcast lgwr post count
db block gets from cache
securefile inode read time
Number of FULL redactions
transaction lock foreground wait time
segment cfs allocations
write clones created for recovery
prefetch clients - recycle
spare statistic 11
OTC commit optimization hits
cursor authentications
calls to kcmgas
java session heap object count
physical write total bytes optimized
gc current block flush time
gc CPU used by this session
securefile number of non-transformed flushes
DDL statements parallelized
Clusterwide global transactions
flash cache insert skip: modification
cell CUs sent uncompressed
session pga memory
consistent gets
Effective IO time
physical reads cache
EHCC Compressed Length Compressed
calls to kcmgrs
redo synch time
lob writes unaligned
write clones created in foreground
Workload Replay: think time
IPC CPU used by this session
Forwarded 2PC commands across RAC nodes
Parallel operations downgraded to serial
*/
