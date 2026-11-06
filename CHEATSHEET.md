# Emacs cheat sheet (DevOps config)

Vim keys everywhere (evil). `SPC` is the leader in normal mode; pause after it and `which-key`
lists the next keys. `,` is the local leader (per file type). `ESC` always gets you back to
normal mode, `C-g` cancels whatever Emacs is doing.

```
  SPC ─┬─ f  files        ─┬─ o  open: playbook, kubel, docker, terminal, ssh, claude
       ├─ b  buffers      ├─ k  kubectl on this YAML
       ├─ w  windows      ├─ c  code: LSP actions, rename, diagnostics
       ├─ p  project      ├─ a  AI: claude-code, gptel
       ├─ s  search       ├─ g  git (magit)
       ├─ n  notes (org)  ├─ h  help
       └─ t  toggles      └─ q  quit / restart
   ,  ── local leader: in org = run blocks; in YAML = kubectl; in Terraform = fmt/plan
```

## Panic buttons

- `ESC` back to normal mode. `C-g` cancel command / minibuffer.
- `SPC q q` quit Emacs (asks). `SPC q r` restart Emacs.
- `:q` close window, `:wq` save and close, `:e!` reload file from disk.
- `u` undo, `C-r` redo, `SPC b u` undo tree (vundo).
- `SPC h k` then press a key to learn what it does. `SPC h f` describe a function.

## Vim refresher (evil)

- Modes: `i` insert, `v` visual, `V` line visual, `C-v` block visual, `ESC` normal.
- Move: `h j k l`, `w b e` words, `0 ^ $` line, `gg G` file, `%` matching paren, `C-u C-d` half page.
- Jump: `*` word under cursor, `/text` search then `n N`, `gd` definition (LSP), `C-o` back, `C-i` forward.
- Edit: `x` delete char, `dd` line, `dw` word, `D` to end, `cc` change line, `ciw` change word, `yy` copy line, `p P` paste.
- Text objects: `ci"` inside quotes, `ca(` around parens, `cit` inside tag, `dap` paragraph.
- Surround: `ysiw"` wrap word in quotes, `cs"'` change quotes, `ds"` delete them.
- Comment: `gcc` line, `gc` + motion (e.g. `gcap` paragraph).
- Numbers: `g +` / `g -` increment and decrement the number under cursor.
- Repeat: `.` repeats last change. `qa ... q` record macro `a`, `@a` play it.
- Replace: `:%s/old/new/g` whole file, `:'<,'>s/old/new/g` in selection.
- Windows from normal mode: `C-h C-j C-k C-l` move between windows.

## Files, buffers, windows

- `SPC .` or `SPC f f` open file. `SPC f r` recent files. `SPC f s` save. `SPC f S` save as.
- `SPC f d` dired here. `SPC f y` copy file path. `SPC f R` rename. `SPC f D` delete.
- `SPC f e` open init.el, `SPC f l` local.el, `SPC f p` any file of the Emacs config.
- `SPC ,` or `SPC b b` switch buffer. `SPC b d` kill buffer. `SPC b n` / `SPC b p` next / previous.
- `` SPC ` `` last buffer. `SPC x` scratch buffer (org).
- `SPC w v` split right, `SPC w s` split below, `SPC w d` close window, `SPC w m` maximise.
- `SPC w h j k l` focus window, `SPC w H J K L` move the window, `SPC w =` balance.
- `SPC w u` undo window layout change.
- Dired: `RET` open, `-` go up, `m` mark, `d` flag delete, `x` execute, `C` copy, `R` rename, `+` new dir, `g` refresh.

## Projects and search

- `SPC p p` switch project (then `f` file, `g` grep, `m` magit, `t` terminal).
- `SPC p f` or `s-p` file in project. `SPC p b` project buffers.
- `SPC /` or `SPC p s` or `s-F` ripgrep the project. `SPC s d` ripgrep a directory.
- `SPC s s` search lines in this buffer. `SPC s i` symbols / headings (imenu). `SPC s o` outline.
- `SPC s f` find file by name (fd). `SPC s y` paste from kill ring history.
- In any list: type several words in any order to filter. `C-.` on a candidate opens actions (embark).
- `<` then a letter narrows consult lists (e.g. `< b` buffers only).

## Playbooks (org runbooks)

- `SPC o p` open a playbook. `SPC o P` new one from the template.
- `, e` or `C-c C-c` run the block under cursor. `, a` run the whole file (asks). `, s` run this heading.
- `, c` clear all results. `, y` copy the block's command. `, n` / `, p` next / previous block.
- `, '` edit the block in its own shell buffer (`C-c C-c` to come back).
- `TAB` fold / unfold a heading. `S-TAB` cycle the whole file.
- Set the identities once at the top of the file: `#+PROPERTY: header-args:sh :var P1="profile"`.
- Shell blocks in playbook folders run without the "evaluate?" prompt. Anywhere else org still asks.
- Where they live: generic ones in `~/.emacs.d/playbooks/`, anything with real cluster names or account ids in `playbooks/local/` or a client workspace folder listed in `lisp/local.el` (both never committed).

## Kubernetes and AWS

