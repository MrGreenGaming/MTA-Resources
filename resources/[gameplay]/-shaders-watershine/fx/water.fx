//
// water.fx
//
// Watershine and other bits and pieces by Ren712/AngerMAN

//---------------------------------------------------------------------
// Water settings
//---------------------------------------------------------------------
texture sReflectionTexture;
texture sRandomTexture;

float4 sWaterColor = float4(90 / 255.0, 170 / 255.0, 170 / 255.0, 240 / 255.0 );
float3 sSkyColorTop = float3(0,0,0);
float3 sSkyColorBott = float3(0,0,0);
float sWatFadeStart = 110;
float sWatFadeEnd = 230;

float3 sLightDir = float3(0.507,-0.507,-0.2);
float4 sSunColorTop = float4(0,0,0,0);
float4 sSunColorBott = float4(0,0,0,0);
float sSpecularPower = 4;
float sSpecularBrightness = 0;
float sStrength = 0;
float sVisibility = 0;
float sFadeStart = 140;          // Near point where distance fading will start
float sFadeEnd = 200;            // Far point where distance fading will complete (i.e. effect will not be visible past this point)


//---------------------------------------------------------------------
// Include some common stuff
//---------------------------------------------------------------------
//#define GENERATE_NORMALS      // Uncomment for normals to be generated
#include "mta-helper.fx"


//------------------------------------------------------------------------------------------
// Samplers for the textures
//------------------------------------------------------------------------------------------
sampler2D RandomSampler = sampler_state
{
   Texture = (sRandomTexture);
   MAGFILTER = LINEAR;
   MINFILTER = LINEAR;
   MIPFILTER = LINEAR;
   MIPMAPLODBIAS = 0.000000;
};

samplerCUBE ReflectionSampler = sampler_state
{
   Texture = (sReflectionTexture);
   MAGFILTER = LINEAR;
   MINFILTER = LINEAR;
   MIPFILTER = LINEAR;
   MIPMAPLODBIAS = 0.000000;
};


//---------------------------------------------------------------------
// Structure of data sent to the vertex shader
//---------------------------------------------------------------------
struct VSInput
{
    float4 Position : POSITION0;
    float4 Diffuse : COLOR0;
    float2 TexCoord : TEXCOORD0;
    float3 Normal : NORMAL0;
};

//---------------------------------------------------------------------
// Structure of data sent to the pixel shader ( from the vertex shader )
//---------------------------------------------------------------------
struct PSInput
{
    float4 Position : POSITION0;
    float4 Diffuse : COLOR0;
    float4 WorldPos : TEXCOORD0;
    float4 SparkleTex : TEXCOORD1;
    float3 Normal : TEXCOORD2;
    float WatDistFade : TEXCOORD3;
    float DistFade : TEXCOORD4;
    float2 TexCoord : TEXCOORD5;
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
    PS.Position = mul(VS.Position,gWorldViewProjection);

    // Convert regular water color to what we want
    float4 waterColorBase = float4(90 / 255.0, 170 / 255.0, 170 / 255.0, 240 / 255.0 );
    float4 conv           = float4(30 / 255.0,  58 / 255.0,  58 / 255.0, 200 / 255.0 );
    PS.Diffuse = saturate( sWaterColor * conv / waterColorBase );

    // Set information to do calculations in pixel shader
    PS.WorldPos = mul(VS.Position, gWorld);

	// Texcoords
	
	PS.TexCoord = VS.TexCoord;
	
    // Scroll noise texture
    float2 uvpos1 = 0;
    float2 uvpos2 = 0;

    uvpos1.x = sin(gTime/40);
    uvpos1.y = fmod(gTime/50,1);

    uvpos2.x = fmod(gTime/10,1);
    uvpos2.y = sin(gTime/12);

    PS.SparkleTex.x = VS.TexCoord.x * 1 + uvpos1.x;
    PS.SparkleTex.y = VS.TexCoord.y * 1 + uvpos1.y;
    PS.SparkleTex.z = VS.TexCoord.x * 2 + uvpos2.x;
    PS.SparkleTex.w = VS.TexCoord.y * 2 + uvpos2.y;

    PS.Normal =  float3(0,0,1);   

    float DistanceFromCamera = MTACalcCameraDistance( gCameraPosition, PS.WorldPos.xyz );
    PS.WatDistFade = MTAUnlerp ( sWatFadeEnd, sWatFadeStart, DistanceFromCamera );
    PS.DistFade = MTAUnlerp ( sFadeEnd, sFadeStart, DistanceFromCamera );
    return PS;
}


//------------------------------------------------------------------------------------------
// PixelShaderFunction
//  1. Read from PS structure
//  2. Process
//  3. Return pixel color
//------------------------------------------------------------------------------------------

