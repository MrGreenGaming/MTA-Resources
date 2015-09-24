// paint fix and reflection by Ren712
// car_refgrun.fx
//
//
// Badly converted from:
//
//      ShaderX2 – Shader Programming Tips and Tricks with DirectX 9
//      http://developer.amd.com/media/gpu_assets/ShaderX2_LayeredCarPaintShader.pdf
//
//      Chris Oat           Natalya Tatarchuk       John Isidoro
//      ATI Research        ATI Research            ATI Research
//

//some additional variables for the reflection
//for reflection factor look for brightnessFactor in piel shader

float sSparkleSize = 0.5;
float bumpSize = 1;

float2 uvMul = float2(1,1);
float2 uvMov = float2(0,0.25);

float brightnessFactor = 0.20;
float transFactor = 0.55;

float minZviewAngleFade = 0.6;
float sNormZ = 3;
float sRefFlan = 0.2;
float sAdd = 0.1;  
float sMul = 1.1; 
float sCutoff : CUTOFF = 0.16;         // 0 - 1
float sPower : POWER  = 2;            // 1 - 5
float sNorFacXY = 0.25;
float sNorFacZ = 1;
float3 sSkyColorTop = float3(0,0,0);
float3 sSkyColorBott = float3(0,0,0);
float sSkyLightIntensity = 0;

bool dirtTex = true;

//---------------------------------------------------------------------
// Textures
//---------------------------------------------------------------------

texture sReflectionTexture;
texture sRandomTexture;

//---------------------------------------------------------------------
// Include some common stuff
//---------------------------------------------------------------------
#include "mta-helper.fx"

//------------------------------------------------------------------------------------------
// Samplers for the textures
//------------------------------------------------------------------------------------------
sampler Sampler0 = sampler_state
{
    Texture         = (gTexture0);
    MinFilter       = Linear;
    MagFilter       = Linear;
    MipFilter       = Linear;
};

sampler3D RandomSampler = sampler_state
{
    Texture = (sRandomTexture); 
    MAGFILTER = LINEAR;
    MINFILTER = LINEAR;
    MIPFILTER = POINT;
    MIPMAPLODBIAS = 0.000000;
};

sampler2D ReflectionSampler = sampler_state
{
    Texture = (sReflectionTexture);	
    AddressU = Mirror;
    AddressV = Mirror;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
};

//---------------------------------------------------------------------
// Structure of data sent to the vertex shader
//---------------------------------------------------------------------
struct VSInput
{
    float4 Position : POSITION; 
    float3 Normal : NORMAL0;
    float4 Diffuse : COLOR0;
    float2 TexCoord : TEXCOORD0;
    float3 View : TEXCOORD1;
};

//---------------------------------------------------------------------
// Structure of data sent to the pixel shader ( from the vertex shader )
//---------------------------------------------------------------------
struct PSInput
{
    float4 Position : POSITION;
    float4 Diffuse : COLOR0;
    float4 Specular : COLOR1;   
    float2 TexCoord : TEXCOORD0;
    float3 Tangent : TEXCOORD1;
    float3 Binormal : TEXCOORD2;
    float3 Normal : TEXCOORD3;
    float3 View : TEXCOORD4;
    float3 SparkleTex : TEXCOORD5;
    float2 TexCoord2 : TEXCOORD6;
    float4 ShineTop : TEXCOORD7;
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
	
    float4 worldPosition = mul ( VS.Position, gWorld );
    float4 viewPosition  = mul ( worldPosition, gView );
    PS.Position  = mul ( viewPosition, gProjection );
 
    PS.View =  normalize( gCameraPosition - worldPosition.rgb);
    PS.ShineTop = float4(0,	worldPosition.rgb);
    // Fake tangent and binormal
    float3 Tangent = VS.Normal.yxz;
    Tangent.xz = VS.TexCoord.xy;
    float3 Binormal = normalize( cross(Tangent, VS.Normal) );
    Tangent = normalize( cross(Binormal, VS.Normal) );

