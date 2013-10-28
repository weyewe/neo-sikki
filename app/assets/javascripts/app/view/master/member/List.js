Ext.define('AM.view.master.member.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.memberlist',

  	store: 'Members', 
 

	initComponent: function() {
		this.columns = [
			{ header: 'ID_NUMBER', dataIndex: 'id_number'},
			{ header: 'Nama',  dataIndex: 'name', flex: 1},
			{	header: 'Address', dataIndex: 'address', flex: 1 },
			{	header: 'Kabur', dataIndex: 'is_run_away', flex: 1 } ,
			{	header: 'Meninggal', dataIndex: 'is_deceased', flex: 1 }  
		];

		this.addObjectButton = new Ext.Button({
			text: 'Add',
			action: 'addObject'
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
		
		this.markAsDeceasedObjectButton = new Ext.Button({
			text: 'Deceased',
			action: 'markasdeceasedObject',
			disabled: true
		});
		
		this.markAsRunAwayObjectButton = new Ext.Button({
			text: 'Run Away',
			action: 'markasrunawayObject',
			disabled: true
		});



		this.tbar = [this.addObjectButton, this.editObjectButton, this.deleteObjectButton ,
		 				'-',
						this.searchField,
						'->',
						this.markAsDeceasedObjectButton,
						this.markAsRunAwayObjectButton
						
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
		
		this.markAsDeceasedObjectButton.enable();
		this.markAsRunAwayObjectButton.enable();
	},

	disableRecordButtons: function() {
		this.editObjectButton.disable();
		this.deleteObjectButton.disable();
		this.markAsDeceasedObjectButton.disable();
		this.markAsRunAwayObjectButton.disable();
	}
});
