tool # Needed so it runs in the editor.
extends EditorScenePostImport

const LOWPOLY_MATERIAL = preload("res://assets/materials/lowpoly_material.tres")

func post_import(scene):
	print("reimport!")
	var combined_aabb
	for object in scene.get_node("RootNode").get_children(): # .get_node("RootNode")
		var aabb = object.mesh.get_aabb()
		if not combined_aabb:
			combined_aabb = aabb
		else:
			combined_aabb = combined_aabb.merge(aabb)

	var centroid = combined_aabb.position + combined_aabb.size / 2
	centroid *= Vector3(1,0,1) # I want to recenter only on xz axis, ignore y.
	
	var mdt = MeshDataTool.new() 
	var centered_model = MeshInstance.new()
	centered_model.name = scene.name # GridMap doesn't work if all meshes have the same name. "CenteredModel"
	centered_model.mesh = Mesh.new()
	for object in scene.get_node("RootNode").get_children(): # .get_node("RootNode")
		var mesh = object.get_mesh()
		mdt.create_from_surface(mesh, 0) #get surface 0 into mesh data tool
		for vtx in range(mdt.get_vertex_count()): # Loop over the vertices
			var vert=mdt.get_vertex(vtx)
			# Move vertices one by one to the center of the sene
			mdt.set_vertex(vtx, vert - centroid) 
		# Replace the surface of the existing object with the updated one
		# object.mesh.surface_remove(0) #Remove the old one
		# mdt.commit_to_surface(object.mesh)
		# object.create_trimesh_collision()
		
		# Save everything into one newly created model
		mdt.commit_to_surface(centered_model.mesh)
		object.queue_free() # remove the old object
		mdt.clear()
	
	scene.add_child(centered_model)
	centered_model.set_owner(scene)
	
	centered_model.create_trimesh_collision()
	centered_model.get_children()[0].name="StaticBody"
	centered_model.get_children()[0].collision_layer=4
	
	for i in centered_model.mesh.get_surface_count():
		centered_model.mesh.surface_set_material(i, LOWPOLY_MATERIAL) 
#		var surface_material = centered_model.mesh.surface_get_material(i)
#		surface_material.params_cull_mode = 0
#		surface_material.roughness = 1
	
	print("returning ", scene)
	return scene
