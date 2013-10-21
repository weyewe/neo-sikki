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

			'grouploanweeklycollectionlist button[action=collectObject]': {
        click: this.collectObject
			}	,
			
			'collectgrouploanweeklycollectionform button[action=collect]' : {
				click : this.executeCollect
			},
			
			'grouploanweeklycollectionlist button[action=confirmObject]': {
        click: this.confirmObject
			}	,
			
			'confirmgrouploanweeklycollectionform button[action=confirm]' : {
				click : this.executeConfirm
			},
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
		
		grid.getStore().getProxy().extraParams.parent_id =  wrapper.selectedParentId ;
		grid.getStore().load(); 
  },

	collectObject: function(){
		var view = Ext.widget('collectgrouploanweeklycollectionform');
		var record = this.getList().getSelectedObject();
		view.setParentData( record );
    view.show();
		// this.reloadRecordView( record, view ) ; 
	},
	
	executeCollect: function(button){
		var me = this; 
		var win = button.up('window');
    var form = win.down('form');
		var list = this.getList();

    var store = this.getGroupLoanWeeklyCollectionsStore();
		var record = this.getList().getSelectedObject();
    var values = form.getValues();
 
		if(record){
			var rec_id = record.get("id");
			record.set( 'collected_at' , values['collected_at'] );
			 
			// form.query('checkbox').forEach(function(checkbox){
			// 	record.set( checkbox['name']  ,checkbox['checked'] ) ;
			// });
			// 
			form.setLoading(true);
			record.save({
				params : {
					collect: true 
				},
				success : function(record){
					form.setLoading(false);
					
					me.reloadRecord( record ) ; 
					
					
					win.close();
				},
				failure : function(record,op ){
					// console.log("Fail update");
					form.setLoading(false);
					var message  = op.request.scope.reader.jsonData["message"];
					var errors = message['errors'];
					form.getForm().markInvalid(errors);
					record.reject(); 
					// this.reject(); 
				}
			});
		}
	},
	
	confirmObject: function(){
		var view = Ext.widget('confirmgrouploanweeklycollectionform');
		var record = this.getList().getSelectedObject();
		view.setParentData( record );
    view.show();
		// this.reloadRecordView( record, view ) ; 
	},
	
	executeConfirm: function(button){
		var me = this; 
		var win = button.up('window');
    var form = win.down('form');
		var list = this.getList();

    var store = this.getGroupLoanWeeklyCollectionsStore();
		var record = this.getList().getSelectedObject();
    var values = form.getValues();
 
		if(record){
			var rec_id = record.get("id");
			record.set( 'confirmed_at' , values['confirmed_at'] );
			 
			// form.query('checkbox').forEach(function(checkbox){
			// 	record.set( checkbox['name']  ,checkbox['checked'] ) ;
			// });
			// 
			form.setLoading(true);
			record.save({
				params : {
					confirm: true 
				},
				success : function(record){
					form.setLoading(false);
					
					me.reloadRecord( record ) ; 
					
					
					win.close();
				},
				failure : function(record,op ){
					// console.log("Fail update");
					form.setLoading(false);
					var message  = op.request.scope.reader.jsonData["message"];
					var errors = message['errors'];
					form.getForm().markInvalid(errors);
					record.reject(); 
					// this.reject(); 
				}
			});
		}
	},
	
	reloadRecord: function(record){
		
		var list = this.getList();
		var store = this.getList().getStore();
		var modifiedId = record.get('id');
		
		AM.model.GroupLoan.load( modifiedId , {
		    scope: list,
		    failure: function(record, operation) {
		        //do something if the load failed
		    },
		    success: function(record, operation) {
					recToUpdate = store.getById(modifiedId);
					recToUpdate.set(record.getData());
					recToUpdate.commit();
					list.getView().refreshNode(store.indexOfId(modifiedId));
		    },
		    callback: function(record, operation) {
		        //do something whether the load succeeded or failed
		    }
		});
	},

});
