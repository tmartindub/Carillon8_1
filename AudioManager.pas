unit AudioManager;
// Westminster Chimes and Carillon Bells
// Version: 8.1
// © 2026 All rights reserved
interface
uses
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.StdCtrls,
  FMX.Types,
  MMDevAPI,
  System.Classes,
  System.SysUtils,
  System.UIConsts,
  System.UITypes,
  System.Variants,
  System.Win.ComObj,
  Winapi.ActiveX,
  Winapi.Windows;
type
  TAudioMuteChangedEvent = procedure(Sender: TObject; Muted: Boolean) of object;

  TAudioManager = class(TObject)
  private
    FTrackBar: TTrackBar;
    FOldVolLevel: Single;
    FEndpointVolume: IAudioEndpointVolume;
    FEndpointVolumeCallback: IAudioEndpointVolumeCallback;
    FEndpointVolumeCallbackObj: TObject;
    FMuted: Boolean;
    FOnMuteChanged: TAudioMuteChangedEvent;
    FUpdatingTrackBarFromEndpoint: Boolean;
    procedure TrackBarChange(Sender: TObject);
    function TryGetEndpointMute(out Muted: Boolean): Boolean;
    procedure ToggleSystemMuteKey;
    procedure UpdateMuteState(const Muted: Boolean);
    procedure SetVolume(Volume: Single);
    procedure UpdateFromEndpoint(const Volume: Single; const Muted: Boolean);
    procedure UpdateTrackBarFromEndpointVolume(const Volume: Single);
  public
    constructor Create(ATrackBar: TTrackBar);
    destructor Destroy; override;
    procedure InitializeAudio;
    procedure SetMute(Value: Boolean);
    procedure ToggleMute;
    property Muted: Boolean read FMuted;
    property OldVolLevel: Single read FOldVolLevel;
    property OnMuteChanged: TAudioMuteChangedEvent read FOnMuteChanged write FOnMuteChanged;
  end;
implementation
const
  AudioManagerEventContext: TGUID = '{491BC1E3-9B6B-457C-9C6B-B4F0F50A76B0}';

type
  TEndpointVolumeCallback = class(TInterfacedObject, IAudioEndpointVolumeCallback)
  private
    FOwner: TAudioManager;
  public
    constructor Create(AOwner: TAudioManager);
    function OnNotify(pNotify: PAudioVolumeNotificationData): HRESULT; stdcall;
  end;

constructor TEndpointVolumeCallback.Create(AOwner: TAudioManager);
begin
  inherited Create;
  FOwner := AOwner;
end;

function TEndpointVolumeCallback.OnNotify(
  pNotify: PAudioVolumeNotificationData): HRESULT;
var
  NewVolume: Single;
  Muted: Boolean;
begin
  Result := S_OK;
  if (FOwner = nil) or (pNotify = nil) then
    Exit;
  if CompareMem(@pNotify^.guidEventContext, @AudioManagerEventContext,
    SizeOf(TGUID)) then
    Exit;
  NewVolume := pNotify^.fMasterVolume;
  Muted := pNotify^.bMuted <> 0;
  if GetCurrentThreadId = MainThreadID then
    FOwner.UpdateFromEndpoint(NewVolume, Muted)
  else
    TThread.Synchronize(nil,
      procedure
      begin
        if FOwner <> nil then
          FOwner.UpdateFromEndpoint(NewVolume, Muted);
      end);
end;

constructor TAudioManager.Create(ATrackBar: TTrackBar);
begin
  inherited Create;
  FTrackBar := ATrackBar;
  FOldVolLevel := 0;
  FEndpointVolume := nil;
  FEndpointVolumeCallback := nil;
  FEndpointVolumeCallbackObj := nil;
  FMuted := False;
  FOnMuteChanged := nil;
  FUpdatingTrackBarFromEndpoint := False;
end;
destructor TAudioManager.Destroy;
begin
  if FEndpointVolumeCallbackObj is TEndpointVolumeCallback then
    TEndpointVolumeCallback(FEndpointVolumeCallbackObj).FOwner := nil;
  if Assigned(FEndpointVolume) and Assigned(FEndpointVolumeCallback) then
    FEndpointVolume.UnregisterControlChangeNotify(FEndpointVolumeCallback);
  FEndpointVolumeCallback := nil;
  FEndpointVolumeCallbackObj := nil;
  FEndpointVolume := nil;
  inherited Destroy;
end;
procedure TAudioManager.InitializeAudio;
var
  deviceEnumerator: IMMDeviceEnumerator;
  defaultDevice: IMMDevice;
  currentVolume: Single;
  currentMute: Boolean;
  HR: HRESULT;
