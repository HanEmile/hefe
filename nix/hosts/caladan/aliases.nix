{
  ":q" = "exit";
  ls = "eza";
  ytop = "btm";

  # short forms
  tf = "terraform";
  h = "mosh hack";

  r2help = ''r2 -qq -c "?*~..." --'';
  mosh = "mosh --no-init";
  t = "task";
  tw = "timew";

  ipa = "scutil --nwi";

  # this can be super nice and super annoying at the same time:
  # ssh = "kitty +kitten ssh";

  light = "kitty +kitten themes --reload-in=all Ayu Light";
  dark = "kitty +kitten themes --reload-in=all Ayu";


  ".." = "cd ..";
  "..." = "cd ../..";
  "...." = "cd ../../..";
  "....." = "cd ../../../..";

  grep = "grep --color=auto";
  nix-stray-roots = ''
    nix-store --gc --print-roots | egrep -v "^(/nix/var|/run/w+-system|{memory)"'';

  holdmybeer = "sudo ";

  servethis = "python3 -m http.server";

  # nmap foo
  nmap_open_ports = "nmap --open";
  nmap_list_interfaces = "nmap --iflist";
  nmap_slow = "sudo nmap -sS -v -T1";
  nmap_fin = "sudo nmap -sF -v";
  nmap_full = "sudo nmap -sS -T4 -PE -PP -PS80,443 -PY -g 53 -A -p1-65535 -v";
  nmap_check_for_firewall = "sudo nmap -sA -p1-65535 -v -T4";
  nmap_ping_through_firewall = "nmap -PS -PA";
  nmap_fast = "nmap -F -T5 --version-light --top-ports 300";
  nmap_detect_versions = "sudo nmap -sV -p1-65535 -O --osscan-guess -T4 -Pn";
  nmap_check_for_vulns = "nmap --script = vuln";
  nmap_full_udp = "sudo nmap -sS -sU -T4 -A -v -PE -PS22,25,80 -PA21,23,80,443,3389 ";
  nmap_traceroute = "sudo nmap -sP -PE -PS22,25,80 -PA21,23,80,3389 -PU -PO --traceroute ";
  nmap_full_with_scripts = "sudo nmap -sS -sU -T4 -A -v -PE -PP -PS21,22,23,25,80,113,31339 -PA80,113,443,10042 -PO --script all " ;
  nmap_web_safe_osscan = "sudo nmap -p 80,443 -O -v --osscan-guess --fuzzy ";
  nmap_ping_scan = "nmap -n -sP";
}
