unit uCamera;

interface

uses
  System.Math,
  System.Math.Vectors;

type
  TCameraMovement = (cmForward, cmBackward, cmLeft, cmRight);

  ICamera = interface
  ['{7EF3B9D7-2157-4AAA-B658-81C8A91B7B15}']
    procedure ProcessMouseScroll(_AYOffset: Single);
    procedure ProcessMouseMovement(_AXOffset, _AYOffset: Single; _AConstrainPitch : Boolean = True);
    procedure ProcessKeyboard(_AMovement: TCameraMovement; _ADeltaTime: Single);
    function GetViewMatrix(): TMatrix3D;
    function FOV: Single;
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

    procedure UpdateCameraVectors();
  public
    constructor Create(_APosition, _AUp: TPoint3D; _AYaw: Single = -90; _APitch: Single = 0);
    procedure ProcessMouseScroll(_AYOffset: Single);
    procedure ProcessMouseMovement(_AXOffset, _AYOffset: Single; _AConstrainPitch : Boolean = True);
    procedure ProcessKeyboard(_AMovement: TCameraMovement; _ADeltaTime: Single);
    function GetViewMatrix(): TMatrix3D;
    function FOV: Single;
  end;

implementation

{ TCamera }

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

function TCamera.GetViewMatrix: TMatrix3D;
begin
  result := TMatrix3D.CreateLookAtRH(FPosition, FPosition + FFront, FUp)
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
