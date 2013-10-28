Ext.define('AM.view.master.member.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.memberlist',

  	store: 'Members', 
 

	initComponent: function() {
		this.columns = [
			{ header: 'ID_NUMBER', dataIndex: 'id_number'},
			{ header: 'Nama',  dataIndex: 'name', flex: 1},
			{	header: 'Address', dataIndex: 'address', flex: 1 } 
		];

		this.addObjectButton = new Ext.Button({
			text: 'Add Member',
			action: 'addObject'
		});

		this.editObjectButton = new Ext.Button({
			text: 'Edit Member',
			action: 'editObject',
			disabled: true
		});

		this.deleteObjectButton = new Ext.Button({
			text: 'Delete Member',
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



		this.tbar = [this.addObjectButton, this.editObjectButton, this.deleteObjectButton ,
		 				'-',
						this.searchField
		];
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

	enableRecordButtons: function() {
		this.editObjectButton.enable();
		this.deleteObjectButton.enable();
	},

	disableRecordButtons: function() {
		this.editObjectButton.disable();
		this.deleteObjectButton.disable();
	}
});
