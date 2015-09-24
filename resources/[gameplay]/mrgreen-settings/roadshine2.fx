//
// Example shader - roadshine2.fx
//


//---------------------------------------------------------------------
// Road shine settings
//---------------------------------------------------------------------
float3 gLightDir = float3(0.507,-0.507,-0.2);
float3 gLightColor = float3(1,1,1);
float gSpecularPower = 16;


//---------------------------------------------------------------------
// Flags for MTA to do something about
//---------------------------------------------------------------------
int CUSTOMFLAGS
<
    string createNormals = "yes";     // Some models do not have normals by default. Setting this to 'yes' will add them to the VertexShaderInput as NORMAL0
>;


//---------------------------------------------------------------------
// These parameters are set by MTA whenever a shader is drawn
//---------------------------------------------------------------------
float4x4 gWorld : WORLD;
float4x4 gView : VIEW;
float4x4 gProjection : PROJECTION;

float3 gCameraPos : CAMERAPOSITION;


//---------------------------------------------------------------------
// The parameters below all mirror the contents of the D3D registers.
// They are only relevant when using engineApplyShaderToWorldTexture.
//---------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------------
// renderState - String value should be one of D3DRENDERSTATETYPE without the D3DRS_  http://msdn.microsoft.com/en-us/library/bb172599%28v=vs.85%29.aspx
//-------------------------------------------------------------------------------------------------------------------------------------------------------
float4 gGlobalAmbient       < string renderState="AMBIENT"; >;

int gSourceAmbient          < string renderState="AMBIENTMATERIALSOURCE"; >;
int gSourceDiffuse          < string renderState="DIFFUSEMATERIALSOURCE"; >;
int gSourceSpecular         < string renderState="SPECULARMATERIALSOURCE"; >;
int gSourceEmissive         < string renderState="EMISSIVEMATERIALSOURCE"; >;

int gLighting               < string renderState="LIGHTING"; >;

//-------------------------------------------------------------------------------------------------------------------------------------------------
// materialState - String value should be one of the members from D3DMATERIAL9  http://msdn.microsoft.com/en-us/library/bb172571%28v=VS.85%29.aspx
//-------------------------------------------------------------------------------------------------------------------------------------------------
float4 gMaterialAmbient     < string materialState="Ambient"; >;
float4 gMaterialDiffuse     < string materialState="Diffuse"; >;
float4 gMaterialSpecular    < string materialState="Specular"; >;
float4 gMaterialEmissive    < string materialState="Emissive"; >;
float gMaterialSpecPower    < string materialState="Power"; >;

//------------------------------------------------------------------------------------------
// textureState - String value should be a texture number followed by 'Texture'
//------------------------------------------------------------------------------------------
texture gTexture0           < string textureState="0,Texture"; >;


//---------------------------------------------------------------------
// Sampler for the main texture
//---------------------------------------------------------------------
sampler texsampler = sampler_state
{
    Texture = (gTexture0);
};


//---------------------------------------------------------------------
// Structure of data sent to the vertex shader
//---------------------------------------------------------------------
struct VertexShaderInput
{
  float3 Position : POSITION0;
  float3 Normal : NORMAL0;
  float4 Diffuse : COLOR0;
  float2 TexCoords : TEXCOORD0;
};

//---------------------------------------------------------------------
// Structure of data sent to the pixel shader ( from the vertex shader )
//---------------------------------------------------------------------
struct PixelShaderInput
{
  float4 Position : POSITION0;
  float4 Diffuse : COLOR0;
  float2 TexCoords : TEXCOORD0;
  float3 Normal : TEXCOORD1;
  float3 WorldPos : TEXCOORD2;
};


//------------------------------------------------------------------------------------------
// VertexShaderFunction
//------------------------------------------------------------------------------------------
PixelShaderInput VertexShaderFunction(VertexShaderInput input)
{
    PixelShaderInput output = (PixelShaderInput)0;

    // Incase we have no normal inputted
    if ( length(input.Normal) == 0 )
        input.Normal = float3(0,0,1);

    // Calc screen pos of vertex
    float4 posWorld = mul(float4(input.Position,1), gWorld);
    float4 posWorldView = mul(posWorld, gView);
    output.Position = mul(posWorldView, gProjection);

    // Pass through tex coords
    output.TexCoords = input.TexCoords;

    // Set information to do specular calculation in pixel shader
    output.Normal = mul(input.Normal, (float3x3)gWorld);
    output.WorldPos = posWorld.xyz;

    // Calc GTA lighting for buildings
    if ( !gLighting )
    {
        // If lighting render state is off, pass through the vertex color
        output.Diffuse = input.Diffuse;
    }
    else
    {
        // If lighting render state is on, calculate diffuse color by doing what D3D usually does
        float4 ambient  = gSourceAmbient  == 0 ? gMaterialAmbient  : input.Diffuse;
        float4 diffuse  = gSourceDiffuse  == 0 ? gMaterialDiffuse  : input.Diffuse;
        float4 emissive = gSourceEmissive == 0 ? gMaterialEmissive : input.Diffuse;
        output.Diffuse = gGlobalAmbient * saturate( ambient + emissive );
        output.Diffuse.a *= diffuse.a;
    }

    return output;
}

//------------------------------------------------------------------------------------------
// PixelShaderFunction
//------------------------------------------------------------------------------------------
float4 PixelShaderFunction(PixelShaderInput input) : COLOR0
{
    // Get texture pixel
    float4 texel = tex2D(texsampler, input.TexCoords);

    // Apply diffuse lighting
    float4 finalColor = texel * input.Diffuse;

    //
    // Specular calculation
    //

    float3 lightDir = normalize(gLightDir);

    // Using Blinn half angle modification for performance over correctness
    float3 h = normalize(normalize(gCameraPos - input.WorldPos) - lightDir);
    float specLighting = pow(saturate(dot(h, input.Normal)), gSpecularPower);

    // Modulate specular with texture a little bit to break up the surface
    specLighting *= texel.g * texel.g;

    // Apply specular
    finalColor.rgb += texel.rgb * specLighting * gLightColor;

    return finalColor;
}


//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique tec0
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
