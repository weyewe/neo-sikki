Ext.define('AM.view.operation.transactiondatadetail.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.transactiondatadetaillist',

  	store: 'TransactionDataDetails', 
 
		
	initComponent: function() {
		this.columns = [
		 { header: 'ID',  dataIndex: 'id', flex: 1},
			{
				xtype : 'templatecolumn',
				text : "Akun",
				flex : 2,
				tpl : '{account_name}' 
			},
			
			{
				xtype : 'templatecolumn',
				text : "Case",
				flex : 2,
				tpl : '<b>{entry_case_text}</b>'  
			},
			{
				xtype : 'templatecolumn',
				text : "Jumlah",
				flex : 2,
				tpl : '{amount}'  
			}, 
			
			
			 
		];
		

		this.addObjectButton = new Ext.Button({
			text: 'Add',
			action: 'addObject',
			disabled : true 
		});
		
	 

		this.editObjectButton = new Ext.Button({
			text: 'Edit',
			action: 'editObject',
			disabled: true
		});
		
		this.deleteObjectButton = new Ext.Button({
			text: 'Delete',
			action: 'deleteObject',
			disabled: true
		});


		console.log("Transaction data detail. before bbar");
		console.log("The store: " + this.store);
		console.log(this.store);
		console.log(this.getStore());

		// this.tbar = [this.addObjectButton,  this.editObjectButton, this.deleteObjectButton ]; 
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
	
	enableAddButton: function(){
		// this.addObjectButton.enable();
	},
	
	disableAddButton: function(){
		// this.addObjectButton.disable();
	},

	enableRecordButtons: function() {
		// this.editObjectButton.enable();
		// 	this.deleteObjectButton.enable();
	},

	disableRecordButtons: function() {
		// this.editObjectButton.disable();
		// 	this.deleteObjectButton.disable();
	},
	
	setObjectTitle : function(record){
		// this.setTitle("TransactionData: " + record.get("code"));
	}
});