    // Transfer some stuff
    PS.Normal = normalize( mul(VS.Normal, (float3x3)gWorldInverseTranspose).xyz );
	PS.Tangent = normalize(mul(Tangent, (float3x3)gWorldInverseTranspose).xyz);
	PS.Binormal = normalize( mul(Binormal, (float3x3)gWorldInverseTranspose).xyz );
	
    PS.SparkleTex.x = fmod( VS.Position.x, 10 ) * 4.0/sSparkleSize;
    PS.SparkleTex.y = fmod( VS.Position.y, 10 ) * 4.0/sSparkleSize;
    PS.SparkleTex.z = fmod( VS.Position.z, 10 ) * 4.0/sSparkleSize; 
	
    float3 ViewNormal = normalize( mul(VS.Normal, (float3x3)gWorldView) );	
    float4 posNorm = float4(VS.Position.xyz,1);
    posNorm.xyz += float3(ViewNormal.xy * sNorFacXY, ViewNormal.z * sNorFacZ);

    float4 pPos = mul(posNorm, gWorldViewProjection); 
    float projectedX = (0.5 * (pPos.x/pPos.w)) * uvMul.x + 0.5 + uvMov.x;
    float projectedY = (0.5 * (pPos.y/pPos.w)) * uvMul.y + 0.5 + uvMov.y;
    float2 TexCoord = float2(projectedX,projectedY);

    // send reflection lookup coords to pixel shader
    PS.TexCoord = float2(TexCoord.x, TexCoord.y);

    PS.TexCoord2.xy = VS.TexCoord.xy;
	
    // Calc lighting
    PS.Diffuse = MTACalcGTACompleteDiffuse( PS.Normal, VS.Diffuse );
    float4 SpecularVeh = MTACalculateVehicleSpecular( PS.Normal );
    SpecularVeh.rgb = pow( SpecularVeh.rgb, 2);
    PS.Diffuse.rgb += saturate( SpecularVeh.rgb);
	
    // Normal Z vector for sky light 
    float worldNormalZ = mul(VS.Normal,(float3x3)gWorld).z;
    float skyTopmask = pow(worldNormalZ,5);
    PS.Specular.rgb = (skyTopmask * sSkyColorTop + saturate(worldNormalZ-skyTopmask)* sSkyColorBott );
    PS.Specular.rgb *= gGlobalAmbient.xyz * sSkyLightIntensity;
    PS.Specular.a = pow(worldNormalZ,sNormZ);
    PS.ShineTop.r  = saturate( PS.Specular.a );
    if (gCameraDirection.z < minZviewAngleFade) PS.Specular.a = PS.ShineTop.r * (1 - saturate((-1/minZviewAngleFade ) * (minZviewAngleFade - gCameraDirection.z)));
    return PS;
}

//------------------------------------------------------------------------------------------
// MTAApplyFog
//------------------------------------------------------------------------------------------

int gFogEnable                     < string renderState="FOGENABLE"; >;
float4 gFogColor                   < string renderState="FOGCOLOR"; >;
float gFogStart                    < string renderState="FOGSTART"; >;
float gFogEnd                      < string renderState="FOGEND"; >;
 
float3 MTAApplyFog( float3 texel, float3 worldPos )
{
    if ( !gFogEnable )
        return texel;
 
    float DistanceFromCamera = distance( gCameraPosition, worldPos );
    float FogAmount = ( DistanceFromCamera - gFogStart )/( gFogEnd - gFogStart );
    texel.rgb = lerp(texel.rgb, gFogColor, saturate( FogAmount ) );
    return texel;
}

