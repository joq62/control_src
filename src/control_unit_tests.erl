%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(control_unit_tests).  
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").
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

    ?debugMsg("Start dbase_test"),
    ?assertEqual(ok, dbase_test:start()),
    ?debugMsg("stop  dbase_test"),
    
   
      %% End application tests
  %  ?debugMsg("Start cleanup"),
  %  ?assertEqual(ok,cleanup()),
  %  ?debugMsg("Stop cleanup"),

    ?debugMsg("------>"++atom_to_list(?MODULE)++" ENDED SUCCESSFUL ---------"),
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
setup()->
    ssh:start(),
    ?assertMatch({ok,_},common:start()),
    ?assertMatch({ok,_},dbase:start()),

    GitConfigs=[{git_user,"joq62"},{git_pw,"20Qazxsw20"},
		{cluster_dir,"cluster_config"}, {cluster_file,"cluster_info.hrl"},
		 {app_specs_dir,"app_specs"},{service_specs_dir,"service_specs"}],
		
    ?assertMatch({ok,_},control:start(GitConfigs)),
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------    

cleanup()->
  
    init:stop(),
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
