/**
 * MapProvider for Open Street Map data.
 * 
 * @author migurski
 * $Id: OpenStreetMapProvider.as 647 2008-08-25 23:38:15Z tom $
 */
package com.modestmaps.mapproviders
{ 
	import com.modestmaps.core.Coordinate;
	
	public class MapQuestOpenAerialMapProvider
		extends AbstractMapProvider
		implements IMapProvider
	{
	    public function MapQuestOpenAerialMapProvider(minZoom:int=MIN_ZOOM, maxZoom:int=MAX_ZOOM)
        {
            super(minZoom, maxZoom);
        }

	    public function toString() : String
	    {
	        return "MAP_QUEST_OPEN_AERIAL";
	    }
	
	    public function getTileUrls(coord:Coordinate):Array
	    {
	        var sourceCoord:Coordinate = sourceCoordinate(coord);
	        return [ 'http://oatile3.mqcdn.com/tiles/1.0.0/sat/'+(sourceCoord.zoom)+'/'+(sourceCoord.column)+'/'+(sourceCoord.row)+'.png' ];
	    }
	    
	}
}