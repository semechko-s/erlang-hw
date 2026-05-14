code_lock
=====

An OTP application

Build
-----

    $ rebar3 compile

Test
----
Тест смены пароля
```
4> code_lock:button(1).
ok
5> code_lock:button(2).
ok
6> code_lock:button(3).
Open
ok
7> code_lock:change_code([5,6,7]).
ok
Locked
8> code_lock:button(1).
ok
9> code_lock:button(2).
ok
10> code_lock:button(3).
ok
11> code_lock:button(5).
ok
12> code_lock:button(6).
ok
13> code_lock:button(7).
Open
ok
```
Тест перехода в состояние suspended и ошибки ввода кода
```
14> code_lock:button(7).
ok
15> code_lock:button(7).
ok
16> code_lock:button(7).
ok
------------------------------------
17> code_lock:button(7).
ok
18> code_lock:button(7).
ok
19> code_lock:button(7).
ok
------------------------------------
20> code_lock:button(7).
ok
21> code_lock:button(7).
ok
22> code_lock:button(7).
suspended
ok

23> code_lock:button(7).
Error: suspended lock
ok
```
Запуск тестов
```
stas@stas-Aspire-A715-43G:~/study/study_eltex/erlang-hw/code_lock$ rebar3 eunit
===> Verifying dependencies...
===> Analyzing applications...
===> Compiling code_lock
===> Performing EUnit tests...
.....
Finished in 0.456 seconds
5 tests, 0 failures
```