//------------------------------------------------------------------------------------------
// PixelShaderFunction
//  1. Read from PS structure
//  2. Process
//  3. Return pixel color
//------------------------------------------------------------------------------------------
float4 PixelShaderFunctionSM3(PSInput PS) : COLOR0
{
   //reflection variable here

    // Some settings for something or another
    float microflakePerturbation = 1.00;
    float normalPerturbation = 1.00;
    float microflakePerturbationA = 0.10;

    // Compute paint colors
    float4 base = gMaterialAmbient;
	
    float4 paintColorMid;
    float4 paintColor2;
    float4 paintColor0;
    float4 flakeLayerColor;

    paintColorMid = base;
    paintColor2.r = base.g / 2 + base.b / 2;
    paintColor2.g = (base.r / 2 + base.b / 2);
    paintColor2.b = base.r / 2 + base.g / 2;

    paintColor0.r = base.r / 2 + base.g / 2;
    paintColor0.g = (base.g / 2 + base.b / 2);
    paintColor0.b = base.b / 2 + base.r / 2;

    flakeLayerColor.r = base.r / 2 + base.b / 2;
    flakeLayerColor.g = (base.g / 2 + base.r / 2);
    flakeLayerColor.b = base.b / 2 + base.g / 2;

    // Get the surface normal
    float3 vNormal = PS.Normal;

    // Micro-flakes normal map is a high frequency normalized
    // vector noise map which is repeated across the surface.
    // Fetching the value from it for each pixel allows us to
    // compute perturbed normal for the surface to simulate
    // appearance of micro-flakes suspended in the coat of paint:
    float3 vFlakesNormal = tex3D(RandomSampler, PS.SparkleTex).rgb;

    // Don't forget to bias and scale to shift color into [-1.0, 1.0] range:
    vFlakesNormal = 2 * vFlakesNormal - 1.0;

    // This shader simulates two layers of micro-flakes suspended in
    // the coat of paint. To compute the surface normal for the first layer,
    // the following formula is used:
    // Np1 = ( a * Np + b * N ) / || a * Np + b * N || where a << b
    //
    float3 vNp1 = microflakePerturbationA * vFlakesNormal + normalPerturbation * vNormal ;

    // To compute the surface normal for the second layer of micro-flakes, which
    // is shifted with respect to the first layer of micro-flakes, we use this formula:
    // Np2 = ( c * Np + d * N ) / || c * Np + d * N || where c == d
    float3 vNp3 = microflakePerturbation * ( vFlakesNormal + vNormal ) ;
    float3 vNp2 = microflakePerturbation * (( vFlakesNormal + 1.0)/2) ;

    // The view vector (which is currently in world space) needs to be normalized.

    float3 vView = PS.View;
    // Transform the surface normal into world space (in order to compute reflection
    // vector to perform environment map look-up):
    float3x3 mTangentToWorld = transpose( float3x3( PS.Tangent,PS.Binormal, PS.Normal ) );
    float3 vNormalWorld = normalize( mul( mTangentToWorld, vNormal ));
       
    // Compute reflection vector resulted from the clear coat of paint on the metallic
    // surface:
	
    float fNdotV = saturate(dot( vNormalWorld, vView ));

    // Calc reflection
    float2 vReflection = PS.TexCoord;
    // Hack in some bumpyness
    vReflection.x += vNp2.x * (0.1 * bumpSize) - (0.1 * bumpSize);
    vReflection.y += vNp2.y * (0.05 * bumpSize) - (0.05 * bumpSize);
	
    float4 envMap = tex2D( ReflectionSampler, vReflection );
    float lum = (envMap.r + envMap.g + envMap.b)/3;
    float adj = saturate( lum - sCutoff );
    adj = adj / (1.01 - sCutoff);
    envMap += sAdd+1.0; 
    envMap = (envMap * adj);
    envMap = pow(envMap, sPower+2); 
    envMap *= sMul;
	
    // Dust texture
    float4 texel = tex2D(Sampler0, PS.TexCoord2.xy );	

    // Brighten the environment map sampling result:
    envMap.rgb *= brightnessFactor;	 
		
    float4 First = float4((envMap.rgb + 0.5 * PS.Specular.rgb ), PS.Specular.a );
    float4 Second = float4(0.6 * (PS.Specular.rgb), PS.ShineTop.r );
    envMap = lerp(First,Second,1-PS.Specular.a);
	
    // Compute modified Fresnel term for reflections from the first layer of
    // microflakes. First transform perturbed surface normal for that layer into
    // world space and then compute dot product of that normal with the view vector:
    float3 vNp1World = normalize( mul( mTangentToWorld, vNp1) );
    float fFresnel1 = saturate( dot( vNp1World, vView ));

    // Compute modified Fresnel term for reflections from the second layer of
    // microflakes. Again, transform perturbed surface normal for that layer into
    // world space and then compute dot product of that normal with the view vector:

    float3 vNp2World = normalize( mul( mTangentToWorld, vNp3 ));
    float fFresnel2 = saturate( dot( vNp2World, vView ));
	
    // Combine all layers of paint as well as two layers of microflakes
       float fFresnel1Sq = fFresnel1 * fFresnel1;

		 float4 paintColor = fFresnel1 * paintColor0 +
		 fFresnel1Sq * paintColorMid +
		 fFresnel1Sq * fFresnel1Sq * paintColor2 +
         pow( fFresnel2, 32 ) * flakeLayerColor;
			
 // Combine result of environment map reflection with the paint color:
 
    float fEnvContribution = 1.0 - 0.5 * fNdotV; 
    float4 finalColor;
    finalColor = envMap * fEnvContribution + paintColor;
    finalColor.a = 1.0;

    // Bodge in the car colors
    float4 Color = 1;
    Color = finalColor / 1 + PS.Diffuse * 0.5;
    Color += finalColor * PS.Diffuse * 1;
    if (dirtTex) {Color *= texel; }
    Color.rgb = MTAApplyFog( Color.rgb, float3(PS.ShineTop.g, PS.ShineTop.b, PS.ShineTop.a ));
    Color.a = PS.Diffuse.a;
	return Color;
}

