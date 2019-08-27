Ext.define('AM.controller.CollectionGroups', {
  extend: 'Ext.app.Controller',

  stores: ['CollectionGroups'],
  models: ['CollectionGroup'],

  views: [
    'master.collectiongroup.List',
    'master.collectiongroup.Form' 
  ],

  	refs: [
		{
			ref: 'list',
			selector: 'collectiongrouplist'
		},
		{
			ref : 'searchField',
			selector: 'collectiongrouplist textfield[name=searchField]'
		}
	],

  init: function() {
  	console.log("I am initialized: CollectionGroups!");
		
		
    this.control({
      'collectiongrouplist': {
        itemdblclick: this.editObject,
        selectionchange: this.selectionChange,
				afterrender : this.loadObjectList,
      },
      'collectiongroupform button[action=save]': {
        click: this.updateObject
      },
      'collectiongrouplist button[action=addObject]': {
        click: this.addObject
      },
      'collectiongrouplist button[action=editObject]': {
        click: this.editObject
      },
      'collectiongrouplist button[action=deleteObject]': {
        click: this.deleteObject
      },
	  	'collectiongrouplist textfield[name=searchField]': {
        change: this.liveSearch
      },
		 
		
    });
  },

	liveSearch : function(grid, newValue, oldValue, options){
		var me = this;

		me.getCollectionGroupsStore().getProxy().extraParams = {
		    livesearch: newValue
		};
	 
		me.getCollectionGroupsStore().load();
	},
	
	 
	   

	loadObjectList : function(me){
		console.log("hajar kena");
		me.getStore().getProxy().extraParams = {}
		me.getStore().load();
	},

  addObject: function() {
    var view = Ext.widget('collectiongroupform');
    view.show();
  },

  editObject: function() {
		var me = this; 
    var record = this.getList().getSelectedObject();
    var view = Ext.widget('collectiongroupform');

		

    view.down('form').loadRecord(record);
    console.log("inside form edit object");
    console.log( record );
    view.setComboBoxData(record);
  },

  updateObject: function(button) {
		var me = this; 
    var win = button.up('window');
    var form = win.down('form');

    var store = this.getCollectionGroupsStore();
    var record = form.getRecord();
    var values = form.getValues();


		// console.log("The values");
		// console.log( values);
		form.query('checkbox').forEach(function(checkbox){
						// 
						// record.set( checkbox['name']  ,checkbox['checked'] ) ;
						// console.log("the checkbox name: " +  checkbox['name']   );
						// console.log("the checkbox value: " + checkbox['checked']  );
			values[checkbox['name']] = checkbox['checked'];
		});
		
		
		
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
			var newObject = new AM.model.CollectionGroup( values ) ;
			
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
      var store = this.getCollectionGroupsStore();
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
