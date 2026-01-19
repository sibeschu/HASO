# 2026-01-16T19:58:19.281884100
import vitis

client = vitis.create_client()
client.set_workspace(path="HASO")

platform = client.get_component(name="platform")
status = platform.build()

comp = client.get_component(name="hello_world")
comp.build()

client.delete_component(name="app_component")

client.delete_component(name="componentName")

client.delete_component(name="platform")

client.delete_component(name="platform")

client.delete_component(name="peripheral_tests")

client.delete_component(name="componentName")

client.delete_component(name="hello_world")

client.delete_component(name="componentName")

advanced_options = client.create_advanced_options_dict(dt_overlay="0")

platform = client.create_platform_component(name = "Morse_Platform",hw_design = "$COMPONENT_LOCATION/../design_1_wrapper.xsa",os = "standalone",cpu = "Microblaze_MCS_microblaze_I",domain_name = "standalone_Microblaze_MCS_microblaze_I",generate_dtb = False,advanced_options = advanced_options,compiler = "gcc")

comp = client.create_app_component(name="Morse_App",platform = "$COMPONENT_LOCATION/../Morse_Platform/export/Morse_Platform/Morse_Platform.xpfm",domain = "standalone_Microblaze_MCS_microblaze_I")

comp = client.create_app_component(name="hello_world",platform = "$COMPONENT_LOCATION/../Morse_Platform/export/Morse_Platform/Morse_Platform.xpfm",domain = "standalone_Microblaze_MCS_microblaze_I",template = "hello_world")

platform = client.get_component(name="Morse_Platform")
status = platform.build()

comp = client.get_component(name="Morse_App")
comp.build()

status = platform.build()

comp.build()

comp = client.create_app_component(name="hello_worl",platform = "$COMPONENT_LOCATION/../Morse_Platform/export/Morse_Platform/Morse_Platform.xpfm",domain = "standalone_Microblaze_MCS_microblaze_I",template = "hello_world")

status = platform.build()

comp = client.get_component(name="hello_world")
comp.build()

status = platform.build()

client.delete_component(name="hello_world")

comp = client.get_component(name="hello_worl")
comp.build()

status = platform.build()

comp = client.get_component(name="Morse_App")
comp.build()

vitis.dispose()

