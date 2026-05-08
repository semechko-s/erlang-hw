iotserv
=====

An OTP application

Build
-----

    $ rebar3 compile

Test
----
```
stas@stas-Aspire-A715-43G:~/study/study_eltex/erlang-hw/iotserv$ rebar3 compile
===> Verifying dependencies...
===> Analyzing applications...
===> Compiling iotserv
```
```
stas@stas-Aspire-A715-43G:~/study/study_eltex/erlang-hw/iotserv$ rebar3 shell
===> Verifying dependencies...
===> Analyzing applications...
===> Compiling iotserv
```
```
1> application:start(iotserv).
{error,{already_started,iotserv}}

```
```
2> whereis(iotserv).
<0.155.0>
```
```
3> iotserv:add({devise,1,"sensor1","room1",23.5,[{mem_load,57}]}).
ok
```
```
4> iotserv:lookup(1).
{ok,{devise,1,"sensor1","room1",23.5,[{mem_load,57}]}}
```
```
5> iotserv:delete(1).
ok
```
```
6> iotserv:lookup(1).
{err,instance}
```
```
8> iotserv:add({devise,2,"sensor1","room1",23.5,[{mem_load,77}]}).
ok
```
```
9> iotserv:change(2,{device,2,"sensorX","room2",30.0,[{cpu,99}]}).
ok
```
```
10> iotserv:lookup(2).
{ok,{device,2,"sensorX","room2",30.0,[{cpu,99}]}}
```
```
11> q().
ok
12> stas@stas-Aspire-A715-43G:~/study/study_eltex/erlang-hw/iotserv$ rebar3 shell
===> Verifying dependencies...
===> Analyzing applications...
===> Compiling iotserv
Erlang/OTP 25 [erts-13.2.2.5] [source] [64-bit] [smp:12:12] [ds:12:12:10] [async-threads:1] [jit:ns]

Eshell V13.2.2.5  (abort with ^G)
1> ===> Booted iotserv
1> iotserv:lookup(2).
{ok,{device,2,"sensorX","room2",30.0,[{cpu,99}]}}
```
