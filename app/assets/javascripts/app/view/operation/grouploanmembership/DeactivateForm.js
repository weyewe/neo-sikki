Ext.define('AM.view.operation.grouploanmembership.DeactivateationForm', {
  extend: 'Ext.window.Window',
  alias : 'widget.deactivategrouploanmembershipform',

  title : 'Deactivate SavingsEntry',
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

				{
					xtype: 'displayfield',
					fieldLabel: 'Group Loan',
					name: 'group_loan_name' 
				},
				{
					xtype: 'displayfield',
					fieldLabel: 'Member Name',
					name: 'member_name' 
				},
				{
					xtype: 'displayfield',
					fieldLabel: 'Member ID',
					name: 'member_id_number' 
				},
				{
					xtype: 'displayfield',
					fieldLabel: 'Tipe Transaksi',
					name: 'direction_text' 
				}
		 
			]
    }];

    this.buttons = [{
      text: 'Deactivate',
      action: 'deactivate'
    }, {
      text: 'Cancel',
      scope: this,
      handler: this.close
    }];

    this.callParent(arguments);
  },

	setParentData: function( record ) {
		this.down('form').getForm().findField('member_name').setValue(record.get('member_name')); 
		this.down('form').getForm().findField('member_id_number').setValue(record.get('member_id_number')); 
		this.down('form').getForm().findField('amount').setValue(record.get('amount')); 
		this.down('form').getForm().findField('direction_text').setValue(record.get('direction_text')); 
	}
});
