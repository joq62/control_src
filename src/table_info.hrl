[db_passwd,"joq62","20Qazxsw20"].

[db_computer,"c0","joq62","festum01","192.168.0.200",22,not_available].
[db_computer,"c1","joq62","festum01","192.168.0.201",22,not_available].
[db_computer,"c2","joq62","festum01","192.168.0.202",22,not_available].

[db_service_def,"adder_service","1.0.0",{application,start,[adder_service]},"https://github.com/joq62/adder_service.git"].
[db_service_def,"multi_service","1.0.0",{application,start,[multi_service]},"https://github.com/joq62/multi_service.git"].
[db_service_def,"divi_service","1.0.0",{application,start,[divi_service]},"https://github.com/joq62/divi_service.git"].
[db_service_def,"common","1.0.0",{application,start,[common]},"https://github.com/joq62/common.git"].

[db_app_spec,"calc","1.0.0",
 [],
 [{"adder_service","1.0.0"},
			     {"multi_service","1.0.0"},
			     {"divi_service","1.0.0"}
			    ]].
[db_app_spec,"server_0","1.0.0",
 [{host,"c0"},{vm_id,"server_100"},{vm_dir,"server_100"}],
 [{"common","1.0.0"},
  {"dbase","1.0.0"},
  {"server","1.0.0"}
 ]].
[db_app_spec,"server_1","1.0.0",
 [{host,"c1"},{vm_id,"server_100"},{vm_dir,"server_100"}],
 [{"common","1.0.0"},
  {"dbase","1.0.0"},
  {"server","1.0.0"}
 ]].
[db_app_spec,"server_2","1.0.0",
 [{host,"c2"},{vm_id,"server_100"},{vm_dir,"server_100"}],
 [{"common","1.0.0"},
  {"dbase","1.0.0"},
  {"server","1.0.0"}
 ]].


[db_deployment_spec,"test_1","1.0.0",1,no_restrictions,[{"calc","1.0.0"}]].

