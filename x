autom4te -l m4sh - <<'END' >x.sh && chmod +x x.sh && ./x.sh
AS_INIT
AS_ME_PREPARE
AS_INIT_GENERATED([x2.sh],[@%:@ hi, is this shorter]) || { AS_ECHO(["Failed to create child script"]); AS_EXIT; }
AS_ECHO("$as_myself")
cat >> "x2.sh" <<\__EOF__
AS_ECHO("$as_myself")
__EOF__
END


autom4te -l m4sh - <<'END' >x.sh && chmod +x x.sh && ./x.sh
AS_INIT
[chn5=27
chn=5]
AS_VAR_ARITH([[xx]],[[chn + 1]])
AS_ECHO([["$xx,$chn"]])
END
