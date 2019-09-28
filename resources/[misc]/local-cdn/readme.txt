This resource acts as aa local CDN for local CEF browsers.
All it does is adding css/js/fonts files so it can be re-used so duplicate files in different resources are not necessary anymore.

HOW TO USE
Add a file to the appropriate folder and add it to meta.xml. 
Include (<include />) this resource in the resource using the CEF browser. 
Refer to these files as "http://mta/local-cdn/folder/file.ext" inside your js/html files.