%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Create1d : 10 dec 2012
%%% -------------------------------------------------------------------
-module(create_delete_test). 
    
%% --------------------------------------------------------------------
%% Include files

-include_lib("eunit/include/eunit.hrl").
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Definitions
-define(ServiceSpecsDir,"service_specs").
-define(AppSpecsDir,"app_specs").
-define(GitUser,"joq62").
-define(GitPassWd,"20Qazxsw20").
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% External exports
-export([start/0]).

%% ====================================================================
%% External functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
start()->
    ?debugMsg("Start setup"),
    ?assertEqual(ok,setup()),
    ?debugMsg("stop setup"),

    ?debugMsg("Start create1"),
    ?assertEqual(ok,create1()),
    ?debugMsg("stop create1"),

    ?debugMsg("Start delete1"),
    ?assertEqual(ok,delete1()),
    ?debugMsg("stop delete1"),

    ?debugMsg("Start create2"),
    ?assertEqual(ok,create2()),
    ?debugMsg("stop create2"),

    ?debugMsg("Start delete2"),
    ?assertEqual(ok,delete2()),
    ?debugMsg("stop delete2"),

   
    ?assertEqual(ok,cleanup()),

    ?debugMsg("------>"++atom_to_list(?MODULE)++" ENDED SUCCESSFUL ---------"),
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
setup()->
    %{ServiceId,ServiceVsn,XAppId,XAppVsn,HostId,VmId,Vm}

  %  ?assertEqual([{"adder_service","1.0.0","calc_100.app_spec","not_relevant","c0","calc_100",'calc_100@c0'},
%		  {"divi_service","1.0.0","calc_100.app_spec","not_relevant","c0","calc_100",'calc_100@c0'},
%		  {"multi_service","1.0.0","calc_100.app_spec","not_relevant","c0","calc_100",'calc_100@c0'}],
%		 if_db:call(db_sd,app_spec,["calc_100.app_spec"])),
    [if_db:call(db_sd,delete,[ServiceId,ServiceVsn,Vm])||
	{ServiceId,ServiceVsn,_,_,_,_,Vm}<-if_db:call(db_sd,app_spec,["calc_100.app_spec"])],
    
    ?assertEqual([],
		 if_db:call(db_sd,app_spec,["calc_100.app_spec"])),
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
create2()->
    ?assertEqual(ok,wait_for_hosts(10,1000,error)),
    CreateResult=deployment:create_application("test1_100.app_spec"),
    io:format("CreateResult ~p~n",[CreateResult]),
    ?assertMatch({ok,"test1_100.app_spec","c0","test1_100",'test1_100@c0'},CreateResult),
           %      {ok,"calc_100.app_spec","c0","calc_100",'calc_100@c0'}
    [Vm1|_]=if_db:call(db_sd,get,["multi_service"]),
    io:format("Vm1 ~p~n",[Vm1]),
    ?assertEqual(440,rpc:call(Vm1,multi_service,multi,[20,22],2000)),
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
delete2()->
    [Vm1|_]=if_db:call(db_sd,get,["multi_service"]),
    io:format("Vm1 ~p~n",[Vm1]),
    ?assertEqual(440,rpc:call(Vm1,multi_service,multi,[20,22],2000)),

    DeleteResult=deployment:delete_application("test1_100.app_spec"),
    io:format("DeleteResult ~p~n",[DeleteResult]),
    ?assertMatch(ok,DeleteResult),
    []=if_db:call(db_sd,get,["multi_service"]),
    ?assertMatch({badrpc,_},rpc:call(Vm1,multi_service,multi,[20,22],2000)),

   ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
create1()->
%    rand_hosts(20),
    ?assertEqual(ok,wait_for_hosts(10,1000,error)),
    CreateResult=deployment:create_application("calc_100.app_spec"),
    io:format("CreateResult ~p~n",[CreateResult]),
    ?assertMatch({ok,"calc_100.app_spec",_,_,_},CreateResult),
           %      {ok,"calc_100.app_spec","c0","calc_100",'calc_100@c0'}
    [Vm1|_]=if_db:call(db_sd,get,["adder_service"]),
    io:format("Vm1 ~p~n",[Vm1]),
    ?assertEqual(42,rpc:call(Vm1,adder_service,add,[20,22],2000)),
    
    
   
    ok.
wait_for_hosts(0,_T,Msg)->
    Msg;
wait_for_hosts(N,T,Msg)->
    case if_db:call(db_server,status,[running]) of
	[]->
	    timer:sleep(T),
	    NewMsg=Msg,	   
	    NewN=N-1;
	_ ->
	    NewMsg=ok,
	    NewN=0
    end,
    wait_for_hosts(NewN,T,NewMsg).

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
delete1()->

    [Vm1|_]=if_db:call(db_sd,get,["adder_service"]),
    ?assertEqual(42,rpc:call(Vm1,adder_service,add,[20,22],2000)),

    DeleteResult=deployment:delete_application("calc_100.app_spec"),
    io:format("DeleteResult ~p~n",[DeleteResult]),
    ?assertMatch(ok,DeleteResult),
    []=if_db:call(db_sd,get,["adder_service"]),
    ?assertMatch({badrpc,_},rpc:call(Vm1,adder_service,add,[20,22],2000)),

   ok.

rand_hosts(0)->
    ok;
rand_hosts(N) ->
    io:format(": ~p",[deployment:random_host()]),
    rand_hosts(N-1).
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------

cleanup()->

    ok.
