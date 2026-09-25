program ReportRegressionTests;
{$APPTYPE CONSOLE}
uses
  System.SysUtils, System.Classes, System.IOUtils, System.DateUtils,
  System.Generics.Collections, Data.DB, FireDAC.Comp.Client,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.StorageBin, LogManager, ScheduleManager;
procedure Check(const Name: string; Actual, Expected: Integer);
begin
  if Actual <> Expected then
    raise Exception.CreateFmt('%s: expected %d, got %d', [Name, Expected, Actual]);
  Writeln('PASS ', Name, ': ', Actual);
end;
procedure TestCounts;
var Lines: TStringList; TodayText, YesterdayText: string;
begin
  if FileExists(CarillonLogFilePath) then
    raise Exception.Create('Run tests in a fresh output directory without an existing log.');
  ForceDirectories(ExtractFileDir(CarillonLogFilePath));
  Check('No existing log', ReadCarillonPlayCount(Date), 0);
  TodayText := FormatDateTime('yyyy-mm-dd', Date);
  YesterdayText := FormatDateTime('yyyy-mm-dd', Date - 1);
  Lines := TStringList.Create;
  try
    Lines.Add(YesterdayText + ' 12:00:00 - Played Song: prior-day.mp3');
    Lines.Add(YesterdayText + ' 12:00:00 - Daily play count checkpoint: 38');
    Lines.Add(TodayText + ' 00:01:00 - Played Song: first.mp3');
    Lines.Add(TodayText + ' 00:02:00 - Played Song: second.mp3');
    Lines.Add(TodayText + ' 00:03:00 - Application initialized');
    Lines.SaveToFile(CarillonLogFilePath);
    Check('Restore legacy plays across restart', ReadCarillonPlayCount(Date), 2);
    Check('Yesterday counts plays and ignores old checkpoints', ReadCarillonPlayCount(Date - 1), 1);
    Lines.Add(TodayText + ' 00:04:00 - Played Song: third.mp3');
    Lines.Add(TodayText + ' 00:04:00 - Daily play count checkpoint: 3');
    Lines.Add(TodayText + ' 00:05:00 - Total Songs played yesterday: 38');
    Lines.Add(TodayText + ' 00:05:00 - Daily Song Count restored for today: 3');
    Lines.SaveToFile(CarillonLogFilePath);
    Check('Checkpoint does not double count', ReadCarillonPlayCount(Date), 3);
    Check('Early morning plays survive maintenance', ReadCarillonPlayCount(Date), 3);
    Lines.Add(TodayText + ' 00:06:00 - Daily play count checkpoint: 4');
    Lines.Add(TodayText + ' 00:07:00 - Application initialized');
    Lines.SaveToFile(CarillonLogFilePath);
    Check('Checkpoint without recorded play is ignored', ReadCarillonPlayCount(Date), 3);
    Lines.Add(TodayText + ' 00:08:00 - Played Song: fifth.mp3');
    Lines.Add(TodayText + ' 00:08:00 - Daily play count checkpoint: 5');
    Lines.Add(TodayText + ' 00:09:00 - Daily play count checkpoint: invalid');
    Lines.Add(TodayText + ' 00:09:00 - Daily play count checkpoint: -1');
    Lines.SaveToFile(CarillonLogFilePath);
    Check('Only recorded plays count, ignoring all checkpoints', ReadCarillonPlayCount(Date), 4);
    Check('Unrelated date returns zero', ReadCarillonPlayCount(Date + 1), 0);
  finally Lines.Free end;
end;
procedure TestSchedules;
const Days: array[1..7] of string = ('monday','tuesday','wednesday','thursday','friday','saturday','sunday');
var Data: TFDMemTable; ReportItems, PlaybackItems: TList<TScheduleEntry>;
    NextId, I, ExpectedRemaining: Integer; Cutoff: TTime;
begin
  Data := TFDMemTable.Create(nil);
  ReportItems := TList<TScheduleEntry>.Create;
  PlaybackItems := TList<TScheduleEntry>.Create;
  try
    Data.FieldDefs.Add('play_date_from', ftDate);
    Data.FieldDefs.Add('play_date_to', ftDate);
    for I := 1 to 7 do Data.FieldDefs.Add('play_' + Days[I], ftInteger);
    for I := 1 to 12 do Data.FieldDefs.Add('scheduled_time' + I.ToString, ftTime);
    Data.FieldDefs.Add('num_times_to_play', ftInteger);
    Data.FieldDefs.Add('song_name', ftString, 100);
    Data.CreateDataSet;
    Data.Append;
    Data.FieldByName('play_date_from').AsDateTime := Date;
    Data.FieldByName('play_date_to').AsDateTime := Date;
    for I := 1 to 7 do Data.FieldByName('play_' + Days[I]).AsInteger := 1;
    Data.FieldByName('song_name').AsString := 'test.mp3';
    Data.FieldByName('num_times_to_play').AsInteger := 1;
    Data.FieldByName('scheduled_time1').AsDateTime := 0;
    Data.FieldByName('scheduled_time2').AsDateTime := EncodeTime(12,0,0,0);
    Data.FieldByName('scheduled_time3').AsDateTime := EncodeTime(23,59,59,0);
    Data.FieldByName('scheduled_time4').AsDateTime := EncodeTime(12,0,0,0);
    Data.Post;
    NextId := 0;
    BuildPlaybackSchedule(Data, ReportItems, NextId, nil, True);
    Check('Full-day report includes past events and removes duplicates', ReportItems.Count, 3);
    Check('Report leaves empty paused playback queue unchanged', PlaybackItems.Count, 0);
    Check('Report preserves dataset position', Data.RecNo, 1);
    BuildPlaybackSchedule(Data, ReportItems, NextId,
      function(const Stamp: TDateTime): Boolean
      begin Result := HourOf(Stamp) = 12 end, True);
    Check('Full-day report respects silence', ReportItems.Count, 2);
    Cutoff := Time;
    BuildPlaybackSchedule(Data, PlaybackItems, NextId, nil);
    ExpectedRemaining := 0;
    if CompareTime(Cutoff, 0) <= 0 then Inc(ExpectedRemaining);
    if CompareTime(Cutoff, EncodeTime(12,0,0,0)) <= 0 then Inc(ExpectedRemaining);
    if CompareTime(Cutoff, EncodeTime(23,59,59,0)) <= 0 then Inc(ExpectedRemaining);
    Check('Playback still includes only remaining events', PlaybackItems.Count, ExpectedRemaining);
    Data.Edit;
    Data.FieldByName('play_' + Days[DayOfTheWeek(Date)]).AsInteger := 0;
    Data.Post;
    BuildPlaybackSchedule(Data, ReportItems, NextId, nil, True);
    Check('Disabled weekday excluded', ReportItems.Count, 0);
    Data.Edit;
    Data.FieldByName('play_' + Days[DayOfTheWeek(Date)]).AsInteger := 1;
    Data.FieldByName('play_date_to').AsDateTime := Date - 1;
    Data.Post;
    BuildPlaybackSchedule(Data, ReportItems, NextId, nil, True);
    Check('Expired date range excluded', ReportItems.Count, 0);
  finally
    PlaybackItems.Free;
    ReportItems.Free;
    Data.Free;
  end;
end;
begin
  try
    TestCounts;
    TestSchedules;
  except
    on E: Exception do begin Writeln('FAIL ', E.Message); Halt(1) end;
  end;
end.
