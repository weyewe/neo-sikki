Ext.define('AM.view.master.collectiongroup.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.collectiongrouplist',

  	store: 'CollectionGroups', 
 

	initComponent: function() {
		this.columns = [
			// { header: 'Member', dataIndex: 'member_name' , flex : 1 },
			{
				xtype : 'templatecolumn',
				text : "Info",
				flex : 1,
				tpl : '<b>{name}</b>'  
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



		this.tbar = [this.addObjectButton, 
						this.editObjectButton,  
						'->',
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
	
	enableAddButton: function(){
		this.addObjectButton.enable();
	},
	disableAddButton : function(){
		this.addObjectButton.disable();
	},

	enableRecordButtons: function() {
		this.editObjectButton.enable();
		// this.deleteObjectButton.enable(); 
		
	},

	disableRecordButtons: function() {
		this.editObjectButton.disable();
		// this.deleteObjectButton.disable();
		// this.deactivateObjectButton.disable();
	}
});
