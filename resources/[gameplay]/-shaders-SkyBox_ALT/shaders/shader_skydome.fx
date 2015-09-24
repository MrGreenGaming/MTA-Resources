// shader_skydome.fx v2.5
// Author: Ren712/AngerMAN

float4x4 gWorldViewProjection : WORLDVIEWPROJECTION;
float pi = 3.141592653589793;

texture gTEX;
float3 gObjScale = (1,1,1);
float3 gTexScale = (1,1,1);
float4 gSkyBott = (1,0,0,1);
bool gFadeEffect = false;
float gSkyVis = 0.5;
float gColorAdd = 0;
float gColorPow = 1;
float gAlpha = 1;
bool makeAngular=false;
//---------------------------------------------------------------------
//-- Sampler for the main texture (needed for pixel shaders)
//---------------------------------------------------------------------

sampler texMap = sampler_state
{
	Texture = (gTEX);
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = None;
    AddressU = Wrap;
    AddressV = Wrap;
};

//---------------------------------------------------------------------
//-- Structure of data sent to the vertex shader
//--------------------------------------------------------------------- 
 
 struct VSInput
{
    float4 Position : POSITION; 
    float3 TexCoord : TEXCOORD0;
};

//---------------------------------------------------------------------
//-- Structure of data sent to the pixel shader ( from the vertex shader )
//---------------------------------------------------------------------

struct PSInput
{
    float4 Position : POSITION; 
    float3 TexCoord : TEXCOORD0;
    float DistFade : TEXCOORD1;	
};

	
//-----------------------------------------------------------------------------
//-- VertexShader
//-----------------------------------------------------------------------------
PSInput VertexShaderSB(VSInput VS)
{
    PSInput PS = (PSInput)0;
    float origPosZ = VS.Position.z;
    VS.Position.xy *= gObjScale.xy;
    VS.Position.z *= gObjScale.z;
    PS.Position = mul(VS.Position, gWorldViewProjection);
    PS.TexCoord = VS.TexCoord.xyz;
    if (!gFadeEffect) { PS.DistFade = 1; }
    else {PS.DistFade = abs(origPosZ*gSkyVis);}
    return PS;
}

// original code from
// https://github.com/notlion/streetview-stereographic/blob/master/index.html
// translated to hlsl and reconfigured by me.

float2 angularTEX(float2 texCoords)
{
    float2 rads=float2(pi*2.0,-pi*0.5);
    texCoords.xy=2*(texCoords.xy-0.5);
    // Project to Sphere
    float x2y2 =(texCoords.x * texCoords.x + texCoords.y * texCoords.y);
    float3 sphere_pnt = float3(texCoords.x,texCoords.y, x2y2- 1.0 ) / (x2y2+ 1.0 );
    // Convert to Spherical Coordinates
    float r = length(sphere_pnt);
    float lon =atan2(sphere_pnt.x, sphere_pnt.y); 
    float lat = acos(sphere_pnt.z/ r);
    return float2(lon, lat)/ rads;
}

//-----------------------------------------------------------------------------
//-- PixelShader
//-----------------------------------------------------------------------------

float4 PixelShaderSB(PSInput PS) : COLOR0
{	
    float3 TexCoord = PS.TexCoord.xyz;
    if (makeAngular==true) {TexCoord.xy = angularTEX(TexCoord.xy);}
    float4 Tex = tex2D(texMap, TexCoord*gTexScale);
    float4 outPut = float4(pow(Tex.rgb+gColorAdd,gColorPow),Tex.a*gAlpha);
    float fadeValue = saturate(PS.DistFade);
    outPut = lerp(gSkyBott,outPut,fadeValue);
    return outPut;
}


////////////////////////////////////////////////////////////
//////////////////////////////// TECHNIQUES ////////////////
////////////////////////////////////////////////////////////
technique skybox_alt
{	
	pass P0
    {
        AlphaRef = 1;
        AlphaBlendEnable = TRUE;
        VertexShader = compile vs_2_0 VertexShaderSB();
        PixelShader = compile ps_2_0 PixelShaderSB();
    }
	
}
