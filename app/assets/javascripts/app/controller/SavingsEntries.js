Ext.define('AM.controller.SavingsEntries', {
  extend: 'Ext.app.Controller',

  stores: ['SavingsEntries'],
  models: ['SavingsEntry'],

  views: [
    'operation.savingsentry.List',
    // 'operation.savingsentry.Form',
		'operation.SavingsEntry',
		'operation.GroupLoanList'
  ],

  	refs: [
		{
			ref : "wrapper",
			selector : "savingsentryProcess"
		},
		{
			ref : 'parentList',
			selector : 'savingsentryProcess operationmemberList'
		},
		{
			ref: 'list',
			selector: 'savingsentrylist'
		},
		{
			ref : 'searchField',
			selector: 'savingsentrylist textfield[name=searchField]'
		}
	],

  init: function() {
    this.control({
			'savingsentryProcess operationmemberList' : {
				afterrender : this.loadParentObjectList,
				selectionchange: this.parentSelectionChange,
			},
	
      'savingsentrylist': {
        itemdblclick: this.editObject,
        selectionchange: this.selectionChange,
				// afterrender : this.loadObjectList,
      },
      // 'savingsentryform button[action=save]': {
      //   click: this.updateObject
      // },
      // 'savingsentrylist button[action=addObject]': {
      //   click: this.addObject
      // },
      // 'savingsentrylist button[action=editObject]': {
      //   click: this.editObject
      // },
      'savingsentrylist button[action=deleteObject]': {
        click: this.deleteObject
      },
			'savingsentrylist textfield[name=searchField]': {
        change: this.liveSearch
      }
		
    });
  },

	liveSearch : function(grid, newValue, oldValue, options){
		var me = this;

		me.getSavingsEntriesStore().getProxy().extraParams = {
		    livesearch: newValue
		};
	 
		me.getSavingsEntriesStore().load();
	},
 

	loadObjectList : function(me){
		me.getStore().load();
	},
	
	loadParentObjectList: function(me){
		me.getStore().load(); 
	},
 

  deleteObject: function() {
    var record = this.getList().getSelectedObject();

    if (record) {
      var store = this.getSavingsEntriesStore();
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
  },

	parentSelectionChange: function(selectionModel, selections) {
		var me = this; 
    var grid = me.getList();
		var parentList = me.getParentList();
		var wrapper = me.getWrapper();
		
		// console.log("parent selection change");
		// console.log("The wrapper");
		// console.log( wrapper ) ;

			//     if (selections.length > 0) {
			// grid.enableAddButton();
			//       // grid.enableRecordButtons();
			//     } else {
			// grid.disableAddButton();
			//       // grid.disableRecordButtons();
			//     }
		
		 
		if (parentList.getSelectionModel().hasSelection()) {
			var row = parentList.getSelectionModel().getSelection()[0];
			var id = row.get("id"); 
			wrapper.selectedParentId = id ; 
		}
		
		
		
		// console.log("The parent ID: "+ wrapper.selectedParentId );
		
		// grid.setLoading(true); 
		grid.getStore().getProxy().extraParams.parent_id =  wrapper.selectedParentId ;
		grid.getStore().getProxy().extraParams.is_savings_account =  true ;
		grid.getStore().load(); 
  },

});