float3 LightingSpecular(float3 normal,float3 lightDir, float3 worldPos, float specul, float intensity) {
	
    float3 reflectionVector = -reflect(lightDir, normal);
    float spec = dot(normalize(reflectionVector), normalize(gCameraPosition - worldPos ));
    float spec1 = saturate(pow(spec, 8 * specul)); 
    float spec2 = saturate(pow(spec, 64 * specul));
    float3 specular = lerp(spec1 * sSunColorTop.rgb/3,spec2 * sSunColorBott.rgb ,spec2);
    return saturate( specular ) * intensity;
}

float4 PixelShaderFunction(PSInput PS) : COLOR0
{
    //
    // This was all ripped and modded from the car paint shader, so some of the comments may seem a bit strange
    //

    float brightnessFactor = 0.10;
    float glossLevel = 0.00;

    // Get the surface normal
    float3 vNormal = PS.Normal;

    // Micro-flakes normal map is a high frequency normalized
    // vector noise map which is repeated across the surface.
    // Fetching the value from it for each pixel allows us to
    // compute perturbed normal for the surface to simulate
    // appearance of micro-flakes suspended in the coat of paint:
    float3 vFlakesNormal = tex2D(RandomSampler, PS.SparkleTex.xy).rgb;
    float3 vFlakesNormal2 = tex2D(RandomSampler, PS.SparkleTex.zw).rgb;

    vFlakesNormal = (vFlakesNormal + vFlakesNormal2 ) / 2;

    // Don't forget to bias and scale to shift color into [-1.0, 1.0] range:
    vFlakesNormal = 2 * vFlakesNormal - 1.0;

    // To compute the surface normal for the second layer of micro-flakes, which
    // is shifted with respect to the first layer of micro-flakes, we use this formula:
    // Np2 = ( c * Np + d * N ) / || c * Np + d * N || where c == d
    float3 vNp2 = ( vFlakesNormal + vNormal ) ;

    // The view vector (which is currently in world space) needs to be normalized.
    // This vector is normalized in the pixel shader to ensure higher precision of
    // the resulting view vector. For this highly detailed visual effect normalizing
    // the view vector in the vertex shader and simply interpolating it is insufficient
    // and produces artifacts.
    float3 vView = normalize( gCameraPosition - PS.WorldPos.xyz );

    // Transform the surface normal into world space (in order to compute reflection
    // vector to perform environment map look-up):
    float3 vNormalWorld = PS.Normal;

    // Compute reflection vector resulted from the clear coat of paint on the metallic
    // surface:
    float fNdotV = saturate(dot( vNormalWorld, vView));
    float3 vReflection = 2 * vNormalWorld * fNdotV - vView;

    // Hack in some bumpyness
    vReflection += vNp2;

    // Calc Sky color reflection
    float3 cameraDirection = float3(gCameraDirection.xy,saturate(gCameraDirection.z));
    float3 h = normalize(normalize(gCameraPosition - PS.WorldPos.xyz) - normalize(cameraDirection));
    float vdn = saturate(pow(saturate(dot(h,vNp2)), 1));
    float3 skyColorTop = lerp(0,sSkyColorTop,vdn);	
    float3 skyColorBott = lerp(0,sSkyColorBott,vdn);
    float3 skyColor = lerp(skyColorBott,skyColorTop,saturate(PS.WatDistFade));	
	
    // Specular calculation
    float3 lightDir = normalize(sLightDir.xyz);
    float3 specLighting = LightingSpecular(vNp2,lightDir, PS.WorldPos.xyz,sSpecularPower,2);

    // Sample environment map using this reflection vector:
    float4 envMap = texCUBE( ReflectionSampler, vReflection );
    float envGray = (envMap.r + envMap.g + envMap.b)/3;
    envMap.rgb = float3(envGray,envGray,envGray);
    envMap.rgb = envMap.rgb * envMap.a;
	
    // Blend rays with water
    specLighting = specLighting * sSpecularBrightness * envMap.rgb ;
	
    // Brighten the environment map sampling result:
    envMap.rgb *= envMap.rgb;
    envMap.rgb *= brightnessFactor;
    envMap.rgb = saturate(envMap.rgb);
    float4 finalColor = 1;

    // Bodge in the water color
    finalColor = envMap + PS.Diffuse * 0.5;
    finalColor += envMap * PS.Diffuse;
    finalColor.rgb += skyColor *0.18;
    finalColor.rgb += specLighting * saturate(PS.DistFade) * sVisibility;
    finalColor.a = PS.Diffuse.a;
    return finalColor;
}


//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique water2
{
    pass P0
    {
        AlphaBlendEnable = TRUE;
        AlphaRef = 1;
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
