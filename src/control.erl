%%% -------------------------------------------------------------------
%%% @author  : Joq Erlang
%%% @doc: : 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(control). 

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
%-include("log.hrl").
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% Key Data structures
%% 
%% --------------------------------------------------------------------
-record(state,{missing,obsolite,failed}).


%% --------------------------------------------------------------------
%% Definitions 
-define(HbInterval,30*1000).
-define(ScheduleInterval,2*30*1000).
-define(LockInterval,40).
%% --------------------------------------------------------------------

-export([
	 create_application/1,
	 delete_application/1,
	 schedule/2
	]).

-export([load_app_specs/3,
	 read_app_specs/0,
	 read_app_spec/1,
	 load_service_specs/3,
	 read_service_specs/0,
	 read_service_spec/1
	]).

-export([create_service/4,delete_service/4,
	 create_deployment_spec/3,
	 delete_deployment_spec/2,
	 read_deployment_spec/2,
	 deploy_app/2,
	 depricate_app/1,
	 delete_deployment/1
	]).

-export([start/0,
	 stop/0,
	 ping/0,
	 heartbeat/1
	]).

%% gen_server callbacks
-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).


%% ====================================================================
%% External functions
%% ====================================================================

%% Asynchrounus Signals



%% Gen server functions
start()-> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
stop()-> gen_server:call(?MODULE, {stop},infinity).

ping()-> 
    gen_server:call(?MODULE, {ping},infinity).

%%-----------------------------------------------------------------------
create_application(AppSpec)->
    gen_server:call(?MODULE, {create_application,AppSpec},infinity). 
delete_application(AppSpec)->
    gen_server:call(?MODULE, {delete_application,AppSpec},infinity). 


load_app_specs(AppSpecsDir,GitUser,GitPassWd)->
    gen_server:call(?MODULE, {load_app_specs,AppSpecsDir,GitUser,GitPassWd},infinity). 
read_app_specs()->
    gen_server:call(?MODULE, {read_app_specs},infinity). 
read_app_spec(AppId)->
    gen_server:call(?MODULE, {read_app_spec,AppId},infinity). 

load_service_specs(AppSpecsDir,GitUser,GitPassWd)->
    gen_server:call(?MODULE, {load_service_specs,AppSpecsDir,GitUser,GitPassWd},infinity). 
read_service_specs()->
    gen_server:call(?MODULE, {read_service_specs},infinity). 
read_service_spec(AppId)->
    gen_server:call(?MODULE, {read_service_spec,AppId},infinity). 


create_service(ServiceId,Vsn,HostId,VmId)->
    gen_server:call(?MODULE, {create_service,ServiceId,Vsn,HostId,VmId},infinity).    
delete_service(ServiceId,Vsn,HostId,VmId)->
    gen_server:call(?MODULE, {delete_service,ServiceId,Vsn,HostId,VmId},infinity).  

deploy_app(AppId,AppVsn)->
    gen_server:call(?MODULE, {deploy_app,AppId,AppVsn},infinity).
depricate_app(DeploymentId)->
    gen_server:call(?MODULE, {depricate_app,DeploymentId},infinity).
delete_deployment(DeploymentId)->
    gen_server:call(?MODULE, {delete_deployment,DeploymentId},infinity).
    
create_deployment_spec(AppId,AppVsn,ServiceList)->
    gen_server:call(?MODULE, {create_deployment_spec,AppId,AppVsn,ServiceList},infinity).
delete_deployment_spec(AppId,AppVsn)->
    gen_server:call(?MODULE, {delete_deployment_spec,AppId,AppVsn},infinity).
read_deployment_spec(AppId,AppVsn)->
    gen_server:call(?MODULE, {read_deployment_spec,AppId,AppVsn},infinity).

%%---------------------------------------------------------------------
schedule(ScheduleInterval,Result)->
    gen_server:cast(?MODULE, {schedule,ScheduleInterval,Result}).
    

heartbeat(Interval)->
    gen_server:cast(?MODULE, {heart_beat,Interval}).


