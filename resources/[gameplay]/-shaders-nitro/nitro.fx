//
// nitro.fx
//
// Author: NeXTreme


//---------------------------------------------------------------------
// Nitro settings
//---------------------------------------------------------------------
float4 gNitroColor = float4(255,255,255,150);


//---------------------------------------------------------------------
// These parameters are set by MTA whenever a shader is drawn
//---------------------------------------------------------------------
float4x4 gWorld : WORLD;
float4x4 gView : VIEW;
float4x4 gProjection : PROJECTION;


//------------------------------------------------------------------------------------------
// textureState - String value should be a texture number followed by 'Texture'
//------------------------------------------------------------------------------------------
texture gTexture0           < string textureState="0,Texture"; >;


//---------------------------------------------------------------------
// Sampler for the main texture
//---------------------------------------------------------------------
sampler texsampler = sampler_state
{
    Texture = (gTexture0);
};


//---------------------------------------------------------------------
// Structure of data sent to the vertex and pixel shaders
//---------------------------------------------------------------------
struct VertexShaderInput
{
    float3 Position : POSITION0;
    float4 Diffuse : COLOR0;
    float2 TexCoords : TEXCOORD0;
};

struct PixelShaderInput
{
    float4 Position  : POSITION;
    float4 Diffuse : COLOR0;
    float2 TexCoords : TEXCOORD0;
};


//------------------------------------------------------------------------------------------
// VertexShaderFunction
//------------------------------------------------------------------------------------------

PixelShaderInput VertexShaderFunction(VertexShaderInput In)
{
    PixelShaderInput Out = (PixelShaderInput)0;
	
	float4 posWorld = mul(float4(In.Position,1), gWorld);
    float4 posWorldView = mul(posWorld, gView);
    Out.Position = mul(posWorldView, gProjection);
	Out.TexCoords = In.TexCoords;
	
    Out.Diffuse = saturate(gNitroColor);
	
    return Out;
}


//------------------------------------------------------------------------------------------
// PixelShaderFunction
//------------------------------------------------------------------------------------------
float4 PixelShaderFunction(PixelShaderInput In) : COLOR0
{
	float4 texel = tex2D(texsampler, In.TexCoords);
	
	float4 finalColor = texel * In.Diffuse;
		
	finalColor *= 0.23;
	
    return finalColor;
}



//-----------------------------------------------------------------------------
// Techniques
//-----------------------------------------------------------------------------
technique nitro
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
