#version 450


uniform vec3[10] u_lightPosition;
uniform vec4[10] u_lightColor;
uniform sampler2D u_sdf;

in vec2 texCoord;

out vec4 FragColor;

float lightFalloff(float distance){
    const float a = 0;
    const float b = 1;
    return 0.01 / (1 + distance * distance);
}

void main(){
    const float LIGHT_RADIUS = 0.01;

    vec3 col = vec3(0);

    vec2 sdfSize = textureSize(u_sdf, 0);

    float aspect = sdfSize.x / sdfSize.y;

    vec2 ndc = ((texCoord) - vec2(.5)) * 2;
    ndc.x *= aspect.x;

    for(int i = 0;i<10;i++){
        vec2 rayPosition = ndc;
        vec4 lightColor = u_lightColor[i];
        vec2 lightPosition = (u_lightPosition[i].xy - vec2(.5)) * 2;


        float intensity = 0;


        float rayDist = 0;

        float startDistance = distance(lightPosition, rayPosition);
        vec2 dir = normalize(lightPosition - rayPosition);

        for(int i = 0;i<32;i++){

            vec2 sdfUv = (rayPosition + vec2(1)) / 2;
            float sdf = texture(u_sdf, sdfUv).r;

            startDistance -= sdf;

            rayDist += sdf;
            rayPosition += dir * sdf;

            if (startDistance <= 0) { 
                break;
            }
        }

        float d = distance(lightPosition, ndc);
        intensity = 1 / (d * d);

        float shadowAtten = min(1, pow(rayDist / distance(ndc, lightPosition), 0.8));


        col += intensity * LIGHT_RADIUS * lightColor.rgb * shadowAtten;
    }
    
    FragColor = vec4(col, 1);
}