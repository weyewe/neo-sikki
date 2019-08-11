Ext.define('AM.store.CollectionGroups', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.CollectionGroup'],
  	model: 'AM.model.CollectionGroup',
  	// autoLoad: {start: 0, limit: this.pageSize},
	autoLoad : false, 
  	autoSync: false,
	pageSize : 40, 
	
	
		
		
	sorters : [
		{
			property	: 'id',
			direction	: 'DESC'
		}
	], 

	listeners: {

	} 
});
