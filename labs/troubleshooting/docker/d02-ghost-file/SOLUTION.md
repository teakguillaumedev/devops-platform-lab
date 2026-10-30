# D02 — Solution

**Root cause:** `entrypoint.sh` has Windows line endings (CRLF). The first line is `#!/bin/sh\r`. The kernel looks for an
interpreter literally named `/bin/sh\r`, which does not exist → `ENOENT` → *no such file or directory*.

**Diagnosis**
```bash
head -1 app/entrypoint.sh | od -c     # # ! / b i n / s h \r \n
file app/entrypoint.sh                # ... with CRLF line terminators
cat -A app/entrypoint.sh | head -2    # lines end with ^M$
```

**Fix:** `sed -i 's/\r$//' app/entrypoint.sh` (or `dos2unix`). Never again:
```gitattributes
# .gitattributes at repo root
*.sh text eol=lf
```
plus a CI check (`shellcheck`, or `! grep -rl $'\r' --include='*.sh' .`), and `"files.eol": "\n"` in VS Code.

**Debrief**
1. `execve()` returns ENOENT for the interpreter, and the shell/Docker reports it against the script name.
2. `.gitattributes eol=lf` + a CI lint (shellcheck / pre-commit `mixed-line-ending`).
3. VS Code status bar "CRLF/LF", `files.eol`; also `git config core.autocrlf` on the Windows side.
