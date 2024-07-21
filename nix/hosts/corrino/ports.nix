{
	# 19xx
	stream_rtmp = 1935;
	
	# 20xx
	initrd_ssh = 2222;
	photo = 2342;

	# 30xx
	git = 3000;
	hydra = 3001;
	grafana = 3002;
	md = 3003;
	gotosocial = 3004;

	sftpgo = {
		webdav = 3304;
		httpd = 3305;
		metrics = 3306;
	};

	# 34xx
	# cs = 3463;

	# 40xx
	events = 4000;
	seafile = 4001;

	# 54xx
	pgweb = 5432;

	garage = {
		rpcPort = 4101;
		apiPort = 4102;
		webPort = 4103;
		adminPort = 4104;
	};

	# 80xx
	stream = 8080;
	netbox = 8001;
	restic = 8002;
	# 8003
	jupyter = 8004;

	# 83xx
	ctf = 8338;
	magic-hash = 8339;

	tickets = 8349;
	talks = 8350;

	# 90xx
	authelia = 9091;
	prometheus_node_exporter = 9002;
	prometheus = 9003;
	loki = 9004;
	promtail = 9005;
	gitDaemon = 9418;
	prometheus_systemd_exporter = 9558;
	prometheus_smartctl_exporter = 9633;
}