begin
  FEndpointVolume := nil;
  FEndpointVolumeCallback := nil;
  FEndpointVolumeCallbackObj := nil;
  // Create the device enumerator.
  HR := CoCreateInstance(CLASS_IMMDeviceEnumerator, nil, CLSCTX_INPROC_SERVER,
    IID_IMMDeviceEnumerator, deviceEnumerator);
  if Failed(HR) then
    Exit; // Handle error as needed
  // Get the default audio endpoint (render, console).
  HR := deviceEnumerator.GetDefaultAudioEndpoint(eRender, eConsole,
    defaultDevice);
  if Failed(HR) then
    Exit;
  // Activate the IAudioEndpointVolume interface.
  HR := defaultDevice.Activate(IID_IAudioEndpointVolume, CLSCTX_INPROC_SERVER,
    nil, FEndpointVolume);
  if Failed(HR) then
    Exit;
  // Retrieve the current volume level (0.0 to 1.0).
  HR := FEndpointVolume.GetMasterVolumeLevelScalar(currentVolume);
  if Succeeded(HR) then
  begin
    UpdateTrackBarFromEndpointVolume(currentVolume);
  end;
  if TryGetEndpointMute(currentMute) then
    UpdateMuteState(currentMute);
  FEndpointVolumeCallbackObj := TEndpointVolumeCallback.Create(Self);
  Supports(FEndpointVolumeCallbackObj, IAudioEndpointVolumeCallback,
    FEndpointVolumeCallback);
  FEndpointVolume.RegisterControlChangeNotify(FEndpointVolumeCallback);
  // Hook the trackbar's OnChange event.
  if Assigned(FTrackBar) then
    FTrackBar.OnChange := TrackBarChange;
end;
procedure TAudioManager.TrackBarChange(Sender: TObject);
var
  newVolume: Single;
begin
  if FUpdatingTrackBarFromEndpoint then
    Exit;
  if Assigned(FTrackBar) then
  begin
    // Convert the trackbar position (0..100) to a 0.0..1.0 scalar.
    newVolume := Round(FTrackBar.Value) / 100;
    SetVolume(newVolume);
  end;
end;
procedure TAudioManager.SetVolume(Volume: Single);
var
  wasMuted: Boolean;
begin
  if not Assigned(FEndpointVolume) then
    Exit;
  wasMuted := FMuted;
  if Succeeded(FEndpointVolume.SetMasterVolumeLevelScalar(Volume,
    @AudioManagerEventContext)) then
    FOldVolLevel := Volume;
  if wasMuted then
    FEndpointVolume.SetMute(1, @AudioManagerEventContext);
end;
procedure TAudioManager.ToggleSystemMuteKey;
begin
  keybd_event(VK_VOLUME_MUTE, 0, 0, 0);
  keybd_event(VK_VOLUME_MUTE, 0, KEYEVENTF_KEYUP, 0);
end;
procedure TAudioManager.UpdateMuteState(const Muted: Boolean);
begin
  FMuted := Muted;
  if Assigned(FOnMuteChanged) then
    FOnMuteChanged(Self, FMuted);
end;
procedure TAudioManager.UpdateFromEndpoint(const Volume: Single;
  const Muted: Boolean);
begin
  UpdateMuteState(Muted);
  UpdateTrackBarFromEndpointVolume(Volume);
end;
procedure TAudioManager.UpdateTrackBarFromEndpointVolume(const Volume: Single);
var
  NewTrackBarValue: Single;
begin
  FOldVolLevel := Volume;
  if not Assigned(FTrackBar) then
    Exit;
  NewTrackBarValue := Round(Volume * 100);
  if Abs(FTrackBar.Value - NewTrackBarValue) < 0.01 then
    Exit;
  FUpdatingTrackBarFromEndpoint := True;
  try
    FTrackBar.Value := NewTrackBarValue;
  finally
    FUpdatingTrackBarFromEndpoint := False;
  end;
end;
function TAudioManager.TryGetEndpointMute(out Muted: Boolean): Boolean;
var
  currentMute: Integer;
begin
  Result := Assigned(FEndpointVolume) and
    Succeeded(FEndpointVolume.GetMute(currentMute));
  if Result then
    Muted := currentMute <> 0
  else
    Muted := FMuted;
end;
procedure TAudioManager.SetMute(Value: Boolean);
var
  HR: HRESULT;
  bMute: Integer;
  currentMute: Boolean;
  DesiredApplied: Boolean;
begin
  DesiredApplied := False;
  if Value then
    bMute := 1
  else
    bMute := 0;

  if Assigned(FEndpointVolume) then
  begin
    HR := FEndpointVolume.SetMute(bMute, @AudioManagerEventContext);
    if Failed(HR) then
    begin
      DesiredApplied := False;
    end
    else
    begin
      if TryGetEndpointMute(currentMute) then
      begin
        DesiredApplied := currentMute = Value;
        UpdateMuteState(currentMute);
      end
      else
      begin
        DesiredApplied := True;
        UpdateMuteState(Value);
      end;
    end;
  end;

  if not DesiredApplied then
  begin
    ToggleSystemMuteKey;
    if TryGetEndpointMute(currentMute) then
      UpdateMuteState(currentMute)
    else
      UpdateMuteState(Value);
  end;
end;
procedure TAudioManager.ToggleMute;
var
  currentMute: Boolean;
begin
  if TryGetEndpointMute(currentMute) then
    SetMute(not currentMute)
  else
    SetMute(not FMuted);
end;
end.






