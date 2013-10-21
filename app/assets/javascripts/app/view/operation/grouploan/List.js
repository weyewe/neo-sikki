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
			// { header: 'Nama', dataIndex: 'name' , flex : 1 },
			{
				xtype : 'templatecolumn',
				text : "Info",
				flex : 1,
				tpl : '<b>{name}</b>' + '<br />' + '<br />' + 
							'Jumlah Meeting: <br /><b>{number_of_meetings}</b>'  + '<br />' + '<br />' + 
							'Jumlah Pengumpulan: <br /><b>{number_of_collections}</b>'  + '<br />' + '<br />' + 
							'Anggota Aktif: <br /><b>{active_group_loan_memberships_count}</b>'
			},
			{
				xtype : 'templatecolumn',
				text : "Start",
				flex : 1,
				tpl : '<b>{is_started}</b>' + '<br />' + '<br />' + 
							'Tanggal Mulai: <br /><b>{started_at}</b>'  + '<br />' + '<br />' + 
							'Anggota Terdaftar: <br /><b>{total_members_count}</b>'  
			},
			
			{
				xtype : 'templatecolumn',
				text : "Disbursement",
				flex : 1,
				tpl : '<b>{is_loan_disbursed}</b>' + '<br />' + '<br />' + 
							'Tanggal Mulai: <br /><b>{disbursed_at}</b>'  + '<br />' + '<br />' + 
							'Anggota Penerima: <br /><b>{disbursed_group_loan_memberships_count}</b>'   
			},
			
			{
				xtype : 'templatecolumn',
				text : "Monitor",
				flex : 1,
				tpl : 'Close: <b>{is_closed}</b>' + '<br />' + '<br />' + 
							'Tanggal Selesai: <br /><b>{closed_at}</b>'     
			},
			
			
			{	header: 'Tabungan Dikembalikan?', dataIndex: 'is_compulsory_savings_withdrawn', flex : 1   } ,
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
		
		this.startObjectButton = new Ext.Button({
			text: 'Start',
			action: 'startObject',
			disabled: true
		});
		
		this.disburseObjectButton = new Ext.Button({
			text: 'Disburse',
			action: 'disburseObject',
			disabled: true
		});
		this.closeObjectButton = new Ext.Button({
			text: 'Close',
			action: 'closeObject',
			disabled: true
		});
		this.withdrawObjectButton = new Ext.Button({
			text: 'Withdraw',
			action: 'withdrawObject',
			disabled: true
		});
		
		this.searchField = new Ext.form.field.Text({
			name: 'searchField',
			hideLabel: true,
			width: 200,
			emptyText : "Search",
			checkChangeBuffer: 300
		});



		this.tbar = [this.addObjectButton, this.editObjectButton, this.deleteObjectButton,
		  			'-',
						this.startObjectButton,
						this.disburseObjectButton,
						this.closeObjectButton,
						this.withdrawObjectButton, 
						'-',
						this.searchField];
						
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
		this.startObjectButton.enable();
		this.disburseObjectButton.enable();
		this.closeObjectButton.enable();
		this.withdrawObjectButton.enable();
	},

	disableRecordButtons: function() {
		this.editObjectButton.disable();
		this.deleteObjectButton.disable();
		this.startObjectButton.disable();
		this.disburseObjectButton.disable();
		this.closeObjectButton.disable();
		this.withdrawObjectButton.disable();
	}
});
