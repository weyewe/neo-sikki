Ext.define('AM.view.operation.grouploan.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.grouploanlist',

  	store: 'GroupLoans', 
 

		// { name: 'id', type: 'int' },
		//   	{ name: 'number_of_meetings', type: 'int' },
		// { name: 'number_of_collections', type: 'int' } ,
		// { name: 'is_started', type: 'boolean' }   ,
		// { name: 'is_loan_disbursed', type: 'boolean' }   ,
		// { name: 'is_closed', type: 'boolean' }   ,
		// { name: 'is_compulsory_savings_withdrawn', type: 'boolean' }
		// 

	initComponent: function() {
		this.columns = [
			{ header: 'Nama', dataIndex: 'name' , flex : 1 },
			{ header: 'Jumlah Meeting',  dataIndex: 'number_of_meetings', flex : 1  },
			{	header: 'Jumlah Pengumpulan', dataIndex: 'number_of_collections', flex : 1   } ,
			{	header: 'Dimulai?', dataIndex: 'is_started', flex : 1   } ,
			{	header: 'Cair?', dataIndex: 'is_loan_disbursed', flex : 1   } ,
			{	header: 'Selesai?', dataIndex: 'is_closed'   } ,
			{	header: 'Tabungan Dikembalikan?', dataIndex: 'is_compulsory_savings_withdrawn', flex : 1   } ,
		];

		this.addObjectButton = new Ext.Button({
			text: 'Add GroupLoan',
			action: 'addObject'
		});

		this.editObjectButton = new Ext.Button({
			text: 'Edit GroupLoan',
			action: 'editObject',
			disabled: true
		});

		this.deleteObjectButton = new Ext.Button({
			text: 'Delete GroupLoan',
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

	enableRecordButtons: function() {
		this.editObjectButton.enable();
		this.deleteObjectButton.enable();
	},

	disableRecordButtons: function() {
		this.editObjectButton.disable();
		this.deleteObjectButton.disable();
	}
});
