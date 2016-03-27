
json.connection_path @paths do |path|
 
 	json.node_type 			path[:node_type]
 	json.node_name			path[:node_name]
 	json.jump				path[:jump]
end

  