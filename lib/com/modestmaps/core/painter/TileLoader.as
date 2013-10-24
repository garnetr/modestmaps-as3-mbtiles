package com.modestmaps.core.painter
{
	import com.modestmaps.mapproviders.mapbox.MBTilesMapProvider;
	
	import flash.data.SQLConnection;
	import flash.data.SQLMode;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.errors.IOError;
	import flash.errors.SQLError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.net.Responder;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	public class TileLoader extends Loader
	{
		private static const SQL_GET_TILE:String = 
			"SELECT CAST(tile_data AS ByteArray) as data " +
			"FROM tiles WHERE " +
			"zoom_level = :zoom " +
			"and tile_column = :column " +
			"and tile_row = :row";
		
		private var connectionHash:Dictionary;
		private var connection:SQLConnection;
		private var sqlResponder:Responder;
		private var _urlRequest:URLRequest;
		private var _loaderUrl:String;
		private var _loaderContent:DisplayObject;
		
		public function TileLoader()
		{
			super();
			this.connectionHash = new Dictionary(true);
			sqlResponder = new Responder(sqlTileSuccessHandler, sqlTileErrorHandler);
			
			this.contentLoaderInfo.addEventListener(Event.COMPLETE, onUrlLoadEnd, false, 0, true);
			this.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onUrlLoadError, false, 0, true);
		}
		
		//
		// Event Handlers
		private function sqlTileSuccessHandler(e:SQLResult):void {
			trace("Got tile!");
			var data:Object = e.data[0];
			var imageByteArray:ByteArray = data.data;
			saveTile(imageByteArray);
		}
		
		private function sqlTileErrorHandler(e:SQLError):void {
			trace("No tiles for you!");
		}
		
		private function onUrlLoadEnd(event:Event):void {
			//save the content and then re-dispatch event
			var l:Loader = (event.target as LoaderInfo).loader;
			_loaderContent = l.content;
			
			var newEvent:Event = event.clone();
			dispatchEvent(newEvent);
		}
		
		private function onUrlLoadError(event:IOErrorEvent):void {
			//pass this event on up	
			var newEvent:IOErrorEvent = IOErrorEvent(event.clone());
			dispatchEvent(newEvent);
		}
		
		//
		// Methods
		private function loadMBTile(mbtilesURL:URLRequest):void {
			var urlVars:URLVariables = new URLVariables();
			var urlVarsStr:String = mbtilesURL.url.replace(/.*:\/\/\?/, "");
			
			//retrieve parameters from URL
			urlVars.decode(urlVarsStr);
			var zoom:Number = Number(urlVars["zoom"]), 
				col:Number = Number(urlVars["col"]), 
				row:Number = Number(urlVars["row"]), 
				dbName:String = urlVars["dbName"];
			
			//retrieve db connection from connection pool
			var c:SQLConnection = getDBConnection(dbName);
			if (!c) {
				//could not read database, dispatch the same error
				//Loader would dispatch
				trace("TileLoader::loadMBTile - failed to open " + dbName);
				var err:IOErrorEvent = new IOErrorEvent(IOErrorEvent.IO_ERROR);
				
				dispatchEvent(err);
				return;
			}
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = c;
			stmt.text = SQL_GET_TILE;
			stmt.parameters[":zoom"] = zoom;
			stmt.parameters[":row"] = row;
			stmt.parameters[":column"] = col;
			
			stmt.execute(-1, sqlResponder);
		}
		
		private function getDBConnection(dbName:String):SQLConnection {
			var conn:SQLConnection = connectionHash[dbName];
			
			if (!conn) {
				conn = new SQLConnection();
				//we will start with attempting to read from relative path
				var dbFile:File;
				try {
					//dbFile = new File("./" + dbName);
					//if (!dbFile.exists) {
						//if no dice, try to read file from application bundle
						dbFile = File.applicationStorageDirectory.resolvePath(dbName);
						if (!dbFile.exists) {
							//lastly try opening from documents directory
							dbFile = File.documentsDirectory.resolvePath(dbName);
						}
					//}
				} catch (err:Error) {
					dbFile = null;
				}
				
				//we found the DB, let's open it
				if (dbFile != null && dbFile.exists) {
					conn.open(dbFile, SQLMode.READ);
					connectionHash[dbName] = conn;
				} else {
					//could not open any referenced database
					//so null out connection
					conn = null;
				}
			}
			
			return conn;
		}

		private function saveTile(imgByteArray:ByteArray):void {
			//load the bytes retrieved from SQLite
			this.loadBytes(imgByteArray);
		}
		
		override public function load(request:URLRequest, context:LoaderContext=null):void {
			var urlScheme:String = request.url.replace(/:\/\/.*/,"");
			
			_urlRequest = request;
			_loaderUrl = request.url; //set the URL so others can access it
			if (urlScheme.match(MBTilesMapProvider.MBTILES_URL_SCHEME)) {
				loadMBTile(request);
			} else {
				super.load(request, context);	
			}
		}
		
		//
		// Getters & Setters
		
//		private function get isMBTiles():Boolean {
//			
//		}
		
		public function get loaderContent():DisplayObject {
			return this._loaderContent;
		}
		
		public function get loaderUrl():String {
			return this._loaderUrl;
		}
		
	}
}