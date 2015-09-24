//
// Example shader - brightPass.fx
//
// Cut off pixels below threshold
//

//---------------------------------------------------------------------
// brightPass settings
//---------------------------------------------------------------------
texture gTex0 : TEX0;
float gCutoff : CUTOFF = 0.2;         // 0 - 1
float gPower : POWER  = 1;            // 1 - 5


//---------------------------------------------------------------------
// These parameters are set by MTA whenever a shader is drawn
//---------------------------------------------------------------------
float4x4 gWorldViewProjection : WORLDVIEWPROJECTION;


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
    float4 OutColor = 0;

	float4 texel = tex2D(Sampler0, In.TexCoord0);

    float lum = (texel.r + texel.g + texel.b)/3;

    float adj = saturate( lum - gCutoff );

    adj = adj / (1.01 - gCutoff);
    
    texel = texel * adj;
    texel = pow(texel, gPower);

    OutColor = texel;

	OutColor.a = 1;
	return OutColor;
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
