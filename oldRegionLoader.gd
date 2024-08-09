extends Node3D

var grid;
var mapSize: Vector3i = Vector3i(16,128,16);

# Called when the node enters the scene tree for the first time.
func _ready():
	#seed(12345)
	grid =  $GridMap;
	'''
	for island in rng.randi_range(10,20):
		var x = rng.randi_range(0,mapSize.x);
		var y = rng.randi_range(0,mapSize.y);
		var islandPos = Vector3(x,0,y);
		islandPositions.append(islandPos);
	'''
	for cx in 8:
		for cz in 8:
			var cxS = str(cx*16)
			var czS = str(cz*16)
			var filename = "res://extracted/chunk_" + cxS + "_" + czS + ".bin"
			var file = FileAccess.open(filename,FileAccess.READ)
			if file != null:
				print(filename)
				for x in mapSize.x:
					for z in mapSize.z:
						for y in mapSize.y:
							var blockId = file.get_8()
							if blockId > 0:
								if blockId > 31:
									grid.set_cell_item(Vector3i(x+cx*16,y,z+cz*16), 0);
								else:
									grid.set_cell_item(Vector3i(x+cx*16,y,z+cz*16), blockId);
			else:
				continue
	pass # Replace with function body.
