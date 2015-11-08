texture gTexture;

technique TextureReplace {
	pass Pass0 {
		Texture[0] = gTexture;
	}
}