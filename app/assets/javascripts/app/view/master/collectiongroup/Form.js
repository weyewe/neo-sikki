Ext.define('AM.view.master.collectiongroup.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.collectiongroupform',

  title : 'Add / Edit Kumpulan',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
	
  initComponent: function() {
	
	
// branch
// user
// collection_day
// collection_hour 
// name
// description 
	
	var remoteJsonStore = Ext.create(Ext.data.JsonStore, {
		storeId : 'branch_search',
		fields	: [
 				{
					name : 'branch_name',
					mapping : "name"
				},
				{
					name : 'branch_id',
					mapping : 'id'
				}
		],
		proxy  	: {
			type : 'ajax',
			url : 'api/search_branch',
			reader : {
				type : 'json',
				root : 'records', 
				totalProperty  : 'total'
			}
		},
		autoLoad : false 
	});
	
	
	
	var remoteAppUserJsonStore = Ext.create(Ext.data.JsonStore, {
		storeId : 'app_user_search',
		fields	: [
 				{
					name : 'user_name',
					mapping : "name"
				},
				{
					name : 'user_id',
					mapping : 'id'
				}
		],
		proxy  	: {
			type : 'ajax',
			url : 'api/search_app_user',
			reader : {
				type : 'json',
				root : 'records', 
				totalProperty  : 'total'
			}
		},
		autoLoad : false 
	});
	
	var localJsonStoreCollectionDay = Ext.create(Ext.data.Store, {
		type : 'array',
		storeId : 'collection_day',
		fields	: [ 
			{ name : "collection_day_id"}, 
			{ name : "collection_day_name"}  
		], 
		data : [
			{ collection_day_id : 1, collection_day_name : "Senin"},
			{ collection_day_id : 2, collection_day_name : "Selasa"},
			{ collection_day_id : 3, collection_day_name : "Rabu"},
			{ collection_day_id : 4, collection_day_name : "Kamis"},
			{ collection_day_id : 5, collection_day_name : "Jumat"},
		] 
	});
	
	
	var localJsonStoreCollectionHour = Ext.create(Ext.data.Store, {
		type : 'array',
		storeId : 'collection_hour',
		fields	: [ 
			{ name : "collection_hour_id"}, 
			{ name : "collection_hour_name"}  
		], 
		data : [
			{ collection_hour_id : 1, collection_hour_name : "08.00"},
			{ collection_hour_id : 2, collection_hour_name : "08.30"},
			{ collection_hour_id : 3, collection_hour_name : "09.00"},
			{ collection_hour_id : 4, collection_hour_name : "09.30"},
			{ collection_hour_id : 5, collection_hour_name : "10.00"},
			{ collection_hour_id : 6, collection_hour_name : "10.30"},
			{ collection_hour_id : 7, collection_hour_name : "11.00"},
			{ collection_hour_id : 8, collection_hour_name : "11.30"},
			{ collection_hour_id : 9, collection_hour_name : "12.00"},
			{ collection_hour_id : 10, collection_hour_name : "12.30"},
			{ collection_hour_id : 11, collection_hour_name : "13.00"},
			{ collection_hour_id : 12, collection_hour_name : "13.30"},
			{ collection_hour_id : 13, collection_hour_name : "14.00"},
			{ collection_hour_id : 14, collection_hour_name : "14.30"},
			{ collection_hour_id : 15, collection_hour_name : "15.00"},
			{ collection_hour_id : 16, collection_hour_name : "15.30"},
			{ collection_hour_id : 17, collection_hour_name : "16.00"},
			{ collection_hour_id : 18, collection_hour_name : "16.30"},
			{ collection_hour_id : 19, collection_hour_name : "17.00"},
		] 
	});
		
		

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
	        xtype: 'hidden',
	        name : 'id',
	        fieldLabel: 'id'
	      },{
	        xtype: 'textfield',
	        name : 'name',
	        fieldLabel: ' Nama'
	      },
	      {
	        xtype: 'textfield',
	        name : 'code',
	        fieldLabel: 'Kode'
	      },
	      {
					xtype: 'textarea',
					name : 'description',
					fieldLabel: 'Deskripsi'
				},
				{
					xtype: 'textarea',
					name : 'address',
					fieldLabel: 'Alamat'
				},
				{
					fieldLabel: 'Branch',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'branch_name',
					valueField : 'branch_id',
					pageSize : 5,
					minChars : 1, 
					allowBlank : false, 
					triggerAction: 'all',
					store : remoteJsonStore , 
					listConfig : {
						getInnerTpl: function(){
							return  	'<div data-qtip="{branch_name}">' +  
													'<div class="combo-name">{branch_name}</div>' +  
							 					'</div>';
						}
					},
					name : 'branch_id' 
				},
				{
					fieldLabel: 'User',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'user_name',
					valueField : 'user_id',
					pageSize : 5,
					minChars : 1, 
					allowBlank : false, 
					triggerAction: 'all',
					store : remoteAppUserJsonStore , 
					listConfig : {
						getInnerTpl: function(){
							return  	'<div data-qtip="{user_name}">' +  
													'<div class="combo-name">{user_name}</div>' +  
							 					'</div>';
						}
					},
					name : 'user_id' 
				},
				{
					fieldLabel: 'Hari Pengumpulan',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'collection_day_name',
					valueField : 'collection_day_id',
					pageSize : 5,
					minChars : 1, 
					allowBlank : false, 
					triggerAction: 'all',
					store : localJsonStoreCollectionDay , 
					listConfig : {
						getInnerTpl: function(){
							return  	'<div data-qtip="{collection_day_name}">' +  
													'<div class="combo-name">{collection_day_name}</div>' +  
							 					'</div>';
						}
					},
					name : 'collection_day' 
				},
				{
					fieldLabel: 'Jam Pengumpulan',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'collection_hour_name',
					valueField : 'collection_hour_id',
					pageSize : 5,
					minChars : 1, 
					allowBlank : false, 
					triggerAction: 'all',
					store : localJsonStoreCollectionHour , 
					listConfig : {
						getInnerTpl: function(){
							return  	'<div data-qtip="{collection_hour_name}">' +  
													'<div class="combo-name">{collection_hour_name}</div>' +  
							 					'</div>';
						}
					},
					name : 'collection_hour' 
				},
		]
    }];

    this.buttons = [{
      text: 'Save',
      action: 'save'
    }, {
      text: 'Cancel',
      scope: this,
      handler: this.close
    }];

    this.callParent(arguments);
  },
  
 	
	setComboBoxData : function( record){
		var me = this; 
		me.setLoading(true);
		
		
		me.setSelectedBranch( record.get("branch_id")  ) ; 
		me.setSelectedUser( record.get("user_id")  ) ; 
	},
	

	setSelectedBranch: function( branch_id ){
		// console.log("inside set selected original account id ");
		var comboBox = this.down('form').getForm().findField('branch_id'); 
		var me = this; 
		var store = comboBox.store;  
		store.load({
			params: {
				selected_id : branch_id 
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( branch_id );
			}
		});
	},
	

	setSelectedUser: function( user_id ){
		// console.log("inside set selected original account id ");
		var comboBox = this.down('form').getForm().findField('user_id'); 
		var me = this; 
		var store = comboBox.store;  
		store.load({
			params: {
				selected_id : user_id 
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( user_id );
			}
		});
	},
	
	
	

});

