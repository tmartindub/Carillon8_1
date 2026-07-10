unit Playlist;
// Westminster Chimes and Carillon Bells
// Version: 8.1
// © 2026 All rights reserved
interface
uses AudioManager, carillonSplash, ClockUnit, Data.Bind.Components, Data.Bind.Controls,
  Data.Bind.DBScope, Data.Bind.Grid, Data.DB, Data.FMTBcd, DateUtils,
  email, FireDAC.Comp.Client, FireDAC.Comp.DataSet, FireDAC.DApt, FireDAC.DApt.Intf,
  FireDAC.DatS, FireDAC.FMXUI.Wait, FireDAC.Phys, FireDAC.Phys.IB, FireDAC.Phys.IBDef,
  FireDAC.Phys.Intf, FireDAC.Phys.MySQL, FireDAC.Phys.MySQLDef, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.Stan.Async,
  FireDAC.Stan.Def, FireDAC.Stan.Error, FireDAC.Stan.ExprFuncs, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Pool, FireDAC.UI.Intf,
  Fmx.Bind.Editors, Fmx.Bind.Grid, Fmx.Bind.Navigator, FMX.ComboEdit, FMX.Controls,
  FMX.Dialogs, FMX.Edit, FMX.Effects, FMX.Forms, FMX.Graphics, FMX.Grid, FMX.Grid.Style, FMX.ImgList,
  FMX.Layouts, FMX.Media, FMX.Menus, FMX.Objects, FMX.Platform, FMX.StdCtrls, FMX.Types, GroupForm,
  FMX.Memo, FMX.WebBrowser,
  Math, Overlay, PowerHoldSimple, SettingsForm, System.Classes, System.Generics.Collections,
  System.Generics.Defaults, System.ImageList, System.IOUtils, System.Rtti, System.SysUtils,
  System.Types, System.UIConsts, System.UITypes, System.Variants, Winapi.ActiveX,
  Winapi.Messages, Winapi.MMSystem, Winapi.ShellAPI, Winapi.Windows, FMX.ScrollBox,
  FMX.Controls.Presentation, CarillonTheme, ScheduleManager, SilenceManager;
type
  TPlaylistGridRowKind = (pgrGroupHeader, pgrSong);
  TThemeButtonTier = (tbtPrimary, tbtSecondary, tbtDanger);
  TPlaylistGridRow = record
    DataSetRecordNo: Integer;
    DurationDisplay: string;
    GroupName: string;
    RowKind: TPlaylistGridRowKind;
    SongDisplay: string;
    VisibleSongIndex: Integer;
  end;
const
  StartPlaylistGroupsClosed = True; // Change True to start closed, or False to start open.
  MainContentDesignWidth: Single = 1597.0;
  MainContentDesignHeight: Single = 837.0;
