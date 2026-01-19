# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "")
  file(REMOVE_RECURSE
  "C:\\Repos\\projects\\NexysA7\\MB1\\platform\\microblaze_mcs_0_microblaze_I\\standalone_microblaze_mcs_0_microblaze_I\\bsp\\include\\sleep.h"
  "C:\\Repos\\projects\\NexysA7\\MB1\\platform\\microblaze_mcs_0_microblaze_I\\standalone_microblaze_mcs_0_microblaze_I\\bsp\\include\\xiltimer.h"
  "C:\\Repos\\projects\\NexysA7\\MB1\\platform\\microblaze_mcs_0_microblaze_I\\standalone_microblaze_mcs_0_microblaze_I\\bsp\\include\\xtimer_config.h"
  "C:\\Repos\\projects\\NexysA7\\MB1\\platform\\microblaze_mcs_0_microblaze_I\\standalone_microblaze_mcs_0_microblaze_I\\bsp\\lib\\libxiltimer.a"
  )
endif()
