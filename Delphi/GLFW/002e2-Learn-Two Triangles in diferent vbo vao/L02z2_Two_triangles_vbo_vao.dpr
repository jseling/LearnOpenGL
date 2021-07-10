program L02z2_Two_triangles_vbo_vao;

uses
  System.StartUpCopy,
  System.SysUtils,
  Winapi.OpenGL,
  Winapi.OpenGLExt,
  System.Math.Vectors,
  Neslib.Glfw3 in '..\Glfw\Neslib.Glfw3.pas';

const
  // set up vertex data (and buffer(s)) and configure vertex attributes
  // ------------------------------------------------------------------
  // add a new set of vertices to form a second triangle (a total of 6 vertices);
  //the vertex attribute configuration remains the same (still one 3-float position vector per vertex)

  firsttriangle: array [0..8] of single = (
        // first triangle
        -0.9, -0.5, 0.0,  // left
        -0.0, -0.5, 0.0,  // right
        -0.45, 0.5, 0.0  // top
  );
        // second triangle
  secondtriangle: array [0..8] of single = (
         0.0, -0.5, 0.0,  // left
         0.9, -0.5, 0.0,  // right
         0.45, 0.5, 0.0   // top
  );


const
  VERTEX_SHADER =
    '#version 330 core'#10+
    'layout (location = 0) in vec3 aPos;'#10+
    'void main()'#10+
    '{'#10+
    '  gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);'#10+
    '}'#10;

const
  FRAGMENT_SHADER =
    '#version 330 core'#10+
    'out vec4 FragColor;'#10+
    'void main()'#10+
    '{'#10+
    '  FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);'#10+
    '}';


procedure ErrorCallback(error: Integer; const description: PAnsiChar); cdecl;
var
  Desc: String;
begin
  Desc := String(AnsiString(description));
  raise Exception.CreateFmt('GLFW Error %d: %s', [error, Desc]);
end;

procedure KeyCallback(window: PGLFWwindow; key, scancode, action, mods: Integer); cdecl;
begin
  if (key = GLFW_KEY_ESCAPE) and (action = GLFW_PRESS) then
    glfwSetWindowShouldClose(window, GLFW_TRUE);
end;

procedure Run;
var
  Window: PGLFWwindow;
  VBO: array [0..1] of GLuint;
  VAO: array [0..1] of GLuint;
  VertexShader: GLuint;
  FragmentShader: GLuint;
  ShaderProgram: GLuint;
  Source: PAnsiChar;
//  Ratio: Single;
  Width, Height: Integer;
//  M, P, MVP: TMatrix3D;
begin
  glfwSetErrorCallback(ErrorCallback);

  //inicializa a GLFW
  if (glfwInit = 0) then
    raise Exception.Create('Unable to initialize GLFW');

  //configura a GLFW
  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
  glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

  //cria a janela
  Window := glfwCreateWindow(800, 600, 'LearnOpenGL', nil, nil);
  if (Window = nil) then
  begin
    glfwTerminate;
    raise Exception.Create('Failed to create GLFW window');
  end;

//  glfwSetKeyCallback(Window, KeyCallback);

  //define a janela como o contexto atual
  glfwMakeContextCurrent(Window);
//  glfwSwapInterval(1);

  // NOTE: OpenGL error checks have been omitted for brevity

  InitOpenGLext;

  glGenVertexArrays(2, @VAO);
  //Gera um buffer e vincula ele a uma ID armazenada dentro da variavel VBO.
  //O 1 aqui é qtd de buffers a ser gerada.
  glGenBuffers(2, @VBO);

   // bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
  glBindVertexArray(VAO[0]);
  //o tipo do VBO é GL_ARRAY_BUFFER. Aqui define-se que o buffer é um VBO mesmo
  glBindBuffer(GL_ARRAY_BUFFER, VBO[0]);
  //carrega os vértices no VBO
  glBufferData(GL_ARRAY_BUFFER, SizeOf(firstTriangle), @firstTriangle, GL_STATIC_DRAW);
  //vincula um vertice a variavel 0 do shader
  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(Single), nil);
  glEnableVertexAttribArray(0);

    // glBindVertexArray(0); // no need to unbind at all as we directly bind a different VAO the next few lines

    // second triangle setup
   // bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
  glBindVertexArray(VAO[1]);
  //o tipo do VBO é GL_ARRAY_BUFFER. Aqui define-se que o buffer é um VBO mesmo
  glBindBuffer(GL_ARRAY_BUFFER, VBO[1]);
  //carrega os vértices no VBO
  glBufferData(GL_ARRAY_BUFFER, SizeOf(secondTriangle), @secondTriangle, GL_STATIC_DRAW);
  //vincula um vertice a variavel 0 do shader
  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(Single), nil);
  glEnableVertexAttribArray(0);
     // glBindVertexArray(0); // not really necessary as well, but beware of calls that could affect VAOs while this one is bound (like binding element buffer objects, or enabling/disabling vertex attributes)


  //cria um vertex shader
  VertexShader := glCreateShader(GL_VERTEX_SHADER);
  Source := VERTEX_SHADER;
  //carrega o código fonte no shader recém criado
  glShaderSource(VertexShader, 1, @Source, nil);
//  Assert(glGetError = GL_NO_ERROR);
  //compila o shader
  glCompileShader(VertexShader);

  //cria um fragment shader
  FragmentShader := glCreateShader(GL_FRAGMENT_SHADER);
  Source := FRAGMENT_SHADER;
  //carrega o código fonte
  glShaderSource(FragmentShader, 1, @Source, nil);
//  Assert(glGetError = GL_NO_ERROR);
  //compila
  glCompileShader(FragmentShader);

  //cria um shader program
  //ele empacotará os shaders
  ShaderProgram := glCreateProgram();
  //anexa o vertex shader ao shader program
  glAttachShader(ShaderProgram, VertexShader);
  //anexa o fragment
  glAttachShader(ShaderProgram, FragmentShader);
  //vincula os shaders ao programa
  glLinkProgram(ShaderProgram);
//  Assert(glGetError = GL_NO_ERROR);

  glDeleteShader(VertexShader);
  glDeleteShader(FragmentShader);

  while (glfwWindowShouldClose(Window) = 0) do
  begin
    glfwGetFramebufferSize(Window, @Width, @Height);

    glViewport(0, 0, Width, Height);

    glClearColor(0.2, 0.3, 0.3, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);

    glUseProgram(ShaderProgram);

    glBindVertexArray(VAO[0]);
    glDrawArrays(GL_TRIANGLES, 0, 3);

    glBindVertexArray(VAO[1]);
    glDrawArrays(GL_TRIANGLES, 0, 3);


    glBindVertexArray(0);

    glfwSwapBuffers(Window);
    glfwPollEvents;
  end;

  glDeleteVertexArrays(2, @VAO);
  glDeleteBuffers(2, @VBO);
  glDeleteProgram(shaderProgram);

  glfwDestroyWindow(Window);
  glfwTerminate;
end;

begin
  Run;
end.
