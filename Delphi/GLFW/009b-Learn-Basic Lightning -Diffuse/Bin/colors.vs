#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aNormal;

out vec3 FragPos;
out vec3 Normal;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main()
{
	gl_Position = projection * view * model * vec4((aPos), 1.0);
	FragPos = vec3(model * vec4(aPos, 1.0));


	//Inversing matrices is a costly operation for shaders, so wherever possible try to avoid doing inverse operations.
	//Send it to the shaders via a uniform before drawing (just like the model matrix)
	Normal =  mat3(transpose(inverse(model))) * aNormal;		
}