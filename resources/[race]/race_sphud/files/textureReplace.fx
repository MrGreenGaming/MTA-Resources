 
//textureReplace.fx shader file. Add this in meta as <file src="textureReplace.fx" />
texture tex;
 
technique tech
{
    pass p0
    {
        Texture[0] = tex;
    }
}
 