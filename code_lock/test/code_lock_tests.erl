-module(code_lock_tests).
-include_lib("eunit/include/eunit.hrl").

start_lock() ->
    {ok, Pid} = code_lock:start_link([1,2,3], lock),
    Pid.

stop_lock() ->
    catch code_lock:stop().

start_stop_test() ->
    Pid = start_lock(),
    ?assert(is_pid(Pid)),
    stop_lock().

correct_code_test() ->
    start_lock(),

    code_lock:button(1),
    code_lock:button(2),
    code_lock:button(3),

    timer:sleep(100),

    ?assertMatch({open,_}, element(1, sys:get_state(code_lock))),

    stop_lock().

failed_code_test() ->
    start_lock(),

    code_lock:button(5),
    code_lock:button(5),
    code_lock:button(5),

    timer:sleep(100),

    ?assertMatch({locked,_}, element(1, sys:get_state(code_lock))),

    stop_lock().

susped_test() ->
    start_lock(),

    code_lock:button(5),
    code_lock:button(5),
    code_lock:button(5),
    code_lock:button(5),
    code_lock:button(5),
    code_lock:button(5),
    code_lock:button(5),
    code_lock:button(5),
    code_lock:button(5),

    timer:sleep(100),

    ?assertMatch({suspended,_}, element(1, sys:get_state(code_lock))),

    stop_lock().

change_code_test() ->
    start_lock(),

    ?assertMatch({{locked,_}, #{code := [1,2,3]}}, sys:get_state(code_lock)),

    code_lock:button(1),
    code_lock:button(2),
    code_lock:button(3),

    timer:sleep(100),
    code_lock:change_code([5, 6, 7]),
    ?assertMatch({{open,_}, #{code := [5,6,7]}}, sys:get_state(code_lock)),

    stop_lock().