Ext.define('AM.view.operation.GroupLoanMembership', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.grouploanmembershipProcess',
	 
		layout : {
			type : 'hbox',
			align : 'stretch'
		},
		header: false, 
		headerAsText : false,
		selectedParentId : null,
		
		items : [
			{
				// xtype : 'container',
				xtype : 'operationgrouploanList',
				// html : "wrapper for group loan list", 
				flex : 1
			},
			{
				xtype : 'container',
				html : "wrapper for the group loan membership list",
				flex : 2 
			}
			// {
			// 	xtype : 'operationgrouploanList' ,
			// 	flex : 1 
			// },
			// {
			// 	xtype : 'grouploanmembershiplist' ,
			// 	flex : 2 
			// } 
		]
});