Ext.define('AM.controller.SavingsEntries', {
  extend: 'Ext.app.Controller',

  stores: ['SavingsEntries', 'Members'],
  models: ['SavingsEntry'],

  views: [
    'operation.savingsentry.List',
    'operation.savingsentry.Form',
		'operation.savingsentry.ConfirmationForm',
		'operation.SavingsEntry',
		'operation.GroupLoanList'
  ],

  	refs: [
		{
			ref : "viewport",
			selector : "vp"
		},
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
				'confirmed' : this.reloadParentRow,
				destroy : this.onDestroy
      },
      'savingsentryform button[action=save]': {
        click: this.updateObject
      },
      'savingsentrylist button[action=addObject]': {
        click: this.addObject
      },
      'savingsentrylist button[action=editObject]': {
        click: this.editObject
      },
      'savingsentrylist button[action=deleteObject]': {
        click: this.deleteObject
      },

			'savingsentrylist button[action=confirmObject]': {
        click: this.confirmObject
			}	,
			
			'confirmsavingsentryform button[action=confirm]' : {
				click : this.executeConfirm
			},
			
			'savingsentryProcess operationmemberList textfield[name=searchField]': {
        change: this.liveSearch
      }
		
    });
  },

	onDestroy: function(){
		// console.log("on Destroy the savings_entries list ");
		this.getSavingsEntriesStore().loadData([],false);
	},
	
	// try this guy: http://www.learnsomethings.com/2012/02/01/re-selecting-the-last-selected-record-after-store-load-in-extjs4/

	reloadParentRow: function(){
		
		// http://vadimpopa.com/reload-a-single-record-and-refresh-its-extjs-grid-row/
		// console.log("Gonna reload parent row");
		// grid.getView().refreshRow(record);
		
		var parentList = this.getParentList();
		// var record = parentList.getSelectionModel().getSelection()[0]; 
		// parentList.getView().refreshRow(record);
		
		// if (parentList.getSelectionModel().hasSelection()) {
		// 	var row = parentList.getSelectionModel().getSelection()[0];
		// 	var id = row.get("id"); 
		// 	wrapper.selectedParentId = id ; 
		// }
		var wrapper = this.getWrapper();
		modifiedId = wrapper.selectedParentId;
		console.log("The store: " );
		console.log( parentList.store );
		var selectedIdx = parentList.store.indexOf(modifiedId);
		console.log("The modified Id: " + modifiedId);
		console.log("The selectedIdx: " + selectedIdx);
		
		var selectedRecord = parentList.getSelectionModel().getSelection()[0];
		var row = parentList.store.indexOf(selectedRecord);
		
		console.log("The row" ) ;
		console.log( row ) ;
		
		// var selectedRecord = grid.getSelectionModel().getSelection()[0];
		// var row = grid.store.indexOf(selectedRecord);
		
		// var row = parentList.getView().getRow(0); // Getting HtmlElement here
		// Ext.get(row).highlight();
		
		// console.log("The row");
		// console.log( row ) ;
		
		AM.model.Member.load( modifiedId , {
		    scope: parentList,
		    failure: function(record, operation) {
		        //do something if the load failed
		    },
		    success: function(record, operation) {
					// console.log("The record");
					// console.log( record ); 
					
		        var store = parentList.getStore(),
		            recToUpdate = store.getById(modifiedId);

		         recToUpdate.set(record.getData());

		     // Do commit if you need: if the data from
		     // the server differs from last commit data
		         recToUpdate.commit();

		         parentList.getView().refreshNode(store.indexOfId(modifiedId));
						// Ext.get(row).highlight();
						
						// parentList.getSelectionModel().select(row);
						parentList.getView().focusRow( row );
						
		
		// reselect the reloaded row 
		
							// var selectionModel = grid.getSelectionModel()
							// 
							// // get the selected record
							// var selectedRecord = selectionModel.getSelection()[0]
							// 
							// // get the index of the selected record
							// var selectedIdx = grid.store.indexOfId(selectedRecord.data.id);
							
							// var selectedIdx = record.get('id');

							// select by index
							// grid.getSelectionModel().select(selectedIdx);
								// console.log("The modifiedId: " + modifiedId);
							// parentList.getSelectionModel().select(modifiedId);
							
						// var row = grid.getView().getRow(0); // Getting HtmlElement here
						// Ext.get(row).highlight(); // Getting element wrapper and using its "highlight" method
						// 		
		    },
		    callback: function(record, operation) {
		        //do something whether the load succeeded or failed
		    }
		});
		
	},

	liveSearch : function(grid, newValue, oldValue, options){
		// console.log("Live search is called");
		var me = this;

		me.getMembersStore().getProxy().extraParams = {
		    livesearch: newValue,				// 
		    				// is_deceased : true, 
		    				// is_run_away : true 
		};
	 
		me.getMembersStore().load();
	},
 

	loadObjectList : function(me){
		me.getStore().load();
	},
	
	loadParentObjectList: function(me){
		// delete me.getStore().getProxy().extraParams ;
		me.getStore().getProxy().extraParams = {}
		me.getStore().load(); 
	},
 

	addObject: function() {
    
		var parentObject  = this.getParentList().getSelectedObject();
		if( parentObject) {
			var view = Ext.widget('savingsentryform');
			view.show();
			view.setParentData(parentObject);
		}
  },

	editObject: function() {
		var me = this; 
    var record = this.getList().getSelectedObject();
		var parentObject  = this.getParentList().getSelectedObject();
		
		if( parentObject) {
			var view = Ext.widget('savingsentryform');
			view.show();
			view.down('form').loadRecord(record);
			view.setParentData(parentObject);
		}
		
		
    // var view = Ext.widget('savingsentryform');
    
  },

  updateObject: function(button) {
		var me = this; 
    var win = button.up('window');
    var form = win.down('form');
		var parentList = this.getParentList();
		var wrapper = this.getWrapper();

    var store = this.getSavingsEntriesStore();
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
			var newObject = new AM.model.SavingsEntry( values ) ;
			
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


	confirmObject: function(){
		var view = Ext.widget('confirmsavingsentryform');
		var record = this.getList().getSelectedObject();
		view.setParentData( record );
		view.down('form').getForm().findField('confirmed_at').setValue(record.get('confirmed_at')); 
    view.show();
	},
	
	
	 
 
	
	executeConfirm : function(button){
		var me = this; 
		var win = button.up('window');
    var form = win.down('form');
		var list = this.getList();

    var store = this.getSavingsEntriesStore();
		var record = this.getList().getSelectedObject();
    var values = form.getValues();
		// console.log("the values from form");
		// console.log( values );
		// form.setLoading( true ) ;
		// console.log(values['confirmed_at']);
 
		if(record){
			// console.log("The record");
			// console.log( record );
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
					
					list.fireEvent('confirmed', record);
					
					// store.load({
					// 	params: {
					// 		booking_id : rec_id
					// 	}
					// });
					
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
	
	
	
	parentSelectionChange: function(selectionModel, selections) {
		var me = this; 
    var grid = me.getList();
		var parentList = me.getParentList();
		var wrapper = me.getWrapper();
		
		// console.log("parent selection change");
		// console.log("The wrapper");
		// console.log( wrapper ) ;

		if (selections.length > 0) {
			grid.enableAddButton();
			// grid.enableRecordButtons();
		} else {
			grid.disableAddButton();
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
		grid.getStore().getProxy().extraParams.is_savings_account =  true ;
		grid.getStore().load(); 
  },

});
