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

//    IDPositionObject: Integer;
//    IDUVObject: Integer;
//    IDNormalObject: Integer;
  end;

//  TObject = class
//  private
//  public
//
//  end;

  TFace = record
    Vertices: TArray<TFaceVertex>;
    IDMaterial: Integer;
    IDObject: Integer;
  end;

  TObjModel = class
  private
    FVerts: TList<TPoint3D>;
    FVertsTexture: TList<TPointF>;
    FVertsNormal: TList<TPoint3D>;
    FFaces: TList<TFace>;

    FObjects: TList<String>;
    FMaterials: TDictionary<String, Integer>;

    FCurrentMaterial: Integer;
    FIsNewObject: Boolean;

    procedure AddVert(_AVert: TPoint3D);
    procedure AddVertTexture(_AVert: TPointF);
    procedure AddVertNormal(_AVert: TPoint3D);
    procedure AddFace(_AFace: TFace);

    procedure ParseVert(const _ALine: String);
    procedure ParseVertTexture(const _ALine: String);
    procedure ParseVertNormal(const _ALine: String);
    procedure ParseFace(const _ALine: String);
    procedure ParseObject(const _ALine: String);
    procedure ParseMaterial(const _ALine: String);
  public
    constructor Create(const _AFileName: String);
    destructor Destroy; override;

    function Vert(i: Integer): TPoint3D;
    function VertCount: integer;

    function VertTexture(i: Integer): TPointF;
    function VertTextureCount: integer;

    function VertNormal(i: Integer): TPoint3D;
    function VertNormalCount: integer;

    function Face(idx: Integer): TFace;  //face=triangle
    function FaceCount: integer;
  end;

implementation

{ TObjModel }

procedure TObjModel.AddFace(_AFace: TFace);
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
//  AFile: TStringList;
  ALine: String;

  FileObj: TextFile;
begin
  FCurrentMaterial := -1;
  FIsNewObject := True;

  FVerts := TList<TPoint3D>.Create;
  FVertsTexture := TList<TPointF>.Create;
  FVertsNormal := TList<TPoint3D>.Create;
  FFaces := TList<TFace>.Create;
  FObjects := TList<String>.Create;
  FMaterials:= TDictionary<String, Integer>.Create;



//  AFile := TStringList.Create;
  AssignFile(FileObj, _AFileName);
  try
    Reset(FileObj);
//    AFile.LoadFromFile(_AFileName);

    OutputDebugString(PWideChar('Parsing TObjModel.'));

//    for ALine in AFile do
    while not EOF(FileObj) do
    begin
      ReadLn(FileObj, ALine);

      if Pos('o ', ALine) = 1 then
      begin
        ParseObject(ALine);
      end
      else if Pos('usemtl ', ALine) = 1 then
      begin
        ParseMaterial(ALine);
      end
      else if Pos('v ', ALine) = 1 then
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
//    AFile.Free;
    CloseFile(FileObj);
  end;
end;

destructor TObjModel.Destroy;
begin
  FVerts.Free;
  FVertsTexture.Free;
  FVertsNormal.Free;
  FFaces.Free;
  FObjects.Free;
  FMaterials.Free;
  inherited;
end;

function TObjModel.Face(idx: Integer): TFace;
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

  AFace: TFace;

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

//    APolygon[i - 1] := TFaceVertex.Create(pos, uv, normal);

    APolygon[i - 1].IDPosition := pos;
    APolygon[i - 1].IDUV := uv;
    APolygon[i - 1].IDNormal := normal;

//    APolygon[i - 1].IDPositionObject := pos;
//    APolygon[i - 1].IDUVObject := uv;
//    APolygon[i - 1].IDNormalObject := normal;
  end;

  APolygonTriangulated := TTriangulator.Triangulate<TFaceVertex>(APolygon);

  for ATriangle in APolygonTriangulated do
  begin
    if FCurrentMaterial = -1 then
      raise Exception.Create('Material not defined.');

    AFace.Vertices := ATriangle;
    AFace.IDMaterial := FCurrentMaterial;
    AFace.IDObject := FObjects.Count -1;
    AddFace(AFace);
  end;
end;

procedure TObjModel.ParseMaterial(const _ALine: String);
var
  ALineValues: TStringDynArray;
  ALine: String;
begin
  ALine := StringReplace(_ALine, '  ', ' ', [rfReplaceAll]);
  ALineValues := SplitString(ALine, ' ');


  if not FMaterials.ContainsKey(ALineValues[1]) then
    FMaterials.Add(ALineValues[1], FMaterials.Count);

  FCurrentMaterial := FMaterials.Items[ALineValues[1]];
end;

procedure TObjModel.ParseObject(const _ALine: String);
var
  ALineValues: TStringDynArray;
  ALine: String;
begin
  ALine := StringReplace(_ALine, '  ', ' ', [rfReplaceAll]);
  ALineValues := SplitString(ALine, ' ');

  FObjects.Add(ALineValues[1]);
  FIsNewObject := True;
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

//constructor TFaceVertex.Create(_AIdPosition, _AIdUV, _AIdNormal: Integer);
//begin
//  IDPosition := _AIdPosition;
//  IDUV := _AIdUV;
//  IDNormal := _AIdNormal;
//end;

end.
