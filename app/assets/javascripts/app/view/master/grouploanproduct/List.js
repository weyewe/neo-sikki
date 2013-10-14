Ext.define('AM.view.master.grouploanproduct.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.grouploanproductlist',

  	store: 'GroupLoanProducts', 
 

	initComponent: function() {
		this.columns = [
			{ header: 'Nama', dataIndex: 'name'},
			{ header: 'Durasi',  dataIndex: 'total_weeks' },
			{	header: 'Pokok Mingguan', dataIndex: 'principal', flex: 1 } ,
			{	header: 'Bunga Mingguan', dataIndex: 'interest', flex: 1 } ,
			{	header: 'Tabungan Wajib Mingguan', dataIndex: 'compulsory_savings', flex: 1 } ,
			{	header: 'Biaya Admin', dataIndex: 'admin_fee', flex: 1 } ,
		];

		this.addObjectButton = new Ext.Button({
			text: 'Add GroupLoanProduct',
			action: 'addObject'
		});

		this.editObjectButton = new Ext.Button({
			text: 'Edit GroupLoanProduct',
			action: 'editObject',
			disabled: true
		});

		this.deleteObjectButton = new Ext.Button({
			text: 'Delete GroupLoanProduct',
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