%% ====================================================================
%% Server functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%
%% --------------------------------------------------------------------
init(_Args) ->

    %spawn(fun()->kick_scheduler(?ScheduleInterval) end),
   
    misc_log:msg(log,
		 ["Starting gen server =", ?MODULE],
		 node(),?MODULE,?LINE),
    {ok, #state{}}.   
    
%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (aterminate/2 is called)
%% --------------------------------------------------------------------
handle_call({ping},_From,State) ->
    Reply={pong,node(),?MODULE},
    {reply, Reply, State};

handle_call({create_application,AppSpec},_From,State) ->
    Reply=rpc:call(node(),deployment,create_application,[AppSpec],5*5*1000),
    {reply, Reply, State};

handle_call({delete_application,AppSpec},_From,State) ->
    Reply=rpc:call(node(),deployment,delete_application,[AppSpec],2*5*1000),
    {reply, Reply, State};






%%---------------------------------------------------------------------

handle_call({read_app_specs},_From,State) ->
    Reply=rpc:call(node(),deployment,read_app_specs,[],2*5000),
    {reply, Reply, State};
handle_call({read_app_spec,AppId},_From,State) ->
    Reply=rpc:call(node(),deployment,read_app_spec,[AppId],2*5000),
    {reply, Reply, State};

handle_call({load_app_specs,AppSpecsDir,GitUser,GitPassWd},_From,State) ->
    Reply=rpc:call(node(),deployment,load_app_specs,[AppSpecsDir,GitUser,GitPassWd],2*5000),
    {reply, Reply, State};

handle_call({read_service_specs},_From,State) ->
    Reply=rpc:call(node(),deployment,read_service_specs,[],2*5000),
    {reply, Reply, State};
handle_call({read_service_spec,Id},_From,State) ->
    Reply=rpc:call(node(),deployment,read_service_spec,[Id],2*5000),
    {reply, Reply, State};

handle_call({load_service_specs,SpecsDir,GitUser,GitPassWd},_From,State) ->
    Reply=rpc:call(node(),deployment,load_service_specs,[SpecsDir,GitUser,GitPassWd],2*5000),
    {reply, Reply, State};


handle_call({create_service,ServiceId,Vsn,HostId,VmId},_From,State) ->
    Reply=rpc:call(node(),service,create,[ServiceId,Vsn,HostId,VmId],2*5000),
    {reply, Reply, State};

handle_call({delete_service,ServiceId,Vsn,HostId,VmId},_From,State) ->
    Reply=rpc:call(node(),service,delete,[ServiceId,Vsn,HostId,VmId],5000),
    {reply, Reply, State};

handle_call({deploy_app,AppId,AppVsn},_From,State) ->
    Reply=rpc:call(node(),deployment,deploy_app,[AppId,AppVsn],25000),
    {reply, Reply, State};

handle_call({depricate_app,DeploymentId},_From,State) ->
    Reply=rpc:call(node(),deployment,depricate_app,[DeploymentId],5000),
    {reply, Reply, State};
handle_call({delete_deployment,DeploymentId},_From,State) ->
    Reply=if_db:deployment_delete(DeploymentId),
    {reply, Reply, State};

handle_call({create_deployment_spec,AppId,AppVsn,ServiceList},_From,State) ->
    Reply=rpc:call(node(),deployment,create_spec,[AppId,AppVsn,ServiceList],5000),
    {reply, Reply, State};

handle_call({delete_deployment_spec,AppId,AppVsn},_From,State) ->
    Reply=rpc:call(node(),deployment,delete_spec,[AppId,AppVsn],5000),
    {reply, Reply, State};

handle_call({read_deployment_spec,AppId,AppVsn},_From,State) ->
    Reply=rpc:call(node(),deployment,read_spec,[AppId,AppVsn],5000),
    {reply, Reply, State};

handle_call({stop}, _From, State) ->
    {stop, normal, shutdown_ok, State};

handle_call(Request, From, State) ->
    %?LOG_INFO(error,{unmatched_signal,Request,From}),
    Reply = {unmatched_signal,?MODULE,Request,From},
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% -------------------------------------------------------------------
handle_cast({schedule,ScheduleInterval,Result}, State) ->
    %% Check REsult
    case Result of
	{no_scheduling,_}->
	    ok;
	{scheduled,[{active,_Z},
		    {missing,{[],[]}},
		    {depricated,[]}]}->
	    ok;
	{scheduled,[{active,_},
		    {missing,_},
		     {depricated,_}]}->
	    rpc:multicall(misc_oam:masters(),
			  sys_log,log,
			  [["Schedule Result" ,Result],
			  node(),?MODULE,?LINE]),
	    timer:sleep(1);
	X ->
	    rpc:multicall(misc_oam:masters(),
			  sys_log,log,
			  [["Unmatched" ,X],
			  node(),?MODULE,?LINE]),
	    timer:sleep(1)
    end,
    spawn(fun()->kick_scheduler(ScheduleInterval) end),
    {noreply, State};

handle_cast(Msg, State) ->
    io:format("unmatched match cast ~p~n",[{?MODULE,?LINE,Msg}]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------

handle_info(Info, State) ->
    io:format("unmatched match info ~p~n",[{?MODULE,?LINE,Info}]),
    {noreply, State}.


%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------
%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% Internal functions
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
kick_scheduler(ScheduleInterval)->
    rpc:multicall(misc_oam:masters(),
		  sys_log,log,
		  [[time(),"kick_scheduler"],
		   node(),?MODULE,?LINE]),
    timer:sleep(1),
%    misc_oam:print("kick_scheduler ~p~n",[{time(),node(),?MODULE,?LINE}]),
    timer:sleep(1000),
    StatusMachines=rpc:call(node(),machine,status,[all],2*5000),
    io:format("StatusMachines ~p~n",[StatusMachines]),
    rpc:multicall(misc_oam:masters(),
		  sys_log,log,
		  [[time(),"StatusMachinesr =", StatusMachines],
		   node(),?MODULE,?LINE],1000),
    timer:sleep(1),
    rpc:call(node(),machine,update_status,[StatusMachines],5000),
    
    timer:sleep(ScheduleInterval),
    %% Check if lock is open so it's time for checking

    Result=case rpc:call(node(),db_lock,is_open,[schedule,?LockInterval],2000) of
	       false->
	%	   misc_oam:print("Lock Closed ~p~n",[{time(),node(),?MODULE,?LINE}]),
		   ActiveApps=rpc:call(node(),schedule,active,[],5*5000),
		   {no_scheduling,[{active,ActiveApps}]};
	       true->
	%	   misc_oam:print("Lock Open  ~p~n",[{time(),node(),?MODULE,?LINE}]),
		   ActiveApps=rpc:call(node(),schedule,active,[],5*5000),
		   MissingResult=rpc:call(node(),schedule,missing,[],6*5000),
		   DepricatedResult=rpc:call(node(),schedule,depricated,[],5*5000),
		   {scheduled,[{active,ActiveApps},{missing,MissingResult},{depricated,DepricatedResult}]}
	   end,
    rpc:cast(node(),control,schedule,[ScheduleInterval,Result]).
			       
				   
			   
					   
   
    
