C Code in Vitis schreiben -> Build -> dann .elf tauschen -> program device

# .elf-Datei austauschen

```bash

set bit "C:/Repos/projects/NexysA7/HASO/MS2.runs/impl\_1/design\_1\_wrapper.bit"

set elf "C:/Repos/projects/NexysA7/HASO/Morse\_App/build/Morse\_App.elf"

set mmi "C:/Repos/projects/NexysA7/HASO/MS2.runs/impl\_1/design\_1\_wrapper.mmi"

set out "C:/Repos/projects/NexysA7/HASO/MS2.runs/impl\_1/design\_1\_wrapper.bit"

exec updatemem -force -meminfo $mmi -data $elf -bit $bit -proc design\_1\_i/Microblaze\_MCS/U0/microblaze\_I -out $out

```



# learnings:
- in der .mmi Datei wird unter anderem der Addressraum für den Speicher auf dem Mikroprozessor angegeben : z.B. MCS\_U0\_dlmb\_cntlr" Begin="0" End="131071"
- interessant bei Fehler :

```bash
ERROR: \[Memdata 28-345] The data file C:/Repos/projects/NexysA7/HASO/Morse\_App/build/Morse\_App.elf is mapped to address range \[00000050:00002493], but there is no memory available in that range. Make sure that the data file base address is set to an address corresponding to the memory address range in the design.
ERROR: \[Updatemem 57-153] Failed to update the BRAM INIT strings for C:/Repos/projects/NexysA7/HASO/Morse\_App/build/Morse\_App.elf and C:/Repos/projects/NexysA7/HASO/MS2.runs/impl\_1/design\_1\_wrapper.mmi.

```



\# nützlich: 

* in der Suchleiste oben -> Open Log File -> öffnet Vivado Log -> besser nachvollziehbar was passiert
