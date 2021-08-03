{
https://en.wikipedia.org/wiki/Wavefront_.obj_file

http://paulbourke.net/dataformats/obj/minobj.html

http://paulbourke.net/dataformats/obj/

https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/27982/versions/5/previews/help%20file%20format/OBJ_format.html

https://stackoverflow.com/questions/23723993/converting-quadriladerals-in-an-obj-file-into-triangles
}

unit uObjModel;

interface

uses
  System.Math.Vectors,
  System.Types,
  uMesh,
  System.Classes,
  SysUtils,
  StrUtils,
  Winapi.Windows,
  uTriangulator,
  System.Generics.Collections;

type
  TFaceVertex = record
    IDPosition: Integer;
    IDUV: Integer;
    IDNormal: Integer;
    constructor Create(_AIdPosition, _AIdUV, _AIdNormal: Integer);
  end;

  TObjModel = class
  private
    FVerts: TList<TPoint3D>;
    FVertsTexture: TList<TPointF>;
    FVertsNormal: TList<TPoint3D>;
    FFaces: TList<TArray<TFaceVertex>>;

    procedure AddVert(_AVert: TPoint3D);
    procedure AddVertTexture(_AVert: TPointF);
    procedure AddVertNormal(_AVert: TPoint3D);
    procedure AddFace(_AFace: TArray<TFaceVertex>);

    procedure ParseVert(const _ALine: String);
    procedure ParseVertTexture(const _ALine: String);
    procedure ParseVertNormal(const _ALine: String);
    procedure ParseFace(const _ALine: String);

  public
    constructor Create(const _AFileName: String);
    destructor Destroy; override;

    function Vert(i: Integer): TPoint3D;
    function VertCount: integer;

    function VertTexture(i: Integer): TPointF;
    function VertTextureCount: integer;

    function VertNormal(i: Integer): TPoint3D;
    function VertNormalCount: integer;

    function Face(idx: Integer): TArray<TFaceVertex>;  //face=triangle
    function FaceCount: integer;
  end;

implementation

{ TObjModel }

procedure TObjModel.AddFace(_AFace: TArray<TFaceVertex>);
begin
  FFaces.Add(_AFace);
end;

procedure TObjModel.AddVert(_AVert: TPoint3D);
begin
  FVerts.Add(_AVert);
end;

procedure TObjModel.AddVertNormal(_AVert: TPoint3D);
begin
  FVertsNormal.Add(_AVert);
end;

procedure TObjModel.AddVertTexture(_AVert: TPointF);
begin
  FVertsTexture.Add(_AVert);
end;

constructor TObjModel.Create(const _AFileName: String);
var
  AFile: TStringList;
  ALine: String;
begin
  FVerts := TList<TPoint3D>.Create;
  FVertsTexture := TList<TPointF>.Create;
  FVertsNormal := TList<TPoint3D>.Create;
  FFaces := TList<TArray<TFaceVertex>>.Create;


  AFile := TStringList.Create;
  try
    AFile.LoadFromFile(_AFileName);

    OutputDebugString(PWideChar('Parsing TObjModel.'));
    for ALine in AFile do
    begin
      if Pos('v ', ALine) = 1 then
      begin
        ParseVert(ALine);
      end
      else if Pos('vt ', ALine) = 1 then
      begin
        ParseVertTexture(ALine);
      end
      else if Pos('vn ', ALine) = 1 then
      begin
        ParseVertNormal(ALine);
      end
      else if Pos('f ', ALine) = 1 then
      begin
        ParseFace(ALine);
      end;
    end;
    OutputDebugString(PWideChar('Parsing TObjModel complete.'));
  finally
    AFile.Free;
  end;
end;

destructor TObjModel.Destroy;
begin
  FVerts.Free;
  FVertsTexture.Free;
  FVertsNormal.Free;
  FFaces.Free;
  inherited;
end;

function TObjModel.Face(idx: Integer): TArray<TFaceVertex>;
begin
  result := FFaces[idx];
end;

function TObjModel.FaceCount: integer;
begin
  result := FFaces.Count;
end;

procedure TObjModel.ParseFace(const _ALine: String);
var
  ATriangle: TArray<TFaceVertex>;
  i: integer;

  faceVertices: TStringDynArray;
  faceVertice: TStringDynArray;

  pos, uv, normal: integer;
  ALine: String;

  APolygon: TArray<TFaceVertex>;
  APolygonTriangulated: TArray<TArray<TFaceVertex>>;
