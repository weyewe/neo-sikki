Ext.define('AM.model.GroupLoan', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'number_of_meetings', type: 'int' },
			{ name: 'number_of_collections', type: 'int' } ,
			{ name: 'total_members_count', type: 'int' } ,  // on start group loan
			{ name: 'name', type: 'string' }   ,
			{ name: 'is_started', type: 'boolean' }   ,
			{ name: 'is_loan_disbursed', type: 'boolean' }   ,
			{ name: 'is_closed', type: 'boolean' }   ,
			{ name: 'is_compulsory_savings_withdrawn', type: 'boolean' }  ,
			
			{ name: 'started_at', type: 'string' }  ,
			{ name: 'disbursed_at', type: 'string' }  ,
			{ name: 'closed_at', type: 'string' }  ,
			{ name: 'compulsory_savings_withdrawn_at', type: 'string' },
			
			//  analysis
			
			
			{ name: 'start_fund', type: 'string' },
			
			{ name: 'disbursed_group_loan_memberships_count', type: 'int' },
			{ name: 'disbursed_fund', type: 'string' },
			{ name: 'non_disbursed_fund', type: 'string' },
			
			{ name: 'active_group_loan_memberships_count', type: 'int' },
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
