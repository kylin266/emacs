# Playbooks

Each `.org` file here is a runbook whose shell blocks run in place: open it with
`SPC o p`, put the cursor on a block and press `, e` (or `C-c C-c`). Results
appear under the block, so the file is both the procedure and the last reading.
`, a` runs the whole file, `, c` clears every result, `, y` copies a block's
command to paste in a terminal or a chat, `, k` kills a runaway run, `, r` writes a
report page (`runs/<date>-<name>.org`, git-ignored) with findings first and opens it beside.

Blocks run in a background bash session (`:session … :async yes` in the file's
`#+PROPERTY` line), so Emacs stays usable while a slow check runs; the result
lands when it finishes. Because the session persists, never `exit` inside a
block (use a function and `return`), and shell functions defined by one block
stay available to the next.

Shell blocks inside a playbook directory run without the "evaluate?" prompt.
Anything else in org still asks.

Layout:

- `_template.org` is what `SPC o P` (new playbook) copies.
- Files starting with `_` are helper libraries: their named blocks are loaded
  when you open a playbook and can be pulled into any block with `<<name>>`.
- `k8s-cluster-health.org` and `aws-account-check.org` are generic. They use whatever
  `kubectl` context and `AWS_PROFILE` are active (`SPC o K`, `SPC o a`).
- `local/` is git-ignored. Client-specific playbooks with real cluster names,
  account ids or hostnames go there, or in a playbook folder inside the client's
  own workspace (added to `my/playbook-dirs` in `lisp/local.el`).

Blocks take `:var` headers, so a file can pin its identities once at the top:

```org
#+PROPERTY: header-args:bash :results output verbatim :var P="my-aws-profile" R="eu-west-3"
```

and every block then uses `aws --profile $P --region $R ...`.
