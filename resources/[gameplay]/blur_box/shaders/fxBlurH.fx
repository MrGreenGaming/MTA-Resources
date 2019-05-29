//
// fxBlurV.fx
//

//---------------------------------------------------------------------
// blurV settings
//---------------------------------------------------------------------
texture sTex0 : TEX0;
float2 TexSize;
float gBlurFac = 1;

//---------------------------------------------------------------------
// Include some common stuff
//---------------------------------------------------------------------
float4x4 gWorldViewProjection : WORLDVIEWPROJECTION;

//-----------------------------------------------------------------------------
// Static data
//-----------------------------------------------------------------------------
static const float Kernel[13] = {-6, -5,     -4,     -3,     -2,     -1,     0,      1,      2,      3,      4,      5,      6};
static const float Weights[13] = {      0.002216,       0.008764,       0.026995,       0.064759,       0.120985,       0.176033,       0.199471,       0.176033,       0.120985,       0.064759,       0.026995,       0.008764,       0.002216};

//---------------------------------------------------------------------
// Sampler for the main texture
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
    PS.Position = mul( float4(VS.Position,1),gWorldViewProjection );

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

    float2 coord;
    coord.y = PS.TexCoord.y;

    for(int i = 0; i < 13; ++i)
    {
        coord.x = PS.TexCoord.x + (gBlurFac * Kernel[i])/TexSize.x;
        Color += tex2D(Sampler0, coord.xy) * Weights[i];
    }

    Color = Color * PS.Diffuse;
    Color.a = 1;
    return Color;
}

//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique fxBlurh
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
