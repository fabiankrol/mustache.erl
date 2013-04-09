-module(mustache_config_tests).
-compile(export_all).

-include_lib("eunit/include/eunit.hrl").

not_set_test_() ->
    {setup,
        fun() ->
                ok = meck:new(application, [unstick, passthrough]),
                ok = meck:expect(application, get_env, fun
                        (mustache, config_key) -> {ok, config_value};
                        (App, Key) -> meck:passthrough([App, Key])
                    end)
        end,
        fun(_) -> ok = meck:unload(application) end,
        fun() ->
            ?assertEqual({ok, config_value}, mustache_config:get_env(config_key)),
            ?assertEqual(undefined, mustache_config:get_env(other_key))
        end
    }.

default_test_() ->
    {setup,
        fun() ->
                ok = meck:new(application, [unstick, passthrough]),
                ok = meck:expect(application, get_env, fun
                        (mustache, config_module) -> {ok, mustache_config};
                        (mustache, config_key) -> {ok, config_value};
                        (App, Key) -> meck:passthrough([App, Key])
                    end)
        end,
        fun(_) -> meck:unload(application) end,
        fun() ->
                ?assertEqual({ok, config_value}, mustache_config:get_env(config_key)),
                ?assertEqual({ok, mustache_config}, mustache_config:get_env(config_module)),
                ?assertEqual(undefined, mustache_config:get_env(other_key))
        end
    }.

custom_test_() ->
    {setup,
        fun() ->
                ok = meck:new(application, [unstick, passthrough]),
                ok = meck:expect(application, get_env, fun
                        (mustache, config_module) -> {ok, other_module};
                        (App, Key) -> meck:passthrough([App, Key])
                    end),
                ok = meck:new(other_module),
                ok = meck:expect(other_module, get_env, fun
                        (mustache, config_key) -> {ok, other_config_value};
                        (_, _) -> undefined
                    end)
        end,
        fun(_) ->
                ok = meck:unload(other_module),
                ok = meck:unload(application)
        end,
        fun() ->
            ?assertEqual({ok, other_config_value}, mustache_config:get_env(config_key)),
            ?assertEqual(undefined, mustache_config:get_env(other_key))
        end
    }.
