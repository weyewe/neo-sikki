Ext.define('AM.model.CollectionGroup', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' }, 
    	{ name: 'name', type: 'string' },  
    	{ name: 'description', type: 'string' },  
    	
    	{ name: 'branch_id', type: 'int' },
    	{ name: 'branch_name', type: 'string' }, 
    	
    	{ name: 'user_id', type: 'int' }, 
    	{ name: 'user_name', type: 'string' }, 
    	
    	{ name: 'collection_day', type: 'int' },
    	{ name: 'collection_day_name', type: 'string' }, 
    	
    	{ name: 'collection_hour', type: 'int' },
    	{ name: 'collection_hour_name', type: 'string' }, 
    	
  	],

  	idProperty: 'id' ,

	proxy: {
		url: 'api/collection_groups',
		type: 'rest',
		format: 'json',

		reader: {
			root: 'collection_groups',
			successProperty: 'success',
			totalProperty : 'total'
		},

		writer: {
			getRecordData: function(record) {
				return { collection_group : record.data };
			}
		}
	}
	
  
});
