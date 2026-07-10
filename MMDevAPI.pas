unit MMDevAPI;
// Westminster Chimes and Carillon Bells
// Version: 8.1
// © 2026 All rights reserved
interface
uses
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Types,
  System.Classes,
  System.SysUtils,
  System.Variants,
  System.Win.ComObj,
  Winapi.ActiveX,
  Winapi.Windows;
const
  CLASS_IMMDeviceEnumerator: TGUID = '{BCDE0395-E52F-467C-8E3D-C4579291692E}';
  IID_IMMDeviceEnumerator: TGUID = '{A95664D2-9614-4F35-A746-DE8DB63617E6}';
  IID_IMMDevice: TGUID = '{D666063F-1587-4E43-81F1-B948E807363F}';
  IID_IMMDeviceCollection: TGUID = '{0BD7A1BE-7A1A-44DB-8397-CC5392387B5E}';
  IID_IAudioEndpointVolume: TGUID = '{5CDF2C82-841E-4546-9722-0CF74078229A}';
  IID_IAudioMeterInformation: TGUID = '{C02216F6-8C67-4B5B-9D00-D008E73E0064}';
  IID_IAudioEndpointVolumeCallback
    : TGUID = '{657804FA-D6AD-4496-8A60-352752AF4F89}';
  DEVICE_STATE_ACTIVE = $00000001;
  DEVICE_STATE_UNPLUGGED = $00000002;
  DEVICE_STATE_NOTPRESENT = $00000004;
  DEVICE_STATEMASK_ALL = $00000007;
type
  EDataFlow = TOleEnum;
const
  eRender = $00000000;
  eCapture = $00000001;
  eAll = $00000002;
  EDataFlow_enum_count = $00000003;
type
  ERole = TOleEnum;
const
  eConsole = $00000000;
  eMultimedia = $00000001;
  eCommunications = $00000002;
  ERole_enum_count = $00000003;
type
  PAudioVolumeNotificationData = ^TAudioVolumeNotificationData;
  TAudioVolumeNotificationData = record
    guidEventContext: TGUID;
    bMuted: Integer; // Windows BOOL, keep explicit for Core Audio ABI calls.
    fMasterVolume: Single;
    nChannels: UINT;
    afChannelVolumes: array[0..0] of Single;
  end;
  IAudioEndpointVolumeCallback = interface(IUnknown)
    ['{657804FA-D6AD-4496-8A60-352752AF4F89}']
    function OnNotify(pNotify: PAudioVolumeNotificationData): HRESULT; stdcall;
  end;
  IAudioEndpointVolume = interface(IUnknown)
    ['{5CDF2C82-841E-4546-9722-0CF74078229A}']
    function RegisterControlChangeNotify(AudioEndPtVol
      : IAudioEndpointVolumeCallback): Integer; stdcall;
    function UnregisterControlChangeNotify(AudioEndPtVol
      : IAudioEndpointVolumeCallback): Integer; stdcall;
    function GetChannelCount(out AChannelCount: UINT): Integer; stdcall;
    function SetMasterVolumeLevel(fLevelDB: single; pguidEventContext: PGUID)
      : Integer; stdcall;
    function SetMasterVolumeLevelScalar(fLevelDB: single;
      pguidEventContext: PGUID): Integer; stdcall;
    function GetMasterVolumeLevel(out fLevelDB: single): Integer; stdcall;
    function GetMasterVolumeLevelScalar(out fLevelDB: single): Integer; stdcall;
    function SetChannelVolumeLevel(nChannel: Integer; fLevelDB: single;
      pguidEventContext: PGUID): Integer; stdcall;
    function SetChannelVolumeLevelScalar(nChannel: Integer; fLevelDB: single;
      pguidEventContext: PGUID): Integer; stdcall;
    function GetChannelVolumeLevel(nChannel: Integer; out fLevelDB: single)
      : Integer; stdcall;
    function GetChannelVolumeLevelScalar(nChannel: Integer; out fLevel: single)
      : Integer; stdcall;
    function SetMute(bMute: Integer; pguidEventContext: PGUID)
      : Integer; stdcall;
    function GetMute(out bMute: Integer): Integer; stdcall;
    function GetVolumeStepInfo(out pnStep: Integer; out pnStepCount: Integer)
      : Integer; stdcall;
    function VolumeStepUp(pguidEventContext: PGUID): Integer; stdcall;
    function VolumeStepDown(pguidEventContext: PGUID): Integer; stdcall;
    function QueryHardwareSupport(out pdwHardwareSupportMask): Integer; stdcall;
    function GetVolumeRange(out pflVolumeMindB: single;
      out pflVolumeMaxdB: single; out pflVolumeIncrementdB: single)
      : Integer; stdcall;
  end;
  IAudioMeterInformation = interface(IUnknown)
    ['{C02216F6-8C67-4B5B-9D00-D008E73E0064}']
  end;
  IPropertyStore = interface(IUnknown)
  end;
  IMMDevice = interface(IUnknown)
    ['{D666063F-1587-4E43-81F1-B948E807363F}']
    function Activate(const refId: TGUID; dwClsCtx: DWORD;
      pActivationParams: PInteger; out pEndpointVolume: IAudioEndpointVolume)
      : Hresult; stdCall;
    function OpenPropertyStore(stgmAccess: DWORD;
      out ppProperties: IPropertyStore): Hresult; stdcall;
    function GetId(out ppstrId: PLPWSTR): Hresult; stdcall;
    function GetState(out State: Integer): Hresult; stdcall;
  end;
  IMMDeviceCollection = interface(IUnknown)
    ['{0BD7A1BE-7A1A-44DB-8397-CC5392387B5E}']
  end;
  IMMNotificationClient = interface(IUnknown)
    ['{7991EEC9-7E89-4D85-8390-6C703CEC60C0}']
  end;
  IMMDeviceEnumerator = interface(IUnknown)
    ['{A95664D2-9614-4F35-A746-DE8DB63617E6}']
    function EnumAudioEndpoints(dataFlow: EDataFlow; deviceState: SYSUINT;
      DevCollection: IMMDeviceCollection): Hresult; stdcall;
    function GetDefaultAudioEndpoint(EDF: SYSUINT; ER: SYSUINT;
      out Dev: IMMDevice): Hresult; stdcall;
    function GetDevice(pwstrId: pointer; out Dev: IMMDevice): Hresult; stdcall;
    function RegisterEndpointNotificationCallback
      (pClient: IMMNotificationClient): Hresult; stdcall;
  end;
implementation
end.





