program L02z1_Two_triangles;

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

  VERTICES: array [0..17] of single = (
        // first triangle
        -0.9, -0.5, 0.0,  // left
        -0.0, -0.5, 0.0,  // right
        -0.45, 0.5, 0.0,  // top
        // second triangle
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
  VBO: GLuint;
  VAO: GLuint;
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

  glGenVertexArrays(1, @VAO);
   // bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
  glBindVertexArray(VAO);

  //Gera um buffer e vincula ele a uma ID armazenada dentro da variavel VBO.
  //O 1 aqui é qtd de buffers a ser gerada.
  glGenBuffers(1, @VBO);
  //o tipo do VBO é GL_ARRAY_BUFFER. Aqui define-se que o buffer é um VBO mesmo
  glBindBuffer(GL_ARRAY_BUFFER, VBO);
  //carrega os vértices no VBO
  glBufferData(GL_ARRAY_BUFFER, SizeOf(VERTICES), @VERTICES, GL_STATIC_DRAW);


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

  //vincula um vertice a variavel 0 do shader
  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(Single), nil);
  glEnableVertexAttribArray(0);

  // note that this is allowed, the call to glVertexAttribPointer registered VBO as the vertex attribute's bound vertex buffer object so afterwards we can safely unbind
  glBindBuffer(GL_ARRAY_BUFFER, 0);

  // You can unbind the VAO afterwards so other VAO calls won't accidentally modify this VAO, but this rarely happens. Modifying other
  // VAOs requires a call to glBindVertexArray anyways so we generally don't unbind VAOs (nor VBOs) when it's not directly necessary.
  glBindVertexArray(0);



  while (glfwWindowShouldClose(Window) = 0) do
  begin
    glfwGetFramebufferSize(Window, @Width, @Height);

    glViewport(0, 0, Width, Height);

    glClearColor(0.2, 0.3, 0.3, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);

    glUseProgram(ShaderProgram);
    glBindVertexArray(VAO);

//    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
//    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

    glDrawArrays(GL_TRIANGLES, 0, 6);




    glBindVertexArray(0);

    glfwSwapBuffers(Window);
    glfwPollEvents;
  end;

  glDeleteVertexArrays(1, @VAO);
  glDeleteBuffers(1, @VBO);
  glDeleteProgram(shaderProgram);

  glfwDestroyWindow(Window);
  glfwTerminate;
end;

begin
  Run;
end.
