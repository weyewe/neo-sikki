Ext.define('AM.view.operation.grouploandetail.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.grouploandetaillist',

//   	store: 'GroupLoanDetails', 
 
 
	initComponent: function() {
		this.columns = [

			{
				xtype : 'templatecolumn',
				text : "Info",
				flex : 1,
				tpl :	'This is the content'
			},
			 
		];


		this.callParent(arguments);
	},
 
	loadMask	: true,
	
	getSelectedObject: function() {
		return this.getSelectionModel().getSelection()[0];
	},
 
});
