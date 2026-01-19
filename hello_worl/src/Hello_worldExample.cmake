set(IOMODULE_NUM_DRIVER_INSTANCES "Microblaze_MCS_iomodule_0")
set(IOMODULE0_PROP_LIST "0x80000000")
list(APPEND TOTAL_IOMODULE_PROP_LIST IOMODULE0_PROP_LIST)
set(UARTLITE_NUM_DRIVER_INSTANCES "")
set(UARTNS550_NUM_DRIVER_INSTANCES "")
set(UARTPS_NUM_DRIVER_INSTANCES "")
set(UARTPSV_NUM_DRIVER_INSTANCES "")
set(Microblaze_MCS_dlmb_cntlr_memory_0 "0x50;0x1ffb0")
set(DDR Microblaze_MCS_dlmb_cntlr_memory_0)
set(CODE Microblaze_MCS_dlmb_cntlr_memory_0)
set(DATA Microblaze_MCS_dlmb_cntlr_memory_0)
set(TOTAL_MEM_CONTROLLERS "Microblaze_MCS_dlmb_cntlr_memory_0")
set(MEMORY_SECTION "MEMORY
{
	Microblaze_MCS_dlmb_cntlr_memory_0 : ORIGIN = 0x50, LENGTH = 0x1ffb0
}")
set(STACK_SIZE 0x400)
set(HEAP_SIZE 0x800)