- `SPC o K` switch kubectl context (global, same as the shell). `SPC o a` set AWS_PROFILE for this Emacs. Both show in the modeline.
- `SPC o k` kubel: `C-c C-n` namespace, `C-c C-c` context, `r` resource type, `RET` describe, `l` logs, `e` edit, `k` delete, `g` refresh, `f` filter, `E` exec shell.
- On a YAML buffer: `SPC k d` apply dry-run on server, `SPC k D` diff, `SPC k a` apply (asks, names context), `SPC k x` delete (asks).
- Same under the local leader: `, d`, `, D`, `, a`.
- YAML snippets: type `deploy`, `svc`, `ing`, `cron`, `job` then `TAB`. `schema` inserts the schema comment for the language server.
- `SPC o d` docker: `i` images, `c` containers, `v` volumes, `n` networks, `?` all commands.

## Terraform, shell, Go

- Terraform: `, f` fmt, `, i` init, `, v` validate, `, p` plan without lock. Format on save is on.
- Snippets: `res`, `var`, `mod` then `TAB`. Shell: `strict` inserts the strict-mode header.
- Shellcheck runs on every shell file; `SPC c x` lists the problems, `SPC c n` / `SPC c p` jump.
- `SPC c c` compile (prompts for a command), `SPC c C` re-run the last one. `g r` in the compile buffer re-runs.

## LSP (eglot) in any supported file

- `K` or `SPC c h` documentation at point. `gd` / `SPC c d` definition, `SPC c D` references, `SPC c b` back.
- `SPC c a` code action, `SPC c r` rename, `SPC c f` format buffer, `SPC c j` symbols in file.
- `SPC c x` diagnostics list. `SPC c s` start server, `SPC c S` stop, `SPC c R` reconnect.
- Completion pops up while typing: `TAB` / `S-TAB` cycle, `RET` accept, `C-g` dismiss.

## Git (magit)

- `SPC g g` status. In status: `s` stage, `u` unstage, `S` stage all, `c c` commit (write message, `C-c C-c` to finish, `C-c C-k` abort).
- `P p` push, `F p` pull, `f f` fetch, `b b` switch branch, `b c` new branch, `z z` stash, `k` discard, `TAB` expand a diff, `g` refresh, `q` quit.
- `SPC g l` log, `SPC g b` blame, `SPC g d` diff this file, `SPC g t` time machine (`p` / `n` through versions).
- `SPC g n` / `SPC g p` next / previous change in the buffer, `SPC g r` revert that hunk.
- `SPC g o` open this line on GitHub / GitLab, `SPC g y` copy that link.

## Remote hosts and terminals

- `SPC o s` ssh into a host from `~/.ssh/config` (terminal). `SPC o S` browse a host's files (dired over TRAMP).
- Open any remote file: `SPC f f` then `/ssh:host:/etc/nginx/nginx.conf`. Sudo on remote: `/ssh:host|sudo::/etc/...`.
- `SPC o t` terminal here, `SPC p t` terminal at project root, `SPC o e` eshell.
- `SPC o t` terminal (vterm, same as Ghostty: colours, mouse, Shift+Tab), `SPC o T` at the project root.
- In the terminal keys go to the shell. `C-c C-e` copy mode (select with `v`, `y` copies, `q` back), `s-v` paste, `s-o` or `C-x o` jump to another pane. `C-c C-t` in vterm also toggles copy mode.

## AI, when you want it

- `SPC o c` toggle Claude Code beside the code (project root, same login as the terminal; Shift+Tab cycles permission mode, `ESC` interrupts).
- `SPC a s` send a prompt with the current file and line as context. Select with `v` then `SPC a r` sends the region.
- `SPC a f` ask Claude Code to fix the error under cursor. `SPC a k` kill the session.
- Inside a client workspace Claude Code runs with its own config dir (`bin/claude-env.local`), as in the shell.
- `SPC o g` gptel chat buffer (needs a key in `~/.authinfo.gpg`), `SPC a R` rewrite the selection, `SPC a m` the gptel menu.

## Org notes

- `SPC n n` inbox, `SPC n f` find a note, `SPC n s` search notes, `SPC n a` agenda.
- `, t` cycle TODO state. `M-RET` new heading, `M-h/l` promote / demote, `M-j/k` move heading.
- `C-c C-l` insert link, `RET` follows a link. `<sh TAB` inserts a shell block, `<y TAB` YAML, `<tf TAB` Terraform.

## Daemon and client

- `ec` new frame, `ec file` open in the current frame, `ec -t file` in the terminal, `ec -w file` wait (EDITOR).
- Closing the last frame (`SPC q q` in a client frame) keeps the daemon; next `ec` is instant.
- Restart the daemon after config changes: `launchctl kickstart -k gui/$(id -u)/org.gnu.emacs.daemon`.
- Logs: `~/Library/Logs/emacs-daemon.log`. Never launch Emacs from the Dock while the daemon runs.

## Toggles and help

- HTML file: `, p` open in browser, `, e` render in eww. Any HTML: `M-x eww-open-file`.
- Markdown: `, l` live preview, `, p` preview in browser, `, e` export HTML, `, t` table of contents.
- `SPC t l` line numbers, `SPC t w` wrap, `SPC t z` fullscreen, `SPC t t` pick a theme, `SPC t r` read-only.
- `s-=` / `s--` zoom text, `s-0` reset. `s-s` save, `s-w` close buffer, `s-b` buffers.
- `SPC h k` what does this key do, `SPC h f` function, `SPC h v` variable, `SPC h m` this mode's keys, `SPC h b` all bindings here.
- Something looks broken after an update: `SPC q r` restart, then `M-x my/install-treesit-grammars` if syntax colours are off.
