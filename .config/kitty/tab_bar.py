# Wired up via tab_title_template "{custom}" in kitty.conf

import os
import subprocess
from functools import lru_cache

@lru_cache(maxsize=512)
def _worktree_name(cwd: str) -> str:
    try:
        out = subprocess.run(
            ['git', '-C', cwd, 'rev-parse', '--show-toplevel', '--absolute-git-dir'],
            capture_output=True, text=True, timeout=1,
        )
        if out.returncode != 0:
            return ''
        toplevel, git_dir = out.stdout.splitlines()[:2]
        if os.path.basename(os.path.dirname(git_dir)) == 'worktrees':
            return os.path.basename(git_dir)
        return os.path.basename(toplevel)
    except Exception:
        return ''

def draw_title(data: dict) -> str:
    try:
        tab = data.get('tab')
        cwd = tab.active_wd if tab is not None else ''
        if cwd:
            name = _worktree_name(cwd)
            if name:
                return ' /' + name
    except Exception:
        pass
    return str(data.get('title', ''))
