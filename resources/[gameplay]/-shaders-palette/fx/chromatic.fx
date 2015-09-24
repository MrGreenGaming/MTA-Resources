float ChromaticAmount = 0.019;
float LensSize = 0.55;
float LensDistortion = 0.05;
float LensDistortionCubic = 0.05;
	
float4x4 gWorldViewProjection : WORLDVIEWPROJECTION;

//---------------------------------------------------------------------
// Settings
//---------------------------------------------------------------------
texture sBaseTexture;

//---------------------------------------------------------------------
// Sampler
//---------------------------------------------------------------------
sampler BaseSampler = sampler_state
{
    Texture = (sBaseTexture);
    AddressU = Mirror;
    AddressV = Mirror;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
};


//---------------------------------------------------------------------
// Structure of data sent to the pixel shader ( from the vertex shader )
//---------------------------------------------------------------------
struct VSInput
{
    float3 Position : POSITION0;
    float2 TexCoord : TEXCOORD0;
};

struct PSInput
{
    float4 Position : POSITION0;
    float2 TexCoord : TEXCOORD0;
};
 
//------------------------------------------------------------------------------------------
// VertexShaderFunction
//------------------------------------------------------------------------------------------

PSInput VertexShaderFunction(VSInput VS)
{
    PSInput PS = (PSInput)0;
    PS.Position = mul(float4(VS.Position, 1), gWorldViewProjection);
    PS.TexCoord = VS.TexCoord;
    return PS;
}


//------------------------------------------------------------------------------------------
// PixelShaderFunction
//------------------------------------------------------------------------------------------
float4 PixelShaderFunction(PSInput PS) : COLOR0
{	
float4 coord=0.0;
coord.xy=PS.TexCoord.xy;
coord.w=0.0;  
float3 eta = float3(1.0+ChromaticAmount*0.9,1.0+ChromaticAmount*0.6,1.0+ChromaticAmount*0.3);
float2 center;
center.x = coord.x-0.5;
center.y = coord.y-0.5;
float LensZoom = 1.0/LensSize;

float r2 = (PS.TexCoord.x-0.5) * (PS.TexCoord.x-0.5) + (PS.TexCoord.y-0.5) * (PS.TexCoord.y-0.5);     
float f = 0;

if( LensDistortionCubic == 0.0){
	f = 1 + r2 * LensDistortion;
}else{
                f = 1 + r2 * (LensDistortion + LensDistortionCubic * sqrt(r2));
};

float x = f*LensZoom*(coord.x-0.5)+0.5;
float y = f*LensZoom*(coord.y-0.5)+0.5;
float2 rCoords = (f*eta.r)*LensZoom*(center.xy*0.5)+0.5;
float2 gCoords = (f*eta.g)*LensZoom*(center.xy*0.5)+0.5;
float2 bCoords = (f*eta.b)*LensZoom*(center.xy*0.5)+0.5;

float4 inputDistord = float4(tex2D(BaseSampler,rCoords).r , tex2D(BaseSampler,gCoords).g ,tex2D(BaseSampler,bCoords).b, tex2D(BaseSampler,float2(x,y)).a);
float4 schmotzcolor = float4(inputDistord.r,inputDistord.g,inputDistord.b,1);
return float4(saturate(schmotzcolor.xyz),1);
}

//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique tec0_PS30
{
    pass P0
    {
        VertexShader = compile vs_3_0 VertexShaderFunction();
        PixelShader = compile ps_3_0 PixelShaderFunction();
    }
}

technique tec0_PS20
{
    pass P0
    {
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
 