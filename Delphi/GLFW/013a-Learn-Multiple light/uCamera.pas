unit uCamera;

interface

uses
  System.Math,
  System.Math.Vectors;

type
  TCameraMovement = (cmForward, cmBackward, cmLeft, cmRight, cmUp, cmDown);

  ICamera = interface
  ['{7EF3B9D7-2157-4AAA-B658-81C8A91B7B15}']
    procedure ProcessMouseScroll(_AYOffset: Single);
    procedure ProcessMouseMovement(_AXOffset, _AYOffset: Single; _AConstrainPitch : Boolean = True);
    procedure ProcessKeyboard(_AMovement: TCameraMovement; _ADeltaTime: Single);
    function GetViewMatrix(): TMatrix3D;
    function FOV: Single;
    function Position: TPoint3D;
    function Front: TPoint3D;
  end;

  TCamera = class(TInterfacedObject, ICamera)
  private
    FPosition: TPoint3D;
    FFront: TPoint3D;
    FUp: TPoint3D;
    FRight: TPoint3D;
    FWorldUp: TPoint3D;

    FPitch: Single;
    FYaw: Single;

    FMovementSpeed: Single;
    FMouseSensitivity: Single;
    FZoom: Single;

    function CalculateLookAt(pos, target, worldUp: TPoint3D): TMatrix3D;
    procedure UpdateCameraVectors();
  public
    constructor Create(_APosition, _AUp: TPoint3D; _AYaw: Single = -90; _APitch: Single = 0);
    procedure ProcessMouseScroll(_AYOffset: Single);
    procedure ProcessMouseMovement(_AXOffset, _AYOffset: Single; _AConstrainPitch : Boolean = True);
    procedure ProcessKeyboard(_AMovement: TCameraMovement; _ADeltaTime: Single);
    function GetViewMatrix(): TMatrix3D;
    function FOV: Single;
    function Position: TPoint3D;
    function Front: TPoint3D;
  end;

implementation

{ TCamera }

function TCamera.CalculateLookAt(pos, target, worldUp: TPoint3D): TMatrix3D;
var
  AXAxis,
  AYAxis,
  AZAxis: TPoint3D;
  ATranslation: TMatrix3D;
  ARotation: TMatrix3D;
begin
    // 1. Position = known
    // 2. Calculate cameraDirection
  AZAxis := (pos - target).Normalize();
      // 3. Get positive right axis vector
  AXAxis := worldUp.Normalize().CrossProduct(AZAxis).Normalize();
    // 4. Calculate camera up vector
  AYAxis := AZAxis.CrossProduct(AXAxis);

    // Create translation and rotation matrix
  ATranslation := TMatrix3D.Identity;   // Identity matrix by default
  ATranslation.m41 := -pos.X; // Fourth column, first row
  ATranslation.m42 := -pos.Y;
  ATranslation.m43 := -pos.Z;

  ARotation := TMatrix3D.Identity;
  ARotation.m11 := AXAxis.X;   // First column, first row
  ARotation.m21 := AXAxis.Y;
  ARotation.m31 := AXAxis.Z;

  ARotation.m12 := AYAxis.X;   // First column, second row
  ARotation.m22 := AYAxis.Y;
  ARotation.m32 := AYAxis.Z;

  ARotation.m13 := AZAxis.X;  // First column, third row
  ARotation.m23 := AZAxis.Y;
  ARotation.m33 := AZAxis.Z;

  result := ATranslation * ARotation;
end;

constructor TCamera.Create(_APosition, _AUp: TPoint3D; _AYaw: Single = -90; _APitch: Single = 0);
begin
  FPosition := _APosition;
  FWorldUp := _AUp;
  FYaw := _AYaw;
  FPitch := _APitch;

  FMovementSpeed := 2.5;
  FMouseSensitivity := 0.1;
  FZoom := 45;

  FFront := TPoint3D.Create(0, 0, -1);

  UpdateCameraVectors();
end;

function TCamera.FOV: Single;
begin
  result := FZoom;
end;

function TCamera.Front: TPoint3D;
begin
  result := FFront;
end;

function TCamera.GetViewMatrix: TMatrix3D;
begin
//  result := TMatrix3D.CreateLookAtRH(FPosition, FPosition + FFront, FUp)
  result := CalculateLookAt(FPosition, FPosition + FFront, FUp);
end;

function TCamera.Position: TPoint3D;
begin
  Result := FPosition;
end;

procedure TCamera.ProcessKeyboard(_AMovement: TCameraMovement; _ADeltaTime: Single);
var
  velocity: Single;
begin
  velocity := FMovementSpeed * _ADeltaTime;
  case _AMovement of
    cmForward: FPosition := FPosition + (FFront * velocity);
    cmBackward: FPosition := FPosition - (FFront * velocity);
    cmLeft: FPosition := FPosition - (FRight * velocity);
    cmRight: FPosition := FPosition + (FRight * velocity);
    cmUp: FPosition := FPosition + (FWorldUp * velocity);
    cmDown: FPosition := FPosition - (FWorldUp * velocity);
  end;
end;

procedure TCamera.ProcessMouseMovement(_AXOffset, _AYOffset: Single; _AConstrainPitch: Boolean);
var
  xoffset: Single;
  yoffset: Single;
begin
  xoffset := _AXOffset;
  yoffset := _AYOffset;

  xoffset := xoffset * FMouseSensitivity;
  yoffset := yoffset * FMouseSensitivity;

  FYaw := FYaw + xoffset;
  FPitch := FPitch + yoffset;

  if _AConstrainPitch then
  begin
    if(FPitch > 89.0) then
      FPitch :=  89.0;
    if(FPitch < -89.0) then
      FPitch := -89.0;
  end;

  UpdateCameraVectors();
end;

procedure TCamera.ProcessMouseScroll(_AYOffset: Single);
begin
  FZoom := FZoom - _AYOffset;
  if (FZoom < 1.0) then
    FZoom := 1.0;
  if (FZoom > 90.0) then
    FZoom := 90.0;
end;

procedure TCamera.UpdateCameraVectors();
begin
  FFront.x := Cos(DegToRad(FYaw)) * Cos(DegToRad(FPitch));
  FFront.y := Sin(DegToRad(FPitch));
  FFront.z := Sin(DegToRad(FYaw)) * Cos(DegToRad(FPitch));
  FFront := FFront.Normalize();

  FRight := FFront.CrossProduct(FWorldUp).Normalize();
  FUp := FRight.CrossProduct(FFront).Normalize();
end;

end.
