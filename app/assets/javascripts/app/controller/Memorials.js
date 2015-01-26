Ext.define('AM.controller.Memorials', {
  extend: 'Ext.app.Controller',

  stores: ['Memorials'],
  models: ['Memorial'],

  views: [
    'operation.memorial.List',
    'operation.memorial.Form',
		'operation.memorialdetail.List',
		'Viewport'
  ],

  	refs: [
		{
			ref: 'list',
			selector: 'memoriallist'
		},
		{
			ref : 'memorialDetailList',
			selector : 'memorialdetaillist'
		},
		
		{
			ref : 'form',
			selector : 'memorialform'
		}
	],

  init: function() {
    this.control({
      'memorialProcess memoriallist': {
        itemdblclick: this.editObject,
        selectionchange: this.selectionChange,
				afterrender : this.loadObjectList,
      },
      'memorialProcess memorialform button[action=save]': {
        click: this.updateObject
      },
			'memorialProcess memorialform customcolorpicker' : {
				'colorSelected' : this.onColorPickerSelect
			},

      'memorialProcess memoriallist button[action=addObject]': {
        click: this.addObject
      },
      'memorialProcess memoriallist button[action=editObject]': {
        click: this.editObject
      },
      'memorialProcess memoriallist button[action=deleteObject]': {
        click: this.deleteObject
			}	,
			
			'memorialProcess memoriallist button[action=confirmObject]': {
        click: this.confirmObject
      },
			'confirmmemorialform button[action=confirm]' : {
				click : this.executeConfirm
			},

			'memorialProcess memoriallist textfield[name=searchField]': {
				change: this.liveSearch
			},
			'memorialform button[action=save]': {
        click: this.updateObject
      }
		
    });
  },

	onColorPickerSelect: function(colorId, theColorPicker){
		var win = theColorPicker.up('window');
    var form = win.down('form');
		var colorField = form.getForm().findField('color'); 
		
		
		// console.log("the colorId in onColorPickerSelect:");
		// console.log( colorId);
		colorField.setValue( colorId );
		
		// console.log("The colorField.getValue()");
		// console.log( colorField.getValue() );
	
	},

	liveSearch : function(grid, newValue, oldValue, options){
		var me = this;

		me.getMemorialsStore().getProxy().extraParams = {
		    livesearch: newValue
		};
	 
		me.getMemorialsStore().load();
	},
 

	loadObjectList : function(me){
		console.log( "I am inside the load object list" ); 
		me.getStore().load();
	},

  addObject: function() {
	var view = Ext.widget('memorialform');
  view.show();

	 
  },

  editObject: function() {
    var record = this.getList().getSelectedObject();
    var view = Ext.widget('memorialform');

    view.down('form').loadRecord(record);
  },

	confirmObject: function(){
		// console.log("the startObject callback function");
		var record = this.getList().getSelectedObject();
		if(record){
			var view = Ext.widget('confirmmemorialform');

			view.setParentData( record );
	    view.show();
		}
		
		
		// this.reloadRecordView( record, view ) ; 
	},

  updateObject: function(button) {
    var win = button.up('window');
    var form = win.down('form');
		var me = this; 

    var store = this.getMemorialsStore();
    var record = form.getRecord();
    var values = form.getValues();
 
		if( record ){
			record.set( values );
			  
			
			form.setLoading(true);
			record.save({
				success : function(record){
					form.setLoading(false);
					//  since the grid is backed by store, if store changes, it will be updated
					store.load();
					win.close();
					// me.updateChildGrid(record );
				},
				failure : function(record,op ){
					form.setLoading(false);
					var message  = op.request.scope.reader.jsonData["message"];
					var errors = message['errors'];
					form.getForm().markInvalid(errors);
					me.reject();
				}
			});
				
			 
		}else{
			//  no record at all  => gonna create the new one 
			var me  = this; 
			var newObject = new AM.model.Memorial( values ) ; 
			
			// learnt from here
			// http://www.sencha.com/forum/showthread.php?137580-ExtJS-4-Sync-and-success-failure-processing
			// form.mask("Loading....."); 
			form.setLoading(true);
			newObject.save({
				success: function(record){
					//  since the grid is backed by store, if store changes, it will be updated
					store.load();
					form.setLoading(false);
					win.close();
					
					me.updateChildGrid(record );
					
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

	executeConfirm: function(button){
		var win = button.up('window');
    var form = win.down('form');

		var me  = this;
		var record = this.getList().getSelectedObject();
		var list = this.getList();
		
		// me.getViewport().setLoading( true ) ;
		// win.setLoading(true);
		
		if(!record){return;}
		
		Ext.Ajax.request({
		    url: 'api/confirm_memorial',
		    method: 'PUT',
		    params: {
					id : record.get('id')
		    },
		    jsonData: {},
		    success: function(result, request ) {
						// me.getViewport().setLoading( false );
						list.getStore().load({
							callback : function(records, options, success){
								// this => refers to a store 
								record = this.getById(record.get('id'));
								// record = records.getById( record.get('id'))
								list.fireEvent('confirmed', record);
							}
						});
						win.close();
						
		    },
		    // failure: function(result, request ) {
		    // 						me.getViewport().setLoading( false ) ;
		    // 						
		    // 						
		    // }
				failure : function(record,op ){
					list.setLoading(false);
					
					var message  = op.request.scope.reader.jsonData["message"];
					var errors = message['errors'];
					
					if( errors["generic_errors"] ){
						Ext.MessageBox.show({
						           title: 'FAIL',
						           msg: errors["generic_errors"],
						           buttons: Ext.MessageBox.OK, 
						           icon: Ext.MessageBox.ERROR
						       });
					}
					
				}
		});
	},

  deleteObject: function() {
    var record = this.getList().getSelectedObject();

    if (record) {
      var store = this.getMemorialsStore();
			store.remove(record);
			store.sync( );
 
			this.getList().query('pagingtoolbar')[0].doRefresh();
    }

  },

  selectionChange: function(selectionModel, selections) {
    var grid = this.getList();
		var me= this;
		var record = this.getList().getSelectedObject();
		if(!record){
			return; 
		}
		
		
		// me.updateChildGrid(record );
		
		
		

    if (selections.length > 0) {
      grid.enableRecordButtons();
    } else {
      grid.disableRecordButtons();
    }
  },

	updateChildGrid: function(record){
		var memorialDetailGrid = this.getMemorialList();
		// memorialDetailGrid.setTitle("Purchase Order: " + record.get('code'));
		memorialDetailGrid.setObjectTitle( record ) ;
		memorialDetailGrid.getStore().load({
			params : {
				calendar_id : record.get('id')
			},
			callback : function(records, options, success){
				
				var totalObject  = records.length;
				if( totalObject ===  0 ){
					memorialDetailGrid.enableRecordButtons(); 
				}else{
					memorialDetailGrid.enableRecordButtons(); 
				}
			}
		});
		
	}

	


});
