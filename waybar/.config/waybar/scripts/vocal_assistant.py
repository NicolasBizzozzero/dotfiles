#!/usr/bin/python3
#
# vocal_assistant.py - state of vocal-assistant for the waybar `custom/vocal-assistant`
# module: `vocal-assistant state --follow`, with the LLM it uses added to the tooltip
#
# Usage:
#   vocal_assistant.py    one JSON line per state change, and every few seconds (never ends)
#
# The system python, not the shebang's usual env: it has PyYAML, the python of
# a virtualenv active in a terminal may not.

import json
import os
import signal
import subprocess
import sys
import time
import urllib.request
from pathlib import Path

import yaml

# What the running assistant applied: config.yaml may hold edits not applied yet
ACTIVE_CONFIG = Path.home() / ".local/share/vocal-assistant/actif/config.yaml"
# Seconds between two questions to Ollama (a state line comes every ~2 s)
OLLAMA_EVERY = 5

_config = {"mtime": None, "llm": None}
_ollama = {"time": 0.0, "line": None}


def active_llm():
    """(url, model) of the applied configuration, None when nothing is applied"""
    try:
        mtime = ACTIVE_CONFIG.stat().st_mtime
    except OSError:
        return None
    if mtime != _config["mtime"]:
        try:
            llm = yaml.safe_load(ACTIVE_CONFIG.read_text())["llm"]
            _config["llm"] = (llm["url"], llm["model"])
        except (OSError, yaml.YAMLError, KeyError, TypeError):
            _config["llm"] = None
        _config["mtime"] = mtime
    return _config["llm"]


def gpu_share(url, model):
    """Share of the model in GPU memory, None when Ollama hasn't loaded it"""
    with urllib.request.urlopen(f"{url.rstrip('/')}/api/ps", timeout=1) as answer:
        loaded = json.load(answer).get("models", [])
    for entry in loaded:
        if model in (entry.get("name"), entry.get("model")):
            size = entry.get("size") or 0
            return entry.get("size_vram", 0) / size if size else 0.0
    return None


def llm_line(state):
    llm = active_llm()
    if llm is None:
        return None
    url, model = llm
    # Stopped, it uses no model: just the one it would use
    if state in ("stopped", "failed"):
        return f"LLM : {model}"
    if time.monotonic() - _ollama["time"] >= OLLAMA_EVERY:
        try:
            share = gpu_share(url, model)
        except (OSError, ValueError):
            line = f"LLM : {model}, mais Ollama ne répond pas"
        else:
            if share is None:
                line = f"LLM : {model}, se charge à la première question"
            else:
                line = f"LLM : {model}, chargé à {share:.0%} sur le GPU"
        _ollama.update(time=time.monotonic(), line=line)
    return _ollama["line"]


def main():
    try:
        follow = subprocess.Popen(
            ["vocal-assistant", "state", "--follow"],
            stdin=subprocess.DEVNULL,
            stdout=subprocess.PIPE,
            text=True,
            bufsize=1,
        )
    except FileNotFoundError:
        sys.exit("vocal_assistant.py: vocal-assistant is not installed")

    def stop(*_):
        raise SystemExit(0)

    for signum in (signal.SIGTERM, signal.SIGHUP, signal.SIGINT):
        signal.signal(signum, stop)

    try:
        for line in follow.stdout:
            try:
                state = json.loads(line)
            except ValueError:
                print(line, end="", flush=True)
                continue
            extra = llm_line(state.get("alt"))
            if extra:
                tooltip = state.get("tooltip", "")
                state["tooltip"] = f"{tooltip}\n{extra}" if tooltip else extra
            print(json.dumps(state, ensure_ascii=False), flush=True)
    except BrokenPipeError:
        # Waybar stopped reading: no error message at exit either
        os.dup2(os.open(os.devnull, os.O_WRONLY), sys.stdout.fileno())
    finally:
        if follow.poll() is None:
            follow.terminate()
    sys.exit(follow.wait())


if __name__ == "__main__":
    main()
