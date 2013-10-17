Ext.define('AM.view.operation.SavingsEntry', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.savingsentryProcess',
	 
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
				xtype : 'operationmemberList',
				flex : 1
			},
			{
				xtype : 'savingsentrylist',
				flex : 2
			}, 
			 
		]
});