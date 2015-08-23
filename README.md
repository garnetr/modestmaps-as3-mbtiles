MB ModestMap
============
This is a fork of the ActionScript 3 [Modest Map](http://modestmaps.com) api. I am converting it to an AIR libary that will support an MBTiles map provider. The MBTiles format is an open spec developed by [MapBox](http://www.mapbox.com") that defines an efficient way to store raster tiles in an SQLite database. By storing map tiles locally, your maps can be accessible offline (without an internet connection) and can see a signifigant speed bost for the user experience.

The code is more of a proof of concept vs a well tested finished product so use at your own risk!

## Basic usage

To use an MBTiles enabled modest map build, you can either include the swc _(located in swc/bin/ModestMapsSWC.swc)_ or the source code located in the `lib` folder within your project. Be sure your mbtiles file is also included in the document root of your project and then add the following map sorce:

```
mbtiles://?zoom=(zoom_val)&col=(col_val)&row=(row_val)&dbName=(dbName_val)
```

For more information, read the documentation within docs, as it was updated with the `MBTilesMapProvider`.

