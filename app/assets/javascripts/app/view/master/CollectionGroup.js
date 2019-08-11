Ext.define('AM.view.master.CollectionGroup', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.collectiongroupProcess',
	 
		layout : {
			type : 'hbox',
			align : 'stretch'
		},
		header: false, 
		headerAsText : false,
		selectedParentId : null,
		
		items : [
		// list of group loan.. just the list.. no CRUD etc
			{
				xtype : 'masterbranchlist',
				flex : 1
			},
			// {
			// 	html: "Banzaiii",
			// 	flex: 1 
			// },
			{
				html: "hahaha",
				flex: 1 
			}
			
			// udah beres. tinggal figure out cara doi pasang
			// collection group list 
			
			
			// {
			// 	xtype : 'collectiongrouplist',
			// 	flex : 2
			// }, 
		]
});