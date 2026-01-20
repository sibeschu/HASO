# 2026-01-19T10:40:13.197993900
import vitis

client = vitis.create_client()
client.set_workspace(path="HASO")

platform = client.get_component(name="Morse_Platform")
status = platform.build()

comp = client.get_component(name="hello_worl")
comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp = client.get_component(name="Morse_App")
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

status = platform.build()

comp.build()

status = platform.build()

comp.build()

vitis.dispose()

