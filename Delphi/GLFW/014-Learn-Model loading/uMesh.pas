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

  TVertexArray = array of TVertex;
  TIndiceArray = array of GLuint;
  TTextureArray = array of TTexture;

  TMesh = class
  private
    FVertices: TVertexArray;
    FIndices: TIndiceArray;
    FTextures: TTextureArray;
    FVAO: GLuint;
    FVBO: GLuint;
    FEBO: GLuint;
  public
    constructor Create(_AVSize, _AISize, _ATSize: Integer);
    property Vertices: TVertexArray read FVertices write FVertices;
    property Indices: TIndiceArray read FIndices write FIndices;
    property Textures: TTextureArray read FTextures write FTextures;
    procedure setupMesh();
    procedure Draw(_AShader: IShader);

  end;

implementation

{ TMesh }


constructor TMesh.Create(_AVSize, _AISize, _ATSize: Integer);
begin
  SetLength(FVertices, _AVSize);
  SetLength(FIndices, _AISize);
  SetLength(FTextures, _ATSize);
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
