Ext.define('AM.view.operation.GroupLoanWeeklyCollection', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.grouploanweeklycollectionProcess',
	 
		layout : {
			type : 'hbox',
			align : 'stretch'
		},
		header: false, 
		headerAsText : false,
		selectedParentId : null,
		
		items : [
		// just the list
			{
				xtype : 'operationgrouploanList',
				flex : 1
			},
			
			{
				xtype : 'grouploanweeklycollectionlist',
				flex : 2
			}, 
			
			// maybe another
			// {
			// 	xtype : 'grouploanweeklycollectionlist',
			// 	flex : 2
			// },
			
		]
});