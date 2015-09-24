//
// Example shader - blurH.fx
//
// Horizontal blur
//

//---------------------------------------------------------------------
// blurH settings
//---------------------------------------------------------------------
float gBloom : BLOOM = 1;
texture gTex0 : TEX0;
float2 gTex0Size : TEX0SIZE;


//---------------------------------------------------------------------
// These parameters are set by MTA whenever a shader is drawn
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
sampler Sampler0 = sampler_state
{
    Texture         = (gTex0);
    MinFilter       = Linear;
    MagFilter       = Linear;
    MipFilter       = Linear;
};


//---------------------------------------------------------------------
// Structure of data sent to the vertex shader
//---------------------------------------------------------------------
struct VertexShaderInput
{
    float3 Position : POSITION;
    float4 Diffuse : COLOR0;
    float2 TexCoord0 : TEXCOORD0;
};

//---------------------------------------------------------------------
// Structure of data sent to the pixel shader ( from the vertex shader )
//---------------------------------------------------------------------
struct PixelShaderInput
{
    float4 Position : POSITION;
    float4 Diffuse : COLOR0;
    float2 TexCoord0: TEXCOORD0;
};


//------------------------------------------------------------------------------------------
// VertexShaderFunction
//------------------------------------------------------------------------------------------
PixelShaderInput VertexShaderFunction(VertexShaderInput In)
{
    PixelShaderInput Out = (PixelShaderInput)0;

    Out.Position = mul(float4(In.Position, 1), gWorldViewProjection);
    Out.Diffuse = In.Diffuse;
    Out.TexCoord0 = In.TexCoord0;

    return Out;
}


//------------------------------------------------------------------------------------------
// PixelShaderFunction
//------------------------------------------------------------------------------------------
float4 PixelShaderFunction(PixelShaderInput In) : COLOR0
{
    float4 Color = 0;

    float2 coord;
    coord.y = In.TexCoord0.y;

    for(int i = 0; i < 13; ++i)
    {
        coord.x = In.TexCoord0.x + Kernel[i]/gTex0Size.x;
        Color += tex2D(Sampler0, coord.xy) * Weights[i] * gBloom;
    }

    Color = Color * In.Diffuse;
    Color.a = 1;
    return Color;  
}



//-----------------------------------------------------------------------------
// Techniques
//-----------------------------------------------------------------------------
technique tec0
{
    pass P0
    {
        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader  = compile ps_2_0 PixelShaderFunction();
    }
}


technique fallback
{
    pass P0
    {
    }
}

