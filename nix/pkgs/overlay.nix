final: prev: {
  vokobe = final.callPackage ./vokobe { inherit (final) naersk; };
  r2wars-web = final.callPackage ./r2wars-web { };
  remarvin = final.callPackage ./remarvin { };

  pretalx_old = prev.pretalx.overrideAttrs ( old: {
    version = "2024.1.0";
  });
}
