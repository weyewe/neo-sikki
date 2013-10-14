Ext.define('AM.controller.Members', {
  extend: 'Ext.app.Controller',

  stores: ['Members'],
  models: ['Member'],

  views: [
    'master.member.List',
    'master.member.Form'
  ],

  	refs: [
		{
			ref: 'list',
			selector: 'memberlist'
		},
		{
			ref : 'searchField',
			selector: 'memberlist textfield[name=searchField]'
		}
	],

  init: function() {
    this.control({
      'memberlist': {
        itemdblclick: this.editObject,
        selectionchange: this.selectionChange,
				afterrender : this.loadObjectList,
      },
      'memberform button[action=save]': {
        click: this.updateObject
      },
      'memberlist button[action=addObject]': {
        click: this.addObject
      },
      'memberlist button[action=editObject]': {
        click: this.editObject
      },
      'memberlist button[action=deleteObject]': {
        click: this.deleteObject
      },
			'memberlist textfield[name=searchField]': {
        change: this.liveSearch
      }
		
    });
  },

	liveSearch : function(grid, newValue, oldValue, options){
		var me = this;

		me.getMembersStore().getProxy().extraParams = {
		    livesearch: newValue
		};
	 
		me.getMembersStore().load();
	},
 

	loadObjectList : function(me){
		me.getStore().load();
	},

  addObject: function() {
    var view = Ext.widget('memberform');
    view.show();
  },

  editObject: function() {
		var me = this; 
    var record = this.getList().getSelectedObject();
    var view = Ext.widget('memberform');

		

    view.down('form').loadRecord(record);
  },

  updateObject: function(button) {
		var me = this; 
    var win = button.up('window');
    var form = win.down('form');

    var store = this.getMembersStore();
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
	 
					store.load();
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
			var newObject = new AM.model.Member( values ) ;
			
			// learnt from here
			// http://www.sencha.com/forum/showthread.php?137580-ExtJS-4-Sync-and-success-failure-processing
			// form.mask("Loading....."); 
			form.setLoading(true);
			newObject.save({
				success: function(record){
	
					store.load();
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
      var store = this.getMembersStore();
      store.remove(record);
      store.sync();
// to do refresh programmatically
			this.getList().query('pagingtoolbar')[0].doRefresh();
    }

  },

  selectionChange: function(selectionModel, selections) {
    var grid = this.getList();

    if (selections.length > 0) {
      grid.enableRecordButtons();
    } else {
      grid.disableRecordButtons();
    }
  }

});
