# GodotMCBetaImport
 A Minecraft Beta 1.7.3 Visualzier written in Godot
 This project has been superseded by [Betrock](https://github.com/OfficialPixelBrush/Betrock)!

## Purpose
This Application is meant to be nothing more than an experiment to see if I can successfully load and display Minecraft Beta 1.7.3 McRegion files manually.

## mcr.py
This tool was my first attempt to understand McRegion files. It takes a Minecraft McRegion file as input, and outputs the first TAG_ByteArray it finds in each Chunk as a chunk\_x\_z.bin file. These can actually be read by the oldRegionLoader GDScript, and was used to create the first versions of this application.
