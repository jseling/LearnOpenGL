unit uMesh;

interface

uses
  Winapi.OpenGL,
  Winapi.OpenGLExt,
  System.Math,
  System.Math.Vectors,
  System.Types,
  uShader,
  System.SysUtils, Winapi.Windows;

type
  TVertex = record
    Position: TPoint3D;
    Normal: TPoint3D;
    TexCoords: TPointF;
  end;

  TTexture = record
    ID: GLuint;
    TexType: string;
  end;

  TMesh = class
  private
    FVertices: array of TVertex;
    FIndices: array of GLuint;
    FTextures: array of TTexture;
    FVAO: GLuint;
    FVBO: GLuint;
    FEBO: GLuint;

    procedure setupMesh();
  public
    constructor Create(_AVertices: array of TVertex;
                       _AIndices: array of GLuint;
                       _ATextures: array of TTexture);

    procedure Draw(_AShader: IShader);

  end;

implementation

{ TMesh }

constructor TMesh.Create(_AVertices: array of TVertex;
                         _AIndices: array of GLuint;
                         _ATextures: array of TTexture);
var
   i: integer;
begin
  OutputDebugString(PWideChar('Loading TMesh vertices. Total: ' + IntToStr(Length(_AVertices))));
  SetLength(FVertices, Length(_AVertices));
  for i := 0 to Length(_AVertices) -1 do
    FVertices[i] := _AVertices[i];

  OutputDebugString(PWideChar('Loading TMesh indices. Total: ' + IntToStr(Length(_AIndices))));
  SetLength(FIndices, Length(_AIndices));
  for i := 0 to Length(_AIndices) -1 do
    FIndices[i] := _AIndices[i];


  OutputDebugString(PWideChar('Loading TMesh textures. Total: ' + IntToStr(Length(_ATextures))));
  SetLength(FTextures, Length(_ATextures));
  for i := 0 to Length(_ATextures) -1 do
    FTextures[i] := _ATextures[i];

  setupMesh();
end;

procedure TMesh.Draw(_AShader: IShader);
var
  diffuseNr: integer;
  specularNr: integer;
  i: integer;
  number: string;
  name: string;
begin
  diffuseNr := 1;
  specularNr := 1;
  for i := 0 to Length(FTextures) -1 do
  begin
    glActiveTexture(GL_TEXTURE0 + i); // activate proper texture unit before binding
    // retrieve texture number (the N in diffuse_textureN)
    name := FTextures[i].TexType;
    if(name = 'texture_diffuse') then
    begin
        number := IntToStr(diffuseNr);
        diffuseNr := diffuseNr + 1;
    end
    else if(name = 'texture_specular') then
    begin
        number := IntToStr(specularNr);
        specularNr := specularNr + 1;
    end;

    _AShader.SetUniform1i('material.' + name + number, i);
    glBindTexture(GL_TEXTURE_2D, FTextures[i].ID);
 end;
  glActiveTexture(GL_TEXTURE0);

  // draw mesh
  glBindVertexArray(FVAO);

//  glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

  glDrawElements(GL_TRIANGLES, Length(FIndices), GL_UNSIGNED_INT, nil);
  glBindVertexArray(0);
end;

procedure TMesh.setupMesh;
begin
  glGenVertexArrays(1, @FVAO);
  glGenBuffers(1, @FVBO);
  glGenBuffers(1, @FEBO);

  glBindVertexArray(FVAO);
  glBindBuffer(GL_ARRAY_BUFFER, FVBO);

  glBufferData(GL_ARRAY_BUFFER, Length(FVertices) * SizeOf(TVertex), @FVertices[0], GL_STATIC_DRAW);

  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, FEBO);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, Length(FIndices) * SizeOf(GLuint),
               @FIndices[0], GL_STATIC_DRAW);

  // vertex positions
  glEnableVertexAttribArray(0);
  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, SizeOf(TVertex), Pointer(0));
  // vertex normals
  glEnableVertexAttribArray(1);
  glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, SizeOf(TVertex), Pointer(Integer(@TVertex(nil^).Normal)));
  // vertex texture coords
  glEnableVertexAttribArray(2);
  glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, SizeOf(TVertex), Pointer(Integer(@TVertex(nil^).TexCoords)));

  glBindVertexArray(0);
end;

end.
