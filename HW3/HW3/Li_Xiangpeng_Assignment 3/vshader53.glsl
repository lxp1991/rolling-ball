/* 
File Name: "vshader53.glsl":
Vertex shader:
  - Per vertex shading for a single point light source;
    distance attenuation is Yet To Be Completed.
  - Entire shading computation is done in the Eye Frame.
*/

// #version 150 

in  vec4 vPosition;
in  vec3 vNormal;

//add the parameters
in  vec3 vColor;

out vec4 color;

//smooth shading settings
varying vec3 vNormal_smooth;
varying vec4 vPosition_smooth;
varying vec4 vColor_smooth;
varying vec4 lightPosition_smooth;

uniform vec4 AmbientProduct, DiffuseProduct, SpecularProduct;
uniform mat4 model_view;
uniform mat4 projection;
uniform mat3 Normal_Matrix;
uniform vec4 LightPosition;   // Must be in Eye Frame
uniform float Shininess;


//spot light settings
uniform float exponent;
uniform float cutoff;
uniform vec3 spotLightDirection;

uniform vec4 positional_ambient_product, positional_diffuse_product, positional_specular_product;

uniform vec3 light_direction; //Difine the distantant light direction

uniform int isShading;		 // Define the shading way or the normal way
uniform int isSpotLight;	//if 1, then it's a spot light, else it's a point light

uniform float ConstAtt;  // Constant Attenuation
uniform float LinearAtt; // Linear Attenuation
uniform float QuadAtt;   // Quadratic Attenuation

void main()
{
    // Transform vertex  position into eye coordinates
    vec3 pos = (model_view * vPosition).xyz;

	float dist = length(pos - LightPosition);

	//In part c, it's a distantant light
	vec3 L = normalize( -light_direction );
    vec3 L_point = normalize( LightPosition.xyz - pos );
    vec3 E = normalize( -pos );
    vec3 H = normalize( L + E );
	vec3 H_positional = normalize(L_point + E);



    // Transform vertex normal into eye coordinates
    vec3 N = normalize(Normal_Matrix * vNormal);
	
	vec3 vNormal_smooth = normalize(Normal_Matrix * vNormal);
	vPosition_smooth = (model_view * vPosition);
	lightPosition_smooth = LightPosition;


/*--- To Do: Compute attenuation ---*/
float attenuation = 1.0; 

 // Compute terms in the illumination equation
    vec4 ambient = AmbientProduct + positional_ambient_product;


    float d = max( dot(L, N), 0.0 );
	float d_positional = max( dot(L_point, N), 0.0 );

	vec4  diffuse = d * DiffuseProduct;
	vec4  diffuse_positional = d_positional * positional_diffuse_product;

    float s = pow( max(dot(N, H), 0.0), Shininess );
	float s_positional = pow( max(dot(N, H_positional), 0.0), Shininess );
    
	vec4  specular = s * SpecularProduct;
	vec4  specular_positional = s_positional * positional_specular_product;
    
    if( dot(L, N) < 0.0 ) {
	specular = vec4(0.0, 0.0, 0.0, 1.0);
    } 

	if ( dot(L_point, N) < 0.0) {
	specular_positional = vec4(0.0, 0.0, 0.0, 1.0);
	}

    gl_Position = projection * model_view * vPosition;

	float term_spot = pow( dot(spotLightDirection, -L_point), exponent);
	


/*--- attenuation below must be computed properly ---*/
	float attenuation_positional = 1 / (ConstAtt + LinearAtt * dist + QuadAtt * dist * dist);
	float attenuation_spot = attenuation_positional * term_spot;

	//cut-off angle
	if (dot(spotLightDirection, -L_point) < cos(cutoff * 3.1415926 / 180)) attenuation_spot = 0.0;


	if (isShading == 1) {
		if (isSpotLight == 1)
			color = (ambient + diffuse + specular) + attenuation_spot * (diffuse_positional + specular_positional);
		else
			color = (ambient + diffuse + specular) + attenuation_positional * (diffuse_positional + specular_positional);
			
	}
    
	if (isShading == 0) {
		vec4 vColor4 = vec4(vColor.r, vColor.g, vColor.b, 1.0); 
		color = vColor4;
	}
	

}
