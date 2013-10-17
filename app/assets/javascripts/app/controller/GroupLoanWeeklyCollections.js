Ext.define('AM.controller.GroupLoanWeeklyCollections', {
  extend: 'Ext.app.Controller',

  stores: ['GroupLoanWeeklyCollections'],
  models: ['GroupLoanWeeklyCollection'],

  views: [
    'operation.grouploanweeklycollection.List',
		'operation.GroupLoanWeeklyCollection',
		'operation.GroupLoanList'
  ],

  	refs: [
		{
			ref : "wrapper",
			selector : "grouploanweeklycollectionProcess"
		},
		{
			ref : 'parentList',
			selector : 'grouploanweeklycollectionProcess operationgrouploanList'
		},
		{
			ref: 'list',
			selector: 'grouploanweeklycollectionlist'
		},
		{
			ref : 'searchField',
			selector: 'grouploanweeklycollectionlist textfield[name=searchField]'
		}
	],

  init: function() {
    this.control({
			'grouploanweeklycollectionProcess operationgrouploanList' : {
				afterrender : this.loadParentObjectList,
				selectionchange: this.parentSelectionChange,
			},
	
      'grouploanweeklycollectionlist': {
        // itemdblclick: this.editObject,
        selectionchange: this.selectionChange,
				// afterrender : this.loadObjectList,
      },
      // 'grouploanweeklycollectionform button[action=save]': {
      //   click: this.updateObject
      // },

// we need to add the execution as well
      'grouploanweeklycollectionlist button[action=collectObject]': {
        click: this.collectObject
      },
      'grouploanweeklycollectionlist button[action=confirmObject]': {
        click: this.confirmObject
      },
      
			'grouploanweeklycollectionlist textfield[name=searchField]': {
        change: this.liveSearch
      },

			// 'collectweeklycollectionform button[action=collect]' : {
			// 	click : this.executeCollectWeeklyCollection
			// },
			// 
			// 'confirmweeklycollectionform button[action=confirm]' : {
			// 	click : this.executeConfirmWeeklyCollection
			// }
		
    });
  },

	liveSearch : function(grid, newValue, oldValue, options){
		var me = this;

		me.getGroupLoanWeeklyCollectionsStore().getProxy().extraParams = {
		    livesearch: newValue
		};
	 
		me.getGroupLoanWeeklyCollectionsStore().load();
	},
 

	loadObjectList : function(me){
		me.getStore().load();
	},
	
	loadParentObjectList: function(me){
		// console.log("after render the group_loan list");
		me.getStore().load(); 
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

    if (selections.length > 0) {
			// grid.enableAddButton();
      // grid.enableRecordButtons();
    } else {
			// grid.disableAddButton();
      // grid.disableRecordButtons();
    }
		
		 
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
