//
// shader.fx
// made by Ren712
//

//-------------------------------------------
// Settings
//-------------------------------------------
float2 UVSpeed = float2(-1, 0); // uv anim speed
float2 UVResize = float2(1, 1); // resize the texture 

float pSpeed = 0.5; // pendulum speed - must be a multiplication of this value ( set 0 - to turn off )
float pMinBright = 0.35; // minimum brightness ( 0 - 1)

texture Tex;

//-------------------------------------------
// Variables
//-------------------------------------------
static const float pi = 3.141592653589793f;
float gTime : TIME;

sampler SamplerTex = sampler_state
{
    Texture = (Tex);
};

//-------------------------------------------
// Returns light transform
//-------------------------------------------
float getTextureBlink(float pendSpeed, float minBright)
{
    if (pendSpeed != 0) 
	{
		float pendTime = fmod( gTime * pendSpeed ,1 );
		return 1 - saturate((( cos( pendTime * 2 * pi) + 1) / 2) * (1 - minBright ));
    } 
	else 
	{
		return 1;
	}
}

float4 PSFunction(float4 TexCoord : TEXCOORD0, float4 Position : POSITION, float4 Diffuse : COLOR0) : COLOR0
{
    float posU = fmod( gTime * UVSpeed.x ,1 );
    float posV = fmod( gTime * UVSpeed.y ,1 );
    float4 Tex = tex2D(SamplerTex, float2( TexCoord.x * UVResize.x + posU, TexCoord.y * UVResize.y + posV ));
    Tex.a *= getTextureBlink( pSpeed, pMinBright );
    Tex.a *= Diffuse.a;
    return saturate(Tex);
}

technique tec0
{
    pass p0
    {
       AlphaRef = 1;
       AlphaBlendEnable = TRUE;
       PixelShader = compile ps_2_0 PSFunction();
    }
}