type
  TfmDailyPlayList = class(TForm)
    ADOConnection1: TFDConnection;
    ADOQuery1: TFDQuery;
    ADOQuery2: TFDQuery;
    btnCloseAllGroups: TButton;
    btnOpenAllGroups: TButton;
    btnPausePlay: TButton;
    btnPlaySong: TButton;
    btnStopPlay: TButton;
    chkEnableSchedule: TCheckBox;
    chkEnableScheduledPanel: TPanel;
    chkPlayFriday: TCheckBox;
    chkPlayMonday: TCheckBox;
    chkPlaySaturday: TCheckBox;
    chkPlaySunday: TCheckBox;
    chkPlayThursday: TCheckBox;
    chkPlayTuesday: TCheckBox;
    chkPlayWednesday: TCheckBox;
    Colors1: TMenuItem;
    DataSource1: TDataSource;
    DBComboBox1: TComboEdit;
    DBGrid1: TStringGrid;
    DBNavigator1: TBindNavigator;
    DisplayClock: TMenuItem;
    DisplayClock1: TMenuItem;
    DisplayHelp1: TMenuItem;
    //dsPlayList: TDataSource;
    edFollowingDays: TLabel;
    EditGroups1: TMenuItem;
    EditGroups3: TMenuItem;
    EditSettings1: TMenuItem;
    edPLPlayDateFrom: TEdit;
    edPLPlayDateTo: TEdit;
    edPLTimeToPlay1: TEdit;
    edPLTimeToPlay2: TEdit;
    edPLTimeToPlay3: TEdit;
    edPLTimeToPlay4: TEdit;
    edPLTimeToPlay5: TEdit;
    edPLTimeToPlay6: TEdit;
    edPLTimeToPlay7: TEdit;
    edPLTimeToPlay8: TEdit;
    edPLTimeToPlay9: TEdit;
    edPLTimeToPlay10: TEdit;
    edPLTimeToPlay11: TEdit;
    edPLTimeToPlay12: TEdit;
    Exit1: TMenuItem;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    FDTransaction1: TFDTransaction;
    File1: TMenuItem;
    File2: TMenuItem;
    gbDatesSeasons: TLayout;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Help1: TMenuItem;
    ImageList1: TImageList;
    KeepUSBAliveTimer: TTimer;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label9: TLabel;
    lblPlayDateFrom: TLabel;
    lblPlayDateFromAndOrSeason: TLabel;
    lblPlayDateTo: TLabel;
    lblPlayTimes: TLabel;
    lblRandSongPlaying: TLabel;
    lblSchedule: TLabel;
    lblScheduleStatus: TLabel;
    lblTimesToPlay: TLabel;
    MainMenu1: TMenuBar;
    mbMuteButton: TButton;
    miThemeAtlanticTeal: TMenuItem;
    miThemeCobaltHarbor: TMenuItem;
    miThemeCopperDawn: TMenuItem;
    miThemeCranberrySilk: TMenuItem;
    miThemeEmeraldGlass: TMenuItem;
    miThemeGraphiteIce: TMenuItem;
    miDefault: TMenuItem;
    miEditDirectories1: TMenuItem;
    miEmailSettings: TMenuItem;
    miSilenceSchedule: TMenuItem;
    miThemeIndigoVelvet: TMenuItem;
    miThemeMidnightCopper: TMenuItem;
    miThemePineGold: TMenuItem;
    miThemeRoyalCurrent: TMenuItem;
    miThemeVerdantSlate: TMenuItem;
    MP3MediaPlayer: TMediaPlayer;
    OpenDialog1: TOpenDialog;
    Panel1: TLayout;
    Panel2: TPanel;
    PlaylistConnection: TFDConnection;
    PlaylistQuery: TFDQuery;
    PlaylistNumTimesToPlayField: TIntegerField;
    PlaylistPlayDateFromField: TDateField;
    PlaylistPlayDateToField: TDateField;
    PlaylistPlayFridayField: TIntegerField;
    PlaylistPlayMondayField: TIntegerField;
    PlaylistPlaySaturdayField: TIntegerField;
    PlaylistPlaySundayField: TIntegerField;
    PlaylistPlayThursdayField: TIntegerField;
    PlaylistPlayTuesdayField: TIntegerField;
    PlaylistPlayWednesdayField: TIntegerField;
    PlaylistNameField: TWideMemoField;
    PlaylistScheduledTime1Field: TTimeField;
    PlaylistScheduledTime2Field: TTimeField;
    PlaylistScheduledTime3Field: TTimeField;
    PlaylistScheduledTime4Field: TTimeField;
    PlaylistScheduledTime5Field: TTimeField;
    PlaylistScheduledTime6Field: TTimeField;
    PlaylistScheduledTime7Field: TTimeField;
    PlaylistScheduledTime8Field: TTimeField;
    PlaylistScheduledTime9Field: TTimeField;
    PlaylistScheduledTime10Field: TTimeField;
    PlaylistScheduledTime11Field: TTimeField;
    PlaylistScheduledTime12Field: TTimeField;
    PlaylistSeasonField: TWideMemoField;
    PlaylistSongDurationField: TWideMemoField;
    PlaylistSongNameField: TWideMemoField;
    plDataSource: TDataSource;
    plNumberOfTimesToPlay: TEdit;
    RandomDirectories1: TMenuItem;
    ShowLog1: TMenuItem;
    ScheduleTimer: TTimer;
    Settings1: TMenuItem;
    ShowRemainingSchedule1: TMenuItem;
    StatusBar1: TStatusBar;
    tbPlaylist: TFDTable;
    Timer1: TTimer;
    tmRebuildSched: TTimer;
    TrackBar1: TTrackBar;
    procedure plbtnDoneClick(Sender: TObject);
    procedure btnCloseAllGroupsClick(Sender: TObject);
    procedure btnOpenAllGroupsClick(Sender: TObject);
    procedure btnPlaySongClick(Sender: TObject);
    procedure btnPausePlayClick(Sender: TObject);
    procedure btnStopPlayClick(Sender: TObject);
    procedure DBComboBox1DropDown(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure DBNavigator1BeforeAction(Sender: TObject; Button: TBindNavigateBtn);
    procedure tbPlaylistAfterPost(DataSet: TDataSet);
    procedure Button1Click(Sender: TObject);
    procedure chkEnableScheduleClick(Sender: TObject);
    procedure ScheduleTimerTimer(Sender: TObject);
    procedure MP3MediaPlayerNotify(Sender: TObject);
    procedure tmRebuildSchedTimer(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure ShowSchedule1Click(Sender: TObject);
    procedure ShowSchedule2Click(Sender: TObject);
    procedure DBComboBox1Change(Sender: TObject);
    procedure DBGrid1CellClick(const Column: TColumn; const Row: Integer);
    procedure DBGrid1ColEnter(Sender: TObject);
    procedure EditGroups3Click(Sender: TObject);
    procedure PlaylistQueryAfterScroll(DataSet: TDataSet);
    procedure ResizeFormForResolution(AForm: TForm);
    procedure ReturnToPlaylistClick(Sender: TObject);
    procedure edPLPlayDateToExit(Sender: TObject);
    procedure PlaySelectedSong;
    procedure RefreshGrid;
    procedure CenterForm(AForm: TForm);
    procedure CompileSchedule;
    procedure ShowSchedule;
    procedure ShowRemainingPlaylist;
    procedure UpdatePlaylistFromSeasonalGroups;
    procedure ToggleFieldsEnabledState(Enabled: Boolean);
    procedure UpdateFieldStateBasedOnSeasonalGroup;
    procedure UpdateFieldStatesForAllRecords;
  // // FMX manual review: procedure WMSysCommand(var Msg: TWMSysCommand); message WM_SYSCOMMAND; - handle through FMX events
    procedure Clock1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure OpenDialog1Show(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF; const Row: Integer; const Value: TValue; const State: TGridDrawStates);
    procedure EditSettings1Click(Sender: TObject);
    procedure DisplayHelp1Click(Sender: TObject);
    procedure ShowLog1Click(Sender: TObject);
    procedure Colors1Click(Sender: TObject);
    procedure gbDatesSeasonsEnter(Sender: TObject);
    procedure PlaylistQueryAfterDelete(DataSet: TDataSet);
    procedure PlaylistQueryAfterPost(DataSet: TDataSet);
    procedure PlaylistQueryAfterCancel(DataSet: TDataSet);
    procedure FormDestroy(Sender: TObject);
    procedure DisableSchedule;
    procedure AddToLog(const Msg: string);
    procedure SendToEmail(const Msg: string);
    procedure mbMuteButtonClick(Sender: TObject);
    procedure miScheduleRestartClick(Sender: TObject);
    procedure miEmailSettingsClick(Sender: TObject);
    procedure miSilenceScheduleClick(Sender: TObject);
    function ConvertToRelativePath(const FullPath: string): string;
    procedure KeepUSBAliveTimerTimer(Sender: TObject);
    procedure mManageDirectories1Click(Sender: TObject);
  Private
    FApplicationEventService: IFMXApplicationEventService;
    FPlaylistBindSource: TBindSourceDB;
    FGeneratedFormCreateRan: Boolean;
    FGeneratedMediaNotifyHandler_MP3MediaPlayer: TNotifyEvent;
    FGeneratedMediaNotifyTimer_MP3MediaPlayer: TTimer;
    FGeneratedMediaNotifyWasPlaying_MP3MediaPlayer: Boolean;
    FGeneratedShuttingDown: Boolean;
    FGeneratedToggleOriginalChange_chkEnableSchedule: TNotifyEvent;
    FGeneratedToggleOriginalClick_chkEnableSchedule: TNotifyEvent;
    FGeneratedToggleSuppress_chkEnableSchedule: Integer;
    FOriginal_DBNavigator1_BeforeAction: EBindNavClick;
    FOriginal_DBComboBox1_OnChange: TNotifyEvent;
    FOriginal_DBComboBox1_OnClosePopup: TNotifyEvent;
    FOriginal_DBComboBox1_OnPopup: TNotifyEvent;
    FOriginal_PlaylistQuery_AfterOpen: TDataSetNotifyEvent;
    FOriginal_PlaylistQuery_OnCalcFields: TDataSetNotifyEvent;
    FPlayedSongCountToday: Integer;
    FPlaylistGridRows: TList<TPlaylistGridRow>;
    FPlaylistGridStartupClosedPending: Boolean;
    FPlaylistGridSelectionSyncDepth: Integer;
    FUpdatingSeasonGroupComboBox: Integer;
    FPlaylistGridRebuildDepth: Integer;
    FPlaylistGridStartCollapsed: TDictionary<string, Boolean>;
    FPlaylistEditSchedulePaused: Boolean;
    FLastScheduleRebuildDate: TDateTime;
    FSkipNextPlaylistGridSelectionSync: Boolean;
    Link_chkPlayFriday: TLinkPropertyToField;
    Link_chkPlayMonday: TLinkPropertyToField;
    Link_chkPlaySaturday: TLinkPropertyToField;
    Link_chkPlaySunday: TLinkPropertyToField;
    Link_chkPlayThursday: TLinkPropertyToField;
    Link_chkPlayTuesday: TLinkPropertyToField;
    Link_chkPlayWednesday: TLinkPropertyToField;
    //FOldVolLevel: Single; // Store the current volume here
    AudioManager: TAudioManager;
    FSilenceManager: TSilenceManager;
    // Now Playing countdown timer
    FCountdownActive: Boolean;
    FThemeAccentColor: TAlphaColor;
    FThemeButtonColor: TAlphaColor;
    FThemeButtonDangerColor: TAlphaColor;
    FThemeButtonDangerTextColor: TAlphaColor;
    FThemeButtonSecondaryColor: TAlphaColor;
    FThemeButtonSecondaryTextColor: TAlphaColor;
    FThemeButtonTextColor: TAlphaColor;
    FThemeCardTextColor: TAlphaColor;
    FCurrentColorThemeIndex: Integer;
    FCurrentSongIsRandom: Boolean;
    FThemeGridEvenColor: TAlphaColor;
    FThemeGridGroupColor: TAlphaColor;
    FThemeGridGroupSelectedColor: TAlphaColor;
    FThemeGridHeaderColor: TAlphaColor;
    FThemeGridHeaderTextColor: TAlphaColor;
    FThemeGroupBoxFrameColor: TAlphaColor;
    FThemeGridOddColor: TAlphaColor;
    FThemeGridSelectedColor: TAlphaColor;
    FThemeGridSelectedTextColor: TAlphaColor;
    FThemeInputColor: TAlphaColor;
    FThemeInputStrokeColor: TAlphaColor;
    FThemeLabelAccentColor: TAlphaColor;
    FNowPlayingCaptionBase: string;
    FThemePanelStrokeColor: TAlphaColor;
    FThemeRaisedSurfaceColor: TAlphaColor;
    FThemeSurfaceColor: TAlphaColor;
    FCurrentSongStartTick: UInt64;
    FCurrentSongDurationSeconds: Integer;
    FResponsiveMainLayout: TScaledLayout;
    procedure plDataSource_GeneratedDataChange(Sender: TObject; Field: TField);
    procedure DBNavigator1_GeneratedBeforeAction(Sender: TObject; Button: TBindNavigateBtn);
    procedure DBComboBox1_SyncFromField;
    procedure DBComboBox1_GeneratedOnChange(Sender: TObject);
    procedure DBComboBox1_GeneratedOnPopup(Sender: TObject);
    procedure DBComboBox1_GeneratedOnClosePopup(Sender: TObject);
    procedure PlaylistQuery_GeneratedCalcFields(DataSet: TDataSet);
    procedure DBGrid1_GeneratedMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
    procedure PlaylistQuery_GeneratedAfterOpen(DataSet: TDataSet);
    procedure GeneratedSetToggleState_chkEnableSchedule(AValue: Boolean);
    procedure chkEnableSchedule_GeneratedUserChange(Sender: TObject);
    procedure GeneratedRegisterMediaNotify_MP3MediaPlayer(AHandler: TNotifyEvent);
    procedure GeneratedSetMediaNotifyEnabled_MP3MediaPlayer(AEnabled: Boolean);
    procedure GeneratedMediaNotifyTimer_MP3MediaPlayer(Sender: TObject);
    procedure AudioManagerMuteChanged(Sender: TObject; Muted: Boolean);
    procedure SilenceManagerStateChanged(Sender: TObject; Active: Boolean;
      const Purpose: string; UntilTime: TDateTime);
    procedure DBGrid1CellDblClick(const Column: TColumn; const Row: Integer);
    function DurationStrToSeconds(const S: string): Integer;
    function FormatRemainingMMSS(SecondsLeft: Integer): string;
    procedure BeginPlaylistEditSession;
    procedure EndPlaylistEditSession;
    procedure UpdateNowPlayingLabel;
    procedure StartNowPlayingCountdown;
    procedure StopNowPlayingCountdown;
    procedure PrepareOverlay;
    procedure ApplyFormTheme(const ABackgroundColor, AFontColor: TAlphaColor;
      const AIncludeInteractiveText: Boolean);
    procedure ApplyColorThemeByIndex(const AThemeIndex: Integer;
      const APersist: Boolean);
    procedure ApplyScheduleStatusTheme;
    procedure ApplyThemePalette(const AThemeIndex: Integer;
      const ABackgroundColor, AFontColor: TAlphaColor);
    procedure ApplyThemeToButton(const AButton: TButton);
    procedure ApplyThemeToCheckBox(const ACheckBox: TCheckBox;
      const AIncludeInteractiveText: Boolean);
    procedure ApplyHeroGradient(const ARectangle: TRectangle;
      const AStartColor, AEndColor: TAlphaColor);
    procedure ApplyHeroVisualTheme;
    procedure ApplyStatusBarTheme;
    procedure ApplyThemeToGrid;
    procedure ApplyThemeToInput(const AControl: TStyledControl);
    procedure ApplyThemeToScheduleInputs;
    procedure ApplyThemeToPlayerGroupBoxes;
    procedure ApplyThemeToLabel(const ALabel: TLabel);
    procedure ApplyThemeToSurface(const AControl: TStyledControl;
      const AFillColor: TAlphaColor);
    procedure ThemeGroupBoxPaint(Sender: TObject; Canvas: TCanvas;
      const ARect: TRectF);
    procedure ApplyThemeButtonStyle(const AButton: TButton;
      const ATier: TThemeButtonTier);
    procedure ConfigureColorThemeMenu;
    procedure DBGrid1DrawColumnHeader(Sender: TObject; const Canvas: TCanvas;
      const Column: TColumn; const Bounds: TRectF);
    function FindColorThemeIndex(const ABackgroundColor,
      AFontColor: TAlphaColor): Integer;
    function FindColorThemeIndexByMenuName(const AMenuItemName: string): Integer;
    function FindColorThemeMenuItem(const AMenuItemName: string): TMenuItem;
    procedure EnsureCheckBoxLink(var ALink: TLinkPropertyToField;
      ACheckBox: TCheckBox; const AFieldName: string);
    function GetThemeButtonTier(const AButton: TButton): TThemeButtonTier;
    function TryResolveSelectedSong(out ASongPath: string;
      out ANumberOfTimes: Integer): Boolean;
    procedure ResolveRandomSongIfNeeded(var ASongPath: string);
    procedure ResolveSongDurationFromPlaylist;
    procedure CenterNowPlayingLabelInHero;
    procedure ShowNowPlaying(const ASongPath: string;
      const AResolveDurationFromPlaylist: Boolean = True);
    procedure HideNowPlaying;
    procedure InitializeResponsiveMainLayout;
    procedure UpdateResponsiveMainLayoutScale;
    procedure PlaySongRepeats(ANumberOfTimes: Integer);
    procedure PlayScheduledEntry(const AEntry: TScheduleEntry);
    function IsSongAlreadyInDailyPlaylist(const AFileName: string): Boolean;
    function GetMediaDurationText(const AFileName: string): string;
    procedure AddSongFileToPlaylist(const AFileName: string);
    procedure BeginOrderlyShutdown;
    function HandleApplicationEvent(AAppEvent: TApplicationEvent;
      AContext: TObject): Boolean;
    procedure InsertSelectedSongs;
    procedure EnsurePlaylistGridColumns;
    function FindPlaylistGridHeaderRow(const AGroupName: string): Integer;
    function FindPlaylistGridRowByRecordNo(const ARecordNo: Integer): Integer;
    function FormatPlaylistGroupDuration(const ATotalSeconds: Integer): string;
    function IsPlaylistGroupCollapsed(const AGroupName: string): Boolean;
    function NormalizePlaylistGroupName(const AGroupName: string): string;
    procedure RebuildPlaylistGrid;
    procedure ResetPlaylistGridToStartupState;
    procedure ScrollPlaylistGridRowToTop(const ARow: Integer);
    procedure SelectPlaylistGridRow(const ARow: Integer);
    procedure SetAllPlaylistGroupsCollapsed(const ACollapsed: Boolean);
    procedure SetPlaylistGroupCollapsed(const AGroupName: string;
      const ACollapsed: Boolean);
    procedure SetupStatusBar;
    procedure SyncPlaylistGridSelectionFromDataSet(
      const AExpandCurrentGroup: Boolean);
    function TrySyncDataSetToScheduledEntry(
      const AEntry: TScheduleEntry): Boolean;
    procedure TogglePlaylistGroup(const AGroupName: string);
    function TrySyncDataSetFromPlaylistGridRow(const ARow: Integer): Boolean;
    procedure UpdateStatusBar(const LastSongFullPath: string = '');
    procedure DBGrid1SelectionChanged(Sender: TObject);
    function BuildScheduleDisplayText(const AOnlyRemaining: Boolean): string;
    procedure SaveCurrentThemeColors;
    procedure ShowScheduleDialog(const ATitle, AText: string);
    procedure UpdateColorThemeMenuChecks;
  public
    MyRecNo: Integer;
    StartTime: TDateTime;
    procedure RefreshSilenceRulesAndSchedule;
  end;
procedure RetrieveRandSongsDirectory(var RandSongsDir: string);
var
  fmDailyPlayList: TfmDailyPlayList;
  NextScheduleEntryId: Integer;
  IsPlaybackInProgress: Boolean;
  PlaybackSchedule: TList<TScheduleEntry>;
  FormBackgroundColor: TAlphaColor; // global variable
  FormFontColor: TAlphaColor; // global variable
implementation
uses FMX.Platform.Win, LogManager, LogViewerForm, RandomDirectory, RandomDirectoryManager, SilenceScheduleForm;
{$R *.fmx}
var
  GeneratedCanvasCurrentPoint: TPointF;
  GeneratedCanvasCurrentPointCanvas: TCanvas;
  GeneratedCapturedGradientBottomColor: TAlphaColor;
  GeneratedCapturedGradientBottomY: Single;
  GeneratedCapturedGradientCanvas: TCanvas;
  GeneratedCapturedGradientRect: TRectF;
  GeneratedCapturedGradientTopColor: TAlphaColor;
  GeneratedCapturedGradientTopY: Single;
  GeneratedCapturedGradientValid: Boolean;
  GeneratedLastFillCanvas: TCanvas;
  GeneratedLastFillColor: TAlphaColor;
  GeneratedLastFillRect: TRectF;
  GeneratedLastFillValid: Boolean;
function GeneratedClientRect(const AObject: TObject): TRect;
begin
  if AObject is TControl then
    Result := Rect(0, 0, Round(TControl(AObject).Width), Round(TControl(AObject).Height))
  else if AObject is TCommonCustomForm then
    Result := Rect(0, 0, Round(TCommonCustomForm(AObject).ClientWidth), Round(TCommonCustomForm(AObject).ClientHeight))
  else
    Result := Rect(0, 0, 0, 0);
end;
function GeneratedRectF(const R: TRect): TRectF;
begin
  Result := TRectF.Create(R.Left, R.Top, R.Right, R.Bottom);
end;
procedure GeneratedCanvasFillRect(ACanvas: TCanvas; const R: TRect);
var
  RF: TRectF;
begin
  RF := GeneratedRectF(R);
  GeneratedLastFillCanvas := ACanvas;
  GeneratedLastFillRect := RF;
  GeneratedLastFillColor := ACanvas.Fill.Color;
  GeneratedLastFillValid := True;
  ACanvas.Fill.Kind := TBrushKind.Solid;
  ACanvas.FillRect(RF, 0, 0, AllCorners, 1);
end;
procedure GeneratedCanvasMoveTo(ACanvas: TCanvas; const X, Y: Single);
begin
  GeneratedCanvasCurrentPointCanvas := ACanvas;
  GeneratedCanvasCurrentPoint := PointF(X, Y);
end;
procedure GeneratedCanvasLineTo(ACanvas: TCanvas; const X, Y: Single);
var
  P1: TPointF;
  L: Single;
  R: Single;
begin
  if GeneratedCanvasCurrentPointCanvas = ACanvas then
    P1 := GeneratedCanvasCurrentPoint
  else
    P1 := PointF(X, Y);
  ACanvas.Stroke.Kind := TBrushKind.Solid;
  ACanvas.DrawLine(P1, PointF(X, Y), 1);
  if Abs(P1.Y - Y) <= 0.5 then
  begin
    if P1.X <= X then
    begin
      L := P1.X;
      R := X;
    end
    else
    begin
      L := X;
      R := P1.X;
    end;
    if (not GeneratedCapturedGradientValid) or (GeneratedCapturedGradientCanvas <> ACanvas) then
    begin
      GeneratedCapturedGradientCanvas := ACanvas;
      GeneratedCapturedGradientRect := TRectF.Create(L, Y, R, Y);
      GeneratedCapturedGradientTopY := Y;
      GeneratedCapturedGradientBottomY := Y;
      GeneratedCapturedGradientTopColor := ACanvas.Stroke.Color;
      GeneratedCapturedGradientBottomColor := ACanvas.Stroke.Color;
      GeneratedCapturedGradientValid := True;
    end
    else
    begin
      if L < GeneratedCapturedGradientRect.Left then
        GeneratedCapturedGradientRect.Left := L;
      if R > GeneratedCapturedGradientRect.Right then
        GeneratedCapturedGradientRect.Right := R;
      if Y < GeneratedCapturedGradientTopY then
      begin
        GeneratedCapturedGradientTopY := Y;
        GeneratedCapturedGradientTopColor := ACanvas.Stroke.Color;
      end;
      if Y > GeneratedCapturedGradientBottomY then
      begin
        GeneratedCapturedGradientBottomY := Y;
        GeneratedCapturedGradientBottomColor := ACanvas.Stroke.Color;
      end;
      if Y < GeneratedCapturedGradientRect.Top then
        GeneratedCapturedGradientRect.Top := Y;
      if Y > GeneratedCapturedGradientRect.Bottom then
        GeneratedCapturedGradientRect.Bottom := Y;
    end;
  end;
  GeneratedCanvasCurrentPointCanvas := ACanvas;
  GeneratedCanvasCurrentPoint := PointF(X, Y);
end;
procedure GeneratedCanvasRoundRect(ACanvas: TCanvas; const Left, Top, Right, Bottom, RadiusX, RadiusY: Single);
var
  RoundRectF: TRectF;
  OriginalFillKind: TBrushKind;
  OriginalFillColor: TAlphaColor;
begin
  RoundRectF := TRectF.Create(Left, Top, Right, Bottom);
  OriginalFillKind := ACanvas.Fill.Kind;
  OriginalFillColor := ACanvas.Fill.Color;
  if GeneratedLastFillValid and (GeneratedLastFillCanvas = ACanvas) and
     (Abs(GeneratedLastFillRect.Left - (Left - 1)) <= 2) and
     (Abs(GeneratedLastFillRect.Top - (Top - 1)) <= 2) and
     (Abs(GeneratedLastFillRect.Right - (Right + 1)) <= 2) and
     (Abs(GeneratedLastFillRect.Bottom - (Bottom + 1)) <= 2) then
  begin
    ACanvas.Fill.Kind := TBrushKind.Solid;
    ACanvas.Fill.Color := GeneratedLastFillColor;
    ACanvas.FillRect(GeneratedLastFillRect, 0, 0, AllCorners, 1);
    ACanvas.Fill.Kind := OriginalFillKind;
    ACanvas.Fill.Color := OriginalFillColor;
  end;
  if (OriginalFillKind = TBrushKind.None) and GeneratedCapturedGradientValid and
     (GeneratedCapturedGradientCanvas = ACanvas) and
     (Abs(GeneratedCapturedGradientRect.Left - (Left - 1)) <= 2) and
     (Abs(GeneratedCapturedGradientRect.Top - (Top - 1)) <= 2) and
     (Abs(GeneratedCapturedGradientRect.Right - (Right + 1)) <= 2) and
     (Abs(GeneratedCapturedGradientRect.Bottom - (Bottom + 1)) <= 2) then
  begin
    ACanvas.Fill.Kind := TBrushKind.Gradient;
    ACanvas.Fill.Gradient.Style := TGradientStyle.Linear;
    ACanvas.Fill.Gradient.Points[0].Color := GeneratedCapturedGradientTopColor;
    ACanvas.Fill.Gradient.Points[0].Offset := 0;
    ACanvas.Fill.Gradient.Points[1].Color := GeneratedCapturedGradientBottomColor;
    ACanvas.Fill.Gradient.Points[1].Offset := 1;
    ACanvas.Fill.Gradient.StartPosition.Point := PointF(0, 0);
    ACanvas.Fill.Gradient.StopPosition.Point := PointF(0, 1);
    ACanvas.FillRect(RoundRectF, RadiusX, RadiusY, AllCorners, 1);
    ACanvas.Fill.Kind := OriginalFillKind;
    ACanvas.Fill.Color := OriginalFillColor;
    GeneratedCapturedGradientValid := False;
  end;
  if (OriginalFillKind <> TBrushKind.None) and not GeneratedCapturedGradientValid then
  begin
    ACanvas.Fill.Kind := OriginalFillKind;
    ACanvas.Fill.Color := OriginalFillColor;
    ACanvas.FillRect(RoundRectF, RadiusX, RadiusY, AllCorners, 1);
  end;
  GeneratedLastFillValid := False;
  ACanvas.Stroke.Kind := TBrushKind.Solid;
  ACanvas.DrawRect(RoundRectF, RadiusX, RadiusY, AllCorners, 1);
end;
procedure GeneratedSetVerticalGradientFill(ACanvas: TCanvas; const R: TRect; const TopColor, BottomColor: TAlphaColor);
begin
  ACanvas.Fill.Kind := TBrushKind.Gradient;
  ACanvas.Fill.Gradient.Style := TGradientStyle.Linear;
  ACanvas.Fill.Gradient.Points[0].Color := TopColor;
  ACanvas.Fill.Gradient.Points[0].Offset := 0;
  ACanvas.Fill.Gradient.Points[1].Color := BottomColor;
  ACanvas.Fill.Gradient.Points[1].Offset := 1;
  ACanvas.Fill.Gradient.StartPosition.Point := PointF(0, 0);
  ACanvas.Fill.Gradient.StopPosition.Point := PointF(0, 1);
end;
procedure GeneratedCanvasStretchDraw(ACanvas: TCanvas; const R: TRect; const Bitmap: FMX.Graphics.TBitmap);
begin
  if Assigned(Bitmap) and not Bitmap.IsEmpty then
    ACanvas.DrawBitmap(Bitmap, TRectF.Create(0, 0, Bitmap.Width, Bitmap.Height), GeneratedRectF(R), 1);
end;
function GeneratedRGB(const R, G, B: Integer): TAlphaColor;
begin
  Result := TAlphaColor($FF000000 or ((Cardinal(R) and $FF) shl 16) or
    ((Cardinal(G) and $FF) shl 8) or (Cardinal(B) and $FF));
end;
function GeneratedColorToRGB(const Color: TAlphaColor): Cardinal;
begin
  Result := Cardinal(TAlphaColorRec(Color).R) or (Cardinal(TAlphaColorRec(Color).G) shl 8) or
    (Cardinal(TAlphaColorRec(Color).B) shl 16);
end;
function GeneratedGetRValue(const Color: Cardinal): Byte;
begin
  if (Color and $FF000000) <> 0 then
    Result := TAlphaColorRec(TAlphaColor(Color)).R
  else
    Result := GetRValue(Color);
end;
function GeneratedGetGValue(const Color: Cardinal): Byte;
begin
  if (Color and $FF000000) <> 0 then
    Result := TAlphaColorRec(TAlphaColor(Color)).G
  else
    Result := GetGValue(Color);
end;
function GeneratedGetBValue(const Color: Cardinal): Byte;
begin
  if (Color and $FF000000) <> 0 then
    Result := TAlphaColorRec(TAlphaColor(Color)).B
  else
    Result := GetBValue(Color);
end;
procedure GeneratedSetCanvasTextColor(ATarget: TObject; const AColor: TAlphaColor);
var
  LTextSettings: ITextSettings;
begin
  if ATarget is TCanvas then
  begin
    TCanvas(ATarget).Fill.Kind := TBrushKind.Solid;
    TCanvas(ATarget).Fill.Color := AColor;
  end
  else if Supports(ATarget, ITextSettings, LTextSettings) then
  begin
    LTextSettings.StyledSettings := LTextSettings.StyledSettings - [TStyledSetting.FontColor];
    LTextSettings.TextSettings.FontColor := AColor;
  end;
end;
procedure GeneratedSyncAutoSizeTextHeight(ATarget: TObject; const ASize: Single);
var
  LLabel: TLabel;
  LDesiredHeight: Single;
begin
  if (ASize <= 0) or not (ATarget is TLabel) then
    Exit;
  LLabel := TLabel(ATarget);
  if not LLabel.AutoSize then
    Exit;
  if LLabel.WordWrap then
    Exit;
  LDesiredHeight := ASize * 1.38;
  if LLabel.Height < LDesiredHeight then
    LLabel.Height := LDesiredHeight;
end;
procedure GeneratedSetCanvasFontPixelHeight(ATarget: TObject; const APixels: Integer);
var
  LTextSettings: ITextSettings;
  LFontSize: Single;
begin
  if APixels <= 0 then
    Exit;
  LFontSize := APixels * 72 / 96;
  if ATarget is TCanvas then
    TCanvas(ATarget).Font.Size := LFontSize
  else if Supports(ATarget, ITextSettings, LTextSettings) then
  begin
    LTextSettings.StyledSettings := LTextSettings.StyledSettings - [TStyledSetting.Size];
    LTextSettings.TextSettings.Font.Size := LFontSize;
  end;
  GeneratedSyncAutoSizeTextHeight(ATarget, LFontSize);
end;
procedure GeneratedSetCanvasFontSize(ATarget: TObject; const ASize: Single);
var
  LTextSettings: ITextSettings;
begin
  if ASize <= 0 then
    Exit;
  if ATarget is TCanvas then
    TCanvas(ATarget).Font.Size := ASize
  else if Supports(ATarget, ITextSettings, LTextSettings) then
  begin
    LTextSettings.StyledSettings := LTextSettings.StyledSettings - [TStyledSetting.Size];
    LTextSettings.TextSettings.Font.Size := ASize;
  end;
  GeneratedSyncAutoSizeTextHeight(ATarget, ASize);
end;
procedure GeneratedDrawText(ACanvas: TCanvas; const AText: string; var ARect: TRect; const AFlags: Cardinal);
var
  RF: TRectF;
  WordWrap: Boolean;
  CalcRect: Boolean;
  HAlign: TTextAlign;
  VAlign: TTextAlign;
begin
  RF := GeneratedRectF(ARect);
  WordWrap := (AFlags and DT_WORDBREAK) <> 0;
  CalcRect := (AFlags and DT_CALCRECT) <> 0;
  if (AFlags and DT_CENTER) <> 0 then
    HAlign := TTextAlign.Center
  else if (AFlags and DT_RIGHT) <> 0 then
    HAlign := TTextAlign.Trailing
  else
    HAlign := TTextAlign.Leading;
  if (AFlags and DT_VCENTER) <> 0 then
    VAlign := TTextAlign.Center
  else if (AFlags and DT_BOTTOM) <> 0 then
    VAlign := TTextAlign.Trailing
  else
    VAlign := TTextAlign.Leading;
  if CalcRect then
  begin
    ACanvas.MeasureText(RF, AText, WordWrap, [], HAlign, VAlign);
    ARect := Rect(Trunc(RF.Left), Trunc(RF.Top), Round(RF.Right), Round(RF.Bottom));
  end
  else
    ACanvas.FillText(RF, AText, WordWrap, 1, [], HAlign, VAlign);
end;
procedure ApplyGridSelectionColor(const AGrid: TFmxObject; const Color: TAlphaColor);
var
  Styled: TStyledControl;
  StyleObj: TFmxObject;
  procedure ApplySelectionToStyleTree(const Node: TFmxObject);
  var
    J: Integer;
    TintObj: ITintedObject;
  begin
    if Node = nil then
      Exit;
    if Supports(Node, ITintedObject, TintObj) then
      TintObj.TintColor := Color;
    if Node is TShape then
    begin
      TShape(Node).Fill.Color := Color;
      TShape(Node).Stroke.Color := Color;
    end;
    for J := 0 to Node.ChildrenCount - 1 do
      ApplySelectionToStyleTree(Node.Children[J]);
  end;
begin
  if not (AGrid is TStyledControl) then
    Exit;
  Styled := TStyledControl(AGrid);
  Styled.ApplyStyleLookup;
  Styled.StylesData['selection.Fill.Color'] := TValue.From<TAlphaColor>(Color);
  Styled.StylesData['selection.Stroke.Color'] := TValue.From<TAlphaColor>(Color);
  Styled.StylesData['focus.Fill.Color'] := TValue.From<TAlphaColor>(Color);
  Styled.StylesData['focus.Stroke.Color'] := TValue.From<TAlphaColor>(Color);
  StyleObj := nil;
  if Styled.FindStyleResource<TFmxObject>('selection', StyleObj) then
    ApplySelectionToStyleTree(StyleObj);
  StyleObj := nil;
  if Styled.FindStyleResource<TFmxObject>('focus', StyleObj) then
    ApplySelectionToStyleTree(StyleObj);
end;
function GetReadableVclTextColor(const ABackgroundColor: Integer): Integer;
begin
  if GetVclColorLuminance(ABackgroundColor) >= 0.58 then
    Result := RGB(34, 38, 45)
  else
    Result := RGB(245, 244, 240);
end;
function GetReadableVclButtonTextColor(const ABackgroundColor: Integer): Integer;
begin
  Result := RGB(34, 38, 45);
end;
function GetReadableAccentLabelVclColor(const AAccentColor,
  ABackgroundColor: Integer): Integer;
var
  BackgroundLuminance: Double;
begin
  BackgroundLuminance := GetVclColorLuminance(ABackgroundColor);
  if BackgroundLuminance < 0.40 then
    Result := BlendVclColors(AAccentColor, RGB(255, 255, 255), 0.24)
  else if BackgroundLuminance < 0.56 then
    Result := BlendVclColors(AAccentColor, RGB(255, 255, 255), 0.18)
  else
    Result := ShiftVclColor(AAccentColor, -0.36);
end;
procedure ApplyStyledResourceColor(const Target: TFmxObject;
  const ResourceName: string; const FillColor, StrokeColor: TAlphaColor);
var
  Styled: TStyledControl;
  StyleObj: TFmxObject;
  procedure ApplyColorToStyleTree(const Node: TFmxObject);
  var
    J: Integer;
    TintObj: ITintedObject;
  begin
    if Node = nil then
      Exit;
    if Supports(Node, ITintedObject, TintObj) then
      TintObj.TintColor := FillColor;
    if Node is TBrushObject then
    begin
      TBrushObject(Node).Brush.Kind := TBrushKind.Solid;
      TBrushObject(Node).Brush.Color := FillColor;
    end;
    if Node is TShape then
    begin
      if TShape(Node).Fill.Kind <> TBrushKind.None then
        TShape(Node).Fill.Color := FillColor;
      TShape(Node).Stroke.Kind := TBrushKind.Solid;
      TShape(Node).Stroke.Color := StrokeColor;
    end;
    for J := 0 to Node.ChildrenCount - 1 do
      ApplyColorToStyleTree(Node.Children[J]);
  end;
begin
  if not (Target is TStyledControl) then
    Exit;
  Styled := TStyledControl(Target);
  Styled.ApplyStyleLookup;
  if SameText(ResourceName, 'background') then
  begin
    Styled.StylesData['background.Fill.Color'] := TValue.From<TAlphaColor>(FillColor);
    Styled.StylesData['background.Stroke.Color'] := TValue.From<TAlphaColor>(StrokeColor);
    Styled.StylesData['Background.Fill.Color'] := TValue.From<TAlphaColor>(FillColor);
    Styled.StylesData['Background.Stroke.Color'] := TValue.From<TAlphaColor>(StrokeColor);
  end;
  StyleObj := nil;
  if Styled.FindStyleResource<TFmxObject>(ResourceName, StyleObj) or
     (SameText(ResourceName, 'background') and
      Styled.FindStyleResource<TFmxObject>('Background', StyleObj)) then
    ApplyColorToStyleTree(StyleObj);
end;
procedure ApplyStyledResourceTextColor(const Target: TFmxObject;
  const ResourceName: string; const TextColor: TAlphaColor);
var
  Styled: TStyledControl;
  StyleObj: TFmxObject;
  procedure ApplyTextToStyleTree(const Node: TFmxObject);
  var
    J: Integer;
  begin
    if Node = nil then
      Exit;
    GeneratedSetCanvasTextColor(Node, TextColor);
    for J := 0 to Node.ChildrenCount - 1 do
      ApplyTextToStyleTree(Node.Children[J]);
  end;
begin
  if not (Target is TStyledControl) then
    Exit;
  Styled := TStyledControl(Target);
  Styled.ApplyStyleLookup;
  Styled.StylesData[ResourceName + '.TextSettings.FontColor'] :=
    TValue.From<TAlphaColor>(TextColor);
  Styled.StylesData[ResourceName + '.FontColor'] :=
    TValue.From<TAlphaColor>(TextColor);
  StyleObj := nil;
  if Styled.FindStyleResource<TFmxObject>(ResourceName, StyleObj) then
    ApplyTextToStyleTree(StyleObj);
end;
procedure ApplyStyledResourceShapeMetrics(const Target: TFmxObject;
  const ResourceName: string; const AXRadius, AYRadius,
  AStrokeThickness: Single);
var
  Styled: TStyledControl;
  StyleObj: TFmxObject;
  procedure ApplyMetricsToStyleTree(const Node: TFmxObject);
  var
    J: Integer;
  begin
    if Node = nil then
      Exit;
    if Node is TShape then
      TShape(Node).Stroke.Thickness := AStrokeThickness;
    if Node is TRectangle then
    begin
      TRectangle(Node).XRadius := AXRadius;
      TRectangle(Node).YRadius := AYRadius;
    end;
    for J := 0 to Node.ChildrenCount - 1 do
      ApplyMetricsToStyleTree(Node.Children[J]);
  end;
begin
  if not (Target is TStyledControl) then
    Exit;
  Styled := TStyledControl(Target);
  Styled.ApplyStyleLookup;
  StyleObj := nil;
  if Styled.FindStyleResource<TFmxObject>(ResourceName, StyleObj) or
     (SameText(ResourceName, 'background') and
      Styled.FindStyleResource<TFmxObject>('Background', StyleObj)) then
    ApplyMetricsToStyleTree(StyleObj);
end;
type
  TGeneratedManualFieldBinding = class
  public
    Control: TCustomEdit;
    DataSet: TDataSet;
    FieldName: string;
    Guard: Integer;
    OriginalChangeTracking: TNotifyEvent;
    OriginalExit: TNotifyEvent;
    OriginalKeyDown: TKeyEvent;
    Owner: TComponent;
  end;
  TGeneratedManualFieldBindingHandler = class
  public
    procedure GeneratedManualFieldChangeTracking(Sender: TObject);
    procedure GeneratedManualFieldExit(Sender: TObject);
    procedure GeneratedManualFieldKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
  end;
var
  GeneratedManualFieldBindingHandler: TGeneratedManualFieldBindingHandler;
  GeneratedManualFieldBindingList: TObjectList<TGeneratedManualFieldBinding>;
  GeneratedManualFieldBindingMap: TObjectDictionary<TObject, TGeneratedManualFieldBinding>;
procedure GeneratedEnsureManualFieldBindingInfra;
begin
  if GeneratedManualFieldBindingList = nil then
    GeneratedManualFieldBindingList := TObjectList<TGeneratedManualFieldBinding>.Create(True);
  if GeneratedManualFieldBindingMap = nil then
    GeneratedManualFieldBindingMap := TObjectDictionary<TObject, TGeneratedManualFieldBinding>.Create;
  if GeneratedManualFieldBindingHandler = nil then
    GeneratedManualFieldBindingHandler := TGeneratedManualFieldBindingHandler.Create;
end;
function GeneratedFindManualFieldBinding(const AControl: TObject): TGeneratedManualFieldBinding;
begin
  Result := nil;
  if (GeneratedManualFieldBindingMap <> nil) and (AControl <> nil) then
    GeneratedManualFieldBindingMap.TryGetValue(AControl, Result);
end;
function GeneratedFormatBoundTimeDisplay(const AValue: TDateTime): string;
begin
  Result := FormatDateTime('h:nn:ss AM/PM', Frac(AValue));
end;
function GeneratedFormatBoundFieldDisplayText(AField: TField): string;
var
  LFieldName: string;
  LValue: string;
  LDateTime: TDateTime;
  FS: TFormatSettings;
begin
  Result := '';
  if (AField = nil) or AField.IsNull then
    Exit;
  LFieldName := UpperCase(AField.FieldName);
  if (AField.DataType = ftTime) or
     (((Pos('_TIME', LFieldName) > 0) or (Pos('TIME_', LFieldName) > 0) or
       (Pos('PLAY_TIME', LFieldName) > 0) or (Pos('SCHEDULED_TIME', LFieldName) > 0)) and
      (Pos('DATE', LFieldName) = 0)) then
  begin
    FS := TFormatSettings.Create;
    LValue := Trim(AField.AsString);
    if TryStrToDateTime(LValue, LDateTime, FS) or TryStrToTime(LValue, LDateTime, FS) then
      Exit(GeneratedFormatBoundTimeDisplay(LDateTime));
    try
      Exit(GeneratedFormatBoundTimeDisplay(AField.AsDateTime));
    except
      Result := AField.DisplayText;
    end;
    Exit;
  end;
  Result := AField.DisplayText;
end;

function GeneratedGetManualFieldDisplayText(AControl: TCustomEdit): string;
var
  Binding: TGeneratedManualFieldBinding;
  LField: TField;
begin
  Result := '';
  if AControl = nil then
    Exit;
  Result := AControl.Text;
  Binding := GeneratedFindManualFieldBinding(AControl);
  if (Binding = nil) or not Assigned(Binding.DataSet) or not Binding.DataSet.Active or Binding.DataSet.IsEmpty then
    Exit;
  LField := Binding.DataSet.FindField(Binding.FieldName);
  if LField <> nil then
    Result := GeneratedFormatBoundFieldDisplayText(LField);
end;
function GeneratedTryParseBoundDate(const AInput: string; out AValue: TDateTime): Boolean;
var
  LText: string;
  FS: TFormatSettings;
  Parts: TArray<string>;
  A, B, C: Integer;
  Y, M, D: Word;
begin
  AValue := 0;
  LText := Trim(AInput);
  if LText = '' then
    Exit(False);
  FS := TFormatSettings.Create;
  if TryStrToDate(LText, AValue, FS) or TryStrToDateTime(LText, AValue, FS) then
  begin
    AValue := Trunc(AValue);
    Exit(True);
  end;
  LText := StringReplace(LText, '-', '/', [rfReplaceAll]);
  LText := StringReplace(LText, '.', '/', [rfReplaceAll]);
  Parts := LText.Split(['/']);
  if Length(Parts) <> 3 then
    Exit(False);
  if not TryStrToInt(Trim(Parts[0]), A) then
    Exit(False);
  if not TryStrToInt(Trim(Parts[1]), B) then
    Exit(False);
  if not TryStrToInt(Trim(Parts[2]), C) then
    Exit(False);
  if Length(Trim(Parts[0])) = 4 then
  begin
    Y := A; M := B; D := C;
  end
  else
  begin
    Y := C;
    if Y < 100 then
      if Y < 50 then Inc(Y, 2000) else Inc(Y, 1900);
    if A > 12 then
    begin
      D := A; M := B;
    end
    else if B > 12 then
    begin
      M := A; D := B;
    end
    else
    begin
      M := A; D := B;
    end;
  end;
  try
    AValue := EncodeDate(Y, M, D);
    Result := True;
  except
    Result := False;
  end;
end;
function GeneratedTryParseBoundTime(const AInput: string; out AValue: TDateTime): Boolean;
var
  LText: string;
  FS: TFormatSettings;
  Hours: Integer;
  Minutes: Integer;
  Seconds: Integer;
  Parts: TArray<string>;
  Suffix: string;
begin
  AValue := 0;
  LText := UpperCase(Trim(AInput));
  if LText = '' then
    Exit(False);
  FS := TFormatSettings.Create;
  if TryStrToTime(LText, AValue, FS) or TryStrToDateTime(LText, AValue, FS) then
  begin
    AValue := Frac(AValue);
    Exit(True);
  end;
  LText := StringReplace(LText, '.', ':', [rfReplaceAll]);
  while Pos('  ', LText) > 0 do
    LText := StringReplace(LText, '  ', ' ', [rfReplaceAll]);
  Suffix := '';
  if Length(LText) >= 2 then
  begin
    if SameText(Copy(LText, Length(LText) - 1, 2), 'AM') or
       SameText(Copy(LText, Length(LText) - 1, 2), 'PM') then
    begin
      Suffix := Copy(LText, Length(LText) - 1, 2);
      Delete(LText, Length(LText) - 1, 2);
      LText := Trim(LText);
    end;
  end;
  Hours := 0;
  Minutes := 0;
  Seconds := 0;
  if Pos(':', LText) = 0 then
  begin
    if (Suffix = '') and (Length(LText) in [3, 4]) then
    begin
      if not TryStrToInt(Copy(LText, 1, Length(LText) - 2), Hours) then
        Exit(False);
      if not TryStrToInt(Copy(LText, Length(LText) - 1, 2), Minutes) then
        Exit(False);
    end
    else
    begin
      if not TryStrToInt(LText, Hours) then
        Exit(False);
    end;
  end
  else
  begin
    Parts := LText.Split([':']);
    if (Length(Parts) < 2) or (Length(Parts) > 3) then
      Exit(False);
    if not TryStrToInt(Trim(Parts[0]), Hours) then
      Exit(False);
    if not TryStrToInt(Trim(Parts[1]), Minutes) then
      Exit(False);
    if Length(Parts) = 3 then
      if not TryStrToInt(Trim(Parts[2]), Seconds) then
        Exit(False);
  end;
  if (Minutes < 0) or (Minutes > 59) or (Seconds < 0) or (Seconds > 59) then
    Exit(False);
  if Suffix = 'AM' then
  begin
    if (Hours < 1) or (Hours > 12) then
      Exit(False);
    if Hours = 12 then
      Hours := 0;
  end
  else if Suffix = 'PM' then
  begin
    if (Hours < 1) or (Hours > 12) then
      Exit(False);
    if Hours < 12 then
      Inc(Hours, 12);
  end
  else if (Hours < 0) or (Hours > 23) then
    Exit(False);
  try
    AValue := EncodeTime(Hours, Minutes, Seconds, 0);
    Result := True;
  except
    Result := False;
  end;
end;
function GeneratedAssignBoundFieldValue(AField: TField; const AInput: string; out ANormalized: string; out AError: string): Boolean;
var
  LValue: string;
  LDateTime: TDateTime;
  LFieldName: string;
begin
  ANormalized := '';
  AError := '';
  if AField = nil then
    Exit(False);
  LValue := Trim(AInput);
  if LValue = '' then
  begin
    AField.Clear;
    ANormalized := '';
    Exit(True);
  end;
  if Assigned(AField.OnSetText) or Assigned(AField.OnGetText) then
  begin
    try
      AField.Text := LValue;
      ANormalized := AField.DisplayText;
      Exit(True);
    except
      on E: Exception do
      begin
        AError := E.Message;
        Exit(False);
      end;
    end;
  end;
  LFieldName := UpperCase(AField.FieldName);
  if (AField.DataType = ftTime) or
     (((AField.DataType in [ftUnknown, ftString, ftWideString, ftMemo, ftWideMemo, ftFmtMemo, ftFixedChar, ftFixedWideChar]) and
       ((Pos('_TIME', LFieldName) > 0) or (Pos('TIME_', LFieldName) > 0) or (Pos('PLAY_TIME', LFieldName) > 0) or (Pos('SCHEDULED_TIME', LFieldName) > 0))) and
      (Pos('DATE', LFieldName) = 0)) then
  begin
    if not GeneratedTryParseBoundTime(LValue, LDateTime) then
    begin
      AError := '"' + AInput + '" is not a valid time.';
      Exit(False);
    end;
    AField.AsString := FormatDateTime('h:nn:ss AM/PM', LDateTime);
    ANormalized := GeneratedFormatBoundTimeDisplay(LDateTime);
    Exit(True);
  end;
  if (AField.DataType in [ftDate, ftDateTime, ftTimeStamp]) or
     ((AField.DataType in [ftUnknown, ftString, ftWideString, ftMemo, ftWideMemo, ftFmtMemo, ftFixedChar, ftFixedWideChar]) and
      (Pos('DATE', LFieldName) > 0)) then
  begin
    if not GeneratedTryParseBoundDate(LValue, LDateTime) then
    begin
      AError := '"' + AInput + '" is not a valid date.';
      Exit(False);
    end;
    AField.AsDateTime := LDateTime;
    ANormalized := AField.DisplayText;
    Exit(True);
  end;
  try
    AField.Text := LValue;
    ANormalized := AField.DisplayText;
    Result := True;
  except
    on E: Exception do
    begin
      AError := E.Message;
      Result := False;
    end;
  end;
end;
procedure GeneratedSyncManualFieldBinding(const ABinding: TGeneratedManualFieldBinding);
var
  LField: TField;
  LText: string;
begin
  if (ABinding = nil) or (ABinding.Control = nil) then
    Exit;
  if ABinding.Guard > 0 then
    Exit;
  if (ABinding.Owner <> nil) and (csDestroying in ABinding.Owner.ComponentState) then
    Exit;
  if csDestroying in ABinding.Control.ComponentState then
    Exit;
  if ABinding.Control.IsFocused then
    Exit;
  LText := '';
  if Assigned(ABinding.DataSet) and ABinding.DataSet.Active and (not ABinding.DataSet.IsEmpty) then
  begin
    LField := ABinding.DataSet.FindField(ABinding.FieldName);
    if LField <> nil then
      LText := GeneratedFormatBoundFieldDisplayText(LField);
  end;
  Inc(ABinding.Guard);
  try
    if ABinding.Control.Text <> LText then
      ABinding.Control.Text := LText;
  finally
    Dec(ABinding.Guard);
  end;
end;
procedure GeneratedSyncManualFieldBindingsForDataSet(const ADataSet: TDataSet);
var
  Binding: TGeneratedManualFieldBinding;
begin
  if (ADataSet = nil) or (GeneratedManualFieldBindingList = nil) then
    Exit;
  for Binding in GeneratedManualFieldBindingList do
    if Binding.DataSet = ADataSet then
      GeneratedSyncManualFieldBinding(Binding);
end;
procedure TGeneratedManualFieldBindingHandler.GeneratedManualFieldChangeTracking(Sender: TObject);
var
  Binding: TGeneratedManualFieldBinding;
begin
  Binding := GeneratedFindManualFieldBinding(Sender);
  if (Binding = nil) or (Binding.Guard > 0) then
    Exit;
  if (Binding.Owner <> nil) and (csDestroying in Binding.Owner.ComponentState) then
    Exit;
  if (Binding.Control <> nil) and (csDestroying in Binding.Control.ComponentState) then
    Exit;
  if not Assigned(Binding.DataSet) or not Binding.DataSet.Active or Binding.DataSet.IsEmpty then
    Exit;
  if not (Binding.DataSet.State in dsEditModes) then
  begin
    if Assigned(fmDailyPlayList) then
      fmDailyPlayList.BeginPlaylistEditSession;
    Binding.DataSet.Edit;
  end;
  if Assigned(Binding.OriginalChangeTracking) then
    Binding.OriginalChangeTracking(Sender);
end;
procedure TGeneratedManualFieldBindingHandler.GeneratedManualFieldExit(Sender: TObject);
var
  Binding: TGeneratedManualFieldBinding;
  LField: TField;
  LNormalized: string;
  LError: string;
  LCurrentText: string;
begin
  Binding := GeneratedFindManualFieldBinding(Sender);
  if (Binding = nil) or (Binding.Control = nil) or (Binding.Guard > 0) then
    Exit;
  if (Binding.Owner <> nil) and (csDestroying in Binding.Owner.ComponentState) then
    Exit;
  if csDestroying in Binding.Control.ComponentState then
    Exit;
  if not Assigned(Binding.DataSet) or not Binding.DataSet.Active or Binding.DataSet.IsEmpty then
    Exit;
  LField := Binding.DataSet.FindField(Binding.FieldName);
  if LField = nil then
    Exit;
  if not (Binding.DataSet.State in dsEditModes) then
  begin
    LCurrentText := GeneratedFormatBoundFieldDisplayText(LField);
    if Trim(Binding.Control.Text) = Trim(LCurrentText) then
    begin
      if Assigned(Binding.OriginalExit) then
        Binding.OriginalExit(Sender);
      Exit;
    end;
    if Assigned(fmDailyPlayList) then
      fmDailyPlayList.BeginPlaylistEditSession;
    Binding.DataSet.Edit;
  end;
  if not GeneratedAssignBoundFieldValue(LField, Binding.Control.Text, LNormalized, LError) then
  begin
    Inc(Binding.Guard);
    try
      if LError <> '' then
        ShowMessage(LError);
      GeneratedSyncManualFieldBinding(Binding);
    finally
      Dec(Binding.Guard);
    end;
    Exit;
  end;
  Inc(Binding.Guard);
  try
    if Binding.Control.Text <> LNormalized then
      Binding.Control.Text := LNormalized;
  finally
    Dec(Binding.Guard);
  end;
  if Assigned(Binding.OriginalExit) then
    Binding.OriginalExit(Sender);
end;
procedure TGeneratedManualFieldBindingHandler.GeneratedManualFieldKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
var
  Binding: TGeneratedManualFieldBinding;
begin
  Binding := GeneratedFindManualFieldBinding(Sender);
  if Key = vkReturn then
  begin
    GeneratedManualFieldBindingHandler.GeneratedManualFieldExit(Sender);
    Key := 0;
    KeyChar := #0;
    Exit;
  end;
  if (Binding <> nil) and Assigned(Binding.OriginalKeyDown) then
    Binding.OriginalKeyDown(Sender, Key, KeyChar, Shift);
end;
procedure GeneratedCommitManualFieldBindingsForDataSet(const ADataSet: TDataSet);
var
  Binding: TGeneratedManualFieldBinding;
begin
  if (ADataSet = nil) or (GeneratedManualFieldBindingList = nil) then
    Exit;
  for Binding in GeneratedManualFieldBindingList do
    if (Binding.DataSet = ADataSet) and (Binding.Control <> nil) then
      GeneratedManualFieldBindingHandler.GeneratedManualFieldExit(Binding.Control);
end;
procedure GeneratedRegisterManualFieldBinding(AControl: TCustomEdit; ADataSet: TDataSet; const AFieldName: string);
var
  Binding: TGeneratedManualFieldBinding;
begin
  if (AControl = nil) or (ADataSet = nil) or (Trim(AFieldName) = '') then
    Exit;
  GeneratedEnsureManualFieldBindingInfra;
  Binding := GeneratedFindManualFieldBinding(AControl);
  if Binding <> nil then
    Exit;
  Binding := TGeneratedManualFieldBinding.Create;
  Binding.Control := AControl;
  Binding.Owner := AControl.Owner;
  Binding.DataSet := ADataSet;
  Binding.FieldName := AFieldName;
  Binding.OriginalChangeTracking := AControl.OnChangeTracking;
  Binding.OriginalExit := AControl.OnExit;
  Binding.OriginalKeyDown := AControl.OnKeyDown;
  Binding.Guard := 0;
  GeneratedManualFieldBindingList.Add(Binding);
  GeneratedManualFieldBindingMap.Add(AControl, Binding);
  AControl.OnChangeTracking := GeneratedManualFieldBindingHandler.GeneratedManualFieldChangeTracking;
  AControl.OnExit := GeneratedManualFieldBindingHandler.GeneratedManualFieldExit;
  AControl.OnKeyDown := GeneratedManualFieldBindingHandler.GeneratedManualFieldKeyDown;
  GeneratedSyncManualFieldBinding(Binding);
end;
procedure GeneratedCleanupManualFieldBindingsForOwner(const AOwner: TComponent);
var
  I: Integer;
  Binding: TGeneratedManualFieldBinding;
begin
  if GeneratedManualFieldBindingList <> nil then
    for I := GeneratedManualFieldBindingList.Count - 1 downto 0 do
    begin
      Binding := GeneratedManualFieldBindingList[I];
      if Binding <> nil then
      begin
        if Binding.Control <> nil then
        begin
          Binding.Control.OnChangeTracking := nil;
          Binding.Control.OnExit := nil;
          Binding.Control.OnKeyDown := nil;
          if GeneratedManualFieldBindingMap <> nil then
            GeneratedManualFieldBindingMap.Remove(Binding.Control);
        end;
        Binding.Control := nil;
        Binding.Owner := nil;
        Binding.DataSet := nil;
        Binding.OriginalChangeTracking := nil;
        Binding.OriginalExit := nil;
        Binding.OriginalKeyDown := nil;
        GeneratedManualFieldBindingList.Delete(I);
      end;
    end;
  if GeneratedManualFieldBindingMap <> nil then
    FreeAndNil(GeneratedManualFieldBindingMap);
  if GeneratedManualFieldBindingHandler <> nil then
    FreeAndNil(GeneratedManualFieldBindingHandler);
  if GeneratedManualFieldBindingList <> nil then
    FreeAndNil(GeneratedManualFieldBindingList);
end;
function GeneratedAlphaBlendValueToOpacity(const AValue: Integer): Single;
begin
  if AValue <= 0 then
    Result := 0
  else if AValue >= 255 then
    Result := 1
  else
    Result := AValue / 255;
end;
procedure GeneratedSetAlphaBlendValue(const ATarget: TObject; const AValue: Integer);
var
  LForm: TCustomForm;
  LControl: TControl;
  LAlpha: Integer;
  LBaseColor: TAlphaColor;
begin
  if AValue <= 0 then
    LAlpha := 0
  else if AValue >= 255 then
    LAlpha := 255
  else
    LAlpha := AValue;
  if ATarget is TCustomForm then
  begin
    LForm := TCustomForm(ATarget);
    LForm.Transparency := True;
    LForm.Fill.Kind := TBrushKind.Solid;
    LBaseColor := TAlphaColor(Cardinal(LForm.Fill.Color) and $00FFFFFF);
    LForm.Fill.Color := TAlphaColor((Cardinal(LAlpha) shl 24) or (Cardinal(LBaseColor) and $00FFFFFF));
  end
  else if ATarget is TControl then
  begin
    LControl := TControl(ATarget);
    LControl.Opacity := GeneratedAlphaBlendValueToOpacity(LAlpha);
  end;
end;
function FindNamedChild(const Root: TFmxObject; const AName: string): TFmxObject;
var
  I: Integer;
  Child: TFmxObject;
begin
  Result := nil;
  if Root = nil then
    Exit;
  if SameText(Root.Name, AName) then
    Exit(Root);
  for I := 0 to Root.ChildrenCount - 1 do
  begin
    Child := FindNamedChild(Root.Children[I], AName);
    if Child <> nil then
      Exit(Child);
  end;
end;
procedure SetStatusBarPanelText(const AStatusBar: TStatusBar; const AIndex: Integer; const AText: string);
var
  Obj: TFmxObject;
begin
  if AStatusBar = nil then
    Exit;
  Obj := FindNamedChild(AStatusBar, AStatusBar.Name + 'Panel' + IntToStr(AIndex));
  if Obj is TLabel then
    TLabel(Obj).Text := AText;
end;
function GetStatusBarPanelText(const AStatusBar: TStatusBar; const AIndex: Integer): string;
var
  Obj: TFmxObject;
begin
  Result := '';
  if AStatusBar = nil then
    Exit;
  Obj := FindNamedChild(AStatusBar, AStatusBar.Name + 'Panel' + IntToStr(AIndex));
  if Obj is TLabel then
    Result := TLabel(Obj).Text;
end;
procedure TfmDailyPlayList.CenterNowPlayingLabelInHero;
var
  HeroCaption: TLabel;
  HeroLayout: TLayout;
  HeroCenterX: Single;
begin
  if lblRandSongPlaying = nil then
    Exit;

  HeroLayout := nil;
  HeroCenterX := ClientWidth / 2;

  if FindNamedChild(Self, 'layHeroArt') is TLayout then
  begin
    HeroLayout := TLayout(FindNamedChild(Self, 'layHeroArt'));
    HeroCenterX := HeroLayout.Position.X + (HeroLayout.Width / 2);
  end;

  if FindNamedChild(Self, 'lblHeroCaption') is TLabel then
  begin
    HeroCaption := TLabel(FindNamedChild(Self, 'lblHeroCaption'));
    if Assigned(HeroLayout) then
      HeroCenterX := HeroLayout.Position.X + HeroCaption.Position.X +
        (HeroCaption.Width / 2)
    else
      HeroCenterX := HeroCaption.Position.X + (HeroCaption.Width / 2);
  end;

  lblRandSongPlaying.Position.X := HeroCenterX -
    (lblRandSongPlaying.Width / 2);
end;
function IsPathRooted(const Path: string): Boolean;
begin
  Result := (Length(Path) >= 2) and ((Path[2] = ':') or (Path[1] = '\'));
end;
function RGBToBGR(Color: TAlphaColor): TAlphaColor;
begin
  // Convert RGB to BGR format
  Result := ((Color and $FF) shl 16) or (Color and $FF00) or
    ((Color and $FF0000) shr 16);
end;
function TfmDailyPlayList.DurationStrToSeconds(const S: string): Integer;
var
  Parts: TArray<string>;
  H, M, Sec: Integer;
begin
  Result := 0;
  Parts := S.Trim.Split([':']);
  if Length(Parts) = 2 then
  begin
    if TryStrToInt(Parts[0], M) and TryStrToInt(Parts[1], Sec) then
      Result := (M * 60) + Sec;
    Exit;
  end;
  if Length(Parts) = 3 then
  begin
    if TryStrToInt(Parts[0], H) and TryStrToInt(Parts[1], M) and TryStrToInt(Parts[2], Sec) then
      Result := (H * 3600) + (M * 60) + Sec;
    Exit;
  end;
end;
{function TfmDailyPlayList.FormatRemainingMMSS(SecondsLeft: Integer): string;
var
  M, S: Integer;
begin
  if SecondsLeft < 0 then
    SecondsLeft := 0;
  M := SecondsLeft div 60;
  S := SecondsLeft mod 60;
  Result := Format('%.2d:%.2d', [M, S]);
end;}
function TfmDailyPlayList.FormatRemainingMMSS(SecondsLeft: Integer): string;
var
  M, S: Integer;
begin
  if SecondsLeft < 0 then
    SecondsLeft := 0;
  M := SecondsLeft div 60;
  S := SecondsLeft mod 60;
  if M > 0 then
    Result := Format(' %d:%.2d', [M, S])
  else
    Result := Format(' :%0.2d ', [S]);
end;
procedure TfmDailyPlayList.UpdateNowPlayingLabel;
var
  ElapsedSec: UInt64;
  Remaining: Integer;
begin
  if not FCountdownActive then
    Exit;
  if MP3MediaPlayer.State <> TMediaState.Playing then
  begin
    StopNowPlayingCountdown;
    Exit;
  end;
  ElapsedSec := (GetTickCount64 - FCurrentSongStartTick) div 1000;
  Remaining := FCurrentSongDurationSeconds - Integer(ElapsedSec);
  if Remaining < 0 then
    Remaining := 0;
  lblRandSongPlaying.Text := FNowPlayingCaptionBase + '  (' + FormatRemainingMMSS(Remaining) + ' remaining )';
  CenterNowPlayingLabelInHero;
end;
procedure TfmDailyPlayList.StartNowPlayingCountdown;
begin
  if FCurrentSongDurationSeconds <= 0 then
  begin
    FCountdownActive := False;
    Exit;
  end;
  FCurrentSongStartTick := GetTickCount64;
  FCountdownActive := True;
  UpdateNowPlayingLabel;
end;
procedure TfmDailyPlayList.StopNowPlayingCountdown;
begin
  FCountdownActive := False;
end;
procedure TfmDailyPlayList.PrepareOverlay;
begin
  frmOverlay := TfrmOverlay.Create(Self);
  frmOverlay.BorderStyle := TFmxFormBorderStyle.None;
  frmOverlay.Transparency := True;
  GeneratedSetAlphaBlendValue(frmOverlay, 128);
  frmOverlay.FormStyle := TFormStyle.StayOnTop;
  frmOverlay.WindowState := TWindowState.wsMaximized;
  frmOverlay.Show;
end;

procedure TfmDailyPlayList.ApplyFormTheme(const ABackgroundColor,
  AFontColor: TAlphaColor; const AIncludeInteractiveText: Boolean);
var
  ActiveThemeIndex: Integer;
  i: Integer;
begin
  ActiveThemeIndex := FindColorThemeIndex(ABackgroundColor, AFontColor);
  ApplyThemePalette(ActiveThemeIndex, ABackgroundColor, AFontColor);
  Self.Fill.Kind := TBrushKind.Solid;
  Self.Fill.Color := ABackgroundColor;
  for i := 0 to Self.ComponentCount - 1 do
  begin
    if Self.Components[i] is TLabel then
      ApplyThemeToLabel(TLabel(Self.Components[i]))
    else if Self.Components[i] is TButton then
      ApplyThemeToButton(TButton(Self.Components[i]))
    else if Self.Components[i] is TComboEdit then
      ApplyThemeToInput(TStyledControl(Self.Components[i]))
    else if Self.Components[i] is TEdit then
      ApplyThemeToInput(TStyledControl(Self.Components[i]))
    else if Self.Components[i] is TPanel then
      ApplyThemeToSurface(TStyledControl(Self.Components[i]), FThemeRaisedSurfaceColor)
    else if Self.Components[i] is TGroupBox then
      ApplyThemeToSurface(TStyledControl(Self.Components[i]), FThemeRaisedSurfaceColor)
    else if Self.Components[i] is TCheckBox then
      ApplyThemeToCheckBox(TCheckBox(Self.Components[i]), AIncludeInteractiveText);
  end;
  ApplyThemeToPlayerGroupBoxes;
  ApplyThemeToScheduleInputs;
  ApplyThemeToGrid;
  ApplyScheduleStatusTheme;
  ApplyHeroVisualTheme;
  ApplyStatusBarTheme;
end;
procedure TfmDailyPlayList.ApplyThemePalette(const AThemeIndex: Integer;
  const ABackgroundColor, AFontColor: TAlphaColor);
var
  Palette: TCarillonThemePalette;
begin
  BuildCarillonThemePalette(AThemeIndex, ABackgroundColor, AFontColor,
    Palette);
  FThemeAccentColor := Palette.AccentColor;
  FThemeButtonColor := Palette.ButtonColor;
  FThemeButtonDangerColor := Palette.ButtonDangerColor;
  FThemeButtonDangerTextColor := Palette.ButtonDangerTextColor;
  FThemeButtonSecondaryColor := Palette.ButtonSecondaryColor;
  FThemeButtonSecondaryTextColor := Palette.ButtonSecondaryTextColor;
  FThemeButtonTextColor := Palette.ButtonTextColor;
  FThemeCardTextColor := Palette.CardTextColor;
  FThemeGridEvenColor := Palette.GridEvenColor;
  FThemeGridGroupColor := Palette.GridGroupColor;
  FThemeGridGroupSelectedColor := Palette.GridGroupSelectedColor;
  FThemeGridHeaderColor := Palette.GridHeaderColor;
  FThemeGridHeaderTextColor := Palette.GridHeaderTextColor;
  FThemeGroupBoxFrameColor := Palette.GroupBoxFrameColor;
  FThemeGridOddColor := Palette.GridOddColor;
  FThemeGridSelectedColor := Palette.GridSelectedColor;
  FThemeGridSelectedTextColor := Palette.GridSelectedTextColor;
  FThemeInputColor := Palette.InputColor;
  FThemeInputStrokeColor := Palette.InputStrokeColor;
  FThemeLabelAccentColor := Palette.LabelAccentColor;
  FThemePanelStrokeColor := Palette.PanelStrokeColor;
  FThemeRaisedSurfaceColor := Palette.RaisedSurfaceColor;
  FThemeSurfaceColor := Palette.SurfaceColor;
end;
procedure TfmDailyPlayList.ApplyThemeToSurface(const AControl: TStyledControl;
  const AFillColor: TAlphaColor);
var
  StrokeColor: TAlphaColor;
begin
  if AControl = nil then
    Exit;
  AControl.ApplyStyleLookup;
  AControl.StylesData['background.Visible'] := TValue.From<Boolean>(True);
  StrokeColor := FThemePanelStrokeColor;
  if AControl is TGroupBox then
    StrokeColor := AFillColor;
  ApplyStyledResourceColor(AControl, 'background', AFillColor, StrokeColor);
  if AControl is TGroupBox then
    ApplyStyledResourceShapeMetrics(AControl, 'background', 12, 12, 0.1)
  else
    ApplyStyledResourceShapeMetrics(AControl, 'background', 12, 12, 1.1);
  if AControl is TGroupBox then
  begin
    TGroupBox(AControl).StyledSettings :=
      TGroupBox(AControl).StyledSettings - [TStyledSetting.FontColor];
    TGroupBox(AControl).TextSettings.FontColor := FThemeGroupBoxFrameColor;
    ApplyStyledResourceTextColor(AControl, 'text', FThemeGroupBoxFrameColor);
    ApplyStyledResourceTextColor(AControl, 'legend', FThemeGroupBoxFrameColor);
    ApplyStyledResourceTextColor(AControl, 'background', FThemeGroupBoxFrameColor);
  end;
end;
procedure TfmDailyPlayList.ApplyThemeToPlayerGroupBoxes;
begin
  if Assigned(GroupBox1) then
  begin
    if GroupBox1.TagString = '' then
      GroupBox1.TagString := Trim(GroupBox1.Text);
    GroupBox1.Text := '';
    GroupBox1.OnPaint := ThemeGroupBoxPaint;
    ApplyThemeToSurface(GroupBox1, FThemeRaisedSurfaceColor);
    GroupBox1.Repaint;
  end;
  if Assigned(GroupBox2) then
  begin
    if GroupBox2.TagString = '' then
      GroupBox2.TagString := Trim(GroupBox2.Text);
    GroupBox2.Text := '';
    GroupBox2.OnPaint := ThemeGroupBoxPaint;
    ApplyThemeToSurface(GroupBox2, FThemeRaisedSurfaceColor);
    GroupBox2.Repaint;
  end;
end;
procedure TfmDailyPlayList.ThemeGroupBoxPaint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
var
  BottomY: Single;
  CaptionGapLeft: Single;
  CaptionGapRight: Single;
  CaptionMaskRight: Single;
  CaptionPadding: Single;
  CaptionRect: TRectF;
  CaptionText: string;
  CaptionTextRect: TRectF;
  CaptionWidth: Single;
  CanvasState: TCanvasSaveState;
  GroupBox: TGroupBox;
  LeftX: Single;
  RightX: Single;
  TopY: Single;
begin
  if not (Sender is TGroupBox) then
    Exit;
  GroupBox := TGroupBox(Sender);
  if (GroupBox.Width <= 1) or (GroupBox.Height <= 1) then
    Exit;

  LeftX := 0.5;
  RightX := GroupBox.Width - 0.5;
  TopY := 8.5;
  BottomY := GroupBox.Height - 0.5;

  CanvasState := Canvas.SaveState;
  try
    if GroupBox.TagString <> '' then
      CaptionText := GroupBox.TagString
    else
      CaptionText := Trim(GroupBox.Text);
    CaptionGapLeft := 15;
    CaptionPadding := 4;
    Canvas.Font.Assign(GroupBox.Font);
    CaptionWidth := Canvas.TextWidth(CaptionText);
    CaptionGapRight := Min(RightX - 8, CaptionGapLeft + CaptionWidth + (CaptionPadding * 2));
    CaptionMaskRight := CaptionGapRight;
    CaptionRect := RectF(CaptionGapLeft, 0, CaptionMaskRight, TopY + 12);
    CaptionTextRect := RectF(CaptionGapLeft + CaptionPadding, 0,
      CaptionMaskRight - CaptionPadding, TopY + 12);

    Canvas.Fill.Kind := TBrushKind.Solid;
    Canvas.Fill.Color := Self.Fill.Color;
    Canvas.FillRect(CaptionRect, 0, 0, [], 1);

    Canvas.Stroke.Kind := TBrushKind.Solid;
    Canvas.Stroke.Color := FThemeGroupBoxFrameColor;
    Canvas.Stroke.Dash := TStrokeDash.Solid;
    Canvas.Stroke.Thickness := 1.25;

    Canvas.DrawLine(PointF(LeftX, TopY), PointF(Max(LeftX, CaptionGapLeft), TopY), 1);
    if CaptionMaskRight < RightX then
      Canvas.DrawLine(PointF(CaptionMaskRight, TopY), PointF(RightX, TopY), 1);
    Canvas.DrawLine(PointF(LeftX, TopY), PointF(LeftX, BottomY), 1);
    Canvas.DrawLine(PointF(RightX, TopY), PointF(RightX, BottomY), 1);
    Canvas.DrawLine(PointF(LeftX, BottomY), PointF(RightX, BottomY), 1);

    Canvas.Fill.Color := FThemeGroupBoxFrameColor;
    Canvas.FillText(CaptionTextRect, CaptionText, False, 1, [],
      TTextAlign.Leading, TTextAlign.Center);
  finally
    Canvas.RestoreState(CanvasState);
  end;
end;
function TfmDailyPlayList.GetThemeButtonTier(
  const AButton: TButton): TThemeButtonTier;
begin
  Result := tbtSecondary;
  if AButton = nil then
    Exit;
  if SameText(AButton.Name, 'btnPlaySong') or
     SameText(AButton.Name, 'btnOpenAllGroups') then
    Exit(tbtPrimary);
  if SameText(AButton.Name, 'btnStopPlay') then
    Exit(tbtDanger);
end;
procedure TfmDailyPlayList.ApplyThemeButtonStyle(const AButton: TButton;
  const ATier: TThemeButtonTier);
var
  FillColor: TAlphaColor;
  StrokeColor: TAlphaColor;
  TextColor: TAlphaColor;
begin
  if AButton = nil then
    Exit;
  case ATier of
    tbtPrimary:
      begin
        FillColor := FThemeButtonColor;
        StrokeColor := FThemePanelStrokeColor;
        TextColor := FThemeButtonTextColor;
      end;
    tbtDanger:
      begin
        FillColor := FThemeButtonDangerColor;
        StrokeColor := FThemePanelStrokeColor;
        TextColor := FThemeButtonDangerTextColor;
      end;
  else
    begin
      FillColor := FThemeButtonSecondaryColor;
      StrokeColor := FThemeInputStrokeColor;
      TextColor := FThemeButtonSecondaryTextColor;
    end;
  end;
  AButton.StyledSettings := AButton.StyledSettings -
    [TStyledSetting.FontColor, TStyledSetting.Style];
  if ATier = tbtPrimary then
    AButton.TextSettings.Font.Style := [TFontStyle.fsBold]
  else
    AButton.TextSettings.Font.Style := [];
  AButton.TextSettings.FontColor := TextColor;
  ApplyStyledResourceColor(AButton, 'background', FillColor, StrokeColor);
  ApplyStyledResourceShapeMetrics(AButton, 'background', 10, 10, 1.35);
  ApplyStyledResourceTextColor(AButton, 'text', TextColor);
  ApplyStyledResourceTextColor(AButton, 'background', TextColor);
end;
procedure TfmDailyPlayList.ApplyThemeToButton(const AButton: TButton);
begin
  if AButton = nil then
    Exit;
  ApplyThemeButtonStyle(AButton, GetThemeButtonTier(AButton));
end;
procedure TfmDailyPlayList.ApplyThemeToInput(const AControl: TStyledControl);
var
  EditControl: TCustomEdit;
  InputSurfaceColor: TAlphaColor;
  InputSurfaceVclColor: Integer;
  InputTextColor: TAlphaColor;
  TextSettings: ITextSettings;
begin
  if AControl = nil then
    Exit;
  EditControl := nil;
  InputSurfaceVclColor := AlphaColorToVCLColor(FThemeInputColor);
  if GetVclColorLuminance(InputSurfaceVclColor) < 0.58 then
    InputSurfaceVclColor := BlendVclColors(InputSurfaceVclColor,
      RGB(255, 255, 255), 0.86);
  InputSurfaceColor := VCLColorToAlphaColor(InputSurfaceVclColor);
  InputTextColor := VCLColorToAlphaColor(
    GetReadableVclTextColor(InputSurfaceVclColor));
  AControl.ApplyStyleLookup;
  if AControl is TCustomEdit then
  begin
    EditControl := TCustomEdit(AControl);
    EditControl.StyledSettings := EditControl.StyledSettings -
      [TStyledSetting.FontColor];
    EditControl.FontColor := InputTextColor;
    EditControl.TextSettings.FontColor := InputTextColor;
  end;
  if Supports(AControl, ITextSettings, TextSettings) then
  begin
    TextSettings.StyledSettings :=
      TextSettings.StyledSettings - [TStyledSetting.FontColor];
    TextSettings.TextSettings.FontColor := InputTextColor;
  end;
  ApplyStyledResourceColor(AControl, 'background', InputSurfaceColor,
    FThemeInputStrokeColor);
  ApplyStyledResourceShapeMetrics(AControl, 'background', 9, 9, 1.25);
  ApplyStyledResourceColor(AControl, 'foreground', InputTextColor,
    InputTextColor);
  ApplyStyledResourceTextColor(AControl, 'text', InputTextColor);
  ApplyStyledResourceTextColor(AControl, 'content', InputTextColor);
  ApplyStyledResourceTextColor(AControl, 'foreground', InputTextColor);
  ApplyStyledResourceTextColor(AControl, 'background', InputTextColor);
    AControl.StylesData['text.FontColor'] := TValue.From<TAlphaColor>(InputTextColor);
  AControl.StylesData['text.TextSettings.FontColor'] :=
    TValue.From<TAlphaColor>(InputTextColor);
  AControl.StylesData['content.FontColor'] :=
    TValue.From<TAlphaColor>(InputTextColor);
  AControl.StylesData['content.TextSettings.FontColor'] :=
    TValue.From<TAlphaColor>(InputTextColor);
  AControl.StylesData['foreground.FontColor'] :=
    TValue.From<TAlphaColor>(InputTextColor);
  AControl.StylesData['foreground.TextSettings.FontColor'] :=
    TValue.From<TAlphaColor>(InputTextColor);
  ApplyGridSelectionColor(AControl, FThemeAccentColor);
  if AControl is TCustomEdit then
  begin
    EditControl.FontColor := InputTextColor;
    EditControl.TextSettings.FontColor := InputTextColor;
  end;
  AControl.Repaint;
end;
procedure TfmDailyPlayList.ApplyThemeToScheduleInputs;
  procedure ThemeInput(const AControl: TStyledControl);
  begin
    if Assigned(AControl) then
      ApplyThemeToInput(AControl);
  end;
begin
  ThemeInput(edPLPlayDateFrom);
  ThemeInput(edPLPlayDateTo);
  ThemeInput(DBComboBox1);
  ThemeInput(plNumberOfTimesToPlay);
  ThemeInput(edPLTimeToPlay1);
  ThemeInput(edPLTimeToPlay2);
  ThemeInput(edPLTimeToPlay3);
  ThemeInput(edPLTimeToPlay4);
  ThemeInput(edPLTimeToPlay5);
  ThemeInput(edPLTimeToPlay6);
  ThemeInput(edPLTimeToPlay7);
  ThemeInput(edPLTimeToPlay8);
  ThemeInput(edPLTimeToPlay9);
  ThemeInput(edPLTimeToPlay10);
  ThemeInput(edPLTimeToPlay11);
  ThemeInput(edPLTimeToPlay12);
end;
procedure TfmDailyPlayList.ApplyThemeToLabel(const ALabel: TLabel);
var
  UseAccentColor: Boolean;
begin
  if ALabel = nil then
    Exit;
  if ALabel = lblScheduleStatus then
    Exit;
  if ALabel = lblRandSongPlaying then
  begin
    ALabel.StyledSettings := ALabel.StyledSettings - [TStyledSetting.FontColor];
    ALabel.TextSettings.FontColor := claWhite;
    Exit;
  end;
  UseAccentColor :=
    SameText(ALabel.Name, 'lblSchedule') or
    SameText(ALabel.Name, 'lblGrpWork') or
    SameText(ALabel.Name, 'lblPlayDateFrom') or
    SameText(ALabel.Name, 'lblPlayDateFromAndOrSeason') or
    SameText(ALabel.Name, 'lblPlayDateTo') or
    SameText(ALabel.Name, 'lblPlayTimes') or
    SameText(ALabel.Name, 'lblTimesToPlay') or
    SameText(ALabel.Name, 'Label1') or
    SameText(ALabel.Name, 'Label2') or
    SameText(ALabel.Name, 'Label3') or
    SameText(ALabel.Name, 'Label4') or
    SameText(ALabel.Name, 'Label5') or
    SameText(ALabel.Name, 'Label6') or
    SameText(ALabel.Name, 'Label7') or
    SameText(ALabel.Name, 'Label9') or
    SameText(ALabel.Name, 'edFollowingDays');
  ALabel.StyledSettings := ALabel.StyledSettings - [TStyledSetting.FontColor];
  if UseAccentColor then
    ALabel.TextSettings.FontColor := FThemeLabelAccentColor
  else
    ALabel.TextSettings.FontColor := FormFontColor;
end;
procedure TfmDailyPlayList.ApplyThemeToCheckBox(const ACheckBox: TCheckBox;
  const AIncludeInteractiveText: Boolean);
begin
  if (ACheckBox = nil) or (not AIncludeInteractiveText) then
    Exit;
  ACheckBox.StyledSettings := ACheckBox.StyledSettings -
    [TStyledSetting.FontColor];
  if SameText(ACheckBox.Name, 'chkEnableSchedule') then
    ACheckBox.TextSettings.FontColor := VCLColorToAlphaColor(
      GetReadableVclTextColor($00FFFFFF))
  else
    ACheckBox.TextSettings.FontColor := FormFontColor;
end;
procedure TfmDailyPlayList.ApplyHeroGradient(const ARectangle: TRectangle;
  const AStartColor, AEndColor: TAlphaColor);
begin
  if ARectangle = nil then
    Exit;
  ARectangle.Fill.Kind := TBrushKind.Gradient;
  ARectangle.Fill.Gradient.Style := TGradientStyle.Linear;
  ARectangle.Fill.Gradient.Color := AStartColor;
  ARectangle.Fill.Gradient.Color1 := AEndColor;
  ARectangle.Fill.Gradient.StartPosition.X := 0.0;
  ARectangle.Fill.Gradient.StartPosition.Y := 0.0;
  ARectangle.Fill.Gradient.StopPosition.X := 1.0;
  ARectangle.Fill.Gradient.StopPosition.Y := 1.0;
end;
procedure TfmDailyPlayList.ApplyHeroVisualTheme;
var
  AccentVclColor: Integer;
  ActiveHeroThemeIndex: Integer;
  BackgroundVclColor: Integer;
  BadgeRect: TRectangle;
  CardRect: TRectangle;
  CircleShape: TCircle;
  HeroBadgeTextColor: Integer;
  HeroCardEndVclColor: Integer;
  HeroCardStartVclColor: Integer;
  HeroDotVclColor: Integer;
  HeroHaloVclColor: Integer;
  HeroLineVclColor: Integer;
  HeroPillarVclColor: Integer;
  HeroStrokeVclColor: Integer;
  HeroSurfaceVclColor: Integer;
  HeroTitleTextColor: Integer;
  IsDarkTheme: Boolean;
  LabelObj: TLabel;
  Obj: TFmxObject;
  ShadowEffect: TShadowEffect;
begin
  BackgroundVclColor := AlphaColorToVCLColor(Self.Fill.Color);
  ActiveHeroThemeIndex := FindColorThemeIndex(Self.Fill.Color, FormFontColor);
  AccentVclColor := AlphaColorToVCLColor(FThemeAccentColor);
  HeroSurfaceVclColor := AlphaColorToVCLColor(FThemeSurfaceColor);
  IsDarkTheme := GetVclColorLuminance(BackgroundVclColor) < 0.38;

  if IsDarkTheme then
  begin
    HeroCardStartVclColor := BlendVclColors(AccentVclColor, RGB(255, 255, 255), 0.10);
    HeroCardEndVclColor := ShiftVclColor(AccentVclColor, -0.30);
    HeroHaloVclColor := BlendVclColors(AccentVclColor, BackgroundVclColor, 0.20);
    HeroPillarVclColor := BlendVclColors(AccentVclColor, HeroSurfaceVclColor, 0.18);
    HeroLineVclColor := BlendVclColors(RGB(255, 255, 255), AccentVclColor, 0.18);
    HeroStrokeVclColor := ShiftVclColor(AccentVclColor, -0.36);
    HeroDotVclColor := ShiftVclColor(AccentVclColor, 0.26);
  end
  else
  begin
    HeroCardStartVclColor := BlendVclColors(AccentVclColor, RGB(255, 255, 255), 0.16);
    HeroCardEndVclColor := ShiftVclColor(AccentVclColor, -0.18);
    HeroHaloVclColor := BlendVclColors(AccentVclColor, BackgroundVclColor, 0.42);
    HeroPillarVclColor := ShiftVclColor(AccentVclColor, -0.04);
    HeroLineVclColor := BlendVclColors(RGB(255, 255, 255), AccentVclColor, 0.12);
    HeroStrokeVclColor := ShiftVclColor(AccentVclColor, -0.28);
    HeroDotVclColor := BlendVclColors(AccentVclColor, RGB(255, 255, 255), 0.18);
  end;

  HeroBadgeTextColor := GetReadableVclTextColor(AccentVclColor);
  HeroTitleTextColor := GetReadableVclTextColor(
    BlendVclColors(HeroCardStartVclColor, HeroCardEndVclColor, 0.52));
  if ThemeUsesWhiteAccentLabels(ActiveHeroThemeIndex) or
     (ActiveHeroThemeIndex = 8) then
    HeroBadgeTextColor := HeroTitleTextColor;

  Obj := FindNamedChild(Self, 'rectHeroCard');
  if Obj is TRectangle then
  begin
    CardRect := TRectangle(Obj);
    ApplyHeroGradient(CardRect, VCLColorToAlphaColor(HeroCardStartVclColor),
      VCLColorToAlphaColor(HeroCardEndVclColor));
    CardRect.Stroke.Kind := TBrushKind.Solid;
    CardRect.Stroke.Color := VCLColorToAlphaColor(HeroStrokeVclColor);
    CardRect.Stroke.Thickness := 1.5;
  end;

  Obj := FindNamedChild(Self, 'rectHeroPillar');
  if Obj is TRectangle then
  begin
    TRectangle(Obj).Fill.Kind := TBrushKind.Solid;
    TRectangle(Obj).Fill.Color := VCLColorToAlphaColor(HeroPillarVclColor);
    TRectangle(Obj).Stroke.Kind := TBrushKind.None;
  end;

  Obj := FindNamedChild(Self, 'rectHeroBadge');
  if Obj is TRectangle then
  begin
    BadgeRect := TRectangle(Obj);
    BadgeRect.Fill.Kind := TBrushKind.Solid;
    BadgeRect.Fill.Color := FThemeAccentColor;
    BadgeRect.Stroke.Kind := TBrushKind.None;
  end;

  Obj := FindNamedChild(Self, 'rectHeroLine1');
  if Obj is TRectangle then
  begin
    TRectangle(Obj).Fill.Color := VCLColorToAlphaColor(HeroLineVclColor);
    TRectangle(Obj).Stroke.Kind := TBrushKind.None;
  end;
  Obj := FindNamedChild(Self, 'rectHeroLine2');
  if Obj is TRectangle then
  begin
    TRectangle(Obj).Fill.Color := VCLColorToAlphaColor(HeroLineVclColor);
    TRectangle(Obj).Stroke.Kind := TBrushKind.None;
  end;
  Obj := FindNamedChild(Self, 'rectHeroLine3');
  if Obj is TRectangle then
  begin
    TRectangle(Obj).Fill.Color := VCLColorToAlphaColor(HeroLineVclColor);
    TRectangle(Obj).Stroke.Kind := TBrushKind.None;
  end;
  Obj := FindNamedChild(Self, 'rectHeroAccent');
  if Obj is TRectangle then
  begin
    TRectangle(Obj).Fill.Color := VCLColorToAlphaColor(
      ShiftVclColor(AccentVclColor, -0.12));
    TRectangle(Obj).Stroke.Kind := TBrushKind.None;
  end;

  Obj := FindNamedChild(Self, 'cirHeroHaloMain');
  if Obj is TCircle then
  begin
    CircleShape := TCircle(Obj);
    CircleShape.Fill.Kind := TBrushKind.Solid;
    CircleShape.Fill.Color := VCLColorToAlphaColor(HeroHaloVclColor);
    CircleShape.Stroke.Kind := TBrushKind.None;
    CircleShape.Opacity := 0.22;
  end;
  Obj := FindNamedChild(Self, 'cirHeroHaloSmall');
  if Obj is TCircle then
  begin
    CircleShape := TCircle(Obj);
    CircleShape.Fill.Kind := TBrushKind.Solid;
    CircleShape.Fill.Color := VCLColorToAlphaColor(
      ShiftVclColor(AccentVclColor, 0.22));
    CircleShape.Stroke.Kind := TBrushKind.None;
    CircleShape.Opacity := 0.28;
  end;
  Obj := FindNamedChild(Self, 'cirHeroBell1');
  if Obj is TCircle then
  begin
    CircleShape := TCircle(Obj);
    CircleShape.Fill.Color := VCLColorToAlphaColor(HeroDotVclColor);
    CircleShape.Stroke.Kind := TBrushKind.None;
  end;
  Obj := FindNamedChild(Self, 'cirHeroBell2');
  if Obj is TCircle then
  begin
    CircleShape := TCircle(Obj);
    CircleShape.Fill.Color := VCLColorToAlphaColor(HeroDotVclColor);
    CircleShape.Stroke.Kind := TBrushKind.None;
  end;
  Obj := FindNamedChild(Self, 'cirHeroBell3');
  if Obj is TCircle then
  begin
    CircleShape := TCircle(Obj);
    CircleShape.Fill.Color := VCLColorToAlphaColor(HeroDotVclColor);
    CircleShape.Stroke.Kind := TBrushKind.None;
  end;

  Obj := FindNamedChild(Self, 'lblHeroBadge');
  if Obj is TLabel then
  begin
    LabelObj := TLabel(Obj);
    LabelObj.StyledSettings := [];
    LabelObj.TextSettings.FontColor := VCLColorToAlphaColor(HeroBadgeTextColor);
  end;
  Obj := FindNamedChild(Self, 'lblHeroCaption');
  if Obj is TLabel then
  begin
    LabelObj := TLabel(Obj);
    LabelObj.StyledSettings := [];
    LabelObj.TextSettings.FontColor := VCLColorToAlphaColor(HeroTitleTextColor);
  end;

  Obj := FindNamedChild(Self, 'shdHeroCard');
  if Obj is TShadowEffect then
  begin
    ShadowEffect := TShadowEffect(Obj);
    ShadowEffect.ShadowColor := VCLColorToAlphaColor(
      BlendVclColors(HeroStrokeVclColor, RGB(0, 0, 0), 0.35));
    if IsDarkTheme then
      ShadowEffect.Opacity := 0.34
    else
      ShadowEffect.Opacity := 0.24;
    ShadowEffect.Softness := 0.35;
    ShadowEffect.Distance := 4;
  end;
end;
procedure TfmDailyPlayList.ApplyThemeToGrid;
begin
  if DBGrid1 = nil then
    Exit;
  DBGrid1.OnDrawColumnHeader := DBGrid1DrawColumnHeader;
  DBGrid1.StyledSettings := DBGrid1.StyledSettings - [TStyledSetting.FontColor];
  DBGrid1.TextSettings.FontColor := FThemeCardTextColor;
  ApplyStyledResourceColor(DBGrid1, 'background', FThemeInputColor,
    FThemeAccentColor);
  ApplyStyledResourceTextColor(DBGrid1, 'text', FThemeCardTextColor);
  ApplyStyledResourceTextColor(DBGrid1, 'background', FThemeCardTextColor);
  ApplyStyledResourceTextColor(DBGrid1, 'selection',
    FThemeGridSelectedTextColor);
  ApplyStyledResourceTextColor(DBGrid1, 'focus',
    FThemeGridSelectedTextColor);
  ApplyGridSelectionColor(DBGrid1, FThemeGridSelectedColor);
  DBGrid1.Repaint;
end;
procedure TfmDailyPlayList.ApplyStatusBarTheme;
var
  I: Integer;
  LabelObj: TLabel;
  Obj: TFmxObject;
  StatusBarTextColor: TAlphaColor;
begin
  if StatusBar1 = nil then
    Exit;

  StatusBarTextColor := FThemeButtonTextColor;
  ApplyStyledResourceColor(StatusBar1, 'background', FThemeSurfaceColor,
    FThemePanelStrokeColor);
  ApplyStyledResourceTextColor(StatusBar1, 'text', StatusBarTextColor);
  ApplyStyledResourceTextColor(StatusBar1, 'background', StatusBarTextColor);

  for I := 0 to 3 do
  begin
    Obj := FindNamedChild(StatusBar1, StatusBar1.Name + 'Panel' + IntToStr(I));
    if Obj is TLabel then
    begin
      LabelObj := TLabel(Obj);
      LabelObj.StyledSettings := [];
      LabelObj.TextSettings.FontColor := StatusBarTextColor;
      LabelObj.Visible := True;
      LabelObj.BringToFront;
      LabelObj.Repaint;
    end;
  end;

  StatusBar1.BringToFront;
  StatusBar1.Repaint;
end;
procedure TfmDailyPlayList.ApplyScheduleStatusTheme;
begin
  if lblScheduleStatus = nil then
    Exit;
  lblScheduleStatus.StyledSettings := lblScheduleStatus.StyledSettings -
    [TStyledSetting.FontColor];
  if SameText(lblScheduleStatus.Text, 'Schedule enabled') then
    GeneratedSetCanvasTextColor(lblScheduleStatus, VCLColorToAlphaColor(RGB(58, 148, 93)))
  else if SameText(lblScheduleStatus.Text, 'Schedule disabled') then
    GeneratedSetCanvasTextColor(lblScheduleStatus, VCLColorToAlphaColor(RGB(175, 74, 64)))
  else
    lblScheduleStatus.TextSettings.FontColor := FThemeLabelAccentColor;
end;
procedure TfmDailyPlayList.EnsureCheckBoxLink(
  var ALink: TLinkPropertyToField; ACheckBox: TCheckBox;
  const AFieldName: string);
begin
  if ALink <> nil then
    Exit;
  ALink := TLinkPropertyToField.Create(Self);
  ALink.DataSource := FPlaylistBindSource;
  ALink.FieldName := AFieldName;
  ALink.Component := ACheckBox;
  ALink.ComponentProperty := 'IsChecked';
  ALink.AutoActivate := True;
end;
function TfmDailyPlayList.TryResolveSelectedSong(out ASongPath: string;
  out ANumberOfTimes: Integer): Boolean;
var
  BasePath: string;
begin
  Result := False;
  ASongPath := '';
  ANumberOfTimes := 1;
  if PlaylistQuery.FindField('song_name') = nil then
  begin
    ShowMessage('Field "song_name" not found in dataset.');
    Exit;
  end;
  if PlaylistQuery.FindField('num_times_to_play') = nil then
  begin
    ShowMessage('Field "num_times_to_play" not found in dataset.');
    Exit;
  end;
  ASongPath := PlaylistQuery.FieldByName('song_name').AsString;
  if not IsPathRooted(ASongPath) then
  begin
    BasePath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
    ASongPath := BasePath + ASongPath;
  end;
  ANumberOfTimes := PlaylistQuery.FieldByName('num_times_to_play').AsInteger;
  if ANumberOfTimes < 1 then
    ANumberOfTimes := 1
  else if ANumberOfTimes > 5 then
    ANumberOfTimes := 5;
  Result := True;
end;
procedure TfmDailyPlayList.ResolveRandomSongIfNeeded(var ASongPath: string);
var
  Files: TStringList;
  SearchRec: TSearchRec;
  RandSongDir: string;
begin
  FCurrentSongIsRandom := Pos('Random Music Generator', ASongPath) > 0;
  if not FCurrentSongIsRandom then
    Exit;
  Files := TStringList.Create;
  RetrieveRandSongsDirectory(RandSongDir);
  try
    if System.SysUtils.FindFirst(RandSongDir + '\*.mp3', faNormal, SearchRec) = 0 then
    try
      repeat
        Files.Add(RandSongDir + '\' + SearchRec.Name);
      until System.SysUtils.FindNext(SearchRec) <> 0;
    finally
      System.SysUtils.FindClose(SearchRec);
    end;
    if Files.Count = 0 then
    begin
      AddToLog('Random song requested but no MP3 files found in: ' + RandSongDir);
      FCurrentSongDurationSeconds := 0;
      Exit;
    end;
    ASongPath := Files[Random(Files.Count)];
    try
      MP3MediaPlayer.FileName := ASongPath;
      FCurrentSongDurationSeconds := Round(MP3MediaPlayer.Duration / MediaTimeScale);
      MP3MediaPlayer.Clear;
    except
      FCurrentSongDurationSeconds := 0;
    end;
  finally
    Files.Free;
  end;
end;
procedure TfmDailyPlayList.ResolveSongDurationFromPlaylist;
begin
  if (not FCurrentSongIsRandom) and (PlaylistQuery.FindField('song_duration') <> nil) and
     (not PlaylistQuery.FieldByName('song_duration').IsNull) then
    FCurrentSongDurationSeconds := DurationStrToSeconds(PlaylistQuery.FieldByName('song_duration').AsString)
  else if not FCurrentSongIsRandom then
    FCurrentSongDurationSeconds := 0;
end;
procedure TfmDailyPlayList.ShowNowPlaying(const ASongPath: string;
  const AResolveDurationFromPlaylist: Boolean);
begin
  MP3MediaPlayer.FileName := ASongPath;
  FNowPlayingCaptionBase := 'Now Playing: ' + ExtractFileName(ASongPath);
  lblRandSongPlaying.Text := FNowPlayingCaptionBase;
  if AResolveDurationFromPlaylist then
    ResolveSongDurationFromPlaylist
  else
    try
      FCurrentSongDurationSeconds := Round(MP3MediaPlayer.Duration / MediaTimeScale);
      MP3MediaPlayer.Clear;
    except
      FCurrentSongDurationSeconds := 0;
    end;
  StopNowPlayingCountdown;
  CenterNowPlayingLabelInHero;
  lblRandSongPlaying.Visible := True;
  Inc(FPlayedSongCountToday);
  UpdateStatusBar(ASongPath);
  Application.ProcessMessages;
end;
procedure TfmDailyPlayList.HideNowPlaying;
begin
  StopNowPlayingCountdown;
  lblRandSongPlaying.Text := '';
  lblRandSongPlaying.Visible := False;
end;
function TfmDailyPlayList.TrySyncDataSetToScheduledEntry(
  const AEntry: TScheduleEntry): Boolean;
var
  RelativeSongPath: string;
begin
  Result := False;
  if not Assigned(PlaylistQuery) or not PlaylistQuery.Active or PlaylistQuery.IsEmpty then
    Exit;

  if (AEntry.PlaylistRecordNo > 0) and
     (AEntry.PlaylistRecordNo <= PlaylistQuery.RecordCount) then
  begin
    try
      PlaylistQuery.RecNo := AEntry.PlaylistRecordNo;
      if SameText(ConvertToRelativePath(PlaylistQuery.FieldByName('song_name').AsString),
           ConvertToRelativePath(AEntry.SongPath)) and
         (PlaylistQuery.FieldByName('num_times_to_play').AsInteger =
           AEntry.NumberOfTimesToPlay) then
        Exit(True);
    except
      // Fall back to a row scan below.
    end;
  end;

  RelativeSongPath := ConvertToRelativePath(AEntry.SongPath);
  PlaylistQuery.First;
  while not PlaylistQuery.Eof do
  begin
    if SameText(
         ConvertToRelativePath(PlaylistQuery.FieldByName('song_name').AsString),
         RelativeSongPath) and
       (PlaylistQuery.FieldByName('num_times_to_play').AsInteger =
         AEntry.NumberOfTimesToPlay) then
      Exit(True);
    PlaylistQuery.Next;
  end;
end;
procedure TfmDailyPlayList.PlayScheduledEntry(const AEntry: TScheduleEntry);
var
  SongPath: string;
  UsePlaylistDuration: Boolean;
begin
  SongPath := AEntry.SongPath;
  UsePlaylistDuration := TrySyncDataSetToScheduledEntry(AEntry);
  ResolveRandomSongIfNeeded(SongPath);
  if Assigned(SettingsMain) and SettingsMain.chkLogOnOff.IsChecked then
    AddToLog('Played Song: ' + SongPath);
  if not FileExists(SongPath) then
  begin
    ShowMessage('File not found: ' + SongPath);
    Exit;
  end;
  ShowNowPlaying(SongPath, UsePlaylistDuration);
  PlaySongRepeats(AEntry.NumberOfTimesToPlay);
  HideNowPlaying;
end;
procedure TfmDailyPlayList.PlaySongRepeats(ANumberOfTimes: Integer);
var
  RepeatIndex: Integer;
begin
  IsPlaybackInProgress := True;
  try
    for RepeatIndex := 1 to ANumberOfTimes do
    begin
      if FGeneratedShuttingDown or Application.Terminated then
        Break;

      MP3MediaPlayer.Play;
      while (MP3MediaPlayer.State <> TMediaState.Playing) and
            (MP3MediaPlayer.State <> TMediaState.Stopped) do
      begin
        if FGeneratedShuttingDown or Application.Terminated then
        begin
          try
            MP3MediaPlayer.Stop;
          except
          end;
          Break;
        end;
        Application.ProcessMessages;
        Sleep(10);
      end;

      if FGeneratedShuttingDown or Application.Terminated then
        Break;

      if MP3MediaPlayer.State = TMediaState.Playing then
        StartNowPlayingCountdown;

      while MP3MediaPlayer.State = TMediaState.Playing do
      begin
        if FGeneratedShuttingDown or Application.Terminated then
        begin
          try
            MP3MediaPlayer.Stop;
          except
          end;
          Break;
        end;
        Application.ProcessMessages;
        Sleep(100);
      end;
    end;
  finally
    IsPlaybackInProgress := False;
  end;
end;
function TfmDailyPlayList.IsSongAlreadyInDailyPlaylist(
  const AFileName: string): Boolean;
var
  RelativeSongName: string;
begin
  Result := False;
  RelativeSongName := ConvertToRelativePath(AFileName);
  PlaylistQuery.First;
  while not PlaylistQuery.Eof do
  begin
    if (PlaylistQuery.FieldByName('playlist_name').AsString = 'Daily Play List') and
       (ConvertToRelativePath(PlaylistQuery.FieldByName('song_name').AsString) = RelativeSongName) then
    begin
      Result := True;
      Exit;
    end;
    PlaylistQuery.Next;
  end;
end;
function TfmDailyPlayList.GetMediaDurationText(const AFileName: string): string;
var
  DurationMilliseconds: Integer;
  Minutes: Integer;
  Seconds: Integer;
begin
  MP3MediaPlayer.FileName := AFileName;
  DurationMilliseconds := Round((MP3MediaPlayer.Duration / MediaTimeScale) * 1000);
  Minutes := DurationMilliseconds div 60000;
  Seconds := (DurationMilliseconds mod 60000) div 1000;
  Result := Format('%d:%.2d', [Minutes, Seconds]);
end;
procedure TfmDailyPlayList.AddSongFileToPlaylist(const AFileName: string);
begin
  try
    tbPlaylist.Insert;
    tbPlaylist.FieldByName('playlist_name').AsString := 'Daily Play List';
    tbPlaylist.FieldByName('song_name').AsString := ConvertToRelativePath(AFileName);
    tbPlaylist.FieldByName('season').AsString := 'Daily List';
    tbPlaylist.FieldByName('num_times_to_play').AsInteger := 1;
    tbPlaylist.FieldByName('song_duration').AsString := GetMediaDurationText(AFileName);
    tbPlaylist.Post;
    MP3MediaPlayer.Clear;
  except
    on E: EDatabaseError do
    begin
      ShowMessage('Error adding song: ' + E.Message);
      tbPlaylist.Cancel;
    end;
  end;
end;
procedure TfmDailyPlayList.InsertSelectedSongs;
var
  i: Integer;
  SongFileName: string;
begin
  if not OpenDialog1.Execute then
  begin
    tbPlaylist.Cancel;
    Exit;
  end;
  if OpenDialog1.Files.Count = 0 then
  begin
    tbPlaylist.Cancel;
    Exit;
  end;
  for i := 0 to OpenDialog1.Files.Count - 1 do
  begin
    SongFileName := OpenDialog1.Files[i];
    if IsSongAlreadyInDailyPlaylist(SongFileName) then
      ShowMessage('This song is already in the playlist: ' + SongFileName)
    else
      AddSongFileToPlaylist(SongFileName);
  end;
  RefreshGrid;
end;
procedure TfmDailyPlayList.EnsurePlaylistGridColumns;
const
  DurationColumnWidth = 96;
  GridChromeWidth = 0.0;
  MinSongColumnWidth = 320.0;
  VerticalScrollbarReserve = 16.0;
  PlaylistGridFontSize = 17.0;
  PlaylistGridRowHeight = 30.0;
var
  AvailableSongColumnWidth: Single;
  ActualSongColumnWidth: Single;
begin
  if not Assigned(DBGrid1) then
    Exit;
  ApplyGridSelectionColor(DBGrid1, $FFD7E8FA);
  DBGrid1.ReadOnly := True;
  DBGrid1.Options := DBGrid1.Options - [TGridOption.Editing,
    TGridOption.CancelEditingByDefault];
  DBGrid1.StyledSettings := DBGrid1.StyledSettings - [TStyledSetting.Size];
  DBGrid1.TextSettings.Font.Size := PlaylistGridFontSize;
  DBGrid1.RowHeight := PlaylistGridRowHeight;
  DBGrid1.Padding.Left := 4;
  DBGrid1.Padding.Right := 0;
  AvailableSongColumnWidth := DBGrid1.Width - DurationColumnWidth -
    VerticalScrollbarReserve - GridChromeWidth - DBGrid1.Padding.Left -
    DBGrid1.Padding.Right;
  ActualSongColumnWidth := Max(MinSongColumnWidth, AvailableSongColumnWidth);
  if DBGrid1.ColumnCount = 0 then
  begin
    DBGrid1.BeginUpdate;
    try
      with TStringColumn.Create(DBGrid1) do
      begin
        Parent := DBGrid1;
        Header := 'Song Name';
        Width := ActualSongColumnWidth;
        ReadOnly := True;
      end;
      with TStringColumn.Create(DBGrid1) do
      begin
        Parent := DBGrid1;
        Header := 'Duration';
        Width := DurationColumnWidth;
        ReadOnly := True;
      end;
    finally
      DBGrid1.EndUpdate;
    end;
  end;
  if DBGrid1.ColumnCount >= 2 then
  begin
    DBGrid1.Columns[0].Header := 'Song Name';
    DBGrid1.Columns[0].Width := ActualSongColumnWidth;
    DBGrid1.Columns[1].Header := 'Duration';
    DBGrid1.Columns[1].Width := DurationColumnWidth;
  end;
end;
function TfmDailyPlayList.NormalizePlaylistGroupName(
  const AGroupName: string): string;
begin
  Result := Trim(AGroupName);
  if Result = '' then
    Result := '(No Group)';
end;
function TfmDailyPlayList.IsPlaylistGroupCollapsed(
  const AGroupName: string): Boolean;
var
  GroupName: string;
begin
  GroupName := NormalizePlaylistGroupName(AGroupName);
  Result := StartPlaylistGroupsClosed;
  if FPlaylistGridStartCollapsed = nil then
    Exit;
  if not FPlaylistGridStartCollapsed.TryGetValue(GroupName, Result) then
  begin
    Result := StartPlaylistGroupsClosed;
    FPlaylistGridStartCollapsed.AddOrSetValue(GroupName, Result);
  end;
end;
procedure TfmDailyPlayList.SetPlaylistGroupCollapsed(const AGroupName: string;
  const ACollapsed: Boolean);
var
  GroupName: string;
begin
  GroupName := NormalizePlaylistGroupName(AGroupName);
  if FPlaylistGridStartCollapsed = nil then
    Exit;
  FPlaylistGridStartCollapsed.AddOrSetValue(GroupName, ACollapsed);
end;
function TfmDailyPlayList.FormatPlaylistGroupDuration(
  const ATotalSeconds: Integer): string;
var
  Hours: Integer;
  Minutes: Integer;
  Seconds: Integer;
begin
  Hours := ATotalSeconds div 3600;
  Minutes := (ATotalSeconds mod 3600) div 60;
  Seconds := ATotalSeconds mod 60;
  if Hours > 0 then
    Result := Format('%d:%0.2d:%0.2d', [Hours, Minutes, Seconds])
  else
    Result := Format('%d:%0.2d', [Minutes, Seconds]);
end;
function TfmDailyPlayList.FindPlaylistGridHeaderRow(
  const AGroupName: string): Integer;
var
  GroupName: string;
  i: Integer;
begin
  Result := -1;
  if FPlaylistGridRows = nil then
    Exit;
  GroupName := NormalizePlaylistGroupName(AGroupName);
  for i := 0 to FPlaylistGridRows.Count - 1 do
    if (FPlaylistGridRows[i].RowKind = pgrGroupHeader) and
       SameText(FPlaylistGridRows[i].GroupName, GroupName) then
      Exit(i);
end;
function TfmDailyPlayList.FindPlaylistGridRowByRecordNo(
  const ARecordNo: Integer): Integer;
var
  i: Integer;
begin
  Result := -1;
  if FPlaylistGridRows = nil then
    Exit;
  for i := 0 to FPlaylistGridRows.Count - 1 do
    if (FPlaylistGridRows[i].RowKind = pgrSong) and
       (FPlaylistGridRows[i].DataSetRecordNo = ARecordNo) then
      Exit(i);
end;
procedure TfmDailyPlayList.SelectPlaylistGridRow(const ARow: Integer);
var
  TargetRow: Integer;
begin
  if not Assigned(DBGrid1) or (DBGrid1.RowCount = 0) then
    Exit;
  TargetRow := ARow;
  if TargetRow < 0 then
    TargetRow := 0;
  if TargetRow >= DBGrid1.RowCount then
    TargetRow := DBGrid1.RowCount - 1;
  Inc(FPlaylistGridSelectionSyncDepth);
  try
    DBGrid1.Selected := TargetRow;
  finally
    Dec(FPlaylistGridSelectionSyncDepth);
  end;
end;
procedure TfmDailyPlayList.ScrollPlaylistGridRowToTop(const ARow: Integer);
var
  TargetRow: Integer;
begin
  if not Assigned(DBGrid1) or (DBGrid1.RowCount = 0) then
    Exit;
  TargetRow := ARow;
  if TargetRow < 0 then
    TargetRow := 0;
  if TargetRow >= DBGrid1.RowCount then
    TargetRow := DBGrid1.RowCount - 1;
  DBGrid1.TopRow := TargetRow;
end;
procedure TfmDailyPlayList.ResetPlaylistGridToStartupState;
begin
  if Assigned(FPlaylistGridStartCollapsed) then
    FPlaylistGridStartCollapsed.Clear;
  FPlaylistGridStartupClosedPending := StartPlaylistGroupsClosed;
  FSkipNextPlaylistGridSelectionSync := StartPlaylistGroupsClosed;
  if Assigned(DBGrid1) then
    DBGrid1.TopRow := 0;
end;
procedure TfmDailyPlayList.RebuildPlaylistGrid;
var
  CurrentGroupDuration: Integer;
  CurrentGroupName: string;
  CurrentGroupSongCount: Integer;
  CurrentGroupSongs: TList<TPlaylistGridRow>;
  GroupStatePrefix: string;
  PlaylistRow: TPlaylistGridRow;
  RowIndex: Integer;
  RowLabel: string;
  SavedBookmark: TBookmark;
  SongRow: TPlaylistGridRow;
  SongDurationText: string;
  SongNameText: string;
  SongSuffix: string;
  VisibleSongIndex: Integer;
  function FieldTextOrEmpty(const AFieldName: string): string;
  begin
    if (PlaylistQuery.FindField(AFieldName) <> nil) and
       (not PlaylistQuery.FieldByName(AFieldName).IsNull) then
      Result := PlaylistQuery.FieldByName(AFieldName).AsString
    else
      Result := '';
  end;
  function ExtractSongTitle(const ASongPath: string): string;
  var
    FileName: string;
  begin
    FileName := Trim(ExtractFileName(ASongPath));
    if FileName = '' then
      FileName := Trim(ASongPath);
    Result := Trim(ChangeFileExt(FileName, ''));
    if Result = '' then
      Result := Trim(ASongPath);
  end;
  procedure FlushCurrentGroup;
  var
    HeaderRow: TPlaylistGridRow;
    i: Integer;
  begin
    if CurrentGroupName = '' then
      Exit;
    HeaderRow.DataSetRecordNo := 0;
    HeaderRow.DurationDisplay := FormatPlaylistGroupDuration(CurrentGroupDuration);
    HeaderRow.VisibleSongIndex := -1;
    HeaderRow.GroupName := CurrentGroupName;
    HeaderRow.RowKind := pgrGroupHeader;
    if CurrentGroupSongCount = 1 then
      SongSuffix := ''
    else
      SongSuffix := 's';
    HeaderRow.SongDisplay := Format('%s (%d song%s)', [CurrentGroupName,
      CurrentGroupSongCount, SongSuffix]);
    FPlaylistGridRows.Add(HeaderRow);
    if not IsPlaylistGroupCollapsed(CurrentGroupName) then
      for i := 0 to CurrentGroupSongs.Count - 1 do
      begin
        SongRow := CurrentGroupSongs[i];
        SongRow.VisibleSongIndex := VisibleSongIndex;
        Inc(VisibleSongIndex);
        FPlaylistGridRows.Add(SongRow);
      end;
  end;
begin
  if not Assigned(DBGrid1) or (FPlaylistGridRows = nil) then
    Exit;
  Inc(FPlaylistGridRebuildDepth);
  try
    EnsurePlaylistGridColumns;
    FPlaylistGridRows.Clear;
    DBGrid1.BeginUpdate;
    try
      if not Assigned(PlaylistQuery) or not PlaylistQuery.Active or PlaylistQuery.IsEmpty then
      begin
        DBGrid1.RowCount := 0;
        Exit;
      end;
      CurrentGroupSongs := TList<TPlaylistGridRow>.Create;
      SavedBookmark := nil;
      try
        SavedBookmark := PlaylistQuery.GetBookmark;
        PlaylistQuery.DisableControls;
        try
          CurrentGroupDuration := 0;
          CurrentGroupName := '';
          CurrentGroupSongCount := 0;
          VisibleSongIndex := 0;
          PlaylistQuery.First;
          while not PlaylistQuery.Eof do
          begin
            RowLabel := NormalizePlaylistGroupName(FieldTextOrEmpty('season'));
            if (CurrentGroupName <> '') and (not SameText(CurrentGroupName, RowLabel)) then
            begin
              FlushCurrentGroup;
              CurrentGroupSongs.Clear;
              CurrentGroupDuration := 0;
              CurrentGroupSongCount := 0;
            end;
            CurrentGroupName := RowLabel;
            SongNameText := FieldTextOrEmpty('song_name');
            if SongNameText = '' then
              SongNameText := FieldTextOrEmpty('song_name_display');
            SongNameText := ExtractSongTitle(SongNameText);
            SongDurationText := FieldTextOrEmpty('song_duration_display');
            if SongDurationText = '' then
              SongDurationText := FieldTextOrEmpty('song_duration');
            SongRow.DataSetRecordNo := PlaylistQuery.RecNo;
            SongRow.DurationDisplay := SongDurationText;
            SongRow.GroupName := CurrentGroupName;
            SongRow.RowKind := pgrSong;
            SongRow.SongDisplay := SongNameText;
            SongRow.VisibleSongIndex := -1;
            CurrentGroupSongs.Add(SongRow);
            Inc(CurrentGroupSongCount);
            Inc(CurrentGroupDuration, DurationStrToSeconds(SongDurationText));
            PlaylistQuery.Next;
          end;
          FlushCurrentGroup;
        finally
          if (SavedBookmark <> nil) and PlaylistQuery.BookmarkValid(SavedBookmark) then
            PlaylistQuery.GotoBookmark(SavedBookmark);
          PlaylistQuery.EnableControls;
        end;
      finally
        CurrentGroupSongs.Free;
      end;
      DBGrid1.RowCount := FPlaylistGridRows.Count;
      for RowIndex := 0 to FPlaylistGridRows.Count - 1 do
      begin
        PlaylistRow := FPlaylistGridRows[RowIndex];
        if PlaylistRow.RowKind = pgrGroupHeader then
        begin
          if IsPlaylistGroupCollapsed(PlaylistRow.GroupName) then
            GroupStatePrefix := '  [+] '
          else
            GroupStatePrefix := '  [-] ';
          DBGrid1.Cells[0, RowIndex] := GroupStatePrefix + PlaylistRow.SongDisplay;
          DBGrid1.Cells[1, RowIndex] := PlaylistRow.DurationDisplay;
        end
        else
        begin
          DBGrid1.Cells[0, RowIndex] := '    ' + PlaylistRow.SongDisplay;
          DBGrid1.Cells[1, RowIndex] := PlaylistRow.DurationDisplay;
        end;
      end;
    finally
      DBGrid1.EndUpdate;
    end;
  finally
    Dec(FPlaylistGridRebuildDepth);
  end;
end;
procedure TfmDailyPlayList.TogglePlaylistGroup(const AGroupName: string);
var
  HeaderRow: Integer;
  GroupName: string;
  WasCollapsed: Boolean;
begin
  GroupName := NormalizePlaylistGroupName(AGroupName);
  WasCollapsed := IsPlaylistGroupCollapsed(GroupName);
  SetPlaylistGroupCollapsed(GroupName, not WasCollapsed);
  RebuildPlaylistGrid;
  HeaderRow := FindPlaylistGridHeaderRow(GroupName);
  if HeaderRow >= 0 then
  begin
    SelectPlaylistGridRow(HeaderRow);
    if WasCollapsed then
      ScrollPlaylistGridRowToTop(HeaderRow);
  end;
end;
procedure TfmDailyPlayList.SetAllPlaylistGroupsCollapsed(const ACollapsed: Boolean);
var
  i: Integer;
begin
  if (FPlaylistGridStartCollapsed = nil) or (FPlaylistGridRows = nil) then
    Exit;
  for i := 0 to FPlaylistGridRows.Count - 1 do
    if FPlaylistGridRows[i].RowKind = pgrGroupHeader then
      SetPlaylistGroupCollapsed(FPlaylistGridRows[i].GroupName, ACollapsed);
  RebuildPlaylistGrid;
  SyncPlaylistGridSelectionFromDataSet(False);
  if Assigned(DBGrid1) then
    DBGrid1.Repaint;
end;
function TfmDailyPlayList.TrySyncDataSetFromPlaylistGridRow(
  const ARow: Integer): Boolean;
var
  PlaylistRow: TPlaylistGridRow;
begin
  Result := False;
  if not Assigned(PlaylistQuery) or not PlaylistQuery.Active or
     not Assigned(DBGrid1) or (FPlaylistGridRows = nil) then
    Exit;
  if (ARow < 0) or (ARow >= FPlaylistGridRows.Count) then
    Exit;
  PlaylistRow := FPlaylistGridRows[ARow];
  if PlaylistRow.RowKind <> pgrSong then
    Exit;
  Result := PlaylistRow.DataSetRecordNo > 0;
  if Result and (PlaylistQuery.RecNo <> PlaylistRow.DataSetRecordNo) then
    PlaylistQuery.RecNo := PlaylistRow.DataSetRecordNo;
end;
procedure TfmDailyPlayList.SyncPlaylistGridSelectionFromDataSet(
  const AExpandCurrentGroup: Boolean);
var
  CurrentGroupName: string;
  TargetRow: Integer;
begin
  if (FPlaylistGridRebuildDepth > 0) or not Assigned(PlaylistQuery) or
     not PlaylistQuery.Active or PlaylistQuery.IsEmpty or not Assigned(DBGrid1) or
     (FPlaylistGridRows = nil) or (FPlaylistGridRows.Count = 0) then
    Exit;
  CurrentGroupName := NormalizePlaylistGroupName(
    PlaylistQuery.FieldByName('season').AsString);
  TargetRow := FindPlaylistGridRowByRecordNo(PlaylistQuery.RecNo);
  if StartPlaylistGroupsClosed and FPlaylistGridStartupClosedPending then
    TargetRow := FindPlaylistGridHeaderRow(CurrentGroupName);
  if (TargetRow < 0) and AExpandCurrentGroup then
  begin
    SetPlaylistGroupCollapsed(CurrentGroupName, False);
    RebuildPlaylistGrid;
    TargetRow := FindPlaylistGridRowByRecordNo(PlaylistQuery.RecNo);
  end;
  if TargetRow < 0 then
    TargetRow := FindPlaylistGridHeaderRow(CurrentGroupName);
  if (TargetRow < 0) and (DBGrid1.RowCount > 0) then
    TargetRow := 0;
  if TargetRow >= 0 then
    SelectPlaylistGridRow(TargetRow);
  if FPlaylistGridStartupClosedPending then
    FPlaylistGridStartupClosedPending := False;
end;
procedure TfmDailyPlayList.DBGrid1SelectionChanged(Sender: TObject);
begin
  if (FPlaylistGridSelectionSyncDepth > 0) or (FPlaylistGridRebuildDepth > 0) then
    Exit;
  if TrySyncDataSetFromPlaylistGridRow(DBGrid1.Selected) then
    UpdateFieldStateBasedOnSeasonalGroup;
end;

procedure TfmDailyPlayList.InitializeResponsiveMainLayout;
var
  I: Integer;
  OriginalChildren: TArray<TFmxObject>;
begin
  if (FResponsiveMainLayout <> nil) or (Panel1 = nil) then
    Exit;

  SetLength(OriginalChildren, Panel1.ChildrenCount);
  for I := 0 to Panel1.ChildrenCount - 1 do
    OriginalChildren[I] := Panel1.Children[I];

  FResponsiveMainLayout := TScaledLayout.Create(Self);
  FResponsiveMainLayout.Name := 'layResponsiveMain';
  FResponsiveMainLayout.Align := TAlignLayout.None;
  FResponsiveMainLayout.Position.X := 0;
  FResponsiveMainLayout.Position.Y := 0;
  FResponsiveMainLayout.OriginalWidth := MainContentDesignWidth;
  FResponsiveMainLayout.OriginalHeight := MainContentDesignHeight;
  FResponsiveMainLayout.Width := MainContentDesignWidth;
  FResponsiveMainLayout.Height := MainContentDesignHeight;
  FResponsiveMainLayout.Parent := Panel1;

  for I := 0 to High(OriginalChildren) do
    OriginalChildren[I].Parent := FResponsiveMainLayout;

  UpdateResponsiveMainLayoutScale;
end;

procedure TfmDailyPlayList.UpdateResponsiveMainLayoutScale;
var
  AvailableHeight: Single;
  AvailableWidth: Single;
  ScaledHeight: Single;
  ScaledWidth: Single;
  ScaleFactor: Single;
begin
  if (FResponsiveMainLayout = nil) or (Panel1 = nil) then
    Exit;

  AvailableWidth := Panel1.Width;
  AvailableHeight := Panel1.Height;
  if (AvailableWidth <= 0) or (AvailableHeight <= 0) then
    Exit;

  ScaleFactor := Min(AvailableWidth / MainContentDesignWidth,
    AvailableHeight / MainContentDesignHeight);
  ScaleFactor := Min(1.0, ScaleFactor);
  ScaledWidth := MainContentDesignWidth * ScaleFactor;
  ScaledHeight := MainContentDesignHeight * ScaleFactor;

  FResponsiveMainLayout.Width := ScaledWidth;
  FResponsiveMainLayout.Height := ScaledHeight;
  FResponsiveMainLayout.Position.X :=
    (AvailableWidth - ScaledWidth) / 2;
  FResponsiveMainLayout.Position.Y :=
    (AvailableHeight - ScaledHeight) / 2;
end;

procedure TfmDailyPlayList.ResizeFormForResolution(AForm: TForm);
var
  ScreenWidth, ScreenHeight: Integer;
begin
  // Get the current screen resolution
  ScreenWidth := Round(Screen.WorkAreaWidth);
  ScreenHeight := Round(Screen.WorkAreaHeight);
  // Center the form on the screen
  AForm.Left := Round((ScreenWidth - AForm.Width) / 2);
  AForm.Top := Round((ScreenHeight - AForm.Height) / 2);
end;
  // FMX manual review: procedure TfmDailyPlayList.WMSysCommand(var Msg: TWMSysCommand);
  // FMX manual review: begin
  // FMX manual review: if (Msg.CmdType and $FFF0) = SC_MINIMIZE then
  // FMX manual review: begin
  // FMX manual review: ScheduleTimer.Enabled := True;
  // FMX manual review: tmRebuildSched.Enabled := True;
  // FMX manual review: end;
  // FMX manual review: 
  // FMX manual review: inherited;
  // FMX manual review: end;
  // FMX manual review: inherited;
  // FMX manual review: end;
function TfmDailyPlayList.HandleApplicationEvent(AAppEvent: TApplicationEvent;
  AContext: TObject): Boolean;
begin
  Result := False;
  case AAppEvent of
    TApplicationEvent.WillTerminate:
      BeginOrderlyShutdown;
  end;
end;

procedure TfmDailyPlayList.BeginOrderlyShutdown;
begin
  if FGeneratedShuttingDown then
    Exit;

  FGeneratedShuttingDown := True;
  FCountdownActive := False;
  IsPlaybackInProgress := False;

  if Assigned(FGeneratedMediaNotifyTimer_MP3MediaPlayer) then
  begin
    FGeneratedMediaNotifyTimer_MP3MediaPlayer.Enabled := False;
    FGeneratedMediaNotifyTimer_MP3MediaPlayer.OnTimer := nil;
  end;

  if Assigned(KeepUSBAliveTimer) then
  begin
    KeepUSBAliveTimer.Enabled := False;
    KeepUSBAliveTimer.OnTimer := nil;
  end;

  if Assigned(ScheduleTimer) then
  begin
    ScheduleTimer.Enabled := False;
    ScheduleTimer.OnTimer := nil;
  end;

  if Assigned(Timer1) then
  begin
    Timer1.Enabled := False;
    Timer1.OnTimer := nil;
  end;

  if Assigned(tmRebuildSched) then
  begin
    tmRebuildSched.Enabled := False;
    tmRebuildSched.OnTimer := nil;
  end;

  if Assigned(fmClock) then
    if Assigned(fmClock.Timer1) then
    begin
      fmClock.Timer1.Enabled := False;
      fmClock.Timer1.OnTimer := nil;
    end;

  if Assigned(frmEmailSettings) then
    if Assigned(frmEmailSettings.Timer1) then
    begin
      frmEmailSettings.Timer1.Enabled := False;
      frmEmailSettings.Timer1.OnTimer := nil;
    end;

  if Assigned(SettingsMain) then
  begin
    if Assigned(SettingsMain.SilenceTimer) then
    begin
      SettingsMain.SilenceTimer.Enabled := False;
      SettingsMain.SilenceTimer.OnTimer := nil;
    end;
    if Assigned(SettingsMain.Timer1) then
    begin
      SettingsMain.Timer1.Enabled := False;
      SettingsMain.Timer1.OnTimer := nil;
    end;
  end;

  if Assigned(Groups) then
    if Assigned(Groups.Timer1) then
    begin
      Groups.Timer1.Enabled := False;
      Groups.Timer1.OnTimer := nil;
    end;

  if Assigned(MP3MediaPlayer) then
  begin
    try
      if MP3MediaPlayer.State in [TMediaState.Playing, TMediaState.Stopped] then
        MP3MediaPlayer.Stop;
    except
    end;

    try
      MP3MediaPlayer.Clear;
    except
    end;
  end;

  if Assigned(PlaybackSchedule) then
    PlaybackSchedule.Clear;

  try
    PowerHoldOff;
  except
  end;
end;

procedure TfmDailyPlayList.plbtnDoneClick(Sender: TObject);
begin
  BeginOrderlyShutdown;
  Application.Terminate;
end;
procedure TfmDailyPlayList.BeginPlaylistEditSession;
begin
  if FGeneratedShuttingDown or Application.Terminated then
    Exit;
  if Assigned(chkEnableSchedule) and chkEnableSchedule.IsChecked then
  begin
    FPlaylistEditSchedulePaused := True;
    DisableSchedule;
  end;
end;

procedure TfmDailyPlayList.EndPlaylistEditSession;
begin
  if FGeneratedShuttingDown or Application.Terminated then
    Exit;
  if FPlaylistEditSchedulePaused then
  begin
    FPlaylistEditSchedulePaused := False;
    GeneratedSetToggleState_chkEnableSchedule(True);
    chkEnableScheduleClick(Self);
  end;
end;
procedure TfmDailyPlayList.PlaySelectedSong;
var
  SongPath: string;
  NumberOfTimes: Integer;
begin
  if FGeneratedShuttingDown or Application.Terminated then
    Exit;
  if not Assigned(PlaylistQuery) or not PlaylistQuery.Active then
  begin
    ShowMessage('Error: Dataset PlaylistQuery is not active.');
    Exit;
  end;
  if PlaylistQuery.IsEmpty then
  begin
    ShowMessage('No file selected for playback.');
    Exit;
  end;
  try
    if not TryResolveSelectedSong(SongPath, NumberOfTimes) then
      Exit;
    ResolveRandomSongIfNeeded(SongPath);
    if Assigned(SettingsMain) and SettingsMain.chkLogOnOff.IsChecked then
      AddToLog('Played Song: ' + SongPath);
    if not FileExists(SongPath) then
    begin
      ShowMessage('File not found: ' + SongPath);
      Exit;
    end;
    ShowNowPlaying(SongPath);
    PlaySongRepeats(NumberOfTimes);
    HideNowPlaying;
  except
    on E: Exception do
      ShowMessage('An error occurred: ' + E.ClassName + ': ' + E.Message);
  end;
end;
procedure TfmDailyPlayList.DBNavigator1BeforeAction(Sender: TObject;
  Button: TBindNavigateBtn);
begin
  if not tbPlaylist.Active then
    tbPlaylist.Open;
  if Button = nbDelete then
    BeginPlaylistEditSession;
  if Button = nbEdit then
    BeginPlaylistEditSession;
  if Button = nbInsert then
  begin
    BeginPlaylistEditSession;
    OpenDialog1.Options := OpenDialog1.Options + [TOpenOption.ofAllowMultiSelect];
    try
      InsertSelectedSongs;
    finally
      EndPlaylistEditSession;
    end;
    Abort;
  end
  else if Button = nbRefresh then
  begin
    RefreshGrid;
    Abort;
  end;
end;
procedure TfmDailyPlayList.DisplayHelp1Click(Sender: TObject);
var
  HelpFilePath: string;
begin
  HelpFilePath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'Help\index.html';
  // Check if the help file exists
  if FileExists(HelpFilePath) then
    ShellExecute(0, 'open', PChar(HelpFilePath), nil, nil, SW_SHOWNORMAL)
  else
    ShowMessage('Help file not found: ' + HelpFilePath);
end;
procedure TfmDailyPlayList.ShowLog1Click(Sender: TObject);
var
  I: Integer;
  LogHandle: HWND;
  LogViewer: TfrmLogViewer;
begin
  for I := 0 to Screen.FormCount - 1 do
    if Screen.Forms[I] is TfrmLogViewer then
    begin
      LogViewer := TfrmLogViewer(Screen.Forms[I]);
      LogViewer.Show;
      LogViewer.BringToFront;
      LogViewer.Activate;
      LogViewer.RefreshLogRows;
      LogHandle := FormToHWND(LogViewer);
      if LogHandle <> 0 then
      begin
        ShowWindow(LogHandle, SW_RESTORE);
        SetWindowPos(LogHandle, HWND_TOP, 0, 0, 0, 0,
          SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);
        SetForegroundWindow(LogHandle);
      end;
      Exit;
    end;

  LogViewer := TfrmLogViewer.Create(Self);
  LogViewer.Show;
end;
procedure TfmDailyPlayList.Exit1Click(Sender: TObject);
begin
  BeginOrderlyShutdown;
  Application.Terminate;
end;
procedure TfmDailyPlayList.tbPlaylistAfterPost(DataSet: TDataSet);
begin
  RefreshGrid; // Ensure the grid is refreshed and resorted
  UpdateStatusBar('');
end;
procedure TfmDailyPlayList.PlaylistQueryAfterPost(DataSet: TDataSet);
begin
  RefreshGrid;
  UpdateStatusBar('');
  EndPlaylistEditSession;
end;
procedure TfmDailyPlayList.PlaylistQueryAfterCancel(DataSet: TDataSet);
begin
  GeneratedSyncManualFieldBindingsForDataSet(PlaylistQuery);
  UpdateStatusBar('');
  EndPlaylistEditSession;
end;
procedure TfmDailyPlayList.btnPlaySongClick(Sender: TObject);
begin
  btnPlaySong.Text := 'Playing';
  Sleep(500);
  btnPausePlay.Text := 'Pause';
  btnStopPlay.Text := 'Stop';
  PlaySelectedSong;
  btnPlaySong.Text := 'Play';
  btnPausePlay.Text := 'Pause';
  btnStopPlay.Text := 'Stop';
end;
procedure TfmDailyPlayList.btnPausePlayClick(Sender: TObject);
begin
  if MP3MediaPlayer.State = TMediaState.Playing then
  begin
    MP3MediaPlayer.Stop;
    btnPlaySong.Text := 'Play';
    btnPausePlay.Text := 'Paused';
    btnStopPlay.Text := 'Stop';
  end
  else if MP3MediaPlayer.State = TMediaState.Stopped then
  begin
    MP3MediaPlayer.Play;
    btnPlaySong.Text := 'Playing';
    btnPausePlay.Text := 'Pause';
    btnStopPlay.Text := 'Stop';
  end
  else
  begin
    ShowMessage('Media is neither playing nor paused.');
  end;
end;
procedure TfmDailyPlayList.btnStopPlayClick(Sender: TObject);
begin
  if MP3MediaPlayer.State in [TMediaState.Playing, TMediaState.Stopped] then
  begin
    MP3MediaPlayer.Stop;
    btnPlaySong.Text := 'Play';
    btnPausePlay.Text := 'Pause';
    btnStopPlay.Text := 'Stopped';
    // Sleep(500);
    btnStopPlay.Text := 'Stop';
    StopNowPlayingCountdown;
    IsPlaybackInProgress := False;
  end;
end;
procedure TfmDailyPlayList.DBComboBox1DropDown(Sender: TObject);
var
  TempQuery: TFDQuery;
begin
  DBComboBox1.Clear;
  TempQuery := TFDQuery.Create(nil); // temporary query
  try
    TempQuery.Connection := ADOConnection1;
    // Assign the same connection
    TempQuery.SQL.Text := 'SELECT seasonalgroup FROM SeasonalGroups';
    TempQuery.Open;
    while not TempQuery.Eof do
    begin
      DBComboBox1.Items.Add(TempQuery.FieldByName('seasonalgroup').AsString);
      TempQuery.Next;
    end;
  finally
    TempQuery.close;
    TempQuery.Free;
  end;
end;
procedure TfmDailyPlayList.DBGrid1CellClick(const Column: TColumn; const Row: Integer);
begin
  if (FPlaylistGridRows <> nil) and (Row >= 0) and (Row < FPlaylistGridRows.Count) and
     (FPlaylistGridRows[Row].RowKind = pgrGroupHeader) then
  begin
    TogglePlaylistGroup(FPlaylistGridRows[Row].GroupName);
    Exit;
  end;
  if TrySyncDataSetFromPlaylistGridRow(Row) then
    UpdateFieldStateBasedOnSeasonalGroup;
end;
procedure TfmDailyPlayList.btnCloseAllGroupsClick(Sender: TObject);
begin
  SetAllPlaylistGroupsCollapsed(True);
end;
procedure TfmDailyPlayList.btnOpenAllGroupsClick(Sender: TObject);
begin
  SetAllPlaylistGroupsCollapsed(False);
end;
procedure TfmDailyPlayList.EditGroups3Click(Sender: TObject);
begin
  DisableSchedule;
  try
    if not Assigned(Groups) then
      Application.CreateForm(TGroups, Groups);
    CenterForm(Groups);
    Groups.ShowModal;
  finally
    GeneratedSetToggleState_chkEnableSchedule(True);
    chkEnableScheduleClick(Self);
  end;
end;
procedure TfmDailyPlayList.EditSettings1Click(Sender: TObject);
begin
  DisableSchedule;
  try
    if not Assigned(SettingsMain) then
      Application.CreateForm(TSettingsMain, SettingsMain);
    CenterForm(SettingsMain);
    SettingsMain.ShowModal;
  finally
    GeneratedSetToggleState_chkEnableSchedule(True);
    chkEnableScheduleClick(Self);
  end;
end;
procedure TfmDailyPlayList.edPLPlayDateToExit(Sender: TObject);
begin
  var
    DateValue: TDateTime;
  if TryStrToDate(TEdit(Sender).Text, DateValue) and (YearOf(DateValue) < 2000)
  then
    TEdit(Sender).Text := FormatDateTime('mm/dd/yyyy',
      IncYear(DateValue, 100));
end;
procedure TfmDailyPlayList.FormCreate(Sender: TObject);
// Set form color using settings file values or default to beige/maroon
var
  TempQuery: TFDQuery;
begin
  if FGeneratedFormCreateRan then
    Exit;
  FGeneratedFormCreateRan := True;
  InitializeResponsiveMainLayout;
  // Generated FMX data field preparation
  if PlaylistQuery.Active then
    PlaylistQuery.Close;
  if PlaylistQuery.FindField('season_display') = nil then
  begin
    with TWideStringField.Create(Self) do
    begin
      FieldKind := fkInternalCalc;
      FieldName := 'season_display';
      Size := 8192;
      DataSet := PlaylistQuery;
    end;
  end;
  if PlaylistQuery.Active then
    PlaylistQuery.Close;
  if PlaylistQuery.FindField('song_name_display') = nil then
  begin
    with TWideStringField.Create(Self) do
    begin
      FieldKind := fkInternalCalc;
      FieldName := 'song_name_display';
      Size := 8192;
      DataSet := PlaylistQuery;
    end;
  end;
  if PlaylistQuery.Active then
    PlaylistQuery.Close;
  if PlaylistQuery.FindField('song_duration_display') = nil then
  begin
    with TWideStringField.Create(Self) do
    begin
      FieldKind := fkInternalCalc;
      FieldName := 'song_duration_display';
      Size := 8192;
      DataSet := PlaylistQuery;
    end;
  end;
  if Assigned(PlaylistQuery) then
  begin
    FOriginal_PlaylistQuery_OnCalcFields := PlaylistQuery.OnCalcFields;
    PlaylistQuery.OnCalcFields := PlaylistQuery_GeneratedCalcFields;
  end;
  if Assigned(PlaylistQuery) then
  begin
    FOriginal_PlaylistQuery_AfterOpen := PlaylistQuery.AfterOpen;
    PlaylistQuery.AfterOpen := PlaylistQuery_GeneratedAfterOpen;
  end;
  if Assigned(DBGrid1) then
  begin
    DBGrid1.OnCellDblClick := DBGrid1CellDblClick;
    DBGrid1.OnSelChanged := DBGrid1SelectionChanged;
  end;
  if FPlaylistGridRows = nil then
    FPlaylistGridRows := TList<TPlaylistGridRow>.Create;
  if FPlaylistGridStartCollapsed = nil then
    FPlaylistGridStartCollapsed := TDictionary<string, Boolean>.Create;
  EnsurePlaylistGridColumns;
  ResetPlaylistGridToStartupState;
  FPlayedSongCountToday := 0;
  SetupStatusBar;
  UpdateStatusBar('');
  // for portable app
  PowerHoldOn;
  //dsPlayList.DataSet := PlaylistQuery;
  // FMX: binding generated automatically for DBNavigator1
  // FMX: binding generated automatically for DBGrid1
  PlaylistQuery.Close;
  PlaylistQuery.UpdateOptions.UpdateMode := upWhereKeyOnly;
  PlaylistQuery.UpdateOptions.KeyFields := 'playlist_name;song_name';
  FSkipNextPlaylistGridSelectionSync := StartPlaylistGroupsClosed;
  ConfigurePortableSQLiteConnection(PlaylistConnection);
  PlaylistConnection.Connected := True;
  ConfigurePortableSQLiteConnection(ADOConnection1);
  ADOConnection1.Connected := True;
  PlaylistQuery.Open;
  GeneratedSyncManualFieldBindingsForDataSet(PlaylistQuery);
  AddToLog('Application initialized');
  AudioManager := TAudioManager.Create(TrackBar1);
  AudioManager.OnMuteChanged := AudioManagerMuteChanged;
  AudioManager.InitializeAudio;
  FSilenceManager := TSilenceManager.Create(AudioManager);
  FSilenceManager.OnStateChanged := SilenceManagerStateChanged;
  FSilenceManager.Reload;
  FSilenceManager.Tick;
  // Create a temporary query to fetch colors
  TempQuery := TFDQuery.Create(nil);
  try
    TempQuery.Connection := PlaylistConnection;
    TempQuery.SQL.Text :=
      'SELECT form_bgcolor, form_fontcolor FROM pl_settings';
    TempQuery.Open;
    if not TempQuery.IsEmpty then
    begin
      // Check if either field is NULL
      if TempQuery.FieldByName('form_bgcolor').IsNull or
        TempQuery.FieldByName('form_fontcolor').IsNull then
      begin
        // Use defaults if NULL
        FormBackgroundColor := VCLColorToAlphaColor($8EBDDC);
        FormFontColor := VCLColorToAlphaColor($000080);
      end
      else
      begin
        // Assign field values directly if not NULL
        FormBackgroundColor := VCLColorToAlphaColor(TempQuery.FieldByName('form_bgcolor').AsInteger);
        FormFontColor := VCLColorToAlphaColor(TempQuery.FieldByName('form_fontcolor').AsInteger);
      end;
    end
    else
    begin
      // No records, use defaults
      FormBackgroundColor := VCLColorToAlphaColor($8EBDDC);
      FormFontColor := VCLColorToAlphaColor($000080);
    end;
  finally
    TempQuery.close;
    TempQuery.Free; // Free the temporary query
  end;
  ApplyFormTheme(FormBackgroundColor, FormFontColor, True);
  FCurrentColorThemeIndex := FindCarillonThemeIndex(FormBackgroundColor, FormFontColor);
  ConfigureColorThemeMenu;
  Randomize; // random number generator
  DBNavigator1.BeforeAction := DBNavigator1BeforeAction;
  tbPlaylist.AfterPost := tbPlaylistAfterPost;
  PlaylistQuery.AfterPost := PlaylistQueryAfterPost;
  PlaylistQuery.AfterCancel := PlaylistQueryAfterCancel;
  PlaylistQuery.AfterScroll := PlaylistQueryAfterScroll;
  // Attach AfterScroll event handler
  PlaybackSchedule := TList<TScheduleEntry>.Create;
  IsPlaybackInProgress := False;
  NextScheduleEntryId := 0; // Initialize the unique ID counter
  ScheduleTimer.Interval := 1000; // Set the timer interval to 10 seconds
  ScheduleTimer.OnTimer := ScheduleTimerTimer;
  // Set the timer event handler
  ScheduleTimer.Enabled := False;
  FLastScheduleRebuildDate := Date;
  tmRebuildSched.Interval := 30000;
  tmRebuildSched.OnTimer := tmRebuildSchedTimer;
  tmRebuildSched.Enabled := True;
  GeneratedRegisterMediaNotify_MP3MediaPlayer(MP3MediaPlayerNotify);
  // Set the notify event handler
  GeneratedSetMediaNotifyEnabled_MP3MediaPlayer(True); // Enable the notification
  UpdateFieldStatesForAllRecords;
  // Ensure initial state is set based on group
  ResizeFormForResolution(Self);
  ApplyThemeToPlayerGroupBoxes;
  // Initialize tracking of program running time
  StartTime := Now; // Capture the time when the form is created
  Timer1.OnTimer := Timer1Timer; // Set the OnTimer event handler
  Timer1.Enabled := True; // Start the timer
  FCountdownActive := False;
  FCurrentSongDurationSeconds := 0;
  FCurrentSongStartTick := 0;
  FNowPlayingCaptionBase := '';
  FCurrentSongIsRandom := False;
  ApplyScheduleStatusTheme;
  // Generated FMX LiveBindings from original VCL data-aware controls
  if FPlaylistBindSource = nil then
  begin
    FPlaylistBindSource := TBindSourceDB.Create(Self);
    FPlaylistBindSource.DataSource := plDataSource;
  end;
  GeneratedRegisterManualFieldBinding(edPLPlayDateTo, PlaylistQuery, 'play_date_to');
  if Assigned(plDataSource) and not Assigned(plDataSource.OnDataChange) then
    plDataSource.OnDataChange := plDataSource_GeneratedDataChange;
  if Assigned(DBNavigator1) then
  begin
    FOriginal_DBNavigator1_BeforeAction := DBNavigator1.BeforeAction;
    DBNavigator1.BeforeAction := DBNavigator1_GeneratedBeforeAction;
  end;
  GeneratedRegisterManualFieldBinding(edPLPlayDateFrom, PlaylistQuery, 'PLAY_DATE_FROM');
  GeneratedRegisterManualFieldBinding(edPLTimeToPlay4, PlaylistQuery, 'scheduled_time4');
  GeneratedRegisterManualFieldBinding(edPLTimeToPlay11, PlaylistQuery, 'scheduled_time11');
  GeneratedRegisterManualFieldBinding(edPLTimeToPlay12, PlaylistQuery, 'scheduled_time12');
  GeneratedRegisterManualFieldBinding(edPLTimeToPlay10, PlaylistQuery, 'scheduled_time10');
  GeneratedRegisterManualFieldBinding(edPLTimeToPlay9, PlaylistQuery, 'scheduled_time9');
  GeneratedRegisterManualFieldBinding(edPLTimeToPlay8, PlaylistQuery, 'scheduled_time8');
  GeneratedRegisterManualFieldBinding(edPLTimeToPlay7, PlaylistQuery, 'scheduled_time7');
  GeneratedRegisterManualFieldBinding(edPLTimeToPlay6, PlaylistQuery, 'scheduled_time6');
  GeneratedRegisterManualFieldBinding(edPLTimeToPlay5, PlaylistQuery, 'scheduled_time5');
  GeneratedRegisterManualFieldBinding(edPLTimeToPlay3, PlaylistQuery, 'scheduled_time3');
  GeneratedRegisterManualFieldBinding(edPLTimeToPlay2, PlaylistQuery, 'scheduled_time2');
  GeneratedRegisterManualFieldBinding(edPLTimeToPlay1, PlaylistQuery, 'scheduled_time1');
  GeneratedRegisterManualFieldBinding(plNumberOfTimesToPlay, PlaylistQuery, 'num_times_to_play');
  EnsureCheckBoxLink(Link_chkPlayMonday, chkPlayMonday, 'play_monday');
  EnsureCheckBoxLink(Link_chkPlayTuesday, chkPlayTuesday, 'play_tuesday');
  EnsureCheckBoxLink(Link_chkPlayWednesday, chkPlayWednesday, 'play_wednesday');
  EnsureCheckBoxLink(Link_chkPlayThursday, chkPlayThursday, 'play_thursday');
  EnsureCheckBoxLink(Link_chkPlayFriday, chkPlayFriday, 'play_friday');
  EnsureCheckBoxLink(Link_chkPlaySaturday, chkPlaySaturday, 'play_saturday');
  EnsureCheckBoxLink(Link_chkPlaySunday, chkPlaySunday, 'play_sunday');
  if Assigned(DBComboBox1) then
  begin
    FOriginal_DBComboBox1_OnChange := DBComboBox1.OnChange;
    FOriginal_DBComboBox1_OnPopup := DBComboBox1.OnPopup;
    FOriginal_DBComboBox1_OnClosePopup := DBComboBox1.OnClosePopup;
    DBComboBox1.OnChange := DBComboBox1_GeneratedOnChange;
    DBComboBox1.OnClosePopup := DBComboBox1_GeneratedOnClosePopup;
    DBComboBox1.OnPopup := DBComboBox1_GeneratedOnPopup;
    DBComboBox1_SyncFromField;
  end;
  if Assigned(DBNavigator1) then
    DBNavigator1.DataSource := FPlaylistBindSource;
  if Assigned(DBGrid1) then
  begin
    DBGrid1.ReadOnly := True;
    DBGrid1.Options := DBGrid1.Options - [TGridOption.Editing, TGridOption.CancelEditingByDefault];
  end;
  if Assigned(DBGrid1) and not Assigned(DBGrid1.OnMouseWheel) then
    DBGrid1.OnMouseWheel := DBGrid1_GeneratedMouseWheel;
  if Assigned(chkEnableScheduledPanel) then
    ApplyThemeToSurface(chkEnableScheduledPanel, FThemeSurfaceColor);
  if Assigned(Panel2) then
    ApplyThemeToSurface(Panel2, FThemeSurfaceColor);
  ApplyThemeToScheduleInputs;
  if Assigned(chkEnableSchedule) then
  begin
    FGeneratedToggleOriginalClick_chkEnableSchedule := chkEnableSchedule.OnClick;
    FGeneratedToggleOriginalChange_chkEnableSchedule := chkEnableSchedule.OnChange;
    chkEnableSchedule.OnClick := nil;
    chkEnableSchedule.OnChange := chkEnableSchedule_GeneratedUserChange;
  end;
  if TPlatformServices.Current.SupportsPlatformService(IFMXApplicationEventService,
    IInterface(FApplicationEventService)) then
    FApplicationEventService.SetApplicationEventHandler(HandleApplicationEvent);
end;
procedure TfmDailyPlayList.FormDestroy(Sender: TObject);
begin
  BeginOrderlyShutdown;
  // Generated FMX cleanup for bindings, timers, and media
  if Assigned(FApplicationEventService) then
  begin
    FApplicationEventService.SetApplicationEventHandler(nil);
    FApplicationEventService := nil;
  end;
  if Assigned(KeepUSBAliveTimer) then
  begin
    KeepUSBAliveTimer.Enabled := False;
    KeepUSBAliveTimer.OnTimer := nil;
  end;
  if Assigned(ScheduleTimer) then
  begin
    ScheduleTimer.Enabled := False;
    ScheduleTimer.OnTimer := nil;
  end;
  if Assigned(Timer1) then
  begin
    Timer1.Enabled := False;
    Timer1.OnTimer := nil;
  end;
  if Assigned(tmRebuildSched) then
  begin
    tmRebuildSched.Enabled := False;
    tmRebuildSched.OnTimer := nil;
  end;
  GeneratedCleanupManualFieldBindingsForOwner(Self);
  if Assigned(plDataSource) and (plDataSource.Owner <> Self) then
    plDataSource.OnDataChange := nil;
  if Assigned(DBNavigator1) and (DBNavigator1.Owner <> Self) then
    DBNavigator1.BeforeAction := FOriginal_DBNavigator1_BeforeAction;
  if Assigned(DBComboBox1) and (DBComboBox1.Owner <> Self) then
  begin
    DBComboBox1.OnChange := FOriginal_DBComboBox1_OnChange;
    DBComboBox1.OnPopup := FOriginal_DBComboBox1_OnPopup;
    DBComboBox1.OnClosePopup := FOriginal_DBComboBox1_OnClosePopup;
  end;
  if Assigned(PlaylistQuery) and (PlaylistQuery.Owner <> Self) then
    PlaylistQuery.OnCalcFields := FOriginal_PlaylistQuery_OnCalcFields;
  if Assigned(PlaylistQuery) and (PlaylistQuery.Owner <> Self) then
    PlaylistQuery.AfterOpen := FOriginal_PlaylistQuery_AfterOpen;
  if Assigned(chkEnableSchedule) then
  begin
    chkEnableSchedule.OnChange := nil;
    chkEnableSchedule.OnClick := nil;
  end;
  AddToLog('Application shut down');
  if Assigned(PlaybackSchedule) then begin PlaybackSchedule.Clear; FreeAndNil(PlaybackSchedule); end;
  FreeAndNil(FSilenceManager);
  FreeAndNil(FPlaylistGridRows);
  FreeAndNil(FPlaylistGridStartCollapsed);
  FreeAndNil(AudioManager);
end;
procedure TfmDailyPlayList.AudioManagerMuteChanged(Sender: TObject;
  Muted: Boolean);
begin
  if Assigned(TrackBar1) then
    TrackBar1.Enabled := not Muted;
  if Assigned(mbMuteButton) then
  begin
    if Muted then
      mbMuteButton.Text := 'Unmute'
    else
      mbMuteButton.Text := 'Mute';
  end;
end;
procedure TfmDailyPlayList.RefreshSilenceRulesAndSchedule;
begin
  if Assigned(FSilenceManager) then
  begin
    FSilenceManager.Reload;
    FSilenceManager.Tick;
  end;

  if Assigned(chkEnableSchedule) and chkEnableSchedule.IsChecked then
    CompileSchedule;
end;

procedure TfmDailyPlayList.SilenceManagerStateChanged(Sender: TObject;
  Active: Boolean; const Purpose: string; UntilTime: TDateTime);
begin
  if Active then
  begin
    AddToLog(Format('Bell system silenced: %s until %s',
      [Purpose, FormatDateTime('h:nn:ss AM/PM', UntilTime)]));
    UpdateStatusBar('');
  end
  else
  begin
    if Purpose <> '' then
      AddToLog('Bell system restored after silence window: ' + Purpose)
    else
      AddToLog('Bell system restored after silence window');
    UpdateStatusBar('');
  end;
end;
procedure TfmDailyPlayList.Timer1Timer(Sender: TObject);
var
  Days, Hours, Minutes, Seconds: Word;
  DisplayText: string;
  TotalYears, TotalMonths, RemainingDays, TotalWeeks: Integer;
begin
  if FGeneratedShuttingDown or Application.Terminated then
    Exit;
  // Calculate years
  TotalYears := YearsBetween(StartTime, Now);
  // Calculate months (remaining months after years)
  TotalMonths := MonthsBetween(IncYear(StartTime, TotalYears), Now);
  // Calculate remaining days after subtracting years and months
  RemainingDays := DaysBetween(IncMonth(IncYear(StartTime, TotalYears),
    TotalMonths), Now);
  // Calculate weeks (remaining weeks after months and years)
  TotalWeeks := RemainingDays div 7;
  // Calculate remaining days after weeks
  Days := RemainingDays mod 7;
  // Calculate hours, minutes, and seconds
  Hours := HoursBetween(StartTime, Now) mod 24;
  Minutes := MinutesBetween(StartTime, Now) mod 60;
  Seconds := SecondsBetween(StartTime, Now) mod 60;
  // Build the display string
  DisplayText :=
    Format('     Uptime:       %d years       %d months       %d weeks       %d days       %d hours       %d minutes        %d seconds',
    [TotalYears, TotalMonths, TotalWeeks, Days, Hours, Minutes, Seconds]);
  // Update the form's caption
  Self.Caption :=
    'Westminster Chimes and Carillon Bells Schedule - Portable Edition            '
    + DisplayText;
  UpdateNowPlayingLabel;
  if Assigned(FSilenceManager) then
    FSilenceManager.Tick;
end;
procedure TfmDailyPlayList.FormShow(Sender: TObject);
begin
  if not FGeneratedFormCreateRan then
    FormCreate(Self);
  // Explicitly set the checkbox to "checked" and simulate click
  GeneratedSetToggleState_chkEnableSchedule(True);
  if not (csDestroying in ComponentState) then
    chkEnableScheduleClick(Self);
  ApplyThemeToPlayerGroupBoxes;
  UpdateStatusBar('');
end;

procedure TfmDailyPlayList.FormResize(Sender: TObject);
begin
  UpdateResponsiveMainLayoutScale;
end;

procedure TfmDailyPlayList.gbDatesSeasonsEnter(Sender: TObject);
begin
  if Sender is TCheckBox then
    BeginPlaylistEditSession;
end;

procedure TfmDailyPlayList.KeepUSBAliveTimerTimer(Sender: TObject);
var
  dummyDir, dummyFile: string;
  f: TextFile;
begin
  if FGeneratedShuttingDown then
    Exit;
  dummyDir := ExtractFilePath(ParamStr(0)) + 'data\';
  dummyFile := dummyDir + 'keepalive.txt';
  try
    if not DirectoryExists(dummyDir) then
      ForceDirectories(dummyDir);
    // ensure the data folder exists
    AssignFile(f, dummyFile);
    Rewrite(f);
    Writeln(f, 'Ping: ' + FormatDateTime('yyyy-mm-dd hh:nn:ss', Now));
    CloseFile(f);
  except
    on E: Exception do; // optionally log
  end;
end;
procedure TfmDailyPlayList.mbMuteButtonClick(Sender: TObject);
begin
  if not Assigned(AudioManager) then
    Exit;
  AudioManager.ToggleMute;
end;
procedure TfmDailyPlayList.RefreshGrid;
begin
  FSkipNextPlaylistGridSelectionSync := True;
  PlaylistQuery.DisableControls;
  try
    PlaylistQuery.close;
    PlaylistQuery.SQL.Text := 'SELECT * FROM playlist ORDER BY season, song_name';
    // Ensure the dataset is sorted
    PlaylistQuery.Open;
  GeneratedSyncManualFieldBindingsForDataSet(PlaylistQuery);
  finally
    PlaylistQuery.EnableControls;
  end;
  if Assigned(FPlaylistBindSource) and Assigned(FPlaylistBindSource.DataSource) and Assigned(FPlaylistBindSource.DataSource.DataSet) then FPlaylistBindSource.DataSource.DataSet.First;
end;
procedure TfmDailyPlayList.CenterForm(AForm: TForm);
begin
  AForm.Left := (Round(Screen.Width / 2)) - (Round(AForm.Width / 2));
  AForm.Top := (Round(Screen.Height / 2)) - (Round(AForm.Height / 2));
end;
procedure TfmDailyPlayList.Button1Click(Sender: TObject);
begin
  EditGroups3Click(Sender);
end;
procedure TfmDailyPlayList.chkEnableScheduleClick(Sender: TObject);
begin
  ResetPlaylistGridToStartupState;
  if chkEnableSchedule.IsChecked then
  begin
    UpdatePlaylistFromSeasonalGroups;
    // Update playlist from seasonal groups
    CompileSchedule;
    // ShowSchedule; // Display the schedule
    ScheduleTimer.Enabled := True;
    IsPlaybackInProgress := False;
    lblScheduleStatus.Text := 'Schedule enabled';
    ApplyScheduleStatusTheme;
    UpdateFieldStatesForAllRecords;
    AddToLog('Scheduled enabled');
    if StartPlaylistGroupsClosed then
    begin
      RebuildPlaylistGrid;
      if Assigned(DBGrid1) and (DBGrid1.RowCount > 0) then
      begin
        SelectPlaylistGridRow(0);
        DBGrid1.TopRow := 0;
        DBGrid1.Repaint;
      end;
    end
    else
      SyncPlaylistGridSelectionFromDataSet(False);
    // Ensure initial state is set based on group
  end
  else
  begin
    ScheduleTimer.Enabled := False;
    if Assigned(PlaybackSchedule) then
      PlaybackSchedule.Clear;
    IsPlaybackInProgress := False;
    lblScheduleStatus.Text := 'Schedule disabled';
    ApplyScheduleStatusTheme;
    AddToLog('Scheduled disabled');
    RebuildPlaylistGrid;
    SyncPlaylistGridSelectionFromDataSet(False);
    if Assigned(DBGrid1) then
      DBGrid1.Repaint;
  end;
end;
// Present the user with the available built-in color themes
procedure TfmDailyPlayList.ConfigureColorThemeMenu;
var
  MenuItem: TMenuItem;
  ThemeIndex: Integer;
begin
  if Assigned(Colors1) then
    Colors1.Text := 'Themes';
  if Assigned(miDefault) then
  begin
    miDefault.Text := 'Current: Custom Saved Colors';
    miDefault.AutoCheck := True;
    miDefault.RadioItem := True;
    miDefault.GroupIndex := 1;
    miDefault.Enabled := True;
    miDefault.HitTest := True;
  end;
  for ThemeIndex := Low(CarillonColorThemes) to High(CarillonColorThemes) do
  begin
    MenuItem := FindColorThemeMenuItem(CarillonColorThemes[ThemeIndex].MenuItemName);
    if Assigned(MenuItem) then
    begin
      MenuItem.Text := CarillonColorThemes[ThemeIndex].ThemeName;
      MenuItem.AutoCheck := True;
      MenuItem.RadioItem := True;
      MenuItem.GroupIndex := 1;
    end;
  end;
  UpdateColorThemeMenuChecks;
end;
function TfmDailyPlayList.FindColorThemeMenuItem(
  const AMenuItemName: string): TMenuItem;
var
  ComponentRef: TComponent;
begin
  Result := nil;
  ComponentRef := FindComponent(AMenuItemName);
  if ComponentRef is TMenuItem then
    Result := TMenuItem(ComponentRef);
end;
function TfmDailyPlayList.FindColorThemeIndex(const ABackgroundColor,
  AFontColor: TAlphaColor): Integer;
var
  BackgroundVclColor: Integer;
  FontVclColor: Integer;
  ThemeIndex: Integer;
begin
  Result := -1;
  BackgroundVclColor := AlphaColorToVCLColor(ABackgroundColor);
  FontVclColor := AlphaColorToVCLColor(AFontColor);
  for ThemeIndex := Low(CarillonColorThemes) to High(CarillonColorThemes) do
    if (CarillonColorThemes[ThemeIndex].BackgroundVclColor = BackgroundVclColor)
      and (CarillonColorThemes[ThemeIndex].FontVclColor = FontVclColor) then
    begin
      Result := ThemeIndex;
      Exit;
    end;
end;
function TfmDailyPlayList.FindColorThemeIndexByMenuName(
  const AMenuItemName: string): Integer;
var
  ThemeIndex: Integer;
begin
  Result := -1;
  for ThemeIndex := Low(CarillonColorThemes) to High(CarillonColorThemes) do
    if SameText(CarillonColorThemes[ThemeIndex].MenuItemName, AMenuItemName) then
    begin
      Result := ThemeIndex;
      Exit;
    end;
end;
procedure TfmDailyPlayList.SaveCurrentThemeColors;
var
  TempQuery: TFDQuery;
begin
  if not Assigned(PlaylistConnection) then
    Exit;
  if not PlaylistConnection.Connected then
    PlaylistConnection.Connected := True;
  TempQuery := TFDQuery.Create(nil);
  try
    TempQuery.Connection := PlaylistConnection;
    TempQuery.SQL.Text :=
      'UPDATE pl_settings SET form_bgcolor = :stbgColor, form_fontcolor = :stfontColor';
    TempQuery.ParamByName('stbgColor').AsInteger :=
      AlphaColorToVCLColor(FormBackgroundColor);
    TempQuery.ParamByName('stfontColor').AsInteger :=
      AlphaColorToVCLColor(FormFontColor);
    try
      TempQuery.ExecSQL;
    except
      on E: Exception do
        ShowMessage('Error saving colors: ' + E.Message);
    end;
  finally
    TempQuery.Close;
    TempQuery.Free;
  end;
end;
procedure TfmDailyPlayList.ApplyColorThemeByIndex(const AThemeIndex: Integer;
  const APersist: Boolean);
begin
  if (AThemeIndex < Low(CarillonColorThemes)) or
     (AThemeIndex > High(CarillonColorThemes)) then
    Exit;
  FormBackgroundColor := VCLColorToAlphaColor(
    CarillonColorThemes[AThemeIndex].BackgroundVclColor);
  FormFontColor := VCLColorToAlphaColor(
    CarillonColorThemes[AThemeIndex].FontVclColor);
  ApplyFormTheme(FormBackgroundColor, FormFontColor, True);
  ApplyScheduleStatusTheme;
  FCurrentColorThemeIndex := AThemeIndex;
  UpdateColorThemeMenuChecks;
  if APersist then
    SaveCurrentThemeColors;
  if Assigned(SettingsMain) then
    ApplyCarillonThemeToForm(SettingsMain, AThemeIndex, True);
  if Assigned(frmEmailSettings) then
    ApplyCarillonThemeToForm(frmEmailSettings, AThemeIndex, True);
  if Assigned(Groups) then
    ApplyCarillonThemeToForm(Groups, AThemeIndex, True);
  if Assigned(frmRandomDirectory) then
    ApplyCarillonThemeToForm(frmRandomDirectory, AThemeIndex, True);
  if Assigned(frmSilenceSchedule) then
    ApplyCarillonThemeToForm(frmSilenceSchedule, AThemeIndex, True);
end;
procedure TfmDailyPlayList.UpdateColorThemeMenuChecks;
var
  MenuItem: TMenuItem;
  ThemeIndex: Integer;
begin
  if Assigned(miDefault) then
  begin
    miDefault.Visible := FCurrentColorThemeIndex < 0;
    miDefault.IsChecked := FCurrentColorThemeIndex < 0;
  end;
  for ThemeIndex := Low(CarillonColorThemes) to High(CarillonColorThemes) do
  begin
    MenuItem := FindColorThemeMenuItem(CarillonColorThemes[ThemeIndex].MenuItemName);
    if Assigned(MenuItem) then
      MenuItem.IsChecked := ThemeIndex = FCurrentColorThemeIndex;
  end;
end;
procedure TfmDailyPlayList.Colors1Click(Sender: TObject);
var
  ThemeIndex: Integer;
begin
  if Sender = Colors1 then
  begin
    UpdateColorThemeMenuChecks;
    Exit;
  end;
  if not (Sender is TMenuItem) then
    Exit;
  if Sender = miDefault then
  begin
    UpdateColorThemeMenuChecks;
    Exit;
  end;
  ThemeIndex := FindColorThemeIndexByMenuName(TMenuItem(Sender).Name);
  if ThemeIndex < 0 then
  begin
    UpdateColorThemeMenuChecks;
    Exit;
  end;
  ApplyColorThemeByIndex(ThemeIndex, True);
end;
procedure TfmDailyPlayList.CompileSchedule;
begin
  if not Assigned(PlaylistQuery) or not PlaylistQuery.Active then
    Exit;
  if not Assigned(PlaybackSchedule) then
    PlaybackSchedule := TList<TScheduleEntry>.Create;
  try
    BuildPlaybackSchedule(PlaylistQuery, PlaybackSchedule, NextScheduleEntryId,
      function(const AScheduledDateTime: TDateTime): Boolean
      begin
        Result := Assigned(FSilenceManager) and
          FSilenceManager.IsScheduleTimeSilenced(AScheduledDateTime);
      end);
  except
    on E: Exception do
      ShowMessage('There was an error compiling schedule: ' + E.Message);
  end;
end;
function TfmDailyPlayList.BuildScheduleDisplayText(
  const AOnlyRemaining: Boolean): string;
var
  CurrentTime: TDateTime;
  DisplayEntries: TList<TScheduleDisplayEntry>;
  DisplayEntry: TScheduleDisplayEntry;
  i: Integer;
  ScheduleLines: TStringList;
  SilenceWindow: TSilenceWindowInfo;
  SilenceWindows: TList<TSilenceWindowInfo>;
  function HtmlEncode(const S: string): string;
  begin
    Result := StringReplace(S, '&', '&amp;', [rfReplaceAll]);
    Result := StringReplace(Result, '<', '&lt;', [rfReplaceAll]);
    Result := StringReplace(Result, '>', '&gt;', [rfReplaceAll]);
    Result := StringReplace(Result, '"', '&quot;', [rfReplaceAll]);
  end;
  function ScheduleEntryTypeForSong(const ASongPath: string): string;
  begin
    if Pos('STRIKE', UpperCase(ExtractFileName(ASongPath))) > 0 then
      Result := 'Time'
    else
      Result := 'Song';
  end;
begin
  DisplayEntries := TList<TScheduleDisplayEntry>.Create;
  ScheduleLines := TStringList.Create;
  try
    CurrentTime := Now;

    if Assigned(PlaybackSchedule) then
      for i := 0 to PlaybackSchedule.Count - 1 do
        if (not AOnlyRemaining) or
           (CompareTime(CurrentTime, PlaybackSchedule[i].ScheduledTime) <= 0) then
        begin
          DisplayEntry.DisplayTime := TimeOf(PlaybackSchedule[i].ScheduledTime);
          DisplayEntry.SortOrder := 1;
          DisplayEntry.DisplayText := Format(
            '<tr><td>%s</td><td>%s</td><td>%s</td></tr>',
            [FormatDateTime('h:nn:ss AM/PM', PlaybackSchedule[i].ScheduledTime),
             ScheduleEntryTypeForSong(PlaybackSchedule[i].SongPath),
             HtmlEncode(ExtractFileName(PlaybackSchedule[i].SongPath))]);
          DisplayEntries.Add(DisplayEntry);
        end;

    if Assigned(FSilenceManager) then
    begin
      SilenceWindows := TList<TSilenceWindowInfo>.Create;
      try
        FSilenceManager.GetSilenceWindowsForDate(Date, SilenceWindows);
        for SilenceWindow in SilenceWindows do
          if (not AOnlyRemaining) or
             (CompareTime(TimeOf(CurrentTime), SilenceWindow.StartTime) <= 0) then
          begin
            DisplayEntry.DisplayTime := SilenceWindow.StartTime;
            DisplayEntry.SortOrder := 0;
            DisplayEntry.DisplayText := Format(
              '<tr><td>%s</td><td>Silence</td><td>%s until %s</td></tr>',
              [FormatDateTime('h:nn:ss AM/PM', SilenceWindow.StartTime),
               HtmlEncode(SilenceWindow.Purpose),
               FormatDateTime('h:nn:ss AM/PM', SilenceWindow.EndTime)]);
            DisplayEntries.Add(DisplayEntry);
          end;
      finally
        SilenceWindows.Free;
      end;
    end;

    if DisplayEntries.Count = 0 then
    begin
      if AOnlyRemaining then
        Exit('')
      else
        Exit('<p class="empty">No scheduled events are available.</p>');
    end;

    DisplayEntries.Sort(TComparer<TScheduleDisplayEntry>.Construct(
      function(const L, R: TScheduleDisplayEntry): Integer
      begin
        Result := CompareTime(L.DisplayTime, R.DisplayTime);
        if Result = 0 then
          Result := L.SortOrder - R.SortOrder;
      end));

    ScheduleLines.Add('<table class="schedule-table">');
    ScheduleLines.Add('<thead><tr><th>Time</th><th>Type</th><th>Song/Purpose</th></tr></thead>');
    ScheduleLines.Add('<tbody>');
    for DisplayEntry in DisplayEntries do
      ScheduleLines.Add(DisplayEntry.DisplayText);
    ScheduleLines.Add('</tbody></table>');
    Result := ScheduleLines.Text;
  finally
    ScheduleLines.Free;
    DisplayEntries.Free;
  end;
end;
procedure TfmDailyPlayList.ShowScheduleDialog(const ATitle, AText: string);
var
  CloseButton: TButton;
  ContentCard: TRectangle;
  DialogForm: TForm;
  DialogBrowser: TWebBrowser;
  Html: string;
  HeaderRect: TRectangle;
  TitleLabel: TLabel;
  function HtmlColor(const AColor: TAlphaColor): string;
  begin
    Result := Format('#%.2x%.2x%.2x', [
      (AColor shr 16) and $FF,
      (AColor shr 8) and $FF,
      AColor and $FF]);
  end;
begin
  DialogForm := TForm.CreateNew(nil);
  try
    DialogForm.Caption := ATitle;
    DialogForm.BorderStyle := TFmxFormBorderStyle.Sizeable;
    DialogForm.Fill.Kind := TBrushKind.Solid;
    DialogForm.Fill.Color := FormBackgroundColor;
    DialogForm.Width := Max(840, Min(Round(Screen.WorkAreaWidth * 0.82), 1240));
    DialogForm.Height := Max(560, Min(Round(Screen.WorkAreaHeight * 0.82), 860));
    DialogForm.Position := TFormPosition.Designed;

    HeaderRect := TRectangle.Create(DialogForm);
    HeaderRect.Parent := DialogForm;
    HeaderRect.Align := TAlignLayout.Top;
    HeaderRect.Height := 76;
    HeaderRect.Margins.Left := 16;
    HeaderRect.Margins.Top := 16;
    HeaderRect.Margins.Right := 16;
    HeaderRect.Fill.Color := FThemeAccentColor;
    HeaderRect.Stroke.Kind := TBrushKind.None;

    TitleLabel := TLabel.Create(DialogForm);
    TitleLabel.Parent := HeaderRect;
    TitleLabel.Align := TAlignLayout.Client;
    TitleLabel.Margins.Left := 24;
    TitleLabel.Margins.Right := 24;
    TitleLabel.StyledSettings := TitleLabel.StyledSettings -
      [TStyledSetting.FontColor, TStyledSetting.Size];
    TitleLabel.TextSettings.FontColor := claWhite;
    TitleLabel.TextSettings.Font.Size := 26;
    TitleLabel.TextSettings.HorzAlign := TTextAlign.Leading;
    TitleLabel.TextSettings.VertAlign := TTextAlign.Center;
    TitleLabel.Text := ATitle;

    ContentCard := TRectangle.Create(DialogForm);
    ContentCard.Parent := DialogForm;
    ContentCard.Align := TAlignLayout.Client;
    ContentCard.Margins.Left := 16;
    ContentCard.Margins.Top := 12;
    ContentCard.Margins.Right := 16;
    ContentCard.Margins.Bottom := 16;
    ContentCard.Fill.Color := FThemeSurfaceColor;
    ContentCard.Stroke.Color := FThemePanelStrokeColor;
    ContentCard.Stroke.Thickness := 1.5;

    CloseButton := TButton.Create(DialogForm);
    CloseButton.Parent := ContentCard;
    CloseButton.Align := TAlignLayout.Bottom;
    CloseButton.Height := 50;
    CloseButton.Margins.Left := 18;
    CloseButton.Margins.Right := 18;
    CloseButton.Margins.Bottom := 18;
    CloseButton.Text := 'Close';
    CloseButton.ModalResult := mrOk;
    ApplyThemeToButton(CloseButton);

    DialogBrowser := TWebBrowser.Create(DialogForm);
    DialogBrowser.Parent := ContentCard;
    DialogBrowser.Align := TAlignLayout.Client;
    DialogBrowser.Margins.Left := 18;
    DialogBrowser.Margins.Top := 18;
    DialogBrowser.Margins.Right := 18;
    DialogBrowser.Margins.Bottom := 12;
    Html := '<!doctype html><html><head><meta charset="utf-8">' +
      '<style>body{font-family:Segoe UI,Arial,sans-serif;margin:0;padding:0;color:' +
      HtmlColor(FThemeCardTextColor) + ';background:' + HtmlColor(FThemeSurfaceColor) + ';}' +
      '.schedule-table{border-collapse:collapse;width:100%;font-size:15px;}' +
      'th{background:' + HtmlColor(FThemeGridHeaderColor) + ';color:' +
      HtmlColor(FThemeGridHeaderTextColor) + ';text-align:left;padding:10px 12px;border:1px solid ' +
      HtmlColor(FThemePanelStrokeColor) + ';}' +
      'td{padding:9px 12px;border:1px solid ' + HtmlColor(FThemeInputStrokeColor) + ';vertical-align:top;}' +
      'tbody tr:nth-child(odd){background:' + HtmlColor(FThemeGridEvenColor) + ';}' +
      'tbody tr:nth-child(even){background:' + HtmlColor(FThemeGridOddColor) + ';}' +
      '.empty{padding:18px;}</style>' +
      '</head><body>' + AText + '</body></html>';
    DialogBrowser.LoadFromStrings(Html, '');

    CenterForm(DialogForm);
    DialogForm.ShowModal;
  finally
    DialogForm.Free;
  end;
end;
procedure TfmDailyPlayList.ShowSchedule;
var
  ScheduleText: string;
begin
  ScheduleText := BuildScheduleDisplayText(False);
  ShowScheduleDialog('Current Schedule', ScheduleText);
end;
procedure TfmDailyPlayList.ShowSchedule2Click(Sender: TObject);
begin
  ShowRemainingPlaylist;
end;
procedure TfmDailyPlayList.ShowSchedule1Click(Sender: TObject);
begin
  CompileSchedule;
  ShowSchedule;
end;
procedure TfmDailyPlayList.ShowRemainingPlaylist;
var
  ScheduleText: string;
begin
  ScheduleText := BuildScheduleDisplayText(True);
  if ScheduleText <> '' then
    ShowScheduleDialog('Remaining Schedule For Today', ScheduleText)
  else
    ShowMessage('No more events scheduled for today.');
  //UpdateStatusBar('');        //********** blanks bar on schedule show- not good!
end;
procedure TfmDailyPlayList.mManageDirectories1Click(Sender: TObject);
begin
  DisableSchedule;
  try
    if not Assigned(frmRandomDirectory) then
      Application.CreateForm(TfrmRandomDirectory, frmRandomDirectory);
    CenterForm(frmRandomDirectory);
    frmRandomDirectory.ShowModal;
  finally
    GeneratedSetToggleState_chkEnableSchedule(True);
    chkEnableScheduleClick(Self);
  end;
end;
procedure TfmDailyPlayList.miEmailSettingsClick(Sender: TObject);
begin
  DisableSchedule;
  try
    if not Assigned(frmEmailSettings) then
      Application.CreateForm(TfrmEmailSettings, frmEmailSettings);
    CenterForm(frmEmailSettings);
    frmEmailSettings.ShowModal;
  finally
    GeneratedSetToggleState_chkEnableSchedule(True);
    chkEnableScheduleClick(Self);
  end;
end;
procedure TfmDailyPlayList.miSilenceScheduleClick(Sender: TObject);
begin
  DisableSchedule;
  try
    if not Assigned(frmSilenceSchedule) then
      Application.CreateForm(TfrmSilenceSchedule, frmSilenceSchedule);
    CenterForm(frmSilenceSchedule);
    frmSilenceSchedule.ShowModal;
  finally
    RefreshSilenceRulesAndSchedule;
    GeneratedSetToggleState_chkEnableSchedule(True);
    chkEnableScheduleClick(Self);
  end;
end;
procedure TfmDailyPlayList.miScheduleRestartClick(Sender: TObject);
begin
  // Optional overlay (you can remove if not needed)
  PrepareOverlay;
  try
    { Run the shutdown/restart scheduler in uScheduleShutdownRestart.pas
      This down time scheduler is used for things like scheduled power
      outages and other times when the bell system must be down.  It is
      designed to allow entry of a date and time to take the system down
      and a date and time to restart it.  It should be noted that this
      will only work on systems like laptops, which are battery driven
      and which will last 12-24 hours, or a system with a UPS. }
    // ScheduleShutdownAndRestart;
  finally
    FreeAndNil(frmOverlay);
  end;
end;
procedure TfmDailyPlayList.ScheduleTimerTimer(Sender: TObject);
var
  CurrentTime: TDateTime;
  DueEntry: TScheduleEntry;
  i: Integer;
begin
  if FGeneratedShuttingDown then
    Exit;
  if not IsPlaybackInProgress and (PlaybackSchedule.Count > 0) then
  begin
    CurrentTime := Now;
    i := 0;
    while i < PlaybackSchedule.Count do
    begin
      if (CompareTime(CurrentTime, PlaybackSchedule[i].ScheduledTime) >= 0) then
      begin
        DueEntry := PlaybackSchedule[i];
        PlaybackSchedule.Delete(i);
        if Assigned(FSilenceManager) and FSilenceManager.IsTimeSilenced(CurrentTime) then
        begin
          AddToLog('Skipped scheduled song during silence: ' + DueEntry.SongPath);
          Break;
        end;
        PlayScheduledEntry(DueEntry);
        Break; // Exit the loop after finding song to play
      end
      else
        Inc(i);
    end;
  end;
end;
// Event handler to reset the M3MediaPlayer when the song finishes playing
procedure TfmDailyPlayList.MP3MediaPlayerNotify(Sender: TObject);
var
  RetryCount: Integer;
begin
  if FGeneratedShuttingDown or Application.Terminated then
    Exit;

  RetryCount := 0;
  // Wait up to 3 seconds for the player to fully stop
  while (MP3MediaPlayer.State <> TMediaState.Stopped) and (RetryCount < 3) do
  begin
    if FGeneratedShuttingDown or Application.Terminated then
      Exit;
    Sleep(100); // Allow the player to finish stopping
    Inc(RetryCount);
  end;
  // Reset Player
  if MP3MediaPlayer.State = TMediaState.Stopped then
  begin
    MP3MediaPlayer.Clear;
    IsPlaybackInProgress := False;
  end;
end;
procedure TfmDailyPlayList.OpenDialog1Show(Sender: TObject);
begin
  BeginPlaylistEditSession;
end;
// Timer event to rebuild the schedule at 12:05 AM if enabled
procedure TfmDailyPlayList.tmRebuildSchedTimer(Sender: TObject);
var
  CurrentTime: TDateTime;
begin
  if FGeneratedShuttingDown then
    Exit;
  CurrentTime := Now;
  // Rebuild once per new day after the 00:05 maintenance window opens.
  if (FLastScheduleRebuildDate <> Date) and
     (FormatDateTime('hh:nn', CurrentTime) >= '00:05') and
     chkEnableSchedule.IsChecked then
  begin
    FLastScheduleRebuildDate := Date;
    AddToLog('Total Songs played yesterday: ' + FPlayedSongCountToday.ToString);
    FPlayedSongCountToday := 0;
    UpdateStatusBar('');
    AddToLog('Daily Song Count reset to zero');
    Randomize;
    AddToLog('Randomize seed reset');
    UpdatePlaylistFromSeasonalGroups;
    CompileSchedule;
    AddToLog(FormatDateTime('"Schedule for "mm"/"dd"/"yyyy" compiled"', Date));
  end;
end;
procedure TfmDailyPlayList.UpdatePlaylistFromSeasonalGroups;
var
  season: string;
  playDateFromNull, playDateToNull, playTimeNull: Boolean;
  StartedTransaction: Boolean;
  UpdateConnection: TFDCustomConnection;
begin
  StartedTransaction := False;
  UpdateConnection := nil;
  // Disable UI controls to prevent unnecessary updates during the process
  PlaylistQuery.DisableControls;
  try
    try
      ADOQuery1.Close;
      ADOQuery2.Close;
    UpdateConnection := PlaylistQuery.Connection;
    ADOQuery1.Connection := UpdateConnection;
    ADOQuery2.Connection := UpdateConnection;
    // Retrieve all seasonal groups except 'Daily List'
    ADOQuery1.SQL.Text :=
      'SELECT * FROM SeasonalGroups WHERE SeasonalGroup <> ''Daily List''';
    ADOQuery1.Open;
    if Assigned(UpdateConnection) and not UpdateConnection.InTransaction then
    begin
      UpdateConnection.StartTransaction;
      StartedTransaction := True;
    end;
    // Loop through all the records in SeasonalGroups
    while not ADOQuery1.Eof do
    begin
      // Read the season and check if play date range and play time are NULL
      season := ADOQuery1.FieldByName('SeasonalGroup').AsString;
      playDateFromNull := ADOQuery1.FieldByName('play_date_from').IsNull;
      playDateToNull := ADOQuery1.FieldByName('play_date_to').IsNull;
      playTimeNull := ADOQuery1.FieldByName('play_time').IsNull;
      ADOQuery2.Close;
      ADOQuery2.SQL.Text :=
        'UPDATE Playlist SET ' +
        'play_date_from = :play_date_from, ' +
        'play_date_to = :play_date_to, ' +
        'scheduled_time1 = :scheduled_time1, ' +
        'scheduled_time2 = NULL, ' +
        'scheduled_time3 = NULL, ' +
        'scheduled_time4 = NULL, ' +
        'scheduled_time5 = NULL, ' +
        'scheduled_time6 = NULL, ' +
        'scheduled_time7 = NULL, ' +
        'scheduled_time8 = NULL, ' +
        'scheduled_time9 = NULL, ' +
        'scheduled_time10 = NULL, ' +
        'scheduled_time11 = NULL, ' +
        'scheduled_time12 = NULL ' +
        'WHERE TRIM(season) = :season COLLATE NOCASE';
      if playDateFromNull then
        ADOQuery2.ParamByName('play_date_from').Clear
      else
        ADOQuery2.ParamByName('play_date_from').AsString :=
          FormatDateTime('yyyy-mm-dd',
            ADOQuery1.FieldByName('play_date_from').AsDateTime);
      if playDateToNull then
        ADOQuery2.ParamByName('play_date_to').Clear
      else
        ADOQuery2.ParamByName('play_date_to').AsString :=
          FormatDateTime('yyyy-mm-dd',
            ADOQuery1.FieldByName('play_date_to').AsDateTime);
      if playTimeNull then
        ADOQuery2.ParamByName('scheduled_time1').Clear
      else
        ADOQuery2.ParamByName('scheduled_time1').AsString :=
          FormatDateTime('HH:NN:SS',
            Frac(ADOQuery1.FieldByName('play_time').AsDateTime));
      ADOQuery2.ParamByName('season').AsString := Trim(season);
      ADOQuery2.ExecSQL;
      // Move to the next record in the SeasonalGroups table
      ADOQuery1.Next;
    end;
    if StartedTransaction then
    begin
      UpdateConnection.Commit;
      StartedTransaction := False;
    end;
  except
    on E: Exception do
    begin
      if StartedTransaction and Assigned(UpdateConnection) and
        UpdateConnection.InTransaction then
        UpdateConnection.Rollback;
      ShowMessage('An error occurred during the playlist table update: ' + E.Message);
      Exit;
    end;
  end;
  finally
    // Close the dataset and re-enable UI controls
    ADOQuery1.close;
    ADOQuery2.close;
    PlaylistQuery.EnableControls;
    // Refresh the DBGrid by closing and reopening the query that populates the grid
    FSkipNextPlaylistGridSelectionSync := True;
    PlaylistQuery.close;
    PlaylistQuery.Open;
  GeneratedSyncManualFieldBindingsForDataSet(PlaylistQuery);
  end;
end;
procedure TfmDailyPlayList.ToggleFieldsEnabledState(Enabled: Boolean);
begin
  edPLPlayDateTo.Enabled := Enabled;
  edPLPlayDateFrom.Enabled := Enabled;
  edPLTimeToPlay1.Enabled := Enabled;
  edPLTimeToPlay2.Enabled := Enabled;
  edPLTimeToPlay3.Enabled := Enabled;
  edPLTimeToPlay4.Enabled := Enabled;
  edPLTimeToPlay5.Enabled := Enabled;
  edPLTimeToPlay6.Enabled := Enabled;
  edPLTimeToPlay7.Enabled := Enabled;
  edPLTimeToPlay8.Enabled := Enabled;
  edPLTimeToPlay9.Enabled := Enabled;
  edPLTimeToPlay10.Enabled := Enabled;
  edPLTimeToPlay11.Enabled := Enabled;
  edPLTimeToPlay12.Enabled := Enabled;
  chkPlayMonday.Enabled := Enabled;
  chkPlayTuesday.Enabled := Enabled;
  chkPlayWednesday.Enabled := Enabled;
  chkPlayThursday.Enabled := Enabled;
  chkPlayFriday.Enabled := Enabled;
  chkPlaySaturday.Enabled := Enabled;
  chkPlaySunday.Enabled := Enabled;
end;
procedure TfmDailyPlayList.UpdateFieldStateBasedOnSeasonalGroup;
begin
  ToggleFieldsEnabledState(True);
end;
procedure TfmDailyPlayList.UpdateFieldStatesForAllRecords;
var
  SavedAfterScroll: TDataSetNotifyEvent;
begin
  if not Assigned(PlaylistQuery) or not PlaylistQuery.Active then
    Exit;
  SavedAfterScroll := PlaylistQuery.AfterScroll;
  PlaylistQuery.AfterScroll := nil;
  PlaylistQuery.DisableControls;
  try
    PlaylistQuery.First;
    while not PlaylistQuery.Eof do
    begin
      UpdateFieldStateBasedOnSeasonalGroup;
      PlaylistQuery.Next;
    end;
    if not PlaylistQuery.IsEmpty then
      PlaylistQuery.First;
  finally
    PlaylistQuery.EnableControls;
    PlaylistQuery.AfterScroll := SavedAfterScroll;
  end;
end;
procedure TfmDailyPlayList.PlaylistQueryAfterDelete(DataSet: TDataSet);
begin
  RefreshGrid;
  UpdateStatusBar('');
  EndPlaylistEditSession;
end;
procedure TfmDailyPlayList.PlaylistQueryAfterScroll(DataSet: TDataSet);
begin
  UpdateFieldStateBasedOnSeasonalGroup;
  if FSkipNextPlaylistGridSelectionSync then
  begin
    FSkipNextPlaylistGridSelectionSync := False;
    Exit;
  end;
  SyncPlaylistGridSelectionFromDataSet(True);
end;
procedure TfmDailyPlayList.DBComboBox1Change(Sender: TObject);
begin
  // Do nothing here as we will handle the assignment using the button click event
end;
// Clock menu item click event
procedure TfmDailyPlayList.Clock1Click(Sender: TObject);
begin
  if not Assigned(fmClock) then
    Application.CreateForm(TfmClock, fmClock);
  CenterForm(fmClock);
  fmClock.ShowModal;
end;
// Return to Playlist button click event - deprecated
procedure TfmDailyPlayList.ReturnToPlaylistClick(Sender: TObject);
begin
  if Assigned(fmClock) then
    fmClock.close;
end;
procedure TfmDailyPlayList.DBGrid1ColEnter(Sender: TObject);
begin
  // No special handling is required when a grid column receives focus.
end;
procedure TfmDailyPlayList.DBGrid1DrawColumnHeader(Sender: TObject;
  const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF);
var
  TextBounds: TRectF;
begin
  Canvas.Font.Size := DBGrid1.TextSettings.Font.Size;
  Canvas.Fill.Kind := TBrushKind.Solid;
  Canvas.Fill.Color := FThemeGridHeaderColor;
  Canvas.FillRect(Bounds, 0, 0, [], 1);
  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.Stroke.Color := FThemePanelStrokeColor;
  Canvas.DrawRect(Bounds, 0, 0, [], 1);
  Canvas.Fill.Color := FThemeGridHeaderTextColor;
  TextBounds := Bounds;
  TextBounds.Left := TextBounds.Left + 8;
  TextBounds.Right := TextBounds.Right - 6;
  Canvas.FillText(TextBounds, Column.Header, False, 1, [], TTextAlign.Leading,
    TTextAlign.Center);
end;
procedure TfmDailyPlayList.DBGrid1DrawColumnCell(Sender: TObject;
  const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF;
  const Row: Integer; const Value: TValue; const State: TGridDrawStates);
begin
  Canvas.Font.Size := DBGrid1.TextSettings.Font.Size;
  Canvas.Fill.Kind := TBrushKind.Solid;
  if (FPlaylistGridRows <> nil) and (Row >= 0) and (Row < FPlaylistGridRows.Count) and
     (FPlaylistGridRows[Row].RowKind = pgrGroupHeader) then
  begin
    if (TGridDrawState.Selected in State) or (TGridDrawState.RowSelected in State) then
      Canvas.Fill.Color := FThemeGridGroupSelectedColor
    else
      Canvas.Fill.Color := FThemeGridGroupColor;
  end
  else if (TGridDrawState.Selected in State) or (TGridDrawState.RowSelected in State) then
  begin
    Canvas.Fill.Color := FThemeGridSelectedColor;
  end
  else if (FPlaylistGridRows <> nil) and (Row >= 0) and (Row < FPlaylistGridRows.Count) and
          (FPlaylistGridRows[Row].VisibleSongIndex >= 0) and
          Odd(FPlaylistGridRows[Row].VisibleSongIndex) then
  begin
    Canvas.Fill.Color := FThemeGridOddColor;
  end
  else
  begin
    Canvas.Fill.Color := FThemeGridEvenColor;
  end;
  Canvas.FillRect(Bounds, 0, 0, [], 1);
end;
procedure RetrieveRandSongsDirectory(var RandSongsDir: string);
var
  Conn: TFDConnection;
  OwnConn: Boolean;
begin
  RandSongsDir := '';
  OwnConn := False;
  if Assigned(fmDailyPlayList) and Assigned(fmDailyPlayList.PlaylistConnection) and
    fmDailyPlayList.PlaylistConnection.Connected then
    Conn := fmDailyPlayList.PlaylistConnection
  else
  begin
    Conn := TFDConnection.Create(nil);
    OwnConn := True;
    ConfigurePortableSQLiteConnection(Conn);
    Conn.Connected := True;
  end;
  try
    RandSongsDir := ResolveRandomMusicDirectory(Conn);
  finally
    if OwnConn then
      Conn.Free;
  end;
end;
procedure TfmDailyPlayList.DisableSchedule;
begin
  // Disable Schedule
  GeneratedSetToggleState_chkEnableSchedule(False);
  chkEnableScheduleClick(Self);
end;
procedure TfmDailyPlayList.AddToLog(const Msg: string);
begin
  try
    AddCarillonLogMessage(Msg);
  except
    on E: Exception do
      ShowMessage('Error logging message: ' + E.Message);
  end;
end;
procedure TfmDailyPlayList.SendToEmail(const Msg: string);
var
  Q: TFDQuery;
  Recipients: string;
begin
  if FGeneratedShuttingDown or Application.Terminated then
    Exit;
  if not Assigned(frmEmailSettings) or not Assigned(frmEmailSettings.FDConnection1) then
    Exit;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := frmEmailSettings.FDConnection1;
    Q.SQL.Text := 'SELECT * FROM pl_settings';
    Q.Open;
    if Q.FieldByName('email_enabled').AsInteger = 0 then
      Exit;
    Recipients := Q.FieldByName('email_recipients').AsString;
  finally
    Q.Free;
  end;
  frmEmailSettings.SendEmailIfEnabled(Msg, Recipients);
end;
function TfmDailyPlayList.ConvertToRelativePath(const FullPath: string): string;
var
  basepath: string;
begin
  basepath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
  Result := FullPath;
  if not IsPathRooted(Result) then
    Result := basepath + Result;
  if SameText(Copy(Result, 1, Length(basepath)), basepath) then
    Result := '.\' + Copy(Result, Length(basepath) + 1, MaxInt);
end;
procedure TfmDailyPlayList.SetupStatusBar;
begin
  ApplyStatusBarTheme;
end;
procedure TfmDailyPlayList.UpdateStatusBar(const LastSongFullPath: string);
var
  LastSongName: string;
  PlaylistCount: Integer;
begin
  if not Assigned(StatusBar1) then
    Exit;
  // Panel 0: Last Song played (filename only) + time
  LastSongName := '';
  if LastSongFullPath <> '' then
    LastSongName := Format('%s at %s', [ExtractFileName(LastSongFullPath),
      FormatDateTime('h:nn am/pm', Now)]);
  SetStatusBarPanelText(StatusBar1, 0, ' Last Song played: ' + LastSongName);
  // Panel 1: Songs in Playlist
  PlaylistCount := 0;
  if Assigned(PlaylistQuery) and PlaylistQuery.Active then
    PlaylistCount := PlaylistQuery.RecordCount;
  SetStatusBarPanelText(StatusBar1, 1, 'Songs in Playlist:  ' + PlaylistCount.ToString);
  // Panel 2: Songs Played Today
  SetStatusBarPanelText(StatusBar1, 2, 'Songs Played Today:  ' + FPlayedSongCountToday.ToString);
  // Panel 3: Version Number, and it is manually kept
  ApplyStatusBarTheme;
end;
procedure TfmDailyPlayList.DBGrid1_GeneratedMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
begin
  if (FPlaylistGridRows <> nil) and (FPlaylistGridRows.Count > 0) then
  begin
    Handled := False;
    Exit;
  end;
  if Assigned(PlaylistQuery) and PlaylistQuery.Active and (not PlaylistQuery.IsEmpty) then
  begin
    if WheelDelta > 0 then
    begin
      if not PlaylistQuery.BOF then
        PlaylistQuery.Prior;
    end
    else if WheelDelta < 0 then
    begin
      if not PlaylistQuery.EOF then
        PlaylistQuery.Next;
      if PlaylistQuery.EOF and (not PlaylistQuery.IsEmpty) then
        PlaylistQuery.Last;
    end;
    if Assigned(DBGrid1) then
    begin
      if PlaylistQuery.RecNo > 0 then
        DBGrid1.Selected := PlaylistQuery.RecNo - 1
      else
        DBGrid1.Selected := 0;
    end;
    Handled := True;
  end;
end;
procedure TfmDailyPlayList.GeneratedSetToggleState_chkEnableSchedule(AValue: Boolean);
begin
  if FGeneratedShuttingDown then
    Exit;
  if not Assigned(chkEnableSchedule) then
    Exit;
  Inc(FGeneratedToggleSuppress_chkEnableSchedule);
  try
    chkEnableSchedule.IsChecked := AValue;
  finally
    Dec(FGeneratedToggleSuppress_chkEnableSchedule);
  end;
end;

procedure TfmDailyPlayList.chkEnableSchedule_GeneratedUserChange(Sender: TObject);
begin
  if FGeneratedShuttingDown then
    Exit;
  if FGeneratedToggleSuppress_chkEnableSchedule = 0 then
    if Assigned(FGeneratedToggleOriginalClick_chkEnableSchedule) then
      FGeneratedToggleOriginalClick_chkEnableSchedule(Sender);
  if Assigned(FGeneratedToggleOriginalChange_chkEnableSchedule) then
    FGeneratedToggleOriginalChange_chkEnableSchedule(Sender);
end;
procedure TfmDailyPlayList.GeneratedRegisterMediaNotify_MP3MediaPlayer(AHandler: TNotifyEvent);
begin
  if FGeneratedShuttingDown then
    Exit;
  if FGeneratedMediaNotifyTimer_MP3MediaPlayer = nil then
  begin
    FGeneratedMediaNotifyTimer_MP3MediaPlayer := TTimer.Create(Self);
    FGeneratedMediaNotifyTimer_MP3MediaPlayer.Enabled := False;
    FGeneratedMediaNotifyTimer_MP3MediaPlayer.Interval := 200;
    FGeneratedMediaNotifyTimer_MP3MediaPlayer.OnTimer := GeneratedMediaNotifyTimer_MP3MediaPlayer;
  end;
  FGeneratedMediaNotifyHandler_MP3MediaPlayer := AHandler;
end;
procedure TfmDailyPlayList.GeneratedSetMediaNotifyEnabled_MP3MediaPlayer(AEnabled: Boolean);
begin
  if FGeneratedShuttingDown then
    Exit;
  if FGeneratedMediaNotifyTimer_MP3MediaPlayer = nil then
  begin
    FGeneratedMediaNotifyTimer_MP3MediaPlayer := TTimer.Create(Self);
    FGeneratedMediaNotifyTimer_MP3MediaPlayer.Enabled := False;
    FGeneratedMediaNotifyTimer_MP3MediaPlayer.Interval := 200;
    FGeneratedMediaNotifyTimer_MP3MediaPlayer.OnTimer := GeneratedMediaNotifyTimer_MP3MediaPlayer;
  end;
  if not AEnabled then
    FGeneratedMediaNotifyWasPlaying_MP3MediaPlayer := False;
  FGeneratedMediaNotifyTimer_MP3MediaPlayer.Enabled := AEnabled;
end;
procedure TfmDailyPlayList.GeneratedMediaNotifyTimer_MP3MediaPlayer(Sender: TObject);
begin
  if FGeneratedShuttingDown then
    Exit;
  if not Assigned(MP3MediaPlayer) then
    Exit;
  if MP3MediaPlayer.State = TMediaState.Playing then
    FGeneratedMediaNotifyWasPlaying_MP3MediaPlayer := True
  else if FGeneratedMediaNotifyWasPlaying_MP3MediaPlayer and (MP3MediaPlayer.State = TMediaState.Stopped) then
  begin
    FGeneratedMediaNotifyWasPlaying_MP3MediaPlayer := False;
    if Assigned(FGeneratedMediaNotifyHandler_MP3MediaPlayer) then
      FGeneratedMediaNotifyHandler_MP3MediaPlayer(MP3MediaPlayer);
  end
  else if MP3MediaPlayer.State = TMediaState.Unavailable then
    FGeneratedMediaNotifyWasPlaying_MP3MediaPlayer := False;
end;
procedure TfmDailyPlayList.DBComboBox1_SyncFromField;
var
  LValue: string;
  LIndex: Integer;
begin
  if FUpdatingSeasonGroupComboBox > 0 then
    Exit;
  if not Assigned(DBComboBox1) then
    Exit;
  Inc(FUpdatingSeasonGroupComboBox);
  try
    if Assigned(PlaylistQuery) and PlaylistQuery.Active and
       (PlaylistQuery.FindField('season') <> nil) then
      LValue := PlaylistQuery.FieldByName('season').AsString
    else
      LValue := '';
    if LValue = '' then
    begin
      DBComboBox1.ItemIndex := -1;
      Exit;
    end;
    LIndex := DBComboBox1.Items.IndexOf(LValue);
    if LIndex = -1 then
    begin
      DBComboBox1.Items.Add(LValue);
      LIndex := DBComboBox1.Items.IndexOf(LValue);
    end;
    DBComboBox1.ItemIndex := LIndex;
  finally
    Dec(FUpdatingSeasonGroupComboBox);
  end;
end;
procedure TfmDailyPlayList.DBComboBox1_GeneratedOnChange(Sender: TObject);
var
  LValue: string;
begin
  if FUpdatingSeasonGroupComboBox > 0 then
    Exit;
  if Assigned(PlaylistQuery) and PlaylistQuery.Active and
     (PlaylistQuery.FindField('season') <> nil) then
  begin
    if DBComboBox1.ItemIndex >= 0 then
      LValue := Trim(DBComboBox1.Items[DBComboBox1.ItemIndex])
    else
      LValue := Trim(DBComboBox1.Text);
    if PlaylistQuery.FieldByName('season').AsString <> LValue then
    begin
      if not (PlaylistQuery.State in dsEditModes) then
      begin
        BeginPlaylistEditSession;
        PlaylistQuery.Edit;
      end;
      PlaylistQuery.FieldByName('season').AsString := LValue;
    end;
  end;
  if Assigned(FOriginal_DBComboBox1_OnChange) then
    FOriginal_DBComboBox1_OnChange(Sender);
end;
procedure TfmDailyPlayList.DBComboBox1_GeneratedOnPopup(Sender: TObject);
begin
  Inc(FUpdatingSeasonGroupComboBox);
  try
    if Assigned(FOriginal_DBComboBox1_OnPopup) then
      FOriginal_DBComboBox1_OnPopup(Sender);
  finally
    Dec(FUpdatingSeasonGroupComboBox);
  end;
  DBComboBox1_SyncFromField;
end;
procedure TfmDailyPlayList.DBComboBox1_GeneratedOnClosePopup(Sender: TObject);
begin
  DBComboBox1_GeneratedOnChange(Sender);
  if Assigned(FOriginal_DBComboBox1_OnClosePopup) then
    FOriginal_DBComboBox1_OnClosePopup(Sender);
end;
procedure TfmDailyPlayList.plDataSource_GeneratedDataChange(Sender: TObject; Field: TField);
begin
  if (Sender is TDataSource) and Assigned(TDataSource(Sender).DataSet) and
     (TDataSource(Sender).DataSet.State in dsEditModes) then
    Exit;
  DBComboBox1_SyncFromField;
  GeneratedSyncManualFieldBindingsForDataSet(PlaylistQuery);
  ApplyThemeToScheduleInputs;
end;
procedure TfmDailyPlayList.DBNavigator1_GeneratedBeforeAction(Sender: TObject; Button: TBindNavigateBtn);
begin
  case Button of
    nbPost:
    begin
      GeneratedCommitManualFieldBindingsForDataSet(PlaylistQuery);
    end;
    nbCancel:
    begin
      if Assigned(PlaylistQuery) and (PlaylistQuery.State in dsEditModes) then
        PlaylistQuery.Cancel;
      GeneratedSyncManualFieldBindingsForDataSet(PlaylistQuery);
      EndPlaylistEditSession;
      Abort;
    end;
  end;
  if Assigned(FOriginal_DBNavigator1_BeforeAction) then
    FOriginal_DBNavigator1_BeforeAction(Sender, Button);
end;
procedure TfmDailyPlayList.DBGrid1CellDblClick(const Column: TColumn; const Row: Integer);
begin
  if not TrySyncDataSetFromPlaylistGridRow(Row) then
    Exit;
  btnPlaySongClick(Self);
end;
procedure TfmDailyPlayList.PlaylistQuery_GeneratedAfterOpen(DataSet: TDataSet);
begin
  if Assigned(FOriginal_PlaylistQuery_AfterOpen) then
    FOriginal_PlaylistQuery_AfterOpen(DataSet);
  RebuildPlaylistGrid;
  GeneratedSyncManualFieldBindingsForDataSet(DataSet);
  SyncPlaylistGridSelectionFromDataSet(False);
  if Assigned(DBGrid1) then
    DBGrid1.Repaint;
end;
procedure TfmDailyPlayList.PlaylistQuery_GeneratedCalcFields(DataSet: TDataSet);
begin
  if Assigned(FOriginal_PlaylistQuery_OnCalcFields) then
    FOriginal_PlaylistQuery_OnCalcFields(DataSet);
  if (DataSet.FindField('season_display') <> nil) and
     (DataSet.FindField('season') <> nil) then
    DataSet.FieldByName('season_display').AsString :=
      DataSet.FieldByName('season').AsString;
  if (DataSet.FindField('song_name_display') <> nil) and
     (DataSet.FindField('song_name') <> nil) then
    DataSet.FieldByName('song_name_display').AsString :=
      DataSet.FieldByName('song_name').AsString;
  if (DataSet.FindField('song_duration_display') <> nil) and
     (DataSet.FindField('song_duration') <> nil) then
    DataSet.FieldByName('song_duration_display').AsString :=
      DataSet.FieldByName('song_duration').AsString;
end;
end.

