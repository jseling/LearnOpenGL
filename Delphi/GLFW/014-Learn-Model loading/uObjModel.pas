{
https://en.wikipedia.org/wiki/Wavefront_.obj_file
}

unit uObjModel;

interface

uses
  System.Math.Vectors,
  uMesh;

type
  TFaceVertex = record
    IDPosition: Integer;
    IDUV: Integer;
    IDNormal: Integer;
    constructor Create(_AIdPosition, _AIdUV, _AIdNormal: Integer);
  end;

  TObjModel = class
  private
    FVerts: TArray<TPoint3D>;
    FVertsTexture: TArray<TPoint3D>;
    FVertsNormal: TArray<TPoint3D>;
    FFaces: TArray<TArray<TFaceVertex>>;

    procedure AddVert(_AVert: TPoint3D);
    procedure AddVertTexture(_AVert: TPoint3D);
    procedure AddVertNormal(_AVert: TPoint3D);
    procedure AddFace(_AFace: TArray<TFaceVertex>);

    procedure ParseVert(const _ALine: String);
    procedure ParseVertTexture(const _ALine: String);
    procedure ParseVertNormal(const _ALine: String);
    procedure ParseFace(const _ALine: String);

    procedure AddItem(var _AArray: TArray<TFaceVertex>; _AItem: TFaceVertex);

  public
    constructor Create(const _AFileName: String);
    function VertCount: integer;
    function FaceCount: integer;
    function Vert(i: Integer): TPoint3D;
    function VertTexture(i: Integer): TPoint3D;
    function Face(idx: Integer): TArray<TFaceVertex>;
  end;

implementation

uses
  System.Classes, SysUtils, StrUtils, System.Types;

{ TObjModel }

procedure TObjModel.AddFace(_AFace: TArray<TFaceVertex>);
begin
  SetLength(FFaces, Length(FFaces) + 1);
  FFaces[High(FFaces)] := _AFace;
end;

procedure TObjModel.AddItem(var _AArray: TArray<TFaceVertex>; _AItem: TFaceVertex);
begin
  SetLength(_AArray, Length(_AArray) + 1);
  _AArray[High(_AArray)] := _AItem;
end;

procedure TObjModel.AddVert(_AVert: TPoint3D);
begin
  SetLength(FVerts, Length(FVerts) + 1);
  FVerts[High(FVerts)] := _AVert;
end;

procedure TObjModel.AddVertNormal(_AVert: TPoint3D);
begin
  SetLength(FVertsNormal, Length(FVertsNormal) + 1);
  FVertsNormal[High(FVertsNormal)] := _AVert;
end;

procedure TObjModel.AddVertTexture(_AVert: TPoint3D);
begin
  SetLength(FVertsTexture, Length(FVertsTexture) + 1);
  FVertsTexture[High(FVertsTexture)] := _AVert;
end;

constructor TObjModel.Create(const _AFileName: String);
var
  AFile: TStringList;
  ALine: String;
begin
  AFile := TStringList.Create;
  try
    AFile.LoadFromFile(_AFileName);

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
  finally
    AFile.Free;
  end;
end;

function TObjModel.Face(idx: Integer): TArray<TFaceVertex>;
begin
  result := FFaces[idx];
end;

function TObjModel.FaceCount: integer;
begin
  result := Length(FFaces);
end;

procedure TObjModel.ParseFace(const _ALine: String);
var
  AFace: TArray<TFaceVertex>;
  i: integer;

  faceVertices: TStringDynArray;
  faceVertice: TStringDynArray;

  pos, uv, normal: integer;
begin
  Setlength(AFace, 0);

  faceVertices := SplitString(_ALine, ' ');

  for i:=1 to Length(faceVertices) - 1 do
  begin
    faceVertice := SplitString(faceVertices[i], '/');

    pos := StrToInt(faceVertice[0]) - 1;
    uv := StrToInt(faceVertice[1]) - 1;
    normal := StrToInt(faceVertice[2]) - 1;

    AddItem(AFace, TFaceVertex.Create(pos, uv, normal));
  end;

  AddFace(AFace);
end;

procedure TObjModel.ParseVert(const _ALine: String);
var
  ALineValues: TStringDynArray;
  AVert: TPoint3D;
  AX, AY, AZ: Single;
  AFormatSettings: TFormatSettings;
begin
  ALineValues := SplitString(_ALine, ' ');

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
begin
  ALineValues := SplitString(_ALine, ' ');

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
  AVert: TPoint3D;
  AU, AV, AW: Single;
  AFormatSettings: TFormatSettings;
begin
  ALineValues := SplitString(_ALine, ' ');

  AFormatSettings := FormatSettings;
  AFormatSettings.DecimalSeparator := '.';

  AU := StrToFloat(ALineValues[2], AFormatSettings);
  AV := StrToFloat(ALineValues[3], AFormatSettings);
  AW := StrToFloat(ALineValues[4], AFormatSettings);

  AVert := TPoint3D.Create(AU, AV, AW);

  AddVertTexture(AVert);
end;

function TObjModel.Vert(i: Integer): TPoint3D;
begin
  result := FVerts[i];
end;

function TObjModel.VertCount: integer;
begin
  result := Length(FVerts);
end;

function TObjModel.VertTexture(i: Integer): TPoint3D;
begin
  result := FVertsTexture[i];
end;

{ TFaceVertex }

constructor TFaceVertex.Create(_AIdPosition, _AIdUV, _AIdNormal: Integer);
begin
  IDPosition := _AIdPosition;
  IDUV := _AIdUV;
  IDNormal := _AIdNormal;
end;

end.
