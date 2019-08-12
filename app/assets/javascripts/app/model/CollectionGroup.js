Ext.define('AM.model.CollectionGroup', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' }, 
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
