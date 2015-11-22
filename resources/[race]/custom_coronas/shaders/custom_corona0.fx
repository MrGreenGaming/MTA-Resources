//
// custom_corona0.fx
//

//-----------------------------------------------------------------------------
// Effect Settings
//-----------------------------------------------------------------------------
float2 gDistFade = float2(250,150);
float fDepthBias = 1;
float3 fCoronaPosition = float3(0,0,0);

//-----------------------------------------------------------------------------
// Include some common stuff
//-----------------------------------------------------------------------------
float4x4 gWorld : WORLD;
float4x4 gView : VIEW;
float4x4 gProjection : PROJECTION;
float3 gCameraPosition : CAMERAPOSITION;
int CUSTOMFLAGS <string skipUnusedParameters = "yes"; >;

//-----------------------------------------------------------------------------
// Texture
//-----------------------------------------------------------------------------
texture gCoronaTexture;

//-----------------------------------------------------------------------------
// Sampler Inputs
//-----------------------------------------------------------------------------
sampler Sampler0 = sampler_state
{
    Texture = (gCoronaTexture);
};

//-----------------------------------------------------------------------------
// Structure of data sent to the vertex shader
//-----------------------------------------------------------------------------
struct VSInput
{
    float4 Position : POSITION0;
    float4 Diffuse : COLOR0;
    float2 TexCoord : TEXCOORD0;
};

//-----------------------------------------------------------------------------
// Structure of data sent to the pixel shader ( from the vertex shader )
//-----------------------------------------------------------------------------
struct PSInput
{
    float4 Position : POSITION0;
    float4 Diffuse : COLOR0;
    float2 TexCoord : TEXCOORD0;
    float DistFactor : TEXCOORD1;
    float DistFade : TEXCOORD2;
};

//-----------------------------------------------------------------------------
// Returns a translation matrix
//-----------------------------------------------------------------------------
float4x4 makeTranslation (float3 pos)
{
    return float4x4(
                    1, 0, 0, 0,
                    0, 1, 0, 0,
					0, 0, 1, 0,
                    pos.x, pos.y, pos.z, 1
                    );
}

//-----------------------------------------------------------------------------
// MTAUnlerp
//-----------------------------------------------------------------------------
float MTAUnlerp( float from, float to, float pos )
{
    if ( from == to )
        return 1.0;
    else
        return ( pos - from ) / ( to - from );
}

//-----------------------------------------------------------------------------
// VertexShaderFunction
//  1. Read from VS structure
//  2. Process
//  3. Write to PS structure
//-----------------------------------------------------------------------------
PSInput VertexShaderFunction(VSInput VS)
{
    PSInput PS = (PSInput)0;
    float4 position = VS.Position;

    float4x4 posMat = makeTranslation( fCoronaPosition );
    float4x4 gWorldFix = mul( gWorld, posMat );

    float4x4 worldViewMatrix = mul( gWorldFix, gView );
    float4 worldViewPosition = float4( worldViewMatrix[3].xyz + position.xzy - fCoronaPosition.xzy , 1 );
    worldViewPosition.xyz += fDepthBias * 1.5 * mul( normalize( gCameraPosition - fCoronaPosition ), gView).xyz;
	
    float DistFromCam = distance( gCameraPosition, fCoronaPosition.xyz );
    PS.DistFade = MTAUnlerp ( gDistFade[0], gDistFade[1], DistFromCam );
    DistFromCam /= fDepthBias;
    PS.DistFactor = saturate( DistFromCam * 0.5 - 1.6 );	

    PS.Position = mul( worldViewPosition, gProjection );
    PS.TexCoord = float2( VS.TexCoord.x, 1 - VS.TexCoord.y );
    PS.Diffuse = VS.Diffuse;
    return PS;
} 

//-----------------------------------------------------------------------------
//-- PixelShaderExample
//--  1. Read from PS structure
//--  2. Process
//--  3. Return pixel color
//-----------------------------------------------------------------------------
float4 PixelShaderFunction(PSInput PS) : COLOR0
{
    float4 color = tex2D( Sampler0 , PS.TexCoord.xy );
    color.rgb = pow( color.rgb * 1.2, 1.5 );
    color *= PS.Diffuse;
    color.a *= PS.DistFactor;
    color.a *= saturate( PS.DistFade );
    return saturate( color );
}

//-----------------------------------------------------------------------------
// Techniques
//-----------------------------------------------------------------------------
technique custom_corona0
{
    pass P0
    {
        SrcBlend = SRCALPHA;
        DestBlend = ONE;
        AlphaRef = 1;
        AlphaBlendEnable = TRUE;
        FogEnable = FALSE;
        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader = compile ps_2_0 PixelShaderFunction();
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
