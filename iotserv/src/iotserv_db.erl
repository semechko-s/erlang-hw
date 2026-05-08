-module(iotserv_db).
-include("iotserv.hrl").

-export([add/1, delete/1, change/2, lookup/1]).
-export([create_tables/1, close_tables/0, restore_backup/0]).

-type devise() :: #devise{}.

-spec create_tables(string()) -> {ok, atom()} | {err, term()}.
create_tables(FileName) ->
    ets:new(deviseRam, [named_table, set, public]),
    dets:open_file(deviseDisk, [{file, FileName}, {type, set}]).

-spec close_tables() -> ok.
close_tables() ->
    ets:delete(deviseRam),
    dets:close(deviseDisk).

restore_backup() ->
    Insert = fun({Id, Devise}) ->
        ets:insert(deviseRam, {Id, Devise}),
        continue
    end,
    dets:traverse(deviseDisk, Insert).

-spec add(devise()) -> ok.
add(#devise{id = IdDev} = Devise) ->
    ets:insert(deviseRam, {IdDev, Devise}),
    dets:insert(deviseDisk, {IdDev, Devise}),
    ok.

-spec lookup(integer()) -> {ok, devise()} | {err, instance}.
lookup(Id) ->
    case ets:lookup(deviseRam, Id) of
        [{_, Dev}] -> {ok, Dev};
        [] -> {err, instance}
    end.

-spec delete(integer()) -> ok.
delete(Id) ->
    ets:delete(deviseRam, Id),
    dets:delete(deviseDisk, Id),
    ok.

-spec change(integer(), devise()) -> ok.
change(Id, Devise) ->
    ets:insert(deviseRam, {Id, Devise}),
    dets:insert(deviseDisk, {Id, Devise}),
    ok.
