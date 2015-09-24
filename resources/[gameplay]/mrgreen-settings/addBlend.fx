//
// Example shader - addBlend.fx
//
// Add pixels to render target
//

//---------------------------------------------------------------------
// addBlend settings
//---------------------------------------------------------------------
texture gTex0 : TEX0;


//-----------------------------------------------------------------------------
// Techniques
//-----------------------------------------------------------------------------
technique tec0
{
    pass P0
    {
        SrcBlend			= SRCALPHA;
        DestBlend			= ONE;

        // Set up texture stage 0
        Texture[0] = gTex0;
    }
}
