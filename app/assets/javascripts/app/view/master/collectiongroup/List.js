Ext.define('AM.view.master.collectiongroup.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.collectiongrouplist',

  	store: 'CollectionGroups', 
 

	initComponent: function() {
		console.log("Gonna init columns"); 
		
		this.columns = [
			{ header: 'ID',  dataIndex: 'id', flex: 1},
			{ header: 'Branch',  dataIndex: 'branch_name', flex: 1},
			
			{ header: 'Nama',  dataIndex: 'name', flex: 1},
			{ header: 'Deskripsi',  dataIndex: 'description', flex: 1},
			{ header: 'User',  dataIndex: 'user_name', flex: 1},
			{ header: 'Hari',  dataIndex: 'collection_day_name', flex: 1},
			{ header: 'Jam',  dataIndex: 'collection_hour_name', flex: 1},
			
		];

		console.log("add Add button"); 
		
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
		 

		console.log("Assigning to tbar ");
		
		this.tbar = [this.addObjectButton, this.editObjectButton, 
						this.deleteObjectButton ,
		 				'-',
						this.searchField 
		];
		
		// console.log("Assigning to bbar ");
		// console.log("The store: " );
		// console.log( this.store );
		
		// console.log(this.getStore() );
		
		this.bbar = Ext.create("Ext.PagingToolbar", {
			store	: this.store, 
			displayInfo: true,
			displayMsg: 'Displaying topics {0} - {1} of {2}',
			emptyMsg: "No kumpulan to display" 
		});


		console.log("Call parents?? ");
		
		// nabrak disini.. store nya ga generated. butuh controller?
		this.callParent(arguments);
		
		console.log("Done calling parents");
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
