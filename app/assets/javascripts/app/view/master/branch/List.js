Ext.define('AM.view.master.branch.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.branchlist',

  	store: 'Branches', 
 

	initComponent: function() {
		this.columns = [
			{ header: 'KODE', dataIndex: 'code', flex: 1},
			// { header: 'Nama',  dataIndex: 'name', flex: 1},
			
		 
			
			
			{	header: 'Nama', dataIndex: 'name', flex: 2 }, 
			{	header: 'Deskripsi', dataIndex: 'description', flex: 2}, 
			{	header: 'Alamat', dataIndex: 'address', flex: 2}, 
			
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
		 


		this.tbar = [this.addObjectButton, this.editObjectButton, this.deleteObjectButton ,
		 				'-',
						this.searchField 
						
		];
		
		console.log("The store in branch#list");
		console.log( this.store );
		
		console.log(this.getStore() );
		this.bbar = Ext.create("Ext.PagingToolbar", {
			store	: this.store, 
			displayInfo: true,
			displayMsg: 'Displaying topics {0} - {1} of {2}',
			emptyMsg: "No topics to display" 
		});

		console.log("Gonna get parent");
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
