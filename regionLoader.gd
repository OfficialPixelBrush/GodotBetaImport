extends Node3D

@onready var grid =  $GridMap;
var file;
var pointer;

func tagType(tag):
	if tag==0: # TAG_END
		return "TAG_END"
	elif tag==1: # TAG_Byte
		return "TAG_Byte"
	elif tag==2: # TAG_Short
		return "TAG_Short"
	elif tag==3: # TAG_Int
		return "TAG_Int"
	elif tag==4: # TAG_Long
		return "TAG_Long"
	elif tag==5: # TAG_Float
		return "TAG_Float"
	elif tag==6: # TAG_Double
		return "TAG_Double"
	elif tag==7: # TAG_Byte_Array
		return "TAG_Byte_Array"
	elif tag==8: # TAG_String
		return "TAG_String"
	elif tag==9: # TAG_List
		return "TAG_List"
	elif tag==10: # TAG_Compound
		return "TAG_Compound"
	elif tag==11: # TAG_Int_Array
		return "TAG_Int_Array"
	elif tag==12: # TAG_Long_Array
		return "TAG_Long_Array"
	else:
		return "Unknown"
	pass

func decodeTag(nbt, index, regionX, regionZ):
	var tag = nbt[pointer]
	pointer += 1
	var tagNameLength = nbt[pointer] << 8 | nbt[pointer+1]
	pointer += 2
	var tagName = ""
	if tagNameLength > 0:
		for i in tagNameLength:
			tagName = tagName + String.chr(nbt[pointer])
			pointer += 1
	var data = 0
	if tag==0: # TAG_END
		data = 0
	elif tag==1: # TAG_Byte
		data = nbt[pointer]
		pointer += 1
	elif tag==2: # TAG_Short
		data = nbt[pointer] << 8 | nbt[pointer+1]
		pointer += 2
	elif tag==3: # TAG_Int
		data = nbt[pointer] << 24 | nbt[pointer+1] << 16 | nbt[pointer+2] << 8 | nbt[pointer+3]
		pointer += 4
	elif tag==4: # TAG_Long
		# data = intread(file,8)
		pointer += 8
	elif tag==5: # TAG_Float
		pointer += 4
	elif tag==6: # TAG_Double
		pointer += 8
	elif tag==7: # TAG_Byte_Array
		var size = nbt[pointer] << 24 | nbt[pointer+1] << 16 | nbt[pointer+2] << 8 | nbt[pointer+3]
		pointer += 4
		data = []
		for i in size:
			data.append(nbt[pointer])
			pointer += 1
		regionX*=512
		regionZ*=512
		var chunkX = regionX + (floor(index % 32) * 16) #region_x + (header_index % 32 * 16)
		var chunkZ = regionZ + (floor(index / 32) * 16) #region_z + (math.floor(header_index / 32) * 16)
		for x in 16:
			for z in 16:
				for y in 128:
					var blockIndex = floor(((x * 16 + z) * 128 + y))
					var blockId = data[blockIndex]
					if blockId > 0:
						if blockId > 31:
							grid.set_cell_item(Vector3i(x+chunkX,y,z+chunkZ), 0);
						else:
							grid.set_cell_item(Vector3i(x+chunkX,y,z+chunkZ), blockId);
	elif tag==8: # TAG_String
		var length = nbt[pointer] << 8 | nbt[pointer+1]
		pointer += 2
		for i in range(length):
			data = nbt[pointer]
			pointer += 1
		#data = file.read(length).decode("utf-8")
	elif tag==9: # TAG_List
		data = 0
	elif tag==10: # TAG_Compound
		data = 0
	elif tag==11: # TAG_Int_Array
		data = 0
	elif tag==12: # TAG_Long_Array
		data = 0
	else:
		print("Invalid Tag: ", tag)
	# print(tagType(tag),": \"",tagName,"\"\n\t",data) 

func compressionDecode(index):
	if index == 1:
		return "GZip"
	elif index == 2:
		return "Zlib"
	elif index == 3:
		return "Uncompressed"
	elif index == 4:
		return "LZ4"
	elif index == 127:
		return "Custom"
	else:
		return "Unsupported"

func readChunk(chunkId, offsetSector, regionX, regionZ):
	#var offset = readData >> 8;
	#var sector = (readData & 0xFF)*4096;
	var offset = (offsetSector >> 8)*4096
	var sector = (offsetSector & 0xFF)*4096
	#print("Chunk #",chunkId,": ", offset, ", ", sector,"KiB")
	file.seek(offset)
	var length = file.get_32()
	var compressionScheme = file.get_8()
	var csString = compressionDecode(compressionScheme)
	#print("\t",length," Bytes\n\tCompression ",csString)
	var compressedData: PackedByteArray
	var data: PackedByteArray
	for b in range(length-1):
		compressedData.append(file.get_8())
	if compressionScheme == 1: # Gzip
		data = compressedData.decompress_dynamic(100000, 3)
	elif compressionScheme == 2: # Zlib/Deflate
		data = compressedData.decompress_dynamic(100000, 1)
	pointer = 0
	for i in range(4):
		decodeTag(data, chunkId, regionX, regionZ)
	return 0
	
func loadRegion(regionX,regionZ):
	var filename = "r." + str(regionX) + "." + str(regionZ) + ".mcr"
	file = FileAccess.open("res://world_3/region/" + filename,FileAccess.READ)
	file.set_big_endian(true)
	if file == null:
		print("Region file " + str(regionX) + "." + str(regionZ) + " does not exist!")
	else:
		print("Region file " + str(regionX) + "." + str(regionZ) + " found!")
		var checkFail = 0
		for chunkId in range(1024):
			file.seek(chunkId*4)
			var offsetSector = file.get_32()
			if offsetSector != 0:
				checkFail |= readChunk(chunkId, offsetSector, regionX, regionZ)
		if checkFail:
			print("Error loading Region " + str(regionX) + "." + str(regionZ) + " !")
		else:
			print("Region " + str(regionX) + "." + str(regionZ) + " loaded successfully!")
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	loadRegion(-1,-1)
	loadRegion(-1,0)
	loadRegion(0,-1)
	loadRegion(0,0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
