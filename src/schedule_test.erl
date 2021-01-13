%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Create1d : 10 dec 2012
%%% -------------------------------------------------------------------
-module(schedule_test). 
    
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

    ?debugMsg("Start start_missing"),
    ?assertEqual(ok,start_missing()),
    ?debugMsg("stop start_missing"),

     
    ?assertEqual(ok,cleanup()),

    ?debugMsg("------>"++atom_to_list(?MODULE)++" ENDED SUCCESSFUL ---------"),
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
setup()->
   
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
start_missing()->
    ?assertEqual(["calc_100.app_spec",
		  "server_c_100.app_spec",
		  "server_a_100.app_spec",
		  "server_b_100.app_spec",
		  "test1_100.app_spec"],
		 deployment:missing_apps()),


    MissingApps=deployment:missing_apps(),
    CreateResult=[{deployment:create_application(AppSpec),AppSpec}||AppSpec<-MissingApps],
    io:format("CreateResult = ~p~n",[CreateResult]),
    
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
depricated()->
    ?assertEqual([],
		 deployment:depricated_apps()),
    
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
create2()->
    
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
%% -------------------------------------------------------------------

cleanup()->
    A=["calc_100.app_spec",
       "server_c_100.app_spec",
       "server_a_100.app_spec",
       "server_b_100.app_spec",
       "test1_100.app_spec"],
    
    DeleteResult=[{deployment:delete_application(AppSpec),AppSpec}||AppSpec<-A],
    io:format("DeleteResult = ~p~n",[DeleteResult]),
    ok.
