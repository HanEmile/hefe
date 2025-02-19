
{
  services.authelia.instances.main.settings.identity_providers.oidc.clients = [
    {
      id = "goapp";

      # ; nix run nixpkgs#authelia -- crypto hash generate pbkdf2 --variant sha512 --random --random.length 72 --random.charset rfc3986
      secret = "$pbkdf2-sha512$310000$WUai4pp1ZVJDrJ8j6ICLiQ$NOMMaCZ3gt.x.a09MWatMkJWQIaH0QeWgRXSbuD2iWRwR.N6MWmJA6QO.LIKcxn6l.zHZN4bO1Ztsrbo9010Tw";
      public = false;
      authorization_policy = "two_factor";
      redirect_uris = [ "https://127.0.0.1:8080/auth/oauth2/callback" ];
      scopes = [
        "openid"
        "email"
        "profile"
      ];
      grant_types = [
        "refresh_token"
        "authorization_code"
      ];
      response_types = [ "code" ];
      response_modes = [
        "form_post"
        "query"
        "fragment"
      ];
      token_endpoint_auth_method = "client_secret_post";
    }
  ];
}
