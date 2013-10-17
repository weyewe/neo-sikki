Ext.define('AM.view.operation.savingsentry.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.savingsentrylist',
  	store: 'SavingsEntries', 
 
 
	initComponent: function() {
		this.columns = [
		
			{ header: 'ID', dataIndex: 'id' , flex : 1 },
			{
				xtype : 'templatecolumn',
				text : "Jumlah",
				flex : 2,
				tpl : '<b>{amount}</b>' + '<br />'  + '<br />'  + 
							'Kondisi: <b>{direction_text}</b>' 
			},
			{
				xtype : 'templatecolumn',
				text : "Status",
				flex : 2,
				tpl : 'Konfirmasi: <b>{is_confirmed}</b>' 
			},
			 
		];

		this.addObjectButton = new Ext.Button({
			text: 'Add',
			action: 'addObject',
			disabled: true
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
		
		this.searchField = new Ext.form.field.Text({
			name: 'searchField',
			hideLabel: true,
			width: 200,
			emptyText : "Search",
			checkChangeBuffer: 300
		});



		this.tbar = [this.addObjectButton, this.editObjectButton, this.deleteObjectButton  ];
		this.bbar = Ext.create("Ext.PagingToolbar", {
			store	: this.store, 
			displayInfo: true,
			displayMsg: 'Displaying topics {0} - {1} of {2}',
			emptyMsg: "No topics to display" 
		});

		this.callParent(arguments);
	},
  
	loadMask	: true,
	
	getSelectedObject: function() {
		return this.getSelectionModel().getSelection()[0];
	},
	
	enableAddButton: function(){
		this.addObjectButton.enable();
	},
	
	disableAddButton : function(){
		this.addObjectButton.disable();
	},

	enableRecordButtons: function() {
		this.editObjectButton.enable();
		this.deleteObjectButton.enable();
	},

	disableRecordButtons: function() {
		this.editObjectButton.disable();
		this.deleteObjectButton.disable();
	}
});
