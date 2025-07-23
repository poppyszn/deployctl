# deployctl

**Modular Bash-based Deployment Controller**

`deployctl` is a lightweight and extensible Bash script designed to manage application deployments in a consistent and environment-agnostic way. It allows you to define deployment logic via portable `.conf` files and control deployments using simple commands like `--stop`, `--start`, or a full `--deploy` cycle.

---

## 🔧 Features

- ✅ Config-driven: Use `.conf` files to define ports, start/stop commands, and intervals
- ✅ Supports `--stop`, `--start`, `--dry-run`, and full deployment
- ✅ Easy to extend for different apps and environments
- ✅ Fallback-ready with Nginx integration (optional)
- ✅ Can be installed globally for reuse across projects

---

## 🚀 Quick Description (for GitHub)

> `deployctl` is a simple but powerful Bash tool to control and monitor application deployments via portable config files. Ideal for teams managing custom deployment logic, port readiness checks, and fallback Nginx routing.

---

## 📦 Installation

Clone this repository and make the script executable:

```bash
git clone https://github.com/your-username/deployctl.git
cd deployctl
chmod +x deployctl.sh
```

**(Optional) Add to your PATH:**

```bash
mv deployctl.sh ~/bin/deployctl
# OR for system-wide use:
sudo mv deployctl.sh /usr/local/bin/deployctl
```

---

## ⚙️ Configuration Format

Create a config file like `frontend.conf`:

```bash
# frontend.conf
PORTS_TO_CHECK="3000 4000"
STOP_COMMAND="pm2 stop frontend"
START_COMMAND="pm2 start frontend"
CHECK_INTERVAL=3  # seconds
```

---

## 🧪 Usage

```bash
deployctl --config frontend.conf              # Full flow (stop → wait → start)
deployctl --config frontend.conf --stop       # Only stop the app
deployctl --config frontend.conf --start      # Only start the app
deployctl --config frontend.conf --dry-run    # Show what would be done
```

---

## 📂 Example Project Structure

```
deployctl/
├── deployctl.sh
├── frontend.conf
├── backend.conf
└── README.md
```

---

## 📌 Planned Features

- `--status` to show port availability in real time
- `--log deployctl.log` to log actions
- `deployctl init` to scaffold new config files
- `--timeout` and retries for better error handling
- Color-coded terminal output

---

## 📄 License

MIT License
