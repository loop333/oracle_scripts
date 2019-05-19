select * from sys.wrm$_snapshot
select lower('select * from '||owner||'.'||table_name) from dba_tables where owner = 'SYS' and table_name like 'WRH%' order by 1
select text from dba_views where view_name = 'DBA_HIST_WAITSTAT'
select * from dba_tab_columns where owner = 'SYS' and column_name = 'CLASS'
------------------------------------------------------------------------------------
select * from sys.wrh$_active_session_history -- !!! session stat
select * from sys.wrh$_active_session_history_bl -- 0
select * from sys.wrh$_bg_event_summary -- !!! wrh$_event_name
select * from sys.wrh$_buffered_queues
select * from sys.wrh$_buffered_subscribers
select * from sys.wrh$_buffer_pool_statistics
select * from sys.wrh$_cluster_intercon
select * from sys.wrh$_comp_iostat -- 0
select * from sys.wrh$_cr_block_server
select * from sys.wrh$_current_block_server
select * from sys.wrh$_datafile -- datafile block size
select * from sys.wrh$_db_cache_advice
select * from sys.wrh$_db_cache_advice_bl
select * from sys.wrh$_dispatcher
select * from sys.wrh$_dlm_misc
select * from sys.wrh$_dlm_misc_bl
select * from sys.wrh$_dyn_remaster_stats
select * from sys.wrh$_enqueue_stat -- !!! enqueue stat 
select * from sys.wrh$_event_histogram -- !!! wrh$_event_name
select * from sys.wrh$_event_histogram_bl -- 0
select * from sys.wrh$_event_name -- !!!
select * from sys.wrh$_filemetric_history -- 0
select * from sys.wrh$_filestatxs -- !!!
select * from sys.wrh$_filestatxs_bl -- 0
select * from sys.wrh$_ic_client_stats -- 0
select * from sys.wrh$_ic_device_stats
select * from sys.wrh$_instance_recovery
select * from sys.wrh$_inst_cache_transfer
select * from sys.wrh$_inst_cache_transfer_bl
select * from sys.wrh$_interconnect_pings
select * from sys.wrh$_interconnect_pings_bl
select * from sys.wrh$_iostat_detail -- !!! with filetype & function
select * from sys.wrh$_iostat_filetype -- !!! with filetype
select * from sys.wrh$_iostat_filetype_name
select * from sys.wrh$_iostat_function -- !!! with function
select * from sys.wrh$_iostat_function_name
select * from sys.wrh$_java_pool_advice
select * from sys.wrh$_latch
select * from sys.wrh$_latch_bl
select * from sys.wrh$_latch_children
select * from sys.wrh$_latch_children_bl
select * from sys.wrh$_latch_misses_summary
select * from sys.wrh$_latch_misses_summary_bl
select * from sys.wrh$_latch_name
select * from sys.wrh$_latch_parent
select * from sys.wrh$_latch_parent_bl
select * from sys.wrh$_librarycache
select * from sys.wrh$_log
select * from sys.wrh$_mem_dynamic_comp
select * from sys.wrh$_memory_resize_ops
select * from sys.wrh$_memory_target_advice
select * from sys.wrh$_metric_name
select * from sys.wrh$_mttr_target_advice
select * from sys.wrh$_mutex_sleep
select * from sys.wrh$_mvparameter
select * from sys.wrh$_mvparameter_bl
select * from sys.wrh$_optimizer_env
select * from sys.wrh$_osstat
select * from sys.wrh$_osstat_bl
select * from sys.wrh$_osstat_name
select * from sys.wrh$_parameter
select * from sys.wrh$_parameter_bl
select * from sys.wrh$_parameter_name
select * from sys.wrh$_persistent_qmn_cache
select * from sys.wrh$_persistent_queues
select * from sys.wrh$_persistent_subscribers
select * from sys.wrh$_pgastat
select * from sys.wrh$_pga_target_advice
select * from sys.wrh$_plan_operation_name
select * from sys.wrh$_plan_option_name
select * from sys.wrh$_process_memory_summary
select * from sys.wrh$_resource_limit
select * from sys.wrh$_rowcache_summary
select * from sys.wrh$_rowcache_summary_bl
select * from sys.wrh$_rsrc_consumer_group
select * from sys.wrh$_rsrc_plan
select * from sys.wrh$_rule_set
select * from sys.wrh$_seg_stat
select * from sys.wrh$_seg_stat_bl
select * from sys.wrh$_seg_stat_obj
select * from sys.wrh$_service_name
select * from sys.wrh$_service_stat
select * from sys.wrh$_service_stat_bl
select * from sys.wrh$_service_wait_class
select * from sys.wrh$_service_wait_class_bl
select * from sys.wrh$_sessmetric_history -- 0
select * from sys.wrh$_sess_time_stats
select * from sys.wrh$_sga
select * from sys.wrh$_sgastat
select * from sys.wrh$_sgastat_bl
select * from sys.wrh$_sga_target_advice
select * from sys.wrh$_shared_pool_advice
select * from sys.wrh$_shared_server_summary
select * from sys.wrh$_sql_bind_metadata
select * from sys.wrh$_sqlcommand_name
select * from sys.wrh$_sql_plan
select * from sys.wrh$_sqlstat
select * from sys.wrh$_sqlstat_bl
select * from sys.wrh$_sql_summary
select * from sys.wrh$_sqltext
select * from sys.wrh$_sql_workarea_histogram
select * from sys.wrh$_stat_name
select * from sys.wrh$_streams_apply_sum
select * from sys.wrh$_streams_capture
select * from sys.wrh$_streams_pool_advice
select * from sys.wrh$_sysmetric_history -- !!!
select * from sys.wrh$_sysmetric_summary
select * from sys.wrh$_sysstat
select * from sys.wrh$_sysstat_bl -- 0
select * from sys.wrh$_system_event
select * from sys.wrh$_system_event_bl
select * from sys.wrh$_sys_time_model
select * from sys.wrh$_sys_time_model_bl
select * from sys.wrh$_tablespace
select * from sys.wrh$_tablespace_space_usage
select * from sys.wrh$_tablespace_stat
select * from sys.wrh$_tablespace_stat_bl
select * from sys.wrh$_tempfile
select * from sys.wrh$_tempstatxs
select * from sys.wrh$_thread
select * from sys.wrh$_toplevelcall_name
select * from sys.wrh$_undostat
select * from sys.wrh$_waitclassmetric_history -- 0
select * from sys.wrh$_waitstat
select * from sys.wrh$_waitstat_bl
