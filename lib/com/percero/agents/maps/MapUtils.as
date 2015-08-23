package com.percero.agents.maps
{
	import com.modestmaps.geo.Location;

	public class MapUtils
	{
		public static const degreesPerRadian : Number = 180.0 / Math.PI;
		public static const radiansPerDegree : Number = Math.PI / 180.0;

		public static const earthRadiusMeters : Number = 6367460.0;
		public static const metersPerDegree : Number = 2.0 * Math.PI * earthRadiusMeters / 360.0;

		public static const metersPerKm : Number = 1000.0;
		public static const meters2PerHectare : Number = 10000.0;
		public static const feetPerMeter : Number = 3.2808399;
		public static const feetPerMile : Number = 5280.0;
		public static const acresPerMile2 : Number = 640;

		public static function getAreas(areaMeters2 : Number) : Areas {
			return Areas.getAreas(areaMeters2);
		}
		
		public static function AreaMeters2(points : Array) : Number {
			var uniquePoints : Array = getUniquePoints(points);
			var areaMeters2 : Number = SphericalPolygonAreaMeters2(uniquePoints);
			if (areaMeters2 < 1000000.0)
				areaMeters2 = PlanarPolygonAreaMeters2(uniquePoints);
			
			return areaMeters2;
		}
		
		public static function PlanarPolygonAreaMeters2(points : Array) : Number {
			var a : Number = 0.0;
			
			if (points != null && points.length > 2)
			{
				for ( var i : int = 0; i < points.length; ++i) {
					var j : int = (i + 1) % points.length;
					var xi : Number = points[i].lon * metersPerDegree
						* Math.cos(points[i].lat * radiansPerDegree);
					var yi : Number = points[i].lat * metersPerDegree;
					var xj : Number = points[j].lon * metersPerDegree
						* Math.cos(points[j].lat * radiansPerDegree);
					var yj : Number = points[j].lat * metersPerDegree;
					a += xi * yj - xj * yi;
				}
				return Math.abs(a / 2.0);
			}
			else
				return 0.0;
		}

		public static function SphericalPolygonAreaMeters2(points : Array) : Number {
			var totalAngle : Number = 0.0;
			var i : int = 0;
			if (points != null && points.length > 2)
			{
				for (i = 0; i < points.length; ++i) {
					var j : int = (i + 1) % points.length;
					var k : int = (i + 2) % points.length;
					totalAngle += Angle(points[i], points[j], points[k]);
				}
				var planarTotalAngle : Number = (points.length - 2) * 180.0;
				var sphericalExcess : Number = totalAngle - planarTotalAngle;
				var result : Number = 0;
				if (sphericalExcess > 420.0) {
					totalAngle = points.length * 360.0 - totalAngle;
					sphericalExcess = totalAngle - planarTotalAngle;
				} else if (sphericalExcess > 300.0 && sphericalExcess < 420.0) {
					sphericalExcess = Math.abs(360.0 - sphericalExcess);
				}
				
				if (sphericalExcess <= 0) {
					result = 0;
				} else {
					result = sphericalExcess * radiansPerDegree * earthRadiusMeters
					* earthRadiusMeters;
				}
				return result;
			}
			else
				return 0.0;
		}
		
		public static function getUniquePoints(points : Array) : Array
		{
			var uniquePoints : Array = new Array();
			var prevPoint : Location;
			for(var i : int = 0; i < points.length; i++)
			{
				if (prevPoint == null)
				{
					prevPoint = points[i] as Location;
					uniquePoints.push(prevPoint);
				}
				else
				{
					var curPoint : Location = points[i] as Location;
					if(curPoint.lat == prevPoint.lat && curPoint.lon == prevPoint.lon)
						continue;
					else
					{
						prevPoint = points[i] as Location;
						uniquePoints.push(prevPoint);
					}
				}
			}
			
			return uniquePoints;
		}

		public static function Angle(p1 : Location, p2 : Location, p3 : Location) : Number {
			var bearing21 : Number = Bearing(p2, p1);
			var bearing23 : Number = Bearing(p2, p3);
			var angle : Number = bearing21 - bearing23;
			if (angle < 0.0)
				angle += 360.0;
			return angle;
		}
		
		public static function Bearing(from : Location, to : Location) : Number {
			var lat1 : Number = from.lat * radiansPerDegree;
			var lon1 : Number = from.lon * radiansPerDegree;
			var lat2 : Number = to.lat * radiansPerDegree;
			var lon2 : Number = to.lon * radiansPerDegree;
			var angle : Number = -Math.atan2(Math.sin(lon1 - lon2) * Math.cos(lat2), Math
				.cos(lat1)
				* Math.sin(lat2)
				- Math.sin(lat1)
				* Math.cos(lat2)
				* Math.cos(lon1 - lon2));
			if (angle < 0.0)
				angle += Math.PI * 2.0;
			angle = angle * degreesPerRadian;
			return angle;
		}
		
		public static function getCenterPoint(locations : Array) : Location
		{
			var lats : Number = 0.0;
			var lngs : Number = 0.0;
			var count : int = 0;
			
			for each(var nextLocation : Location in locations)
			{
				if (!isNaN(nextLocation.lat) && nextLocation.lat != 0.0 && !isNaN(nextLocation.lon) && nextLocation.lon != 0.0)
				{
					lats += nextLocation.lat;
					lngs += nextLocation.lon;
					count++;
				}
			}
			
			var lat : Number = NaN;
			var lng : Number = NaN;
			
			if (count > 0)
			{
				lat = lats / count;
				lng = lngs / count;
			}
			
			var result : Location = new Location(lat, lng);
			return result;
		}
	}
}