Ext.define('AM.view.Content', {
    extend: 'Ext.panel.Panel',
    alias : 'widget.content', 
    
    
		border: false,
		activeItem : 1 ,  // by default, setting the WorkProcess to be default page.

		layout: {
			type : 'card',
			align: 'stretch'
		},
		
		items : [
			{
				html : "Personal",
				xtype : 'container'
			},
			{
				html : "Work Awesome Banzai",
				xtype : 'container'
			},
			{
				html : "Master",
				xtype : 'container'
			},
			// {
			// 	xtype : 'personalProcessPanel'
			// },
			// 
			// 
			// {
			// 	xtype : "workProcess",
			// },
			// {
			// 	html : "Master Data",
			// 	xtype : 'masterProcessPanel'
			// },
			// {
			// 	html : "Third",
			// 	xtype : 'container'
			// }
		]
		 
});
