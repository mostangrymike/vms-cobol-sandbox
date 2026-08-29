# vms-wc-cobol

Minimal Unix-style `wc` implementation in VSI COBOL for OpenVMS.

## Platform

Accepted on OpenVMS V9.2-3 x86-64 with VSI COBOL V3.4-3.

## Build

```text
$ COBOL WC.COB
$ LINK WC
$ WC :== $SYS$SYSDEVICE:[path]WC.EXE
```

## Supported behavior

- line, word, and byte counts
- `-l`, `-w`, and `-c`, including combined options
- one or more file arguments
- totals for multiple files
- `SYS$INPUT` when no file argument is supplied

For OpenVMS RMS text files, byte counts use logical POSIX-stream semantics: record data bytes plus one LF byte per input record.

`WC.COB` is the exact source accepted by the native OpenVMS compiler, linker, and runtime tests during the M287 OVMS Agent multi-language campaign.
