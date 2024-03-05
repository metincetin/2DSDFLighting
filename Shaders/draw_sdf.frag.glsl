#version 450

uniform float u_radius;
uniform vec2[10] u_position;

uniform sampler2D tex;


in vec2 texCoord;

out vec4 FragColor;

float sdCircle( vec2 p, float r )
{
    return length(p) - r;
}

void main(){

    float sdf = sdCircle(texCoord - u_position[0], u_radius);

    for(int i = 1;i<9;i++){
        float p = sdCircle(texCoord - u_position[i], u_radius);
        sdf = min(sdf, p);
    }

    FragColor = vec4(sdf, 0,0, 1);
}