begin
  ALine := StringReplace(_ALine, '  ', ' ', [rfReplaceAll]);
  faceVertices := SplitString(ALine, ' ');

  SetLength(APolygon, Length(faceVertices) - 1);
  for i := 1 to Length(APolygon) do
  begin
    faceVertice := SplitString(faceVertices[i], '/');

    pos := StrToInt(faceVertice[0]) - 1;
    uv := StrToInt(faceVertice[1]) - 1;
    normal := StrToInt(faceVertice[2]) - 1;

    APolygon[i - 1] := TFaceVertex.Create(pos, uv, normal);
  end;

  APolygonTriangulated := TTriangulator.Triangulate<TFaceVertex>(APolygon);

  for ATriangle in APolygonTriangulated do
    AddFace(ATriangle);
end;

procedure TObjModel.ParseVert(const _ALine: String);
var
  ALineValues: TStringDynArray;
  AVert: TPoint3D;
  AX, AY, AZ: Single;
  AFormatSettings: TFormatSettings;
  ALine: String;
begin
  ALine := StringReplace(_ALine, '  ', ' ', [rfReplaceAll]);
  ALineValues := SplitString(ALine, ' ');

  AFormatSettings := FormatSettings;
  AFormatSettings.DecimalSeparator := '.';

  AX := StrToFloat(ALineValues[1], AFormatSettings);
  AY := StrToFloat(ALineValues[2], AFormatSettings);
  AZ := StrToFloat(ALineValues[3], AFormatSettings);

  AVert := TPoint3D.Create(AX, AY, AZ);

  AddVert(AVert);
end;

procedure TObjModel.ParseVertNormal(const _ALine: String);
var
  ALineValues: TStringDynArray;
  AVert: TPoint3D;
  AX, AY, AZ: Single;
  AFormatSettings: TFormatSettings;
  ALine: String;
begin
  ALine := StringReplace(_ALine, '  ', ' ', [rfReplaceAll]);
  ALineValues := SplitString(ALine, ' ');

  AFormatSettings := FormatSettings;
  AFormatSettings.DecimalSeparator := '.';

  AX := StrToFloat(ALineValues[1], AFormatSettings);
  AY := StrToFloat(ALineValues[2], AFormatSettings);
  AZ := StrToFloat(ALineValues[3], AFormatSettings);

  AVert := TPoint3D.Create(AX, AY, AZ);

  AddVertNormal(AVert);
end;

procedure TObjModel.ParseVertTexture(const _ALine: String);
var
  ALineValues: TStringDynArray;
  AVertTex: TPointF;
  AU, AV{, AW}: Single;
  AFormatSettings: TFormatSettings;
  ALine: String;
begin
  ALine := StringReplace(_ALine, '  ', ' ', [rfReplaceAll]);
  ALineValues := SplitString(ALine, ' ');

  AFormatSettings := FormatSettings;
  AFormatSettings.DecimalSeparator := '.';

  AU := StrToFloat(ALineValues[1], AFormatSettings);
  AV := StrToFloat(ALineValues[2], AFormatSettings);
//  AW := StrToFloatDef(ALineValues[4], 0, AFormatSettings);

  AVertTex := TPointF.Create(AU, AV{, AW});

  AddVertTexture(AVertTex);
end;

function TObjModel.Vert(i: Integer): TPoint3D;
begin
  result := FVerts[i];
end;

function TObjModel.VertCount: integer;
begin
  result := FVerts.Count;
end;

function TObjModel.VertNormal(i: Integer): TPoint3D;
begin
  result := FVertsNormal[i];
end;

function TObjModel.VertNormalCount: integer;
begin
  result := FVertsNormal.Count;
end;

function TObjModel.VertTexture(i: Integer): TPointF;
begin
  result := FVertsTexture[i];
end;

function TObjModel.VertTextureCount: integer;
begin
  result := FVertsTexture.Count;
end;

{ TFaceVertex }

constructor TFaceVertex.Create(_AIdPosition, _AIdUV, _AIdNormal: Integer);
begin
  IDPosition := _AIdPosition;
  IDUV := _AIdUV;
  IDNormal := _AIdNormal;
end;

end.
