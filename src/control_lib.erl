%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Create1d : 10 dec 2012
%%% -------------------------------------------------------------------
-module(control_lib). 
    
%% --------------------------------------------------------------------
%% Include files

%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Definitions

%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% External exports
-export([init_dbase/1]).

%% ====================================================================
%% External functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
init_dbase(GitConfigs)->
    {git_user,GitUser}=lists:keyfind(git_user,1,GitConfigs),
    {git_pw,GitPassWd}=lists:keyfind(git_pw,1,GitConfigs),
    {cluster_dir,ClusterConfigDir}=lists:keyfind(cluster_dir,1,GitConfigs),
    {cluster_file,ClusterConfigFileName}=lists:keyfind(cluster_file,1,GitConfigs),
    {app_specs_dir,AppSpecsDir}=lists:keyfind(app_specs_dir,1,GitConfigs),
    {service_specs_dir,ServiceSpecsDir}=lists:keyfind(service_specs_dir,1,GitConfigs),
    
    ok=config_lib:load_app_specs(AppSpecsDir,GitUser,GitPassWd),
    ok=config_lib:load_service_specs(ServiceSpecsDir,GitUser,GitPassWd),
    ok=config_lib:load_cluster_config(ClusterConfigDir,ClusterConfigFileName,GitUser,GitPassWd),
    ok.



%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