float4 PixelShaderFunctionSM2(PSInput PS) : COLOR0
{
   //reflection variable here

    // Some settings for something or another
    float microflakePerturbation = 1.00;
    float normalPerturbation = 1.00;
    float microflakePerturbationA = 0.10;

    // Compute paint colors
    float4 base = gMaterialAmbient;
	
    float4 paintColorMid;
    float4 paintColor2;
    float4 paintColor0;
    float4 flakeLayerColor;

    paintColorMid = base;
    paintColor2.r = base.g / 2 + base.b / 2;
    paintColor2.g = (base.r / 2 + base.b / 2);
    paintColor2.b = base.r / 2 + base.g / 2;

    paintColor0.r = base.r / 2 + base.g / 2;
    paintColor0.g = (base.g / 2 + base.b / 2);
    paintColor0.b = base.b / 2 + base.r / 2;

    flakeLayerColor.r = base.r / 2 + base.b / 2;
    flakeLayerColor.g = (base.g / 2 + base.r / 2);
    flakeLayerColor.b = base.b / 2 + base.g / 2;

    // Get the surface normal
    float3 vNormal = PS.Normal;

    // Micro-flakes normal map is a high frequency normalized
    // vector noise map which is repeated across the surface.
    // Fetching the value from it for each pixel allows us to
    // compute perturbed normal for the surface to simulate
    // appearance of micro-flakes suspended in the coat of paint:
    float3 vFlakesNormal = tex3D(RandomSampler, PS.SparkleTex).rgb;

    // Don't forget to bias and scale to shift color into [-1.0, 1.0] range:
    vFlakesNormal = 2 * vFlakesNormal - 1.0;

    // This shader simulates two layers of micro-flakes suspended in
    // the coat of paint. To compute the surface normal for the first layer,
    // the following formula is used:
    // Np1 = ( a * Np + b * N ) / || a * Np + b * N || where a << b
    //
    float3 vNp1 = microflakePerturbationA * vFlakesNormal + normalPerturbation * vNormal ;

    // To compute the surface normal for the second layer of micro-flakes, which
    // is shifted with respect to the first layer of micro-flakes, we use this formula:
    // Np2 = ( c * Np + d * N ) / || c * Np + d * N || where c == d
    float3 vNp3 = microflakePerturbation * ( vFlakesNormal + vNormal ) ;
    float3 vNp2 = microflakePerturbation * (( vFlakesNormal + 1.0)/2) ;

    // The view vector (which is currently in world space) needs to be normalized.

    float3 vView = PS.View;
    // Transform the surface normal into world space (in order to compute reflection
    // vector to perform environment map look-up):
    float3x3 mTangentToWorld = transpose( float3x3( PS.Tangent,PS.Binormal, PS.Normal ) );
    float3 vNormalWorld = normalize( mul( mTangentToWorld, vNormal ));
       
    // Compute reflection vector resulted from the clear coat of paint on the metallic
    // surface:
	
    float fNdotV = saturate(dot( vNormalWorld, vView ));

    // Calc reflection
    float2 vReflection = PS.TexCoord;
    // Hack in some bumpyness
    //vReflection.x += vNp2.x * (0.1 * bumpSize) - (0.1 * bumpSize);
    //vReflection.y += vNp2.y * (0.05 * bumpSize) - (0.05 * bumpSize);
	
    float4 envMap = tex2D( ReflectionSampler, vReflection );
    float lum = (envMap.r + envMap.g + envMap.b)/3;
    float adj = saturate( lum - sCutoff );
    adj = adj / (1.01 - sCutoff);
    envMap += sAdd+1.0; 
    envMap = (envMap * adj);
    envMap = pow(envMap, sPower+2); 
    envMap *= sMul;
	
    // Dust texture
    float4 texel = tex2D(Sampler0, PS.TexCoord2.xy );	

    // Brighten the environment map sampling result:
    envMap.rgb *= brightnessFactor;	 
		
    float4 First = float4((envMap.rgb + 0.5 * PS.Specular.rgb ), PS.Specular.a );
    float4 Second = float4(0.6 * (PS.Specular.rgb), PS.ShineTop.r );
    envMap = lerp(First,Second,1-PS.Specular.a);
	
    // Compute modified Fresnel term for reflections from the first layer of
    // microflakes. First transform perturbed surface normal for that layer into
    // world space and then compute dot product of that normal with the view vector:
    float3 vNp1World = normalize( mul( mTangentToWorld, vNp1) );
    float fFresnel1 = saturate( dot( vNp1World, vView ));

    // Compute modified Fresnel term for reflections from the second layer of
    // microflakes. Again, transform perturbed surface normal for that layer into
    // world space and then compute dot product of that normal with the view vector:

    float3 vNp2World = normalize( mul( mTangentToWorld, vNp3 ));
    float fFresnel2 = saturate( dot( vNp2World, vView ));
	
    // Combine all layers of paint as well as two layers of microflakes
       float fFresnel1Sq = fFresnel1 * fFresnel1;

		 float4 paintColor = fFresnel1 * paintColor0 +
		 fFresnel1Sq * paintColorMid +
		 fFresnel1Sq * fFresnel1Sq * paintColor2 +
         pow( fFresnel2, 32 ) * flakeLayerColor;
			
 // Combine result of environment map reflection with the paint color:
 
    float fEnvContribution = 1.0 - 0.5 * fNdotV; 
    float4 finalColor;
    finalColor = envMap * fEnvContribution + paintColor;
    finalColor.a = 1.0;

    // Bodge in the car colors
    float4 Color = 1;
    Color = finalColor / 1 + PS.Diffuse * 0.5;
    Color += finalColor * PS.Diffuse * 1;
    if (dirtTex) {Color *= texel; }
    Color.a = PS.Diffuse.a;
	return Color;
}


//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique car_reflect_paint_SM3
{
    pass P0
    {
        AlphaRef = 1;
        AlphaBlendEnable = TRUE;
        VertexShader = compile vs_3_0 VertexShaderFunction();
        PixelShader  = compile ps_3_0 PixelShaderFunctionSM3();
    }
}

technique car_reflect_paint_SM2
{
    pass P0
    {
        AlphaRef = 1;
        AlphaBlendEnable = TRUE;
        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader  = compile ps_2_0 PixelShaderFunctionSM2();
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
