#!/usr/bin/env python3
"""
Battery Check - Quick battery and TLP status check
"""

import subprocess
import sys
from pathlib import Path


def run_cmd(cmd):
    """Run a shell command and return output."""
    try:
        result = subprocess.run(
            cmd, shell=True, capture_output=True, text=True
        )
        return result.stdout.strip()
    except Exception as e:
        return str(e)


def read_file(path):
    """Read file content."""
    try:
        return Path(path).read_text().strip()
    except (FileNotFoundError, PermissionError):
        return None


def get_battery_level():
    """Get current battery percentage."""
    for path in Path("/sys/class/power_supply").glob("BAT*/capacity"):
        try:
            return read_file(path)
        except FileNotFoundError:
            continue
    return None


def is_on_ac_power():
    """Check if system is plugged in."""
    for path in Path("/sys/class/power_supply").glob("AC*/online"):
        try:
            return read_file(path) == "1"
        except FileNotFoundError:
            continue
    return False


def get_tlp_config():
    """Get current TLP CPU settings."""
    output = run_cmd("sudo tlp-stat -c 2>/dev/null | grep '99-current' | grep -E 'CPU_MAX_PERF|CPU_SCALING'")
    return output


def get_timer_status():
    """Get battery monitor timer status."""
    output = run_cmd("systemctl list-timers --no-pager battery-monitor.timer 2>/dev/null | grep battery")
    return output


def get_config_files():
    """List TLP config files."""
    output = run_cmd("ls /etc/tlp.d/*.conf 2>/dev/null | grep -v template | grep -v README")
    return output


def main():
    battery = get_battery_level()
    ac_power = is_on_ac_power()

    print("=== Battery Status ===")
    print(f"Battery: {battery}%")
    print(f"Power: {'AC (plugged in)' if ac_power else 'BATTERY'}")

    print("\n=== Active TLP Config ===")
    config = read_file("/etc/tlp.d/99-current-battery.conf")
    if config:
        for line in config.split("\n"):
            if "CPU_MAX_PERF" in line:
                print(line)
    else:
        print("Config not found")

    print("\n=== Current CPU Settings ===")
    print(get_tlp_config())

    print("\n=== Battery Monitor Timer ===")
    timer = get_timer_status()
    print(timer if timer else "Timer not found")

    print("\n=== Config Files ===")
    print(get_config_files())


if __name__ == "__main__":
    main()
