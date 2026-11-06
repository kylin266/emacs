# emacs

My Emacs for DevOps work: Kubernetes, Terraform, AWS, Ansible, shell, Go, and a
set of runnable org playbooks so the routine checks are one keypress away. The
2023 version of this repo was an `elpa/` dump (evil, helm, magit, kubel, docker,
yaml-mode); this is the rewrite on Emacs 31 with vanilla `package.el` and
`use-package`, no framework.

## Install

```sh
brew install --cask emacs-app                 # universal GNU Emacs from emacsformacosx.com
brew install terraform-ls shellcheck shfmt jq
brew install --cask font-jetbrains-mono-nerd-font
npm i -g yaml-language-server bash-language-server @ansible/ansible-language-server dockerfile-language-server-nodejs
go install golang.org/x/tools/gopls@latest
git clone https://github.com/kylin266/emacs.git ~/.emacs.d
ln -sf /Applications/Emacs.app/Contents/MacOS/Emacs /usr/local/bin/emacs
ln -sf /Applications/Emacs.app/Contents/MacOS/bin/emacsclient /usr/local/bin/emacsclient
emacs   # first start installs packages; then M-x my/install-treesit-grammars
```

Why the cask and not a Homebrew formula: this Mac runs Intel Homebrew under
Rosetta, and a formula build links against Homebrew's libraries, which is how
the previous install broke (`libxml2.2.dylib` missing after an upgrade). The
cask is a self-contained universal binary; Emacs runs native arm64.

## Layout

- `early-init.el`, `init.el` load `lisp/my-*.el` in order.
- `lisp/my-core.el` packages, PATH from zsh, defaults. `my-ui.el` doom-one, JetBrains Mono Nerd Font, doom-modeline.
- `lisp/my-evil.el` evil everywhere, `SPC` leader via general. `my-completion.el` vertico, orderless, consult, embark, corfu, yasnippet.
- `lisp/my-lang.el` tree-sitter modes, eglot per language, yaml-mode with Kubernetes and schemastore schemas, terraform-mode, ansible, apheleia formatting.
- `lisp/my-devops.el` kubel, docker, kube context and AWS profile switchers (shown in the modeline), `kubectl apply/diff/dry-run` on the current buffer, TRAMP, ssh helpers, eat terminal.
- `lisp/my-playbooks.el` the playbook runner. `lisp/my-ai.el` Claude Code in a terminal next to the code, gptel for in-buffer chat.
- `lisp/my-keys.el` the whole leader map in one file. `lisp/local.el` (git-ignored, see `local.el.example`) for machine-specific bits.
- `playbooks/` runnable org runbooks, see its README. `playbooks/local/` is git-ignored.
- `snippets/` yasnippet: `deploy`, `svc`, `ing`, `cron`, `schema`, `job` in YAML; `res`, `var`, `mod` in Terraform; `strict` in shell.

## Keys worth knowing

`SPC` is the leader; `which-key` shows the rest after a short pause.

- `SPC o p` open a playbook, `SPC o P` new one from the template. In a playbook: `, e` run block, `, a` run file, `, c` clear results, `, y` copy the command.
- `SPC o k` kubel, `SPC o K` switch kube context, `SPC o a` set AWS_PROFILE, `SPC o d` docker, `SPC o t` terminal, `SPC o s` ssh to a host from `~/.ssh/config`.
- `SPC k d` / `SPC k D` / `SPC k a` kubectl dry-run / diff / apply the YAML buffer (apply and delete ask, and name the context).
- `SPC o c` Claude Code beside the code, `SPC a s` send it a prompt, `SPC a f` fix the error at point. `SPC o g` gptel chat.
- `SPC g g` magit, `SPC p p` projects, `SPC /` ripgrep the project, `SPC c a` code action, `SPC c r` rename, `SPC c x` diagnostics.
- `s-p` find file in project, `s-F` ripgrep, `s-b` buffers, `s-s` save.

## LLM

Claude Code runs through `bin/claude`, which sets a separate `CLAUDE_CONFIG_DIR`
when the buffer is inside a client workspace that must stay isolated (the same
rule as the `claude` function in `~/.zshrc`). gptel reads its key from
`~/.authinfo.gpg` (`machine api.anthropic.com login apikey password ...`); a
LiteLLM gateway for client work goes in `lisp/local.el`.

## Playbooks and client data

Nothing client-specific is committed. Generic playbooks use the active kube
context and `AWS_PROFILE`; the ones with real cluster names and account ids live in
`playbooks/local/` or in a `playbooks/` folder inside the client workspace, added
to `my/playbook-dirs` from `lisp/local.el`.
