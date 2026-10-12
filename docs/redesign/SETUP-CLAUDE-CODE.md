# Moving to Claude Code in VS Code

## 1. Install (once)

1. VS Code 1.94 or newer.
2. Git (on Windows also install Git for Windows: https://git-scm.com/downloads/win).
3. Claude Code extension: in VS Code press `Ctrl+Shift+X` (`Cmd+Shift+X` on
   Mac), search **Claude Code** (publisher Anthropic), click **Install**.
4. Optional, for the terminal: install the Claude Code CLI
   - macOS / Linux / WSL: `curl -fsSL https://claude.ai/install.sh | bash`
   - Windows PowerShell: `irm https://claude.ai/install.ps1 | iex`
5. Sign in with your Claude account the first time you open the panel
   (Pro, Max, Team or Enterprise plan; the free plan doesn't include Claude Code).

Docs: https://code.claude.com/docs/en/vs-code

## 2. Get the fork

```sh
git clone https://github.com/pubfx/vlc.git
cd vlc
git checkout redesign/phase1
code .
```

On Windows, clone it **inside WSL** (Ubuntu) and run `code .` there, so
Claude Code and the build use the same Linux tools. See `BUILD.md`.

## 3. Connect Figma

The repo's `.mcp.json` already lists Figma's server. In the Claude Code
panel, type `/mcp`, approve the **figma** server, choose it, and sign in to
Figma in the browser.

CLI alternative: `claude mcp add --transport http figma https://mcp.figma.com/mcp`
then `/mcp` to sign in.

## 4. First prompt to give Claude Code

> Read CLAUDE.md and docs/redesign/. Set up a development build of this fork
> following docs/redesign/BUILD.md for my OS, build the redesign/phase1
> branch, run it with a test video, and fix anything that fails to compile or
> shows QML errors. Then compare the player against Figma frame 247:445 and
> list any differences.

## 5. Then, phase by phase

> Create branch redesign/phase2 from redesign/phase1 and implement
> SPEC.md §2 (quick access). Check the Figma frames listed for it, build and
> run after each change, and commit small steps.

Push with `git push -u origin <branch>` when a phase builds and runs, then
merge it into `master` on GitHub.
