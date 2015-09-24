//
// dBlurV.fx
//

//---------------------------------------------------------------------
// blurV settings
//---------------------------------------------------------------------
texture sTex0 : TEX0;
texture sTex1 : TEX1;
float2 sTex0Size : TEX0SIZE;
float gblurFactor = 0.5;
bool gBrightBlur = true;
//---------------------------------------------------------------------
// Include some common stuff
//---------------------------------------------------------------------
#include "mta-helper.fx"

//-----------------------------------------------------------------------------
// Static data
//-----------------------------------------------------------------------------
static const float Kernel[13] = {-6, -5,     -4,     -3,     -2,     -1,     0,      1,      2,      3,      4,      5,      6};

//---------------------------------------------------------------------
// Samplers
//---------------------------------------------------------------------
sampler2D Sampler0 = sampler_state
{
    Texture         = (sTex0);
    MinFilter       = Linear;
    MagFilter       = Linear;
    MipFilter       = Linear;
    AddressU        = Mirror;
    AddressV        = Mirror;
};

sampler2D Sampler1 = sampler_state
{
    Texture         = (sTex1);
    MinFilter       = Linear;
    MagFilter       = Linear;
    MipFilter       = Linear;
    AddressU        = Mirror;
    AddressV        = Mirror;
};

//---------------------------------------------------------------------
// Structure of data sent to the vertex shader
//---------------------------------------------------------------------
struct VSInput
{
    float3 Position : POSITION0;
    float4 Diffuse : COLOR0;
    float2 TexCoord : TEXCOORD0;
};

//---------------------------------------------------------------------
// Structure of data sent to the pixel shader ( from the vertex shader )
//---------------------------------------------------------------------
struct PSInput
{
    float4 Position : POSITION0;
    float4 Diffuse : COLOR0;
    float2 TexCoord: TEXCOORD0;
};

//------------------------------------------------------------------------------------------
// VertexShaderFunction
//  1. Read from VS structure
//  2. Process
//  3. Write to PS structure
//------------------------------------------------------------------------------------------
PSInput VertexShaderFunction(VSInput VS)
{
    PSInput PS = (PSInput)0;

    // Calculate screen pos of vertex
    PS.Position = MTACalcScreenPosition ( VS.Position );

    // Pass through color and tex coord
    PS.Diffuse = VS.Diffuse;
    PS.TexCoord = VS.TexCoord;

    return PS;
}

//------------------------------------------------------------------------------------------
// PixelShaderFunction
//  1. Read from PS structure
//  2. Process
//  3. Return pixel color
//------------------------------------------------------------------------------------------
float4 PixelShaderFunction(PSInput PS) : COLOR0
{
    float4 Color = 0;
    float4 Texel = tex2D(Sampler0, PS.TexCoord);
    float4 Depth = tex2D(Sampler1, PS.TexCoord);
    float Bright = 1;
    if (gBrightBlur) {Bright = saturate(Texel.r + Texel.g + Texel.b ) * 0.9 + 0.1;}
    float2 coord;
    coord.y = PS.TexCoord.y;

    for(int i = 0; i < 13; ++i)
    {
        coord.x = PS.TexCoord.x + (Bright * Depth.g * gblurFactor * Kernel[i])/sTex0Size.x;
        Color += tex2D(Sampler0, coord.xy);
    }
	
    Color/=13;
    return Color * PS.Diffuse;
}

//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique blurh
{
    pass P0
    {
        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader  = compile ps_2_0 PixelShaderFunction();
    }
}

// Fallback
technique fallback
{
    pass P0
    {
        // Just draw normally
    }
}
