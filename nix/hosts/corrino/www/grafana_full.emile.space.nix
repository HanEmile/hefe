{ pkgs, config, ... }:

let
  cfg = config.services.grafana;
in
{
  services.nginx.virtualHosts."git.emile.space" = {
    forceSSL = true;
    enableACME = true;

    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:3000";
      };
    };
  };

  services = {
    grafana = {
      enable = true;
      package = pkgs.grafana;
      #declarativePlugins = with pkgs.grafanaPlugins; [
      #  grafana-piechart-panel
      #];
      dataDir = "/var/lib/grafana";

      settings = {
        users = {
          # Viewers can access and use Explore and perform temporary edits on panels in dashboards they have access to. They cannot save their changes.
          viewers_can_edit = true;

          # Require email validation before sign up completes
          verify_email_enabled = false;

          # The duration in time a user invitation remains valid before expiring. This setting should be expressed as a duration. Examples: 6h (hours), 2d (days), 1w (week). The minimum supported duration is 15m (15 minutes).
          user_invite_max_lifetime_duration = "24h";

          # Text used as placeholder text on login page for password input.
          password_hint = "password";

          # Text used as placeholder text on login page for login/username input.
          login_hint = "email or username";

          # Path to a custom home page. Users are only redirected to this if the default home dashboard is used. It should match a frontend route and contain a leading slash.
          home_page = "";

          # This is a comma-separated list of usernames. Users specified here are hidden in the Grafana UI. They are still visible to Grafana administrators and to themselves.
          hidden_users = "";

          # Editors can administrate dashboards, folders and teams they create.
          editors_can_admin = false;

          # Sets the default UI theme. system matches the user’s system theme.
          default_theme = "system";

          # This setting configures the default UI language, which must be a supported IETF language tag, such as en-US.
          default_language = "en-US";

          # The role new users will be assigned for the main organization (if the auto_assign_org setting is set to true).
          # one of "Viewer", "Editor", "Admin"
          auto_assign_org_role = "Viewer";

          # Set this value to automatically add new users to the provided org. This requires auto_assign_org to be set to true. Please make sure that this organization already exists.
          auto_assign_org_id = 1;

          # Set to true to automatically add new users to the main organization (id 1). When set to false, new users automatically cause a new organization to be created for that new user. The organization will be created even if the allow_org_create setting is set to false.
          auto_assign_org = true;

          # Set to false to prohibit users from being able to sign up / create user accounts. The admin user can still create users.
          allow_sign_up = false;

          # Set to false to prohibit users from creating new organizations.
          allow_org_create = false;
        };

        smtp = {
          # User used for authentication.
          user = "mail";

          # StartTLS policy when connecting to server.
          # null or one of "OpportunisticStartTLS", "MandatoryStartTLS", "NoStartTLS"
          startTLS_policy = null;

          # Verify SSL for SMTP server.
          skip_verify = false;

          # Password used for authentication. Please note that the contents of this option will end up in a world-readable Nix store. Use the file provider pointing at a reasonably secured file in the local filesystem to work around that. Look at the documentation for details: https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/#file-provider
          password = "";

          # File path to a key file.
          key_file = "$__file{${config.age.secrets.grafana_smtp_password.path}}";

          # Host to connect to.
          host = "localhost:25";

          # Name to be used as client identity for EHLO in SMTP dialog.
          from_name = "Grafana";

          # Address used when sending out emails
          from_address = "admin@grafana.localhost";

          # Whether to enable SMTP
          enabled = true;

          # Name to be used as client identity for EHLO in SMTP dialog
          ehlo_identity = null;

          # File path to a cert file
          cert_file = null;
        };
        server = {
          # Root path for static assets.
          #static_root_path = "${package}/share/grafana/public";

          # Mode where the socket should be set when protocol=socket. Make sure that Grafana process is the file owner before you change this setting.
          socket_mode = "0660";

          # GID where the socket should be set when protocol=socket. Make sure that the target group is in the group of Grafana process and that Grafana process is the file owner before you change this setting. It is recommended to set the gid as http server user gid. Not set when the value is -1.
          socket_gid = -1;

          # Path where the socket should be created when protocol=socket. Make sure that Grafana has appropriate permissions before you change this setting.
          socket = "/run/grafana/grafana.sock";

          # Serve Grafana from subpath specified in the root_url setting. By default it is set to false for compatibility reasons.
          # 
          # By enabling this setting and using a subpath in root_url above, e.g. root_url = "http://localhost:3000/grafana", Grafana is accessible on http://localhost:3000/grafana. If accessed without subpath, Grafana will redirect to an URL with the subpath.
          serve_from_sub_path = false;

          # Set to true for Grafana to log all HTTP requests (not just errors). These are logged as Info level events to the Grafana log.
          router_logging = false;

          # This is the full URL used to access Grafana from a web browser. This is important if you use Google or GitHub OAuth authentication (for the callback URL to be correct).
          # 
          # This setting is also important if you have a reverse proxy in front of Grafana that exposes it through a subpath. In that case add the subpath to the end of this URL setting.
          root_url = "%(protocol)s://%(domain)s:%(http_port)s/";

          # Sets the maximum time using a duration format (5s/5m/5ms) before timing out read of an incoming request and closing idle connections. 0 means there is no timeout for reading the request.
          read_timeout = 0;

          # Which protocol to listen.
          # one of "http", "https", "h2", "socket"
          protocol = "http";

          # Listening port.
          http_port = "3000";

          # Listening address.
          # This setting intentionally varies from upstream’s default to be a bit more secure by default.
          http_addr = "127.0.0.1";

          # Redirect to correct domain if the host header does not match the domain. Prevents DNS rebinding attacks.
          enforce_domain = true;

          # Set this option to true to enable HTTP compression, this can improve transfer speed and bandwidth utilization. It is recommended that most users set it to true. By default it is set to false for compatibility reasons.
          enable_gzip = true;

          # The public facing domain name used to access grafana from a browser.
          # This setting is only used in the default value of the root_url setting. If you set the latter manually, this option does not have to be specified.
          domain = "grafana.emile.space";

          # Path to the certificate key file (if protocol is set to https or h2).
          cert_key = null;

          # Path to the certificate file (if protocol is set to https or h2).
          cert_file = null;

          # Specify a full HTTP URL address to the root of your Grafana CDN assets. Grafana will add edition and version paths.
          # 
          # For example, given a cdn url like https://cdn.myserver.com grafana will try to load a javascript file from http://cdn.myserver.com/grafana-oss/7.4.0/public/build/app.<hash>.js.
          cdn_url = null;
        };

        security = {
          # Set to false to disable the X-XSS-Protection header, which tells browsers to stop pages from loading when they detect reflected cross-site scripting (XSS) attacks.
          x_xss_protection = true;

          # Set to false to disable the X-Content-Type-Options response header. The X-Content-Type-Options response HTTP header is a marker used by the server to indicate that the MIME types advertised in the Content-Type headers should not be changed and be followed.
          x_content_type_options = true;

          # Set to true to enable HSTS includeSubDomains option. Only applied if strict_transport_security is enabled.
          strict_transport_security_subdomains = true;

          # Set to true to enable HSTS preloading option. Only applied if strict_transport_security is enabled.
          strict_transport_security_preload = true;

          # Sets how long a browser should cache HSTS in seconds. Only applied if strict_transport_security is enabled.
          strict_transport_security_max_age_seconds = 86400;

          # Set to true if you want to enable HTTP Strict-Transport-Security (HSTS) response header. Only use this when HTTPS is enabled in your configuration, or when there is another upstream system that ensures your application does HTTPS (like a frontend load balancer). HSTS tells browsers that the site should only be accessed using HTTPS.
          strict_transport_security = true;

          # Secret key used for signing. Please note that the contents of this option will end up in a world-readable Nix store. Use the file provider pointing at a reasonably secured file in the local filesystem to work around that. Look at the documentation for details: https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/#file-provider
          secret_key = "$__file{${config.age.secrets.grafana_secret_key.path}}";

          # Disable creation of admin user on first start of Grafana.
          disable_initial_admin_creation = false;

          # Set to true to disable the use of Gravatar for user profile images.
          disable_gravatar = false;

          # Set to true to disable brute force login protection.
          disable_brute_force_login_protection = false;

          # Define a whitelist of allowed IP addresses or domains, with ports, to be used in data source URLs with the Grafana data source proxy. Format: ip_or_domain:port separated by spaces. PostgreSQL, MySQL, and MSSQL data sources do not use the proxy and are therefore unaffected by this setting.
          data_source_proxy_whitelist = [ ];

          # List of additional allowed URLs to pass by the CSRF check. Suggested when authentication comes from an IdP.
          csrf_trusted_origins = [ ];

          # List of allowed headers to be set by the user. Suggested to use for if authentication lives behind reverse proxies.
          csrf_additional_headers = [ ];

          # Set to true if you host Grafana behind HTTPS.
          cookie_secure = true;

          # Sets the SameSite cookie attribute and prevents the browser from sending this cookie along with cross-site requests. The main goal is to mitigate the risk of cross-origin information leakage. This setting also provides some protection against cross-site request forgery attacks (CSRF), read more about SameSite here. Using value disabled does not add any SameSite attribute to cookies.
          # one of "lax", "strict", "none", "disabled"
          cookie_samesite = "strict";

          # Set to true to add the Content-Security-Policy-Report-Only header to your requests. CSP in Report Only mode enables you to experiment with policies by monitoring their effects without enforcing them. You can enable both policies simultaneously.
          content_security_policy_report_only = false;

          # Set to true to add the Content-Security-Policy header to your requests. CSP allows to control resources that the user agent can load and helps prevent XSS attacks.
          content_security_policy = true;

          # When false, the HTTP header X-Frame-Options: deny will be set in Grafana HTTP responses which will instruct browsers to not allow rendering Grafana in a <frame>, <iframe>, <embed> or <object>. The main goal is to mitigate the risk of Clickjacking.
          allow_embedding = false;

          # Default admin username.
          admin_user = "admin";

          # Default admin password. Please note that the contents of this option will end up in a world-readable Nix store. Use the file provider pointing at a reasonably secured file in the local filesystem to work around that. Look at the documentation for details: https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/#file-provider
          admin_password = "$__file{${config.age.secrets.grafana_admin_password.path}}";

          # The email of the default Grafana Admin, created on startup.
          admin_email = "admin@emile.space";
        };

        paths = {
          # Folder that contains provisioning config files that grafana will apply on startup and while running. Don’t change the value of this option if you are planning to use services.grafana.provision options.
          # provisioning = ...

          # Directory where grafana will automatically scan and look for plugins
          plugins = "${cfg.dataDir}/plugins";
        };

        database = {

          # For sqlite3 only. Setting to enable/disable Write-Ahead Logging.
          # https://sqlite.org/wal.html
          wal = false;

          # The database user (not applicable for sqlite3).
          user = "root";

          # Database type.
          # one of "mysql", "sqlite3", "postgres"
          type = "sqlite3";

          # This setting applies to sqlite3 only and controls the number of times the system retries a transaction when the database is locked.
          transaction_retries = 5;

          # For Postgres, use either disable, require or verify-full. For MySQL, use either true, false, or skip-verify.
          # one of "disable", "require", "verify-full", "true", "false", "skip-verify"
          ssl_mode = "disable";

          # The common name field of the certificate used by the mysql or postgres server. Not necessary if ssl_mode is set to skip-verify.
          server_cert_name = null;

          # This setting applies to sqlite3 only and controls the number of times the system retries a query when the database is locked.
          query_retries = 0;

          # Only applicable to sqlite3 database. The file path where the database will be stored.
          path = "${config.services.grafana.dataDir}/data/grafana.db";

          # The database user’s password (not applicable for sqlite3).
          # Please note that the contents of this option will end up in a world-readable Nix store. Use the file provider pointing at a reasonably secured file in the local filesystem to work around that. Look at the documentation for details: https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/#file-provider
          password = "$__file{${config.age.secrets.grafana_database_password.path}}";

          # The name of the Grafana database.
          name = "grafana";

          # The maximum number of open connections to the database.
          # 0 = unlimited (I'm just assuming this, everything else would be weird)
          max_open_conn = 0;

          # The maximum number of connections in the idle connection pool.
          max_idle_conn = 2;

          # Set to true to log the sql calls and execution times
          log_queries = false;

          # For mysql, if the migrationLocking feature toggle is set, specify the time (in seconds) to wait before failing to lock the database for the migrations.
          locking_attempt_timeout_sec = 0;

          # Only the MySQL driver supports isolation levels in Grafana. In case the value is empty, the driver’s default isolation level is applied.
          # null or one of "READ-UNCOMMITTED", "READ-COMMITTED", "REPEATABLE-READ", "SERIALIZABLE"
          isolation_level = null;

          # Only applicable to MySQL or Postgres. Includes IP or hostname and port or in case of Unix sockets the path to it. For example, for MySQL running on the same host as Grafana: host = "127.0.0.1:3306" or with Unix sockets: host = "/var/run/mysqld/mysqld.sock"
          host = "127.0.0.1:3306";

          # Sets the maximum amount of time a connection may be reused. The default is 14400 (which means 14400 seconds or 4 hours). For MySQL, this setting should be shorter than the wait_timeout variable.
          conn_max_lifetime = 14400;

          # The path to the client key. Only if server requires client authentication.
          client_key_path = null;

          # The path to the client cert. Only if server requires client authentication.
          client_cert_path = null;

          # For sqlite3 only. Shared cache setting used for connecting to the database.
          # one of "private", "shared"
          cache_mode = "private";

          # The path to the CA certificate to use.
          ca_cert_path = null;
        };

        analytics = {
          # When enabled Grafana will send anonymous usage statistics to stats.grafana.org. No IP addresses are being tracked, only simple counters to track running instances, versions, dashboard and error counts. Counters are sent every 24 hours.
          reporting_enabled = true;

          # Set to false to remove all feedback links from the UI.
          feedback_links_enabled = true;

          # When set to false, disables checking for new versions of Grafana from Grafana’s GitHub repository. When enabled, the check for a new version runs every 10 minutes. It will notify, via the UI, when a new version is available. The check itself will not prompt any auto-updates of the Grafana software, nor will it send any sensitive information.
          check_for_updates = true;

          # When set to false, disables checking for new versions of installed plugins from https://grafana.com. When enabled, the check for a new plugin runs every 10 minutes. It will notify, via the UI, when a new plugin update exists. The check itself will not prompt any auto-updates of the plugin, nor will it send any sensitive information.
          # check_for_plugin_updates = ...
        };
      };

      #provision = {
      #  notifiers.*.uid
      #  notifiers.*.type
      #  notifiers.*.settings
      #  notifiers.*.send_reminder
      #  notifiers.*.secure_settings
      #  notifiers.*.org_name
      #  notifiers.*.org_id
      #  notifiers.*.name
      #  notifiers.*.is_default
      #  notifiers.*.frequency
      #  notifiers.*.disable_resolve_message
      #  notifiers
      #  enable
      #  datasources.settings.deleteDatasources.*.orgId
      #  datasources.settings.deleteDatasources.*.name
      #  datasources.settings.deleteDatasources
      #  datasources.settings.datasources.*.url
      #  datasources.settings.datasources.*.uid
      #  datasources.settings.datasources.*.type
      #  datasources.settings.datasources.*.secureJsonData
      #  datasources.settings.datasources.*.name
      #  datasources.settings.datasources.*.jsonData
      #  datasources.settings.datasources.*.editable
      #  datasources.settings.datasources.*.access
      #  datasources.settings.datasources
      #  datasources.settings.apiVersion
      #  datasources.settings
      #  datasources.path
      #  datasources
      #  dashboards.settings.providers.*.type
      #  dashboards.settings.providers.*.options.path
      #  dashboards.settings.providers.*.name
      #  dashboards.settings.providers
      #  dashboards.settings.apiVersion
      #  dashboards.settings
      #  dashboards.path
      #  dashboards
      #  alerting.templates.settings.templates.*.template
      #  alerting.templates.settings.templates.*.name
      #  alerting.templates.settings.templates
      #  alerting.templates.settings.deleteTemplates.*.orgId
      #  alerting.templates.settings.deleteTemplates.*.name
      #  alerting.templates.settings.deleteTemplates
      #  alerting.templates.settings.apiVersion
      #  alerting.templates.settings
      #  alerting.templates.path
      #  alerting.rules.settings.groups.*.name
      #  alerting.rules.settings.groups.*.interval
      #  alerting.rules.settings.groups.*.folder
      #  alerting.rules.settings.groups
      #  alerting.rules.settings.deleteRules.*.uid
      #  alerting.rules.settings.deleteRules.*.orgId
      #  alerting.rules.settings.deleteRules
      #  alerting.rules.settings.apiVersion
      #  alerting.rules.settings
      #  alerting.rules.path
      #  alerting.policies.settings.resetPolicies
      #  alerting.policies.settings.policies
      #  alerting.policies.settings.apiVersion
      #  alerting.policies.settings
      #  alerting.policies.path
      #  alerting.muteTimings.settings.muteTimes.*.name
      #  alerting.muteTimings.settings.muteTimes
      #  alerting.muteTimings.settings.deleteMuteTimes.*.orgId
      #  alerting.muteTimings.settings.deleteMuteTimes.*.name
      #  alerting.muteTimings.settings.deleteMuteTimes
      #  alerting.muteTimings.settings.apiVersion
      #  alerting.muteTimings.settings
      #  alerting.muteTimings.path
      #  alerting.contactPoints.settings.deleteContactPoints.*.uid
      #  alerting.contactPoints.settings.deleteContactPoints.*.orgId
      #  alerting.contactPoints.settings.deleteContactPoints
      #  alerting.contactPoints.settings.contactPoints.*.name
      #  alerting.contactPoints.settings.contactPoints
      #  alerting.contactPoints.settings.apiVersion
      #  alerting.contactPoints.settings
      #  alerting.contactPoints.path
      #};

      #services.grafana-agent.enable
      #services.grafana_reporter.port
      #services.grafana_reporter.addr
      #services.grafana-agent.package
      #services.grafana-agent.settings
      #services.grafana_reporter.enable
      #services.grafana-agent.extraFlags
      #services.grafana-agent.credentials
      #services.grafana_reporter.templateDir
      #services.grafana_reporter.grafana.port
      #services.grafana_reporter.grafana.addr
      #services.grafana-image-renderer.enable
      #services.grafana-image-renderer.verbose
      #services.grafana-image-renderer.settings
      #services.grafana-image-renderer.chromium
      #services.grafana_reporter.grafana.protocol
      #services.grafana-image-renderer.provisionGrafana
      #services.grafana-image-renderer.settings.service.port
      #services.grafana-image-renderer.settings.service.logging.level
      #services.grafana-image-renderer.settings.rendering.width
      #services.grafana-image-renderer.settings.rendering.mode
      #services.grafana-image-renderer.settings.rendering.height
      #services.grafana-image-renderer.settings.rendering.args
    };
  };

}
