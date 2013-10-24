package com.modestmaps.mapproviders.mapbox
{
	import com.modestmaps.core.Coordinate;
	import com.modestmaps.mapproviders.AbstractMapProvider;
	import com.modestmaps.mapproviders.IMapProvider;
	
	public class MBTilesMapProvider extends AbstractMapProvider implements IMapProvider
	{
		//private static const MBTILES_EXTENTION:String = ".mbtiles";
		public static const MBTILES_URL_SCHEME:String = "mbtiles";
		
		private var _dbName:String;
		
		public function MBTilesMapProvider(databaseName:String = null, minZoom:int=MIN_ZOOM, maxZoom:int=MAX_ZOOM)
		{
			super(minZoom, maxZoom);
			this._dbName = databaseName;
		}
		
		public function getTileUrls(coord:Coordinate):Array
		{
			var sourceCoord:Coordinate = sourceCoordinate(coord);
			if (sourceCoord.row < 0 || sourceCoord.row >= Math.pow(2, coord.zoom)) {
				return [];
			} else if (this._dbName == null) {
				//the database name MUST be set
				return [];
			}
			
			var urlStr:String = formatUrl(_dbName, sourceCoord.zoom, sourceCoord.row, sourceCoord.column);
			//trace(urlStr);
			return [ urlStr ];
		}
		
		public function toString():String
		{
			return "MBTILES_MAP";
		}
		
		/**
		 * Formats the URL with the following format:
		 * mbtiles://?zoom=(val)&col=(val)&row=(val)&dbName=(val)
		 * 
		 * Where (val) is substituted with appropriate values
		 * 
		 * This is a non-standard URL and must be handled differently 
		 * in TilePainter class
		 * 
		 * @param dbName - path to mbtiles database
		 * @param zoom - zoom level
		 * @param row - tile row
		 * @param col - tile column
		 * 
		 * @returns mbtiles formatted URL
		 */
		private function formatUrl(dbName:String, zoom:Number, row:Number, col:Number):String {
			if (dbName == null) {
				return null;
			}
			
			var urlStr:String;
			urlStr = MBTILES_URL_SCHEME + "://?zoom=" + zoom + "&col=" + col + "&row=" + row + 
					 "&dbName=" + dbName;
			
			return urlStr;
		}

		//
		// Getters & Setters
		public function get dbName():String
		{
			return _dbName;
		}

		public function set dbName(value:String):void
		{
			_dbName = value;
		}

	}
}