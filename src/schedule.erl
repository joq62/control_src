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
     rpc:call(node(),db_sd,active_apps,[]).
%% --------------------------------------------------------------------
%% Function:create(ServiceId,Vsn,HostId,VmId)
%% Description: Starts vm and deploys services 
%% Returns: ok |{error,Err}
%% --------------------------------------------------------------------
missing()->
    MissingApps=deployment:missing_apps(),
    
    %% Start master nodes first and add 
    MissingAppSpecsInfo=[{AppSpec,db_app_spec:read(AppSpec)}||AppSpec<-MissingApps],
 %   io:format("MissingAppSpecsInfo ~p~n",[MissingAppSpecsInfo]),
    MissingMasters=[XAppSpec||
		       {XAppSpec,[{_AppId,_AppVsn,Type,_Directives,_Services}]}<-MissingAppSpecsInfo,
		       Type==master],
    MissingWorkers=[XAppSpec||
		       {XAppSpec,[{_AppId,_AppVsn,Type,_Directives,_Services}]}<-MissingAppSpecsInfo,
		       Type==worker],
    
    %% Start masters first   
    case MissingMasters of
	[]->
	     %% Start workers
	    case MissingWorkers of
		[]->
		    ok;
		WorkerAppSpecs->
		    rpc:multicall(misc_oam:masters(),
				  sys_log,log,
				  [["Start WorkerAppSpecs ",WorkerAppSpecs],node(),
				   ?MODULE,?LINE]),
		    rpc:multicall(misc_oam:masters(),
				  sys_log,log,
				  [["StartResult WorkerAppSpecs",[deployment:create_application(WorkerAppSpec)||
								     WorkerAppSpec<-WorkerAppSpecs]],node(),
				   ?MODULE,?LINE])
	    end;
	MasterAppSpecs->
	     rpc:multicall(misc_oam:masters(),
			   sys_log,log,
			   [["Start Start MasterAppSpecs ",MasterAppSpecs],node(),
			    ?MODULE,?LINE]),
	    StartResult=[deployment:create_application(MasterAppSpec)||MasterAppSpec<-MasterAppSpecs],

	    rpc:multicall(misc_oam:masters(),
			  sys_log,log,
			  [["StartResult Masters",StartResult],node(),
			   ?MODULE,?LINE]),

	    misc_oam:print("StartResult ~p~n",[{StartResult,?MODULE,?LINE}]),
	    timer:sleep(1000),
	    
	    %% Add dbase nodes
	    {ok,BootHostId}=net:gethostname(),
	    BootVmId="master",
	    BootNode=list_to_atom(BootVmId++"@"++BootHostId),
	    ok=add_node(MasterAppSpecs,BootNode)
    end,    
    
    {MissingMasters,MissingWorkers}.
    
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

