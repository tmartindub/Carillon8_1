unit ScheduleManager;

// Version: 8.1
interface

uses
  Data.DB, System.Generics.Collections, System.SysUtils;

type
  TScheduleEntry = record
    NumberOfTimesToPlay: Integer;
    PlaylistRecordNo: Integer;
    SongPath: string;
    ScheduledTime: TTime;
    ScheduleEntryId: Integer;
  end;

  TScheduleDisplayEntry = record
    DisplayText: string;
    DisplayTime: TTime;
    SortOrder: Integer;
  end;

  TScheduleSilencePredicate = reference to function(
    const AScheduledDateTime: TDateTime): Boolean;

procedure BuildPlaybackSchedule(const APlaylistDataSet: TDataSet;
  const ASchedule: TList<TScheduleEntry>; var ANextScheduleEntryId: Integer;
  const ASilencePredicate: TScheduleSilencePredicate);

implementation

uses
  DateUtils, System.Generics.Defaults, System.IOUtils;

procedure BuildPlaybackSchedule(const APlaylistDataSet: TDataSet;
  const ASchedule: TList<TScheduleEntry>; var ANextScheduleEntryId: Integer;
  const ASilencePredicate: TScheduleSilencePredicate);
var
  CurrentDate: TDateTime;
  CurrentTime: TDateTime;
  DayOfWeekChecked: Boolean;
  I: Integer;
  SavedAfterScroll: TDataSetNotifyEvent;
  SavedBookmark: TBookmark;
  ScheduleEntry: TScheduleEntry;
  TimeField: string;

  function ScheduleAlreadyContains(const AEntry: TScheduleEntry): Boolean;
  var
    Existing: TScheduleEntry;
  begin
    Result := False;
    for Existing in ASchedule do
      if (Existing.PlaylistRecordNo = AEntry.PlaylistRecordNo) and
        SameText(Existing.SongPath, AEntry.SongPath) and
        (Abs(TimeOf(Existing.ScheduledTime) - TimeOf(AEntry.ScheduledTime)) <
          OneMillisecond) then
        Exit(True);
  end;
begin
  if (APlaylistDataSet = nil) or (not APlaylistDataSet.Active) or
    (ASchedule = nil) then
    Exit;
  ASchedule.Clear;
  CurrentDate := Date;
  CurrentTime := Time;
  SavedBookmark := nil;
  SavedAfterScroll := APlaylistDataSet.AfterScroll;
  APlaylistDataSet.AfterScroll := nil;
  APlaylistDataSet.DisableControls;
  try
    SavedBookmark := APlaylistDataSet.GetBookmark;
    APlaylistDataSet.First;
    while not APlaylistDataSet.Eof do
    begin
      if (not APlaylistDataSet.FieldByName('play_date_from').IsNull) and
        (not APlaylistDataSet.FieldByName('play_date_to').IsNull) and
        (CurrentDate >= APlaylistDataSet.FieldByName('play_date_from').AsDateTime) and
        (CurrentDate <= APlaylistDataSet.FieldByName('play_date_to').AsDateTime +
        EncodeTime(23, 59, 59, 999)) then
      begin
        DayOfWeekChecked := False;
        case DayOfTheWeek(CurrentDate) of
          1: DayOfWeekChecked := APlaylistDataSet.FieldByName('play_monday').AsInteger = 1;
          2: DayOfWeekChecked := APlaylistDataSet.FieldByName('play_tuesday').AsInteger = 1;
          3: DayOfWeekChecked := APlaylistDataSet.FieldByName('play_wednesday').AsInteger = 1;
          4: DayOfWeekChecked := APlaylistDataSet.FieldByName('play_thursday').AsInteger = 1;
          5: DayOfWeekChecked := APlaylistDataSet.FieldByName('play_friday').AsInteger = 1;
          6: DayOfWeekChecked := APlaylistDataSet.FieldByName('play_saturday').AsInteger = 1;
          7: DayOfWeekChecked := APlaylistDataSet.FieldByName('play_sunday').AsInteger = 1;
        end;
        if DayOfWeekChecked then
          for I := 1 to 12 do
          begin
            TimeField := 'scheduled_time' + IntToStr(I);
            if not APlaylistDataSet.FieldByName(TimeField).IsNull then
              if CompareTime(APlaylistDataSet.FieldByName(TimeField).AsDateTime,
                CurrentTime) >= 0 then
              begin
                ScheduleEntry.NumberOfTimesToPlay :=
                  APlaylistDataSet.FieldByName('num_times_to_play').AsInteger;
                if ScheduleEntry.NumberOfTimesToPlay < 1 then
                  ScheduleEntry.NumberOfTimesToPlay := 1
                else if ScheduleEntry.NumberOfTimesToPlay > 5 then
                  ScheduleEntry.NumberOfTimesToPlay := 5;
                ScheduleEntry.PlaylistRecordNo := APlaylistDataSet.RecNo;
                ScheduleEntry.ScheduledTime :=
                  APlaylistDataSet.FieldByName(TimeField).AsDateTime;
                ScheduleEntry.ScheduleEntryId := ANextScheduleEntryId;
                Inc(ANextScheduleEntryId);
                ScheduleEntry.SongPath :=
                  APlaylistDataSet.FieldByName('song_name').AsString;
                if not TPath.IsPathRooted(ScheduleEntry.SongPath) then
                  ScheduleEntry.SongPath := IncludeTrailingPathDelimiter(
                    ExtractFilePath(ParamStr(0))) + ScheduleEntry.SongPath;
                if ((not Assigned(ASilencePredicate)) or
                  (not ASilencePredicate(CurrentDate +
                  TimeOf(ScheduleEntry.ScheduledTime)))) and
                  (not ScheduleAlreadyContains(ScheduleEntry)) then
                  ASchedule.Add(ScheduleEntry);
              end;
          end;
      end;
      APlaylistDataSet.Next;
    end;
    ASchedule.Sort(TComparer<TScheduleEntry>.Construct(
      function(const L, R: TScheduleEntry): Integer
      begin
        Result := CompareDateTime(L.ScheduledTime, R.ScheduledTime);
        if Result = 0 then
        begin
          if L.ScheduleEntryId < R.ScheduleEntryId then
            Result := -1
          else if L.ScheduleEntryId > R.ScheduleEntryId then
            Result := 1
          else
            Result := 0;
        end;
      end));
  finally
    if (SavedBookmark <> nil) and APlaylistDataSet.BookmarkValid(SavedBookmark) then
      APlaylistDataSet.GotoBookmark(SavedBookmark)
    else if not APlaylistDataSet.IsEmpty then
      APlaylistDataSet.First;
    APlaylistDataSet.EnableControls;
    APlaylistDataSet.AfterScroll := SavedAfterScroll;
  end;
end;

end.
