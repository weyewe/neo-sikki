Ext.define('AM.view.operation.grouploanweeklycollection.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.grouploanweeklycollectionlist',

  	store: 'GroupLoanWeeklyCollections', 
 
 
	initComponent: function() {
		this.columns = [
			{ header: 'Week', dataIndex: 'week_number'  }, 
			
			{ header: 'Terkumpul', dataIndex: 'is_collected'  },
			{ header: 'Terkonfirmasi', dataIndex: 'is_confirmed'   },
		 
			
			{
				xtype : 'templatecolumn',
				text : "Kasus khusus",
				flex : 1,
				tpl : 'Tak Tertagih: <b>{group_loan_weekly_uncollectible_count}</b>' + '<br />' + 
							'Meninggal: <b>{group_loan_deceased_clearance_count}</b>' + '<br />' + 
							'Kabur: <b>{group_loan_run_away_receivable_count}</b>' + '<br />' + 
							'Premature Clearance: <b>{group_loan_premature_clearance_payment_count}</b>' 
			},
			
			
		];

		this.collectObjectButton = new Ext.Button({
			text: 'Collect',
			action: 'collectObject',
			disabled: true
		});

		this.confirmObjectButton = new Ext.Button({
			text: 'Confirm',
			action: 'confirmObject',
			disabled: true
		});
 


		this.tbar = [ this.collectObjectButton, this.confirmObjectButton  ];
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
		this.collectObjectButton.enable();
		this.confirmObjectButton.enable();
	},

	disableRecordButtons: function() {
		this.collectObjectButton.disable();
		this.confirmObjectButton.disable();
	}
});
