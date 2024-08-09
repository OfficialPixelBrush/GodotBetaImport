import zlib
import os
import gzip

f = open("level.dat", "rb")
old_file_position = f.tell()
f.seek(0, os.SEEK_END)
size = f.tell()
f.seek(old_file_position, os.SEEK_SET)
data = gzip.decompress(f.read(size))
open('out.nbt', 'wb').write(data)