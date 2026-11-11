# Unity Hub HiDPI launcher for KDE Plasma (Wayland)

The Unity Editor on Linux ignores fractional OS scaling (like 125% or 150%), so it
looks tiny. On Linux the editor has no scale slider like on Windows. Unity only reacts to 2x,
which is too big on many screens.

This launcher script starts Unity Hub together with a tiny virtual 2x monitor. Which forces the editor
to render at 2x and KWin scales it down to your real display scale, so it has the
right scale. Because it's scaled down instead of up, it does not look blurry.


## Tested on

- Kubuntu 26.04, KDE Plasma 6.6.6, Wayland
- Unity Hub with Unity Editor 6000.3.22f1

It might work on other setups, but I haven't tested them. I'm a Unity developer that recently switched to Linux. I was annoyed that Unity didn't support this and was searching for a solution, [this](https://discussions.unity.com/t/no-ui-scaling-for-linux-you-gotta-be-joking/1638248/67) post tought me that the virtual monitor was a good solution. I created this script and readme file with the help of AI, but I have read all outputs, understood the code and confirmed this script is working.


## How it works

With "Apply scaling themselves", KWin runs one XWayland instance (the X11 compatibility
layer Unity runs in) at the highest scale of all your monitors. The script creates a
tiny virtual monitor with scale 2 using `krfb-virtualmonitor`, so Unity gets a 2x
scale. When the last Unity Editor closes, the virtual monitor is removed again.


## Requirements

- KDE Plasma 6 on Wayland
- Unity Hub, installed so that typing `unityhub` in a terminal starts it.
- A few small packages, installed with the command below


### Install the dependencies

On Kubuntu / Ubuntu:

```bash
sudo apt install libkscreen-bin krfb iproute2 procps
```

`apt` skips packages that are already installed, so it is safe to run even if you
already have some or all of them. On other distributions, install the packages that
provide the same commands (they are usually named the same).


### Why these are needed

| Package | Command | What the script uses it for |
|---|---|---|
| `libkscreen-bin` | `kscreen-doctor` | Lists your monitors, to check whether the virtual monitor already exists |
| `krfb` | `krfb-virtualmonitor` | Creates the virtual 2x monitor (a tool from KDE's desktop sharing app) |
| `iproute2` | `ss` | Finds a free network port for the virtual monitor |
| `procps` | `pgrep` | Checks if a Unity Editor is still running, so the monitor is only removed after the last editor closes |


## Setup

1. Put `unity-scale.sh` somewhere permanent and make sure it is executable.
2. Set: "System Settings > Display & Monitor > Legacy applications
  (X11)"  to "Apply scaling themselves".
3. Run it once from a terminal: `./unity-scale.sh`. Unity Hub opens.
4. While it is running, open "System Settings > Display & Monitor" and select the
   `UnityHiDPI` output and set its scale to **200%**.
5. Close Unity Hub and all editors. The virtual monitor is removed automatically.
6. Optional launcher: copy `unity-hidpi.desktop` to `~/.local/share/applications/`
  **and edit the `Exec=` line so it contains the absolute path to
  `unity-scale.sh`** (for example `/home/username/scripts/unity-scale.sh`; `~` does not work there).


## Things to know

- **Browser redirects to Unity Hub don't work.** Actions where the browser sends you
  back to Unity Hub, like signing in, do not work when Unity Hub was opened through
  this script. Use the original Unity Hub shortcut for those.
- **All X11 apps are affected.** While the virtual monitor exists, not only Unity is scaled. Apps
  that cannot handle a scale change while running may break, so restart them after the
  monitor appears or disappears.
- **The monitor is a VNC server.** `krfb-virtualmonitor` listens on all network
  interfaces on a free port between 5900 and 5999. The script generated a random password
  on every start, so nobody can to connect to it.
- **KDE Plasma on Wayland only.** This does not apply to X11 sessions or other desktops.


## Uninstall

Delete the script and the `.desktop` file (`~/.local/share/applications/`).

---

Not affiliated with or endorsed by Unity Technologies. Unity is a trademark of Unity
Technologies.
