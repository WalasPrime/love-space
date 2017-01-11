return love.graphics.newShader([[
	vec4 position(mat4 transform, vec4 pos){
		return transform*pos;
	}
]], [[
	uniform Image sphere_normal;
	uniform vec2 dirToSun;
	vec4 effect(vec4 color, Image texture, vec2 tex_co, vec2 co){
		vec4 texcolor = Texel(sphere_normal, tex_co);
		number d = dot((texcolor.xyz*2.0-vec3(1.0,1.0,1.0)), vec3(dirToSun,0));
		if(d < 0.1){d = 0.1;}
		if(d > 1.0){d = 1.0;}
		//d = clamp(d,0.1,1);
		
		vec2 center = vec2(0.5,0.5);
		vec2 toc = tex_co-center;
		if(toc.x*toc.x + toc.y*toc.y <= 0.25){
			return d*vec4(1,1,1,0)+vec4(0,0,0,1);
		}else{
			return vec4(0,0,0,0);
		}
	}
]])