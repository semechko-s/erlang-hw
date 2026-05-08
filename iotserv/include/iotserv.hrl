-type metric() :: {atom(), integer()}.
-type metrics() :: [metric()].

-record(devise, {
        id :: integer(),
        name :: string(),
        address :: integer(),
        temperature :: float(),
        metrics :: metrics()}).