//
// custom_corona1.fx
//

//-----------------------------------------------------------------------------
// Effect Settings
//-----------------------------------------------------------------------------
float fDepthSpread = 0.3;
float fDistMult = 0.97;
float fDistAdd = -2.5;
float3 fCoronaPosition = float3(0,0,0);
float2 gDistFade = float2(250,150);
float fDepthBias = 1;

//-----------------------------------------------------------------------------
// Include some common stuff
//-----------------------------------------------------------------------------
float4x4 gWorld : WORLD;
float4x4 gView : VIEW;
float4x4 gProjection : PROJECTION;
texture gDepthBuffer : DEPTHBUFFER;
matrix gProjectionMainScene : PROJECTION_MAIN_SCENE;
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

sampler SamplerDepth = sampler_state
{
    Texture     = (gDepthBuffer);
    AddressU    = Clamp;
    AddressV    = Clamp;
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
    float2 TexCoordProj : TEXCOORD1;
    float DistFromCam : TEXCOORD2;
    float DistFactor : TEXCOORD3;
    float DistFade : TEXCOORD4;
};

//-----------------------------------------------------------------------------
// Get value from the depth buffer
// Uses define set at compile time to handle RAWZ special case (which will use up a few more slots)
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
// Use the last scene projecion matrix to linearize the depth value a bit more
//-----------------------------------------------------------------------------
float Linearize(float posZ)
{
    return gProjectionMainScene[3][2] / (posZ - gProjectionMainScene[2][2]);
}

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
PSInput VertexShaderFunctionDB(VSInput VS)
{
    PSInput PS = (PSInput)0;
    float4 position = VS.Position;

    float4x4 posMat = makeTranslation( fCoronaPosition );
    float4x4 gWorldFix = mul( gWorld, posMat );

    float4x4 worldViewMatrix = mul( gWorldFix, gView );
    float4 worldViewPosition = float4( worldViewMatrix[3].xyz + position.xzy - fCoronaPosition.xzy , 1 );

    float DistFromCam = distance( gCameraPosition , fCoronaPosition.xyz ) ;
    PS.DistFade = MTAUnlerp ( gDistFade[0], gDistFade[1], DistFromCam );
    DistFromCam /= fDepthBias;
    PS.DistFactor = saturate( DistFromCam * 0.5 - 1.6 );
    PS.DistFromCam = worldViewPosition.z / worldViewPosition.w;

    float4 pPos = mul( worldViewPosition, gProjection );
	
    PS.Position = pPos;
    PS.TexCoord = float2( VS.TexCoord.x, 1 - VS.TexCoord.y );
    PS.Diffuse = VS.Diffuse;
	
    float projectedX = (0.5 * ( pPos.w + pPos.x ) );
    float projectedY = (0.5 * ( pPos.w - pPos.y ) );
    PS.TexCoordProj = float2( float2( projectedX, projectedY )/ pPos.w );
    return PS;
}

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
float4 PixelShaderFunctionDB(PSInput PS) : COLOR0
{
    float2 TexCoordProj = PS.TexCoordProj.xy;
    TexCoordProj += float2( 0.0006, 0.0009 );
	
    float BufferValue = FetchDepthBufferValue( TexCoordProj );
    float depth = Linearize( BufferValue );
    float fade = saturate(( depth - ( PS.DistFromCam + fDistAdd ) * fDistMult  ) * fDepthSpread );
	
    float4 color = tex2D( Sampler0 , PS.TexCoord.xy );
    color.rgb = pow( color.rgb * 1.2, 1.5 );
    color *= PS.Diffuse;
    color.a *= fade * PS.DistFactor;
    color.a *= saturate( PS.DistFade );
	
    return saturate( color );
}

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
technique custom_corona1_db
{
    pass P0
    {
        SrcBlend = SRCALPHA;
        DestBlend = ONE;
        AlphaRef = 1;
        AlphaBlendEnable = TRUE;
        FogEnable = FALSE;
        ZEnable = FALSE;
        VertexShader = compile vs_2_0 VertexShaderFunctionDB();
        PixelShader = compile ps_2_0 PixelShaderFunctionDB();
    }
}

technique custom_corona1_nodb
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
