//
//  radial_blur.fx
//

//---------------------------------------------------------------------
// Settings
//---------------------------------------------------------------------
texture sSceneTexture;
texture sRadialMaskTexture;
float sLengthScale = 1;
float2 sMaskScale = float2(3,1.5);
float2 sMaskOffset = float2(0,-0.15);
float sVelZoom = 1;
float2 sVelDir = float2(0,0);
float sAmount = 0;


//---------------------------------------------------------------------
// Include some common stuff
//---------------------------------------------------------------------
#include "mta-helper.fx"


//---------------------------------------------------------------------
// Sampler for the main texture
//---------------------------------------------------------------------
sampler Sampler0 = sampler_state
{
    Texture         = (sSceneTexture);
    MinFilter       = Linear;
    MagFilter       = Linear;
    MipFilter       = Linear;
    AddressU        = Mirror;
    AddressV        = Mirror;
};

//---------------------------------------------------------------------
// Sampler for the radial mask
//---------------------------------------------------------------------
sampler SamplerMask = sampler_state
{
    Texture         = (sRadialMaskTexture);
    MinFilter       = Linear;
    MagFilter       = Linear;
    MipFilter       = Linear;
    AddressU        = Clamp;
    AddressV        = Clamp;
};


//---------------------------------------------------------------------
// Structure of data sent to the vertex shader
//---------------------------------------------------------------------
struct VSInput
{
    float3 Position : POSITION;
    float4 Diffuse : COLOR0;
    float2 TexCoord0 : TEXCOORD0;
};


//---------------------------------------------------------------------
// Structure of data sent to the pixel shader ( from the vertex shader )
//---------------------------------------------------------------------
struct PSInput
{
    float4 Pos: POSITION;  
    float2 texCoord0: TEXCOORD0;  
    float2 texCoord1: TEXCOORD1;  
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

    PS.Pos = mul(float4(VS.Position, 1), gWorldViewProjection);

    PS.texCoord0 = VS.TexCoord0;
    PS.texCoord1.x = ( VS.TexCoord0.x - 0.5 ) * sMaskScale.x + 0.5;
    PS.texCoord1.y = ( VS.TexCoord0.y - 0.5 ) * sMaskScale.y + 0.5;

    PS.texCoord1 += sMaskOffset;

    return PS;  
}  

//------------------------------------------------------------------------------------------
// PixelShaderFunction
//  1. Read from PS structure
//  2. Process
//  3. Return pixel color
//------------------------------------------------------------------------------------------
float4 PixelShaderFunction(
    float2 texCoord0: TEXCOORD0,
    float2 texCoord1: TEXCOORD1,  
    uniform int numsteps  
    ) : COLOR  
{

    // Vector from pixel to the center of the screen  
    float2 dir = 0.5 - texCoord0;  

    float mixAmount = sAmount;
    float lengthAmount = lerp(0.5, 1, sAmount) * sLengthScale;

    if ( sVelZoom < 0 )
    {
        dir *= sVelZoom * lengthAmount * 2;
        dir += sVelDir * lengthAmount * 2;
    }
    else
    {
        dir += dir * sVelZoom * lengthAmount;
        dir += sVelDir * lengthAmount * 2;
        dir += sVelDir * lengthAmount * 2 * sVelZoom;
    }
      
    // Average the pixels going along the vector  
    float4 sum = 0;
    float weightTotal = 0;
    for (int i = 0; i < numsteps; i++)  
    {
        float u = i / (float)numsteps;
        float weight = 1 - u;
        float s = 0.01 + i * 0.005;
        s += i*(i*0.2)*0.001;
        sum += tex2D( Sampler0, texCoord0 + dir * s * 1.2 * lengthAmount) * weight;
        weightTotal += weight;
    }  
    sum /= weightTotal;  


    float4 mask = tex2D( SamplerMask, texCoord1 );
    float t = mask.a;

    t *= mixAmount;
    t = min(0.7,t);
    float4 finalColor = sum;
    finalColor.b *= 0.85;
    finalColor.a = t;

    return finalColor;
}  


//-----------------------------------------------------------------------------
// Techniques
//-----------------------------------------------------------------------------
technique tec10
{
    pass P0
    {
        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader  = compile ps_2_0 PixelShaderFunction(10);
    }
}

technique tec6
{
    pass P0
    {
        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader  = compile ps_2_0 PixelShaderFunction(6);
    }
}

technique fallback
{
    pass P0
    {
    }
}

