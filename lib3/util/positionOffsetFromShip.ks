{
	local geoOffsetFromShip is import("util/geoOffsetFromShip").
	export({
		parameter x, y.
		local point is geoOffsetFromShip(x, y).
		return point:altitudePosition(point:terrainHeight).
	}).
}