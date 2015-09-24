#include "mta-helper.fx"
float4 ColorMe=(1,1,1,1);

sampler Sampler0 = sampler_state
{
    Texture = (gTexture0);
};

float4 DarkenMe(float4 TexCoord : TEXCOORD0, float4 Position : POSITION, float4 Diff:COLOR0) : COLOR0
{
    float4 Tex = tex2D(Sampler0, TexCoord);
	float4 Diffuse = MTACalcGTABuildingDiffuse( Diff );
	return Tex*Diffuse*ColorMe;
}

technique PostProcess
{
    pass p0
    {
		AlphaRef = 1;
		AlphaBlendEnable = TRUE;
        PixelShader = compile ps_2_0 DarkenMe();
    }
}
