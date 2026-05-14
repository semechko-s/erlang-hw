-module(code_lock).
-behaviour(gen_statem).
-define(NAME, code_lock).

-export([start_link/2,stop/0]).
-export([button/1,set_lock_button/1, change_code/1]).
-export([init/1,callback_mode/0,terminate/3]).
-export([handle_event/4]).

start_link(Code, LockButton) ->
    gen_statem:start_link(
        {local,?NAME}, ?MODULE, {Code,LockButton}, []).

stop() ->
    gen_statem:stop(?NAME).

button(Button) ->
    gen_statem:cast(?NAME, {button,Button}).

set_lock_button(LockButton) ->
    gen_statem:call(?NAME, {set_lock_button,LockButton}).

change_code(NewLock) ->
    gen_statem:cast(?NAME, {change_code, NewLock}).

init({Code,LockButton}) ->
    process_flag(trap_exit, true),
    Data = #{code => Code,
            length => length(Code),
            buttons => [],
            lock_failed => 0},
    {ok, {locked,LockButton}, Data}.

callback_mode() ->
    [handle_event_function,state_enter].

%% State: locked
handle_event(enter, _OldState, {locked,_}, Data) ->
    do_lock(),
    {keep_state, Data#{buttons := []}};
handle_event(state_timeout, button, {locked,_}, Data) ->
    {keep_state, Data#{buttons := []}};
handle_event(cast, {change_code, _}, {locked, _}, _Data) ->
    io:format("Error: Locked change~n", []),
    {keep_state_and_data, []};
handle_event(
  cast, {button,Button}, {locked,LockButton},
  #{code := Code,
    length := Length,
    buttons := Buttons,
    lock_failed := Failed
    } = Data) ->
    NewButtons =
        if
            length(Buttons) < Length ->
                Buttons;
            true ->
                tl(Buttons)
        end ++ [Button],

    case NewButtons of
        Code ->
            %%correct
            {next_state, {open,LockButton}, Data#{lock_failed := 0}};
        _->
            case length(NewButtons) =:= Length of
                true ->
                    NewFail = Failed + 1,

                    case NewFail == 3 of
                        true ->
                            {next_state, {suspended, LockButton}, Data};
                        false ->
                            {keep_state, Data#{buttons := [],
                                                lock_failed := NewFail}}
                    end;
                false ->
                    {keep_state, Data#{buttons := NewButtons},
                    [{state_timeout,30_000,button}]}
            end
    end;

%%
%% State: suspended
handle_event(enter, _OldState, {suspended, _}, _Data) ->
    do_suspended(),
    {keep_state_and_data,
     [{state_timeout,10_000,lock}]};
handle_event(state_timeout, lock, {suspended, LockButton}, Data) ->
    {next_state, {locked, LockButton},
    Data#{lock_failed := 0, buttons := []}};
handle_event(cast, {change_code, _}, {suspended, _}, _Data) ->
    io:format("Error: Locked change~n", []),
    {keep_state_and_data, []};
handle_event(cast, {button,_}, {suspended, _}, _Data) ->
    io:format("Error: suspended lock~n", []),
    {keep_state_and_data, []};

%%
%% State: open
handle_event(enter, _OldState, {open,_}, _Data) ->
    do_unlock(),
    {keep_state_and_data,
     [{state_timeout,10_000,lock}]}; % Time in milliseconds
handle_event(state_timeout, lock, {open,LockButton}, Data) ->
    {next_state, {locked,LockButton}, Data};
handle_event(cast, {change_code, NewLock}, {open, _}, Data) ->
    {keep_state, Data#{code := NewLock, length := length(NewLock), buttons := []}};
handle_event(cast, {button,LockButton}, {open,LockButton}, Data) ->
    {next_state, {locked,LockButton}, Data};
handle_event(cast, {button,_}, {open,_}, _Data) ->
    {keep_state_and_data, [postpone]};

%%
%% Common events
handle_event(
    {call,From},
    {set_lock_button, NewLockButton},
    {StateName, OldLockButton}, Data) ->
        {next_state, {StateName, NewLockButton}, Data,
        [{reply, From, OldLockButton}]}.

do_lock() ->
    io:format("Locked~n", []).
do_unlock() ->
    io:format("Open~n", []).
do_suspended() ->
    io:format("suspended~n", []).

terminate(_Reason, State, _Data) ->
    State =/= locked andalso do_lock(),
    ok.
