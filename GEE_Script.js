// 1. Load your data
var countries = ee.FeatureCollection('FAO/GAUL_SIMPLIFIED_500m/2015/level0'); // Standard country boundaries
var binaryRaster =  ee.Image('WRI/SBTN/naturalLands/v1_1/2020').select('natural'); // Your 0,1 raster

// 2. Create an area image (units: m2)
var areaImg = ee.Image.pixelArea();

// 3. Create an image of the area of only Class 1
var class1AreaImg = areaImg.updateMask(binaryRaster.eq(1));

// 4. Summarise areas within country boundaries
// We combine two reducers (sum of Class 1 and total area) for efficiency
var countryStats = class1AreaImg.addBands(areaImg).reduceRegions({
  collection: countries,
  reducer: ee.Reducer.sum().forEach(['area_1', 'area_total']),
  scale: 30,
  crs: 'EPSG:4326'
});

// 5. Calculate the proportion
var finalTable = countryStats.map(function(feature) {
  var area1 = ee.Number(feature.get('area_1'));
  var areaTotal = ee.Number(feature.get('area_total'));
  
  // Calculate proportion (handle division by zero if necessary)
  var proportion = ee.Algorithms.If(
    areaTotal.gt(0),
    area1.divide(areaTotal),
    0
  );
  
  return feature.select(['ADM0_CODE', 'ADM0_NAME','Shape_Area']) // Keep name/code columns
                .set({
                  'class_1_proportion': proportion,
                  'total_area_m2': areaTotal,
                  'class_1_area_m2': area1
                });
});

// 6. Export to CSV
Export.table.toDrive({
  collection: finalTable,
  description: 'Country_Class1_Proportions',
  fileFormat: 'CSV',
  selectors: ['ADM0_CODE', 'ADM0_NAME','Shape_Area', 'class_1_proportion', 'class_1_area_m2', 'total_area_m2']
});
