Ext.define('AM.controller.GroupLoanMemberships', {
  extend: 'Ext.app.Controller',

  stores: ['GroupLoanMemberships'],
  models: ['GroupLoanMembership'],

  views: [
    'operation.grouploanmembership.List',
    'operation.grouploanmembership.Form',
		'operation.GroupLoanMembership'
  ],

  	refs: [
		{
			ref : 'wrapper',
			selector : 'grouploanmembershipProcess'
		},
		{
			ref: 'list',
			selector: 'grouploanmembershiplist'
		},
		{
			ref : 'searchField',
			selector: 'grouploanmembershiplist textfield[name=searchField]'
		}
	],

  init: function() {
    this.control({
			'wrapper operationgrouploanList' : {
				afterrender : this.loadParentObjectList,
				selectionchange: this.parentSelectionChange,
			},
	
      'grouploanmembershiplist': {
        itemdblclick: this.editObject,
        // selectionchange: this.selectionChange,
				// afterrender : this.loadObjectList,
      },
      'grouploanmembershipform button[action=save]': {
        click: this.updateObject
      },
      'grouploanmembershiplist button[action=addObject]': {
        click: this.addObject
      },
      'grouploanmembershiplist button[action=editObject]': {
        click: this.editObject
      },
      'grouploanmembershiplist button[action=deleteObject]': {
        click: this.deleteObject
      },
			'grouploanmembershiplist textfield[name=searchField]': {
        change: this.liveSearch
      }
		
    });
  },

	liveSearch : function(grid, newValue, oldValue, options){
		var me = this;

		me.getGroupLoanMembershipsStore().getProxy().extraParams = {
		    livesearch: newValue
		};
	 
		me.getGroupLoanMembershipsStore().load();
	},
 

	loadObjectList : function(me){
		me.getStore().load();
	},
	
	loadParentObjectList: function(me){
		me.getStore().load(); 
	},

  addObject: function() {
    var view = Ext.widget('grouploanmembershipform');
    view.show();
  },

  editObject: function() {
		var me = this; 
    var record = this.getList().getSelectedObject();
    var view = Ext.widget('grouploanmembershipform');

		

    view.down('form').loadRecord(record);
  },

  updateObject: function(button) {
		var me = this; 
    var win = button.up('window');
    var form = win.down('form');
		var wrapper = this.getWrapper();

    var store = this.getGroupLoanMembershipsStore();
    var record = form.getRecord();
    var values = form.getValues();

		
		if( record ){
			record.set( values );
			 
			form.setLoading(true);
			record.save({
				success : function(record){
					form.setLoading(false);
					//  since the grid is backed by store, if store changes, it will be updated
					
					// store.getProxy().extraParams = {
					//     livesearch: ''
					// };
	 
					store.load({
						params: {
							parent_id : wrapper.selectedParentId 
						}
					});
					 
					
					win.close();
				},
				failure : function(record,op ){
					form.setLoading(false);
					var message  = op.request.scope.reader.jsonData["message"];
					var errors = message['errors'];
					form.getForm().markInvalid(errors);
					this.reject();
				}
			});
				
			 
		}else{
			//  no record at all  => gonna create the new one 
			var me  = this; 
			var newObject = new AM.model.GroupLoanMembership( values ) ;
			
			// learnt from here
			// http://www.sencha.com/forum/showthread.php?137580-ExtJS-4-Sync-and-success-failure-processing
			// form.mask("Loading....."); 
			form.setLoading(true);
			newObject.save({
				success: function(record){
	
					store.load({
						params: {
							parent_id : wrapper.selectedParentId 
						}
					});
					
					form.setLoading(false);
					win.close();
					
				},
				failure: function( record, op){
					form.setLoading(false);
					var message  = op.request.scope.reader.jsonData["message"];
					var errors = message['errors'];
					form.getForm().markInvalid(errors);
					this.reject();
				}
			});
		} 
  },

  deleteObject: function() {
    var record = this.getList().getSelectedObject();

    if (record) {
      var store = this.getGroupLoanMembershipsStore();
      store.remove(record);
      store.sync();
// to do refresh programmatically
			this.getList().query('pagingtoolbar')[0].doRefresh();
    }

  },

  // selectionChange: function(selectionModel, selections) {
  //   var grid = this.getList();
  // 
  //   if (selections.length > 0) {
  //     grid.enableRecordButtons();
  //   } else {
  //     grid.disableRecordButtons();
  //   }
  // },

	parentSelectionChange: function(selectionModel, selections) {
		var me = this; 
    var grid = me.getList();
		var wrapper = me.getWrapper();


    if (selections.length > 0) {
      grid.enableRecordButtons();
    } else {
      grid.disableRecordButtons();
    }
		
		 
		if (grid.getSelectionModel().hasSelection()) {
			var row = grid.getSelectionModel().getSelection()[0];
			var id = row.get("id"); 
			wrapper.selectedParentId = id ; 
		}
		
		
		
		me.setLoading(true);
		grid.getStore.load({
			params: {
				parent_id : wrapper.selectedParentId 
			},
			callback : function(records, options, success){
				me.setLoading(false); 
			}
		});
  },

});
