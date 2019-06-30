%Add borders & coasts
%Mostly a helper script for plotBlankMap and its spawn

%If desired, add provincial boundaries for certain countries
hold on;
addprovboundaries=0;
if addprovboundaries==1
    load china.province.mat;plotm(lat,long,'color',colors('gray'));
    S=shaperead('IndiaStates.shp','UseGeoCoords',true);geoshow(S,'FaceColor',co,'edgecolor',colors('gray'),'FaceAlpha',0);
    S=shaperead('RussiaStates.shp','UseGeoCoords',true);geoshow(S,'FaceColor',co,'edgecolor',colors('gray'),'FaceAlpha',0);
    S=shaperead('AustraliaStates.shp','UseGeoCoords',true);geoshow(S,'FaceColor',co,'edgecolor',colors('gray'),'FaceAlpha',0);
    S=shaperead('BrazilStates.shp','UseGeoCoords',true);geoshow(S,'FaceColor',co,'edgecolor',colors('gray'),'FaceAlpha',0);
    S=shaperead('CanadaProvinces.shp','UseGeoCoords',true);geoshow(S,'FaceColor',co,'edgecolor',colors('gray'),'FaceAlpha',0);
    S=shaperead('MexicoStates.shp','UseGeoCoords',true);geoshow(S,'FaceColor',co,'edgecolor',colors('gray'),'FaceAlpha',0);
end


load coast;
states=shaperead('usastatelo', 'UseGeoCoords', true);
%Gray vs black US state borders
geoshow(states, 'DisplayType', 'polygon','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
%geoshow(states, 'DisplayType', 'polygon','facecolor',co,'edgecolor',colors('gray'),'FaceAlpha',0);

%Other countries to always add
borders('Canada','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
borders('Mexico','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
borders('Cuba','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
borders('Bahamas','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
borders('United States','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);

if strcmp(region,'nnh') || strcmp(region,'north-atlantic') || strcmp(region,'world') || ...
        strcmp(region,'world50s50n') || strcmp(region,'placesivebeen') || strcmp(region,'placeswevebeen') ||...
        strcmp(region,'centeredonpoint') || strcmp(region,'mainland-europe') || strcmp(region,'middle-east') ||...
        strcmp(region,'western-europe') || strcmp(region,'eastern-europe') || strcmp(region,'middle-east-india') ||...
        strcmp(region,'south-asia') || strcmp(region,'south-asia-larger') || strcmp(region,'persian-gulf') || ...
        strcmp(region,'middle-east-small')
    borders('Japan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Korea, Republic of','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Syrian Arab Republic','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Korea, Democratic People''s Republic of','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Greenland','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Puerto Rico','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('China','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Mongolia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Nepal','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('India','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Bhutan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Russia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Kazakhstan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Tajikistan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Turkmenistan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Uzbekistan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Kyrgyzstan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Afghanistan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Pakistan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Iran Islamic Republic of','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Iraq','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Kuwait','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Lebanon','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Israel','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Jordan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Azerbaijan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Georgia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Armenia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Turkey','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Egypt','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Libyan Arab Jamahiriya','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Algeria','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Tunisia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Morocco','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Cyprus','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Ukraine','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Romania','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Bulgaria','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Greece','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Albania','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Montenegro','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Croatia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Serbia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Bosnia and Herzegovina','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Hungary','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Slovakia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Belarus','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Lithuania','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Latvia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Estonia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Finland','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Sweden','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Norway','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Poland','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Czech Republic','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Austria','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Italy','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Switzerland','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('France','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Germany','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Denmark','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Netherlands','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Belgium','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('United Kingdom','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Ireland','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Spain','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Portugal','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Iceland','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Luxembourg','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Liechtenstein','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Monaco','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('San Marino','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Andorra','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Malta','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
end
if strcmp(region,'north-america') || strcmp(region,'usa-full') || strcmp(region,'usaminushawaii-tight') || ...
        strcmp(region,'usa-exp') || strcmp(region,'world') || strcmp(region,'world50s50n') ||...
        strcmp(region,'placesivebeen') || strcmp(region,'placeswevebeen') || ...
        strcmp(region,'greater-eastern-usa') || strcmp(region,'centeredonpoint') || strcmp(region,'na-sw')
    borders('Jamaica','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Greenland','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Haiti','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Dominican Republic','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Russia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Guatemala','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Honduras','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('El Salvador','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Belize','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Dominica','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('British Virgin Islands','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Bermuda','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
end
if strcmp(region,'world') || strcmp(region,'world50s50n') ||...
        strcmp(region,'placesivebeen') || strcmp(region,'placeswevebeen') || strcmp(region,'centeredonpoint') ||...
        strcmp(region,'middle-east') || strcmp(region,'middle-east-india') || strcmp(region,'south-asia') ||...
        strcmp(region,'south-asia-larger') || strcmp(region,'persian-gulf') || strcmp(region,'middle-east-small')
    borders('Antigua and Barbuda','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Barbados','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Grenada','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Saint Kitts and Nevis','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Saint Lucia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Saint Vincent and the Grenadines','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Trinidad and Tobago','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Guinea-Bissau','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Equatorial Guinea','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Nicaragua','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Costa Rica','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Panama','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Colombia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Venezuela','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Suriname','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Guyana','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Brazil','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Ecuador','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Peru','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Bolivia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Chile','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Paraguay','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Argentina','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Uruguay','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Chad','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Senegal','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Mali','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Mauritania','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Niger','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Nigeria','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Ghana','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Togo','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Benin','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Liberia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Guinea','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Cameroon','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Congo','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Gabon','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Democratic Republic of the Congo','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Angola','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Namibia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Botswana','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('South Africa','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Swaziland','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Madagascar','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Mozambique','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Malawi','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Gambia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Zambia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Zimbabwe','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Kenya','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('United Republic of Tanzania','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Uganda','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Rwanda','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Burundi','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Ethiopia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Somalia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Oman','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Sudan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Central African Republic','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Qatar','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Western Sahara','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Yemen','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Saudi Arabia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('United Arab Emirates','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Bahrain','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Sri Lanka','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Thailand','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Burma','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Cambodia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Cote d''Ivoire','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Cape Verde','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Sierra Leone','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Burkina Faso','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Djibouti','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Eritrea','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
end
if strcmp(region,'world') || strcmp(region,'world50s50n') ||...
        strcmp(region,'centeredonpoint') || strcmp(region,'australia') || ...
        strcmp(region,'middle-east-india') || strcmp(region,'south-asia') || strcmp(region,'south-asia-larger')
    borders('Viet Nam','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Philippines','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Malaysia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Taiwan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Indonesia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Singapore','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Comoros','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Papua New Guinea','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Australia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('New Zealand','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Antarctica','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Solomon Islands','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Fiji','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Micronesia, Federated States of','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Vanuatu','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Tonga','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Tuvalu','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Lesotho','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Bangladesh','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Brunei Darussalam','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Samoa','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('American Samoa','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('New Caledonia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('British Indian Ocean Territory','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Reunion','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Seychelles','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Palau','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Nauru','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Kiribati','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Lao People''s Democratic Republic','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Guam','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('South Georgia South Sandwich Islands','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Marshall Islands','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Sao Tome and Principe','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('French Southern and Antarctic Lands','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Cocos Keeling Islands','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Commonwealth of the Northern Mariana Islands','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Saint Martin','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
end




