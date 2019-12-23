README.md:% DOCTEST
% this example is tested in place as a part of the build pipeline

:- use_module(library(http/json)).
:- use_module(library(date)).



lambda_local_datetime(context(headers(H), _), DT) :-
  member('TZ'(TimeZone), H),
  member(TimeZone-TZ, ['PST'-(5 * 60 * 60)]),
  I is TZ,
  get_time(TS),
  stamp_date_time(TS, DT, I).

names(FullName, NickName, _) :-
  member(FullName-NickName, [
        'Nicholas'-'Nick',
        'William'-'Bob',
        'William'-'Robert',
        'Steven'-'Steve']).

% During the holiday season recognize additional nick names
names('Nicholas', 'Santa', Context) :-
  lambda_local_datetime(Context, DT),
  date_time_value(month, DT, 12),
  date_time_value(day, DT, Day),
  Day < 26.

% Given an event described by the JSON schema:
% {"type": "object", "properties": {"nickName": {"type": "string"}, "fullName": {"type": "string"}}}
% The response is described by the JSON schema:
% {"type": "object", "required": ["possibleNames], "properties": {"possibleNames: {"type": "array", "items": 
%   {"type": "object", "properties": {"fullName": {"type": "string"}, "nickName": {"type": "string"}}}}}}
handler(json(Event), Context, Response) :-
    (member(fullName=FullName, Event); true),
    (member(nickName=NickName, Event); true),
    findall(json([fullname=FullName, nickName=NickName]), 
            names(FullName, NickName, Context), 
            Names),
    atom_json_term(Response, json([possibleNames=Names]), []).
 