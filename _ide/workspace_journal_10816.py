# 2026-01-16T17:54:40.492702400
import vitis

client = vitis.create_client()
client.set_workspace(path="HASO")

platform = client.get_component(name="platform")
status = platform.build()

comp = client.get_component(name="hello_world")
comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.update_hw(hw_design = "$COMPONENT_LOCATION/export/platform/hw/design_1_wrapper.xsa")

status = platform.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

comp = client.create_app_component(name="peripheral_tests",platform = "$COMPONENT_LOCATION/../platform/export/platform/platform.xpfm",domain = "standalone_Microblaze_MCS_microblaze_I",template = "peripheral_tests")

status = platform.build()

comp = client.get_component(name="peripheral_tests")
comp.build()

vitis.dispose()

vitis.dispose()

