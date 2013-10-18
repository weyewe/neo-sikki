Ext.define('AM.controller.GroupLoanRunAwayReceivables', {
  extend: 'Ext.app.Controller',

  stores: ['GroupLoanRunAwayReceivables'],
  models: ['GroupLoanRunAwayReceivable'],

  views: [
    'operation.grouploanrunawayreceivable.List',
    // 'operation.grouploanrunawayreceivable.Form',
		'operation.GroupLoanRunAwayReceivable',
		'operation.GroupLoanList'
  ],

  	refs: [
		{
			ref : "wrapper",
			selector : "grouploanrunawayreceivableProcess"
		},
		{
			ref : 'parentList',
			selector : 'grouploanrunawayreceivableProcess operationmemberList'
		},
		{
			ref: 'list',
			selector: 'grouploanrunawayreceivablelist'
		},
		{
			ref : 'searchField',
			selector: 'grouploanrunawayreceivablelist textfield[name=searchField]'
		}
	],

  init: function() {
    this.control({
			'grouploanrunawayreceivableProcess operationmemberList' : {
				afterrender : this.loadParentObjectList,
				selectionchange: this.parentSelectionChange,
			},
	
      'grouploanrunawayreceivablelist': {
        itemdblclick: this.editObject,
        selectionchange: this.selectionChange,
				// afterrender : this.loadObjectList,
      },
      // 'grouploanrunawayreceivableform button[action=save]': {
      //   click: this.updateObject
      // },
      // 'grouploanrunawayreceivablelist button[action=addObject]': {
      //   click: this.addObject
      // },
      // 'grouploanrunawayreceivablelist button[action=editObject]': {
      //   click: this.editObject
      // },
      'grouploanrunawayreceivablelist button[action=deleteObject]': {
        click: this.deleteObject
      },
			'grouploanrunawayreceivablelist textfield[name=searchField]': {
        change: this.liveSearch
      }
		
    });
  },

	liveSearch : function(grid, newValue, oldValue, options){
		var me = this;

		me.getGroupLoanRunAwayReceivablesStore().getProxy().extraParams = {
		    livesearch: newValue
		};
	 
		me.getGroupLoanRunAwayReceivablesStore().load();
	},
 

	loadObjectList : function(me){
		me.getStore().load();
	},
	
	loadParentObjectList: function(me){
		me.getStore().getProxy().extraParams.is_run_away =  true ;
		
		me.getStore().load(); 
	},
 

  deleteObject: function() {
    var record = this.getList().getSelectedObject();

    if (record) {
      var store = this.getGroupLoanRunAwayReceivablesStore();
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
		grid.getStore().load(); 
  },

});