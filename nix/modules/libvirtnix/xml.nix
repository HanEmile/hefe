{ lib, ... }:

# takes a few args and creats a valid xml tag pair out of it
#
# testTag = mkTag {
#   name = "name";
#   args = [
#     {
#       key = "arg1";
#       val = "arg1val";
#     }
#     {
#       key = "arg2";
#       val = "arg2val";
#     }
#   ];
#   value = "qwe";
#   children = [
#     (mkTag { name = "nested"; args = []; value = "qwe"; children = [];})
#   ];
# };
#
# <name arg1=arg1val arg2=arg2val>
#   value
#   {children}
# </name>
{
  name, # name of the tag to be used, such as `secret`, `description`, ...
  args ? [ ], # args, [ { key="a"; val="b"; } { key="c"; val="d"; } ]
  value ? "", # the value to place in the middle
  children ? [ ], # the child elements
  closing ? true, # add a closing tag
}:
let
  args_str =
    " " + lib.strings.concatStrings (lib.strings.intersperse " " (map (x: "${x.key}='${x.val}'") args));
  child_evaled = lib.strings.concatStrings children;

  cond = condition: value: if condition then value else "";

  closingTag = if closing == true then "</${name}>" else "";
in
"<${name}${
  lib.optionalString (args != [ ]) args_str
}${cond (closing == false) "/"}>${value}${child_evaled}${lib.optionalString (closing) closingTag}"
