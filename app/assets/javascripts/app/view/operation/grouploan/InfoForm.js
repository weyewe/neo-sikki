Ext.define('AM.view.operation.grouploan.InfoForm', {
  extend: 'Ext.window.Window',
  alias : 'widget.infogrouploanform',

  title : 'Info GroupLoan',
  layout: 'fit',
	width	: 400,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
	
  initComponent: function() {
    this.items = [{
        xtype: 'form',
        	msgTarget	: 'side',
        	border: false,
            bodyPadding: 10,
        	fieldDefaults: {
                labelWidth: 165,
    			anchor: '100%'
            },
            
            
 

  
			
      items: [
                // start
                
                // disbursement 
                
                // closing 
                
                // withdrawal
                
                {
					xtype: 'displayfield',
					fieldLabel: 'Nama Kelompok',
					name: 'name' 
			    },
			    {
					xtype: 'displayfield',
					fieldLabel: 'Meeting',
					name: 'number_of_meetings' 
			    }, 
			    {
					xtype: 'displayfield',
					fieldLabel: 'Collection',
					name: 'number_of_collections' 
			    },  
			    {
					xtype: 'displayfield',
					fieldLabel: 'Jumlah anggota',
					name: 'active_group_loan_memberships_count' 
			    },  
			    
			 //   start 

			    {
					xtype: 'displayfield',
					fieldLabel: 'Jumlah Pengajuan',
					name: 'start_fund' 
			    },   
			    
			 //   disburse
			    {
					xtype: 'displayfield',
					fieldLabel: 'Tanggal Pencairan',
					name: 'disbursed_at' 
			    }, 
			    {
					xtype: 'displayfield',
					fieldLabel: 'Jumlah Dicairkan',
					name: 'disbursed_fund' 
			    },  
			    
			    
			    {
					xtype: 'displayfield',
					fieldLabel: 'Tanggal Setoran Pertama',
					name: 'started_at' 
			    }, 
			    
			    {
					xtype: 'displayfield',
					fieldLabel: 'Jumlah setoran mingguan',
					name: 'weekly_collection_amount' 
			    }, 
			    
			 
				
				// closing 
			    {
					xtype: 'displayfield',
					fieldLabel: 'Jumlah BTAB',
					name: 'total_compulsory_savings_pre_closure' 
			    }, 
				{
					xtype: 'displayfield',
					fieldLabel: 'Tgl Selesai',
					name: 'closed_at' 
			    }, 

		 
			    
			 //   savings return 
			    
			    
			    
				{
					xtype: 'displayfield',
					fieldLabel: 'Tgl bagi tabungan',
					name: 'compulsory_savings_withdrawn_at' 
				}, 
				
				 
		 
			]
    }];

    this.buttons = [
    // {
    //   text: 'Confirm',
    //   action: 'confirmClose'
    // }, 
    {
      text: 'Close',
      scope: this,
      handler: this.close
    }];

    this.callParent(arguments);
  },

	setParentData: function( record ) {
		
		
		console.log("Inside set Parent Data");
		console.log( record );  
		
		
// 		Base 
		this.down('form').getForm().findField('name').setValue(record.get('name')); 
		this.down('form').getForm().findField('number_of_meetings').setValue(record.get('number_of_meetings')); 
		this.down('form').getForm().findField('number_of_collections').setValue(record.get('number_of_collections')); 
		this.down('form').getForm().findField('active_group_loan_memberships_count').setValue(record.get('active_group_loan_memberships_count')); 
		
// start 
			 
					
		this.down('form').getForm().findField('started_at').setValue(record.get('started_at')); 
		this.down('form').getForm().findField('start_fund').setValue(record.get('start_fund')); 			
		
// disburse 
 
		
		this.down('form').getForm().findField('disbursed_at').setValue(record.get('disbursed_at'));  
		this.down('form').getForm().findField('weekly_collection_amount').setValue(record.get('weekly_collection_amount')); 
		this.down('form').getForm().findField('disbursed_fund').setValue(record.get('disbursed_fund')); 
		
		// this.down('form').getForm().findField('disbursed_group_loan_memberships_count').setValue(record.get('disbursed_group_loan_memberships_count')); 
		
// closing 	
		
		this.down('form').getForm().findField('closed_at').setValue(record.get('closed_at')); 
		this.down('form').getForm().findField('total_compulsory_savings_pre_closure').setValue(record.get('total_compulsory_savings_pre_closure')); 
		// this.down('form').getForm().findField('premature_clearance_deposit').setValue(record.get('premature_clearance_deposit'));
		// this.down('form').getForm().findField('bad_debt_allowance').setValue(record.get('bad_debt_allowance'));
		// this.down('form').getForm().findField('bad_debt_expense').setValue(record.get('bad_debt_expense'));
				  
// savings withdrawal 


		this.down('form').getForm().findField('compulsory_savings_withdrawn_at').setValue(record.get('compulsory_savings_withdrawn_at'));


 
		
		
		
	}
});
