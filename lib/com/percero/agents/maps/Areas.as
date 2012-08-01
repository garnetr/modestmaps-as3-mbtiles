package com.percero.agents.maps
{
	[Bindable]
	public class Areas
	{
		public static function getAreas(areaMeters2 : Number) : Areas {
			var areaHectares : Number = areaMeters2 / MapUtils.meters2PerHectare;
			var areaKm2 : Number = areaMeters2 / MapUtils.metersPerKm / MapUtils.metersPerKm;
			var areaFeet2 : Number = areaMeters2 * MapUtils.feetPerMeter * MapUtils.feetPerMeter;
			var areaMiles2 : Number = areaFeet2 / MapUtils.feetPerMile / MapUtils.feetPerMile;
			var areaAcres : Number = areaMiles2 * MapUtils.acresPerMile2;
			
			var result : Areas = new Areas();
			result.meters = areaMeters2;
			result.hectares = areaHectares;
			result.kilometers = areaKm2;
			result.feet = areaFeet2;
			result.acres = areaAcres;
			result.miles = areaMiles2;
			
			return result;
		}

		public var meters:Number;
		public var hectares:Number;
		public var kilometers:Number;
		public var feet:Number;
		public var acres:Number;
		public var miles:Number;
		
	}
}