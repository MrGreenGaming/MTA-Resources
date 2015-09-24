var _ms_XMLHttpRequest_ActiveX="";function encode(uri){if(encodeURIComponent){return encodeURIComponent(uri);}
if(escape){return escape(uri);}}
function decode(uri){uri=uri.replace(/\+/g,' ');if(decodeURIComponent){return decodeURIComponent(uri);}
if(unescape){return unescape(uri);}
return uri;}
function AJAXRequest(method,url,data,process,async,dosend){var self=this;if(window.XMLHttpRequest){self.AJAX=new XMLHttpRequest();}else if(window.ActiveXObject){if(_ms_XMLHttpRequest_ActiveX){self.AJAX=new ActiveXObject(_ms_XMLHttpRequest_ActiveX);}else{var versions=["Msxml2.XMLHTTP.7.0","Msxml2.XMLHTTP.6.0","Msxml2.XMLHTTP.5.0","Msxml2.XMLHTTP.4.0","MSXML2.XMLHTTP.3.0","MSXML2.XMLHTTP","Microsoft.XMLHTTP"];for(var i=0;i<versions.length;i++){try{self.AJAX=new ActiveXObject(versions[i]);if(self.AJAX){_ms_XMLHttpRequest_ActiveX=versions[i];break;}}
catch(objException){};}
;}}
self.process=process;self.AJAX.onreadystatechange=function(){self.process(self.AJAX);}
if(!method){method="POST";}
method=method.toUpperCase();if(typeof async=='undefined'||async==null){async=true;}
self.AJAX.open(method,url,async);if(method=="POST"){self.AJAX.setRequestHeader("Content-Type","application/x-www-form-urlencoded");self.AJAX.setRequestHeader("Method","POST "+url+"HTTP/1.1");}
if(dosend||typeof dosend=='undefined'){if(!data)data="";self.AJAX.send(data);}
return self.AJAX;}
function getKeyCode(e)
{if(window.event)
{keynum=e.keyCode;}
else if(e.which)
{keynum=e.which;}
return keynum;}
var elementManager=new ElementManager();function ElementManager(){this.elements=new Array();this.get=function(id){for(i=0;i<this.elements.length;i++)
{var element=this.elements[i];if(element.id!=null)
{if(element.id==id)
{return element;}}}
var newElement=new Element(id);this.elements[this.elements.length]=newElement;return newElement;}}
var resourceManager=new ResourceManager();function ResourceManager(){this.resources=new Array();this.get=function(name){for(i=0;i<this.resources.length;i++)
{var resource=this.resources[i];if(resource.name!=null)
{if(resource.name==name)
{return resource;}}}
var newResource=new Resource(name);this.resources[this.resources.length]=newResource;return newResource;}}
function Element(id){this.id=id;this.toJSONString=function(){return'"^E^'+id+'"';}}
function Resource(name){this.name=name;this.toJSONString=function(){return'"^R^'+name+'"';}}
var values;var usePOST=true;function callFunction(resourceName,functionName,returnFunction,errorFunction,args)
{var url="/"+resourceName+"/call/"+functionName;var data="";var method="GET";if(usePOST==true)
{data=args.toJSONString();method="POST";}
else
{for(var i=0;i<args.length;i++)
{if(i!=0)
url+="&";else
url+="?";url+=i+"="+escape(args[i]);}}
new AJAXRequest(method,url,data,function(AJAX)
{if(AJAX.readyState==4){if(AJAX.status==200){if(returnFunction!=null)
{globalReturnTemp=returnFunction;{values=AJAX.responseText.parseJSON(function(key,value){if(typeof(value)=="string")
{if(value.indexOf('^E^')==0)
{return elementManager.get(value.substr(3));}
else if(value.indexOf('^R^')==0)
{return resourceManager.get(value.substr(3));}}
return value;});var argumentList="";for(i=0;i<values.length;i++)
{argumentList+="values["+i+"]";if(i!=values.length-1)
argumentList+=",";}
var funcCall="globalReturnTemp("+argumentList+");";eval(funcCall);values=null;return;}}
if(errorFunction!=null)
errorFunction(AJAX.responseText);return;}
if(errorFunction!=null)
errorFunction("ajax: "+AJAX.statusText);}}
,true);}