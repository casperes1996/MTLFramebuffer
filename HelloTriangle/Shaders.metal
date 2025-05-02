//
//  Shaders.metal
//  HelloTriangle
//
//  Created by Casper Sørensen on 13/07/2021.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float4 position;
    float4 colour;
};

struct RasterData {
    float4 position [[position]];
    float4 color;
};

vertex RasterData vertex_shader(constant Vertex* vertices [[buffer(0)]], uint id [[vertex_id]]) {
    float4 color = vertices[id].colour;
    float3 colorsNoAlpha = {color.r,color.g,color.b};
    float4 colors = float4(colorsNoAlpha,color.a);
    return {vertices[id].position,colors};
}

//fragment half4 fragment_shader(RasterData pixelIn [[stage_in]], device float* time [[buffer(1)]]) {
//    float x0 =  (pixelIn.position.x/1280*1.24)-3;
//    float y0 =  (pixelIn.position.y/720/1.15)-1.57;
//    float x  = 0.0;
//    float y  = 0.0;
//    int iteration = 0;
//    int max_iteration = 1000;
//    while (x*x + y*y <= 2*2 && iteration < max_iteration) {
//        float xtemp = x*x - y*y + x0;
//        y = 2*x*y + y0;
//        x = xtemp;
//        iteration = iteration + 1;
//    }
//    
//    half4 color = half4(iteration/7, iteration/45, iteration/10,1);
//    return color;
//}

//fragment half4 fragment_shader(RasterData pixelIn [[stage_in]], device float* time [[buffer(1)]]) {
//    float4 color = pixelIn.color;
//    float4 position = {0,1-pixelIn.position.y/2880,0,1};
//    position.y = position.y*2;
//    position.y -= 1;
//    position.y = abs(position.y);
//    position.y = 1.1/position.y;
//    position.y = fmod(time[0], 4);
//    position.y -= 2;
//    position.y = abs(position.y);
//    return half4{static_cast<half>(position.y*color.r), static_cast<half>(position.y*color.g), static_cast<half>(position.y*color.b), static_cast<half>(color.a)};
//}






//  Random horror parabola
float rand(int x, int y, int z)
{
    int seed = x + y * 57 + z * 241;
    seed= (seed<< 13) ^ seed;
    return (( 1.0 - ( (seed * (seed * seed * 15731 + 789221) + 1376312589) & 2147483647) / 1073741824.0f) + 1.0f) / 2.0f;
}

fragment half4 fragment_shader(RasterData pixelIn [[stage_in]], device float* time [[buffer(1)]]) {
    float x = pixelIn.position.x;
    x-=2560;
    float equationResult = 0.00023f*pow(x, 2.0)+680;
    float mult = pixelIn.position.y > equationResult? 1.0f : 0.0f;
    float random = rand(*time, *time, *time)*(1/(pixelIn.position.x/4000));
    float random2 = rand(*time*2, pow(*time,2.0), *time*2)*(1/(pixelIn.position.x/4000));
    float random3 = rand(*time*3, *time*3, pow(*time,3.0))*(1/(pixelIn.position.x/4000));
    return half4(random, random2, random3,1)*mult;
}

//*/
