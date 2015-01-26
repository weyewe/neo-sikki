Ext.define('AM.view.operation.Memorial', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.memorialProcess',
	 
		
		
		layout : {
			type : 'hbox',
			align : 'stretch'
		},
		
		
		items : [
			{
				xtype : 'memoriallist' ,
				flex : 1 //,
				// html : 'hahaha'
			},
			{
				xtype :'memorialdetaillist',
				// html : "This is gonna be the price_rule",
				flex : 1
			} 
		],
		
		selectedObject : null, 
		selectedChild : null 
});