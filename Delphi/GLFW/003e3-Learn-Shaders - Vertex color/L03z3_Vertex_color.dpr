program L03z3_Vertex_color;

uses
  System.StartUpCopy,
  System.SysUtils,
  Winapi.OpenGL,
  Winapi.OpenGLExt,
  System.Math.Vectors,
  Neslib.Glfw3 in '..\Glfw\Neslib.Glfw3.pas',
  uShader in 'uShader.pas';

const
  VERTICES: array [0..17] of single = (
    // positions         // colors
     0.5, -0.5, 0.0,  1.0, 0.0, 0.0,   // bottom right
    -0.5, -0.5, 0.0,  0.0, 1.0, 0.0,   // bottom left
     0.0,  0.5, 0.0,  0.0, 0.0, 1.0    // top
  );

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
  AShader: IShader;
  Width, Height: Integer;
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
  glBindVertexArray(VAO);

  //Gera um buffer e vincula ele a uma ID armazenada dentro da variavel VBO.
  //O 1 aqui é qtd de buffers a ser gerada.
  glGenBuffers(1, @VBO);
  //o tipo do VBO é GL_ARRAY_BUFFER. Aqui define-se que o buffer é um VBO mesmo
  glBindBuffer(GL_ARRAY_BUFFER, VBO);
  //carrega os vértices no VBO
  glBufferData(GL_ARRAY_BUFFER, SizeOf(VERTICES), @VERTICES, GL_STATIC_DRAW);


  /////////////////////////
  AShader := TShader.Create('3.3.shader.vs', '3.3.shader.fs');



  //vincula um vertice a variavel 0 do shader
  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(Single), pointer(0));
  glEnableVertexAttribArray(0);

  // color attribute
  glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(Single), pointer(3 * sizeof(Single)));
  glEnableVertexAttribArray(1);




  while (glfwWindowShouldClose(Window) = 0) do
  begin
    glfwGetFramebufferSize(Window, @Width, @Height);

    glViewport(0, 0, Width, Height);

    glClearColor(0.2, 0.3, 0.3, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);

    AShader.Use();

    glBindVertexArray(VAO);
    glDrawArrays(GL_TRIANGLES, 0, 3);

    glfwSwapBuffers(Window);
    glfwPollEvents;
  end;

  glfwDestroyWindow(Window);
  glfwTerminate;
end;

begin
  Run;
end.
