Ext.define('AM.view.operation.grouploandetail.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.grouploandetaillist',


// cuman issue di sini aja nih.. kalo solved, lumayan juga 
  	// store: 'GroupLoanDetails', 
 
 
	initComponent: function() {
		this.columns = [

			{
				xtype : 'templatecolumn',
				text : "Info",
				flex : 1,
				tpl :	'This is the content'
			},
			 
		];
		
	

		// this.addObjectButton = new Ext.Button({
		// 	text: 'Add',
		// 	action: 'addObject',
		// 	disabled : true 
		// });
		
	 

		// this.editObjectButton = new Ext.Button({
		// 	text: 'Edit',
		// 	action: 'editObject',
		// 	disabled: true
		// });
		
		// this.deleteObjectButton = new Ext.Button({
		// 	text: 'Delete',
		// 	action: 'deleteObject',
		// 	disabled: true
		// });

		console.log("This is me!!!");
		console.log("The store: " + this.store);

		this.tbar = [this.addObjectButton,  this.editObjectButton, this.deleteObjectButton ]; 
		
		
		console.log("Gonna set bbar");
		this.bbar = Ext.create("Ext.PagingToolbar", {
			store	: this.store, 
			displayInfo: true,
			displayMsg: 'Details {0} - {1} of {2}',
			emptyMsg: "No details" 
		});
		
		console.log("Gonna call parents");
		
		
		this.callParent(arguments);
		console.log("finished call parents");

	},
 
	loadMask	: true,
	
	getSelectedObject: function() {
		return this.getSelectionModel().getSelection()[0];
	},
 
});
