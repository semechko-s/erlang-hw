-module(iotserv).
-export([start_link/0, start_link/1, stop/0]).
-export([add/1, delete/1, change/2, lookup/1]).
-export([init/1, terminate/2, handle_call/3, handle_cast/2]).

-behavior(gen_server).
-include("iotserv.hrl").

-type devise() :: #devise{}.

-spec start_link() -> {ok, pid()} | {error, term()}.
start_link() ->
    FileName = get_config(),
    start_link(FileName).
-spec start_link(string()) -> {ok, pid()} | {error, term()}.
start_link(FileName) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, FileName, []).

-spec stop() -> ok.
stop() ->
    gen_server:cast(?MODULE, stop).

-spec add(devise()) -> ok.
add(Devise) ->
    gen_server:call(?MODULE, {add, Devise}).

-spec delete(integer()) -> ok.
delete(Id) ->
    gen_server:call(?MODULE, {delete, Id}).

-spec change(integer(), devise()) -> ok.
change(Id, Devise) ->
    gen_server:call(?MODULE, {change, Id, Devise}).

-spec lookup(integer()) -> {ok, devise()} | {err, instance}.
lookup(Id) ->
    gen_server:call(?MODULE, {lookup, Id}).

-spec init(string()) -> {ok, term()}.
init(FileName) ->
    iotserv_db:create_tables(FileName),
    iotserv_db:restore_backup(),
    {ok, null}.

handle_call({add, Devise}, _From, State) ->
    Reply = iotserv_db:add(Devise),
    {reply, Reply, State};
handle_call({delete, Id}, _From, State) ->
    Reply = iotserv_db:delete(Id),
    {reply, Reply, State};
handle_call({change, Id, Devise}, _From, State) ->
    Reply = iotserv_db:change(Id, Devise),
    {reply, Reply, State};
handle_call({lookup, Id}, _From, State) ->
    Reply = iotserv_db:lookup(Id),
    {reply, Reply, State};
handle_call(_Request, _From, State) ->
    {reply, err, State}.

handle_cast(stop, State) ->
    {stop, normal, State}.

terminate(_Reason, _State) ->
    iotserv_db:close_tables(),
    ok.

-spec get_config() -> string().
get_config() ->
    {ok, File} = application:get_env(iotserv, dets_name),
    {ok, Bin} = file:read_file(File),
    Json = jsx:decode(Bin, [return_maps]),
    binary_to_list(maps:get(<<"dets_name">>, Json)).