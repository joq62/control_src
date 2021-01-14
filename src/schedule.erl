%%% -------------------------------------------------------------------
%%% @author : joqerlang
%%% @doc : ets dbase for master service to manage app info , catalog  
%%%
%%% -------------------------------------------------------------------
-module(schedule).
  

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
%% --------------------------------------------------------------------
%% Definition
-define(Cookie,"abc").
%% --------------------------------------------------------------------


%-compile(export_all).
-export([
	 active/0,
	 missing/0,
	 depricated/0
	]).

%% ====================================================================
%% External functions
%% ====================================================================

active()->
     rpc:call(sd:dbase_node(),db_sd,active_apps,[]).
%% --------------------------------------------------------------------
%% Function:create(ServiceId,Vsn,HostId,VmId)
%% Description: Starts vm and deploys services 
%% Returns: ok |{error,Err}
%% --------------------------------------------------------------------
missing()->
    MissingApps=deployment:missing_apps(),
    
    %% Start master nodes first and add 
    MissingAppSpecsInfo=[{AppSpec,rpc:call(sd:dbase_node(),db_app_spec,read,[AppSpec],2000)}||AppSpec<-MissingApps],
 %   io:format("MissingAppSpecsInfo ~p~n",[MissingAppSpecsInfo]),
    MissingLog=[XAppSpec||{XAppSpec,[{_AppId,_AppVsn,Type,_Host,_VmId,_VmDir,_Cookie,_Services}]}<-MissingAppSpecsInfo,
			  Type==log],
    MissingDbase=[XAppSpec||{XAppSpec,[{_AppId,_AppVsn,Type,_Host,_VmId,_VmDir,_Cookie,_Services}]}<-MissingAppSpecsInfo,
		       Type==dbase],
    MissingControl=[XAppSpec||{XAppSpec,[{_AppId,_AppVsn,Type,_Host,_VmId,_VmDir,_Cookie,_Services}]}<-MissingAppSpecsInfo,
			 Type==control],
    MissingService=[XAppSpec||{XAppSpec,[{_AppId,_AppVsn,Type,_Host,_VmId,_VmDir,_Cookie,_Services}]}<-MissingAppSpecsInfo,
			 Type==service],

   %% Algorithm
   %% 1. start missing type log
    case MissingLog of
	[]->
	    no_missing;
	MissingLog->
	    misc_log:msg(log,
			 ["StartResult Missinglog ",[deployment:create_application(AppSpec)||
							AppSpec<-MissingLog]],
			 node(),?MODULE,?LINE)
    end,
   %% 2. start missing type dbase 
    case MissingDbase of
	[]->
	    no_missing;
	MissingDbase->
	    misc_log:msg(log,
			 ["StartResult MissingDbase ",[deployment:create_application(AppSpec)||
							AppSpec<-MissingDbase]],
			 node(),?MODULE,?LINE)
    end,
   %% 3. start missing type control 
    case MissingControl of
	[]->
	    no_missing;
	MissingControl->
	    misc_log:msg(log,
			 ["StartResult MissingControl ",[deployment:create_application(AppSpec)||
							AppSpec<-MissingControl]],
			 node(),?MODULE,?LINE)
    end,
   %% 4. start missing type service 
    case MissingService of
	[]->
	    no_missing;
	MissingService->
	    misc_log:msg(log,
			 ["StartResult MissingService ",[deployment:create_application(AppSpec)||
							AppSpec<-MissingService]],
			 node(),?MODULE,?LINE)
    end,  
   %% 5.

    [{log,MissingLog},{dbase,MissingDbase},
     {control,MissingControl},{service,MissingService}].
    
add_node([],_)->
    ok;
add_node([MasterAppSpec|T],BootNode)->   
    [{_AppId,_AppVsn,master,Directives,_Services}]=db_app_spec:read(MasterAppSpec),
    {host,HostId}=lists:keyfind(host,1,Directives),
    {vm_id,VmId}=lists:keyfind(vm_id,1,Directives),
    rpc:multicall(misc_oam:masters(),
		  sys_log,log,
		  [["Add Mnesia node ",rpc:call(BootNode,dbase_lib,add_node,[list_to_atom(VmId++"@"++HostId)],2*5000)]
		  ,node(),?MODULE,?LINE]),
    add_node(T,BootNode).
	
%% --------------------------------------------------------------------
%% Function:create(ServiceId,Vsn,HostId,VmId)
%% Description: Starts vm and deploys services 
%% Returns: ok |{error,Err}
%% --------------------------------------------------------------------
depricated()->
    DepricatedApps=deployment:depricated_apps(),
 %   [spawn(fun()->
%	       deployment:delete_application(AppSpec) end)||AppSpec<-DepricatedApps],
    DepricatedApps.
    
%% -------------------------------------------------------------------
%% Function:create(ServiceId,Vsn,HostId,VmId)
%% Description: Starts vm and deploys services 
%% Returns: ok |{error,Err}
%% --------------------------------------------------------------------

