float3 sLumPixel=float3(0,0,0);
float4x4 gWorldViewProjection : WORLDVIEWPROJECTION;

//---------------------------------------------------------------------
// Settings
//---------------------------------------------------------------------
texture sBaseTexture;
texture sPaletteTexture;

//---------------------------------------------------------------------
// Sampler
//---------------------------------------------------------------------
sampler BaseSampler = sampler_state
{
    Texture = (sBaseTexture);
    AddressU = Mirror;
    AddressV = Mirror;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = None;
};


sampler PaletteSampler = sampler_state
{
    Texture = (sPaletteTexture);
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = Clamp;
    AddressV  = Clamp;
    SRGBTexture = FALSE;
    MaxMipLevel = 0;
    MipMapLodBias = 0;
};


//---------------------------------------------------------------------
// Structure of data sent to the pixel shader ( from the vertex shader )
//---------------------------------------------------------------------
struct VSInput
{
    float3 Position : POSITION0;
    float2 TexCoord : TEXCOORD0;
};

struct PSInput
{
    float4 Position : POSITION0;
    float2 TexCoord : TEXCOORD0;
};
 
//------------------------------------------------------------------------------------------
// VertexShaderFunction
//------------------------------------------------------------------------------------------

PSInput VertexShaderFunction(VSInput VS)
{
    PSInput PS = (PSInput)0;
    PS.Position = mul(float4(VS.Position, 1), gWorldViewProjection);
    PS.TexCoord = VS.TexCoord;
    return PS;
}


//------------------------------------------------------------------------------------------
// PixelShaderFunction
//------------------------------------------------------------------------------------------
float4 PixelShaderFunctionP2(PSInput PS) : COLOR0
{	
    float4 color = tex2D(BaseSampler,PS.TexCoord);
    float3 brightness =sLumPixel;
    float3 palette;
    float4 uvsrc = 0.0; 
    uvsrc.y = brightness.r;
    uvsrc.x = color.r;
    palette.r = tex2D(PaletteSampler, uvsrc).r; 
    uvsrc.x = color.g;
    uvsrc.y = brightness.g;
    palette.g = tex2D(PaletteSampler, uvsrc).g;
    uvsrc.x = color.b;
    uvsrc.y = brightness.b;
    palette.b = tex2D(PaletteSampler, uvsrc).b;
    color.rgb = palette.rgb;
    return saturate(color);
}


float4 PixelShaderFunctionP3(PSInput PS) : COLOR0
{
    float4 color = tex2D(BaseSampler,PS.TexCoord);
    float3 brightness =sLumPixel;
    float3 palette;
    float4 uvsrc=0.0;
    uvsrc.y=brightness.r;
    uvsrc.x=color.r;
    palette.r=tex2Dlod(PaletteSampler, uvsrc).r;
    uvsrc.x=color.g;
    uvsrc.y=brightness.g;
    palette.g=tex2Dlod(PaletteSampler, uvsrc).g;
    uvsrc.x=color.b;
    uvsrc.y=brightness.b;
    palette.b=tex2Dlod(PaletteSampler, uvsrc).b;
    color.rgb=palette.rgb;
    return saturate(color);
}
//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique tec0_PS30
{
    pass P0
    {
        VertexShader = compile vs_3_0 VertexShaderFunction();
        PixelShader = compile ps_3_0 PixelShaderFunctionP3();
    }
}

technique tec0_PS20
{
    pass P0
    {
        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader = compile ps_2_0 PixelShaderFunctionP2();
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
