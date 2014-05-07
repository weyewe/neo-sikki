Ext.define('AM.view.operation.GroupLoanWeeklyCollection', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.grouploanweeklycollectionProcess',
	 
		// layout : {
		// 	type : 'hbox',
		// 	align : 'stretch'
		// },
		
		layout : {
			type : 'vbox',
			align : 'stretch'
		},
		header: false, 
		headerAsText : false,
		selectedParentId : null,
		
		items : [
			{
				xtype : 'container',
				flex: 3 ,
				layout : {
					type : 'hbox',
					align : 'stretch'
				},
				items : [
					{
						xtype : 'operationgrouploanList',
						flex : 1
					},

					{
						xtype : 'grouploanweeklycollectionlist',
						flex : 2
					},
				]
				
			},
			{
				// html : "This is fucking awesome",
				xtype : 'grouploanweeklycollectionvoluntarysavingsentrylist',
				flex : 2
				
			}
		
	 
			
		]
});