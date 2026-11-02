# D02 — The ghost file

| Domain | Difficulty | Plan week | Skills |
|--------|-----------|-----------|--------|
| Docker | ★★☆ | Nov 6 – 12 | shebang, `cat -A` / `file` / `od -c`, CRLF vs LF, `.gitattributes` |

## Story
After a colleague's commit, the container refuses to start:
`exec /entrypoint.sh: no such file or directory`.
But `/entrypoint.sh` is clearly in the image, with the right permissions. Nobody touched the Dockerfile.

## Symptoms
```bash
docker run --rm tshoot/d02                                         # exec /entrypoint.sh: no such file or directory
docker run --rm --entrypoint ls tshoot/d02 -l /entrypoint.sh        # -rwxr-xr-x ... /entrypoint.sh  (!?)
```

## Your mission
1. Explain which file is really "not found" (it is not `/entrypoint.sh`).
2. Fix `app/entrypoint.sh`, then make sure it **can never happen again** in this repo.

## Commands
```bash
./break.sh   |   ./check.sh   |   ./reset.sh
```

<details><summary>Hint 1</summary><code>head -1 app/entrypoint.sh | od -c</code> — read every character of the first line.</details>
<details><summary>Hint 2</summary>When the kernel runs a script, it reads the <code>#!</code> line and runs that interpreter path, character for character.</details>

## Debrief
1. Why does the error say "no such file or directory" and not "bad interpreter"?
2. Name two ways to prevent it at repo level (one in git, one in CI).
3. You work in WSL2 but your editor may be on Windows: which setting do you check in VS Code?
