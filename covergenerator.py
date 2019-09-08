#!/usr/bin/env python
import binascii
import os
import sys
from PIL import Image
from resizeimage import resizeimage

# FUNCTIONS


def romCRC32(romfile):
    buf = open(romfile, 'rb').read()
    buf = (binascii.crc32(buf) & 0xFFFFFFFF)
    return "%08X" % buf


def rename(old_file, new_file):
    if os.path.isfile(old_file):
        os.rename(old_file, new_file)


def remove(filetodelete):
    if os.path.isfile(filetodelete):
        os.remove(filetodelete)


def valid_arg(arg, multilist):
    isValid = any(arg in sublist for sublist in multilist)
    return isValid


def help():
    print("\nUsage: \n    python ", os.path.basename(
        __file__), "files | [options]")
    print("\nFiles: \n    Rom files of type: \".nes\", \".snes\", \".gb\", \".gbc\", \".sms\", \".gen\", \".gg\"")
    print("\nOptions: \n    -?, -h, -help			This information screen")
    print("    .md                                Convert Mega Drive roms \".md\" to nds compatible roms \".gen\"")
    print("    -png                                Optimize png files")
    print("\nExamples: \n    python ", os.path.basename(
        __file__), ".nes        Rename matching title \"png\" files to the rom CRC")
    print("    python ", os.path.basename(
        __file__), "-?         Display help info")
    print("    python ", os.path.basename(
        __file__), "-png       Compress \"png\" files")
    # SCRIPT

if len(sys.argv) == 1:
    help()
    sys.exit()

for rom in sys.argv:
    helpArgs = ['help', '-h', '-?']
    romArgs = ['.snes', '.gbc', '.nes', '.gb', '.sms', '.gen', '.gg', '.md']
    pngArgs = ['png', 'boxart']
renameArgs = ['rename', '-r']
arg_list = [helpArgs, romArgs, pngArgs, renameArgs]

if not valid_arg(rom, arg_list):
    help()
    sys.exit()

if rom in helpArgs:
    help()

if rom in romArgs:
    for file in os.listdir("."):
        if file.endswith(rom):
            rom_title, rom_extension = os.path.splitext(file)

            if (rom_extension == '.md'):
                rom_extension = '.gen'
                rename(file, rom_title + rom_extension)

            crc32 = romCRC32(rom_title + rom_extension)
            rename(rom_title + '.png', crc32 + '.png')
            remove(rom_title + rom_extension)

if rom in renameArgs:
    for filename in os.listdir('.'):
        if filename.endswith('.png'):
    	    if filename.find("_") > 0:
    	    	newfilename = filename.replace("_", "&")
    	    	os.rename(filename, newfilename)

if rom in pngArgs:
		for coverart in os.listdir('.'):
			if coverart.endswith('.png'):
				img = Image.open(coverart)
				w,h = img.size
				if not w == 128 and not h == 115:
					imResize = img.resize((128, 115), Image.ANTIALIAS)
					imResize.save(coverart, format="PNG", compress_level=5, optimize=True)
