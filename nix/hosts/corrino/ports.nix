{
  emile.ports = {
    stream_rtmp = 1935;
    initrd_ssh = 2222;
    photo = {
      photoprism = 2342;
      immich = 2343;
    };
    git = 3000;
    hydra = 3001;
    grafana = 3002;
    md = 3003;
    gotosocial = 3004;
    immich = 3005;
    harmonia = 5000;
    irc = {
      clear = 6667;
      ssl = 6697;
    };
    hound = 6080;
    stream = 8080;
    netbox = 8001;
    restic = 8002;
    nocodb = 8003;
    r2wars-web = 8089;
    ctf = 8338;
    magic-hash = 8339;
    tickets = 8349;
    talks = 8350;
    minio = {
      s3 = 9000;
      web = 9001;
    };
    promtail = 9033;
    loki = 9034;
    authelia = 9091;
    gitDaemon = 9418;
    prometheus = {
      web = 9003;
      exporter = {
        node = 9002;
        nginx = 9913;
        systemd = 9558;
        smartctl = 9633;
      };
    };
  };
}
