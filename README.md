# 2D SDF Lighting

Demo project that implements raymarching for 2D lighting and shadows, made in [dream engine](https://github.com/metincetin/dreamengine)

Play the build [here](https://metincetin.xyz/work/2d-sdf-lighting)

It writes every occluder to the uniform occluder position array, alongside with their radius. Then, the first pass (DrawSDF) draws the occluder SDF values to a texture, later to be used for lighting calculation. 

Second pass (DrawLight) calculates the lights and shadows, raymarching from each pixel towards the each light source. If the ray hits any occluder sampled from occluder texture, it would mean that the given pixel is in shadow. For the second pass, similar uniform arrays are passed for light positions and colors.

To build the project, follow the build instructions on dream engine page.
