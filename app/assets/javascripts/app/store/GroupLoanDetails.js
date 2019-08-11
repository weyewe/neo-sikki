Ext.define('AM.store.GroupLoanDetails', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.GroupLoanDetail'],
  	model: 'AM.model.GroupLoanDetail',
  	// autoLoad: {start: 0, limit: this.pageSize},
		autoLoad : false, 
  	autoSync: false,
	pageSize : 20, 
	
	
		
		
	sorters : [
		{
			property	: 'entry_case',
			direction	: 'ASC'
		}
	], 

	listeners: {

	} 
});
