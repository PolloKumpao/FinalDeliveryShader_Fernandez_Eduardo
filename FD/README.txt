AA5 . Final Delivery
Eduardo Fernández Sánchez	

////Post Processing
Vignetting || He añadido un efecto de vignetting al entrar la camara en el agua (Shaders/Vignetting)
////
////Shader in Unity
PBR (Shaders/ PBR + BRDF)
Adding Reflections || Estan aplicados en el agua de la playa (Scripts/Planar Reflection Manager, CustomWater,TransparentStencil )
Create materials || Variando los componentes Ambien,Diffuse y Specular he creado materiales con diferentes propiedades.(Carpeta materials)
////
////Additional implementation
Vertex Shader animation || Aplicados en el agua del mar y en la vela del barco. En el agua las Z varian según una funcion sinoidal y en el mar es basicamente lo mismo pero en el eje Y (Shader Vela, TransparentStencilShader)
Texture Blending || He creado un material para rocas que combina texturas de roca con texturas de grieta, además también tiene una pequeña animación. (Blending Shader)
Transparent Mat || He aplicado transparencia a los materiales de agua (Shader CustomTransparent, TransparentStencil, CustomWater)
////
Rogue Exercise
Texture animation || He añadido una animación simple a la cascada (Shader CustomTransparent)

