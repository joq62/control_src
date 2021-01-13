%% This is the application resource file (.app file) for the 'base'
%% application.
{application, system_test,
[{description, "system_test  " },
{vsn, "1.0.0" },
{modules, 
	  [system_test_app,system_test_sup,system_test]},
{registered,[system_test]},
{applications, [kernel,stdlib]},
{mod, {system_test_app,[]}},
{start_phases, []}
]}.
