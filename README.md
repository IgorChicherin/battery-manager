# Battery Manager

Automatic TLP power profile switching based on battery level.

## Features

- **4-tier power management with CPU frequency limiting:**
  - 81-100% battery → 100% CPU, 100% freq (FULL performance)
  - 51-80% battery → 80% CPU, 80% freq (BALANCED)
  - 31-50% battery → 50% CPU, 50% freq (MEDIUM)
  - 0-30% battery → 35% CPU, 35% freq (AGGRESSIVE power saving)

- **Automatic switching** via systemd timer (every 2 minutes)
- **Python-based** for better maintainability
- **Easy status checking** with battery-check tool
- **Direct CPU frequency control** - actually limits clock speed
- **Dynamic frequency detection** - reads max CPU freq from hardware

## Installation

```bash
cd ~/battery-manager
./install.sh
```

This will:
- Copy systemd service files to `/etc/systemd/system/`
- Install `battery-monitor.py` to `/usr/local/bin/`
- Create symlinks for easy command-line access
- Enable and start the timer

## Usage

### Check Status
```bash
battery-check
# or
python3 ~/battery-manager/battery-check.py
```

### Manual Trigger
```bash
sudo battery-monitor
# or
sudo python3 /usr/local/bin/battery-monitor.py
```

### View Timer Status
```bash
systemctl list-timers battery-monitor.timer
```

### View Logs
```bash
journalctl -u battery-monitor.service -n 20
```

## Files

| File | Purpose |
|------|---------|
| `battery-monitor.py` | Main script - switches TLP profiles |
| `battery-check.py` | Status check utility |
| `battery-monitor.service` | Systemd service definition |
| `battery-monitor.timer` | Systemd timer (2 min interval) |
| `install.sh` | Installation script |

## Configuration

Edit `PROFILES` dict in `battery-monitor.py` to customize:
- Battery thresholds
- CPU max percentages
- Platform profiles
- Disk/SATA/PCIe power settings

## Requirements

- Arch Linux (or similar with systemd)
- TLP installed (`sudo pacman -S tlp tlp-rdw`)
- Python 3.6+

## License

MIT
