Ext.define('AM.view.ProtectedContent', {
    extend: 'Ext.panel.Panel',
		alias : 'widget.protectedcontent',
    
    
		layout : {
			type : 'vbox',
			align : 'stretch'
		},
    
    items: [
				{
					xtype : 'container',
					html : "Congratulations.. you have entered the protectedContent.js"
				}
				// {
				// 	xtype : 'navigation',
				// },
				// 
				// {
				// 	xtype : 'content',
				// 	flex :  1
				// }
    ]
});
