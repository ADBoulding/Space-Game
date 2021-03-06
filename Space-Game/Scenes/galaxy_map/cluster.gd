extends Node2D

var stars = []
var ClusterID : Vector2
var cluster : Galaxy.Cluster
		
func getID(id : Vector2):
	ClusterID = id
		
func generateCluster():
	cluster = Global.clusterContainer[ClusterID]
	stars = cluster.systems.keys()
	var starScene = load("res://Scenes/galaxy_map/star.tscn")
	for star in stars:
		var _s = starScene.instance()
		_s.position = star * 32 
		_s.setID(star, cluster)
		_s.name = str("s_",star)
		add_child(_s, true)
