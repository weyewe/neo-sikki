Ext.define('AM.view.operation.GroupLoan', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.grouploanProcess',
	 
	 
 		layout : {
			type : 'hbox',
			align : 'stretch'
		},
		
		
		header: false, 
		headerAsText : false,
		selectedParentId : null,
		
		items : [
			{
				xtype : 'grouploanlist' ,
				flex : 1 
			} ,
			{
				xtype : 'grouploandetaillist' ,
				flex : 3
			} 
			
			
		]
});