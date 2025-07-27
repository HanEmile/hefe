final: prev: {
  vokobe = final.callPackage ./vokobe { inherit (final) naersk; };
  r2wars-web = final.callPackage ./r2wars-web { };
  # remarvin = final.callPackage ./remarvin { };
  # libc-database = final.callPackage ./libc-database {};
  # glibc-all-in-one = final.callPackage ./glibc-all-in-one { };
}
