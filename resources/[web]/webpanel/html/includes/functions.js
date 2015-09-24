var user = "<* = getAccountName(user) *>";

String.prototype.htmlEntities = function () { return this.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); };

<*
includowane = {}
for k,v in pairs(getResourceExportedFunctions(getThisResource())) do
if includowane [ v ] == nil then
includowane [ v ] = true
*>
function <* = v *> () {
var args = new Array();
for ( var i = 0; i < arguments.length - 1 ; i++ )
{ args[i] = arguments[i]; }
var resultHandler = arguments[arguments.length-1];
callFunction ( "<* = getResourceName(getThisResource()) *>", "<* = v *>", resultHandler,
function ( error ) /* called if an error occurs, 'error' contains a text message of the error */
{
alert("An error occured while calling '<* = v *>':\n\n" + error);
},
args);
}
<*
end
end
*> 
