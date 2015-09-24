//
//-- Stuff for reading depth buffer
//
//-- Reading depth buffer supported by:
//--   NVidia - from GeForce 6 (2004)
//--   Radeon - from 9500      (2002)
//--   Intel  - from G45       (2008)
//
//-- Sources:
//-- http://obge.paradice-insight.us/wiki/Internals_%28Effects%29
//-- http://www.gamasutra.com/blogs/BranoKemen/20090812/2725/Logarithmic_Depth_Buffer.php
//-- http://mynameismjp.wordpress.com/2009/05/05/reconstructing-position-from-depth-continued/
//-- 

float sFadeStart = 1;
float sFadeEnd = 700;
float sFarClip = 1000;
float sMaxCut = true;
float sMaxCutBlur = 0.5;

#include "mta-helper.fx"
//-- These two are set by MTA
texture gDepthBuffer : DEPTHBUFFER;
matrix gProjectionMainScene : PROJECTION_MAIN_SCENE;
 
sampler SamplerDepth = sampler_state
{
    Texture     = (gDepthBuffer);
    AddressU    = Clamp;
    AddressV    = Clamp;
};
 
//---------------------------------------------------------------------
// Structure of data sent to the pixel shader ( from the vertex shader )
//---------------------------------------------------------------------
struct PSInput
{
  float4 Position : POSITION0;
  float2 TexCoord : TEXCOORD0;
};
 
//-----------------------------------------------------------------------------
//-- Get value from the depth buffer
//-- Uses define set at compile time to handle RAWZ special case (which will use up a few more slots)
//-----------------------------------------------------------------------------
float FetchDepthBufferValue( float2 uv )
{
    float4 texel = tex2D(SamplerDepth, uv);
#if IS_DEPTHBUFFER_RAWZ
    float3 rawval = floor(255.0 * texel.arg + 0.5);
    float3 valueScaler = float3(0.996093809371817670572857294849, 0.0038909914428586627756752238080039, 1.5199185323666651467481343000015e-5);
    return dot(rawval, valueScaler / 255.0);
#else
    return texel.r;
#endif
}
 
//-----------------------------------------------------------------------------
//-- Use the last scene projecion matrix to linearize the depth value a bit more
//-----------------------------------------------------------------------------
float Linearize(float posZ)
{
    return gProjectionMainScene[3][2] / (posZ - gProjectionMainScene[2][2]);
}

//-----------------------------------------------------------------------------
//-- Type: Pixel shader
//-----------------------------------------------------------------------------
float4 PS_Example( PSInput In ) : COLOR
{
	float2 texCoords = In.TexCoord.xy;

    float depthValue = Linearize( FetchDepthBufferValue( texCoords.xy ) );
    float depthFucus = Linearize( FetchDepthBufferValue( float2(0.5,0.5) ) );

	float depth = MTAUnlerp( sFadeStart, sFadeEnd, depthValue );
	depthFucus = MTAUnlerp( sFadeStart, sFadeEnd, depthFucus );
	
    float4 OutColor = 0;
    OutColor.g = depth;
	OutColor.r= depthFucus;
	if (OutColor.g>1) {OutColor.b=OutColor.g-1;}	
    OutColor.a = 1;
    if (sMaxCut) {if (depthValue > sFarClip ) {OutColor.g = sMaxCutBlur;}}
    return saturate(OutColor);
}
 
//-----------------------------------------------------------------------------
//-- Techniques
//-----------------------------------------------------------------------------
 
//
//-- Use any readable depthbuffer format
//
technique yes_effect
{
    pass P0
    {
        PixelShader  = compile ps_2_0 PS_Example();
    }
}
 
 
//
//-- If no depthbuffer support, do nothing
//
technique no_effect
{
    pass P0
    {
    }
}