# 2026-01-16T17:49:37.103569300
import vitis

client = vitis.create_client()
client.set_workspace(path="HASO")

platform = client.get_component(name="platform")
status = platform.build()

comp = client.get_component(name="hello_world")
comp.build()

vitis.dispose()

