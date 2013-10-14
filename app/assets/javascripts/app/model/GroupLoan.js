Ext.define('AM.model.GroupLoan', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'number_of_meetings', type: 'int' },
			{ name: 'number_of_collections', type: 'int' } ,
			{ name: 'name', type: 'string' }   ,
			{ name: 'is_started', type: 'boolean' }   ,
			{ name: 'is_loan_disbursed', type: 'boolean' }   ,
			{ name: 'is_closed', type: 'boolean' }   ,
			{ name: 'is_compulsory_savings_withdrawn', type: 'boolean' }   
  	],

	 


   
  	idProperty: 'id' ,

		proxy: {
			url: 'api/group_loans',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'group_loans',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { group_loan : record.data };
				}
			}
		}
	
  
});
