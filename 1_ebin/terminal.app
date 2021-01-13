%% This is the application resource file (.app file) for the 'base'
%% application.
{application, terminal,
[{description, "terminal  " },
{vsn, "1.0.0" },
{modules, 
	  [terminal_app,terminal_sup,terminal,common]},
{registered,[terminal,common]},
{applications, [kernel,stdlib]},
{mod, {terminal_app,[]}},
{start_phases, []}
]}.
