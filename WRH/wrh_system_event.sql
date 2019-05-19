with param as
(
 select to_date('19.05.2019 06:00:00', 'DD.MM.YYYY HH24:MI:SS') begin,
        to_date('19.05.2019 14:00:00', 'DD.MM.YYYY HH24:MI:SS') end
        from dual
)
select
 s.begin_interval_time t,
-- en.event_id,
 en.wait_class,
 en.event_name,
 (se2.total_waits-se1.total_waits) total_waits, 
 (se2.total_timeouts-se1.total_timeouts) total_timeouts, 
 (se2.time_waited_micro-se1.time_waited_micro) time_waited_micro, 
 (se2.total_waits_fg-se1.total_waits_fg) total_waits_fg, 
 (se2.total_timeouts_fg-se1.total_timeouts_fg) total_timeouts_fg, 
 (se2.time_waited_micro_fg-se1.time_waited_micro_fg) time_waited_micro_fg 
from
 param p, sys.wrm$_snapshot s, sys.wrh$_system_event se1, sys.wrh$_system_event se2, sys.wrh$_event_name en
where
 s.begin_interval_time < p.end and s.end_interval_time > p.begin
 and se1.dbid = s.dbid and se1.instance_number = s.instance_number and se1.snap_id = s.snap_id-1
 and se2.dbid = s.dbid and se2.instance_number = s.instance_number and se2.snap_id = s.snap_id
 and en.dbid = se1.dbid and en.event_id = se1.event_id
 and en.dbid = se2.dbid and en.event_id = se2.event_id
-- and en.event_name = 'db file scattered read'
 and en.event_name = 'db file sequential read'
-- and en.event_name = 'db file parallel read'
-- and en.event_name = 'direct path read'
-- and en.event_name = 'direct path write'
-- and en.event_name = 'db file single write'
-- and en.event_name = 'db file parallel write'
-- and lower(en.event_name) like '%write%'
order by
 s.begin_interval_time, en.event_id

/*
kksfbc child completion
latch: checkpoint queue latch
BFILE get path object
LogMiner preparer: idle
direct path write temp
SecureFile mutex
control file heartbeat
index block split
PX Deq: Msg Fragment
os thread startup
PX Deq: Execution Msg
ksdxexeotherwait
db file async I/O submit
latch: call allocation
Streams miscellaneous event
enq: RO - fast object reuse
Streams capture: waiting for subscribers to catch up
flashback log file sync
Disk file operations I/O
BFILE closure
PX qref latch
enq: XL - fault extent map
log file single write
wait for unread message on broadcast channel
buffer deadlock
HS message to agent
wait for EMON to spawn
latch: redo allocation
enq: TX - allocate ITL entry
latch: object queue header operation
enq: JS - queue lock
enq: TX - row lock contention
CSS group membership query
cursor: pin S
CSS initialization
BFILE get length
db file scattered read
log file sequential read
SQL*Net more data to client
SQL*Net break/reset to dblink
ADR file lock
enq: TM - contention
latch: parallel query alloc buffer
enq: UL - contention
jobq slave wait
PX Deq: Table Q Normal
Streams capture: waiting for database startup
PL/SQL lock timer
db file parallel read
direct path read temp
rdbms ipc message
cursor: mutex X
Streams capture: waiting for archive log
direct path write
reliable message
DBWR range invalidation sync
library cache lock
Streams AQ: qmn coordinator idle wait
PX Deq: Txn Recovery Reply
EMON slave idle wait
enq: TX - index contention
Streams AQ: emn coordinator idle wait
class slave wait
PX Deq: Table Q Sample
latch: row cache objects
Streams AQ: deallocate messages from Streams Pool
SQL*Net more data from dblink
multiple dbwriter suspend/resume for file offline
Parameter File I/O
checkpoint completed
LogMiner builder: idle
enq: TC - contention
enq: FB - contention
BFILE read
db file single write
log file sync
L1 validation
latch: In memory undo latch
smon timer
SQL*Net message from client
enq: MN - contention
enq: CF - contention
KSV master wait
instance state change
LogMiner reader: redo (idle)
enq: WL - contention
CSS operation: query
Streams AQ: qmn coordinator waiting for slave to start
kfk: async disk IO
local write wait
cursor: mutex S
db file parallel write
enq: TX - contention
enq: HW - contention
library cache: mutex X
Streams AQ: emn coordinator waiting for slave to start
row cache lock
cursor: pin S wait on X
Streams AQ: delete acknowledged messages
enq: CI - contention
ADR block file read
undo segment extension
shared server idle wait
process terminate
CSS Xgrp shared operation
PX Deq: Txn Recovery Start
Streams AQ: qmn slave idle wait
latch: enqueue hash chains
recovery area: computing backed up files
SQL*Net more data to dblink
SQL*Net break/reset to client
SQL*Net vector data from dblink
latch: messages
PX Deq: Signal ACK EXT
SGA: MMAN sleep for component shrink
BFILE open
PX Deq Credit: free buffer
ASM background timer
PX Deq: Table Q qref
CSS operation: action
SQL*Net message to client
enq: PS - contention
Log archive I/O
direct path sync
LogMiner builder: memory
buffer busy waits
JOX Jit Process Sleep
JS coord start wait
latch: undo global data
single-task message
PX Deq Credit: need buffer
BFILE internal seek
PX Deq: Slave Session Stats
enq: SQ - contention
Data file init write
ARCH wait for archivelog lock
control file single write
ASM: MARK subscribe to msg channel
Streams AQ: enqueue blocked on low memory
asynch descriptor resize
wait list latch free
latch: redo writing
enq: CR - block range reuse ckpt
Streams capture: filter callback waiting for ruleset
rdbms ipc reply
PX Deq: Execute Reply
PX Deq Credit: send blkd
db file sequential read
ASM background starting
sort segment request
process diagnostic dump
latch: shared pool
PX Deq: Signal ACK RSG
process shutdown
latch: active service list
flashback log file read
latch: cache buffers chains
library cache pin
utl_file I/O
LogMiner client: transaction
log file switch (checkpoint incomplete)
enq: DX - contention
latch: session allocation
enq: HV - contention
latch: cache buffer handles
Space Manager: slave idle wait
library cache load lock
enq: JI - contention
LogMiner reader: buffer
Streams: waiting for messages
wait for a undo record
read by other session
enq: PV - syncstart
wait for stopper event to be increased
cursor: pin X
RMAN backup & recovery I/O
DIAG idle wait
control file sequential read
OJVM: Generic
CSS group registration
CRS call completion
log buffer space
PX Idle Wait
latch: cache buffers lru chain
Streams: flow control
PX Deq: Metadata Update
latch free
flashback log file write
SGA: allocation forcing component growth
SQL*Net more data from client
pmon timer
recovery area: computing dropped files
SQL*Net message to dblink
TCP Socket (KGAS)
LogMiner: activate
Streams AQ: waiting for time management or cleanup tasks
enq: PR - contention
inactive session
log file switch completion
switch logfile command
direct path read
Streams AQ: waiting for messages in the queue
SQL*Net vector data to client
ASM file metadata operation
log file parallel write
recovery area: computing obsolete files
PX Deq: Table Q Get Keys
control file parallel write
dispatcher timer
ADR block file write
SQL*Net message from dblink
LogMiner preparer: memory
PX Deq: Test for msg
enq: KO - fast object checkpoint
PX Deq: Join ACK
write complete waits
PX Deq: Parse Reply
CSS operation: data query
LGWR wait for redo copy
*/
