Ext.define('AM.model.Member', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'name', type: 'string' },
			{ name: 'address', type: 'string' } ,
			{ name: 'id_number', type: 'string' }   
  	],

	 


   
  	idProperty: 'id' ,

		proxy: {
			url: 'api/members',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'members',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { member : record.data };
				}
			}
		}
	
  
});