# Rahat Platform Bootstrap Scripts

Automated setup scripts for quickly getting the Rahat Platform development environment up and running.

## 📋 Prerequisites

Before running the bootstrap script, ensure you have the following installed on your system:

- **Git** - Version control system
- **Docker** - Container platform (with Docker Compose)
- **pnpm** - Fast, disk space efficient package manager
- **Node.js** - JavaScript runtime (v16 or higher recommended)

## 🚀 Quick Start

Run the following command to set up the entire Rahat Platform:

```bash
curl -sSL https://raw.githubusercontent.com/dipesh-rumsan/bootstrap-scripts/main/bootstrap.sh | bash
```

Or, if you've cloned this repository:

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

## 📦 What Does the Bootstrap Script Do?

The `bootstrap.sh` script automates the following setup process:

### 1. **Prerequisites Validation**

- Checks if Git and Docker are installed
- Exits with helpful error messages if dependencies are missing

### 2. **Repository Setup**

- Clones the `rahat-platform` repository (if not already present)
- Switches to the `dev` branch
- Installs all project dependencies using pnpm

### 3. **Environment Configuration**

- Creates `.env` files from `.env.example` templates
- Sets up environment variables for:
  - Root project
  - Dev tools (Docker Compose services)

### 4. **Blockchain Setup**

- Generates mnemonic phrases for wallet creation
- Retrieves Ganache blockchain accounts

### 5. **Docker Infrastructure**

- Creates Docker volumes for:
  - PostgreSQL database (`rahat_pg_data`)
  - PgAdmin (`rahat_pg_admin_data`)
  - Ganache (local blockchain) (`rahat_ganache_data`)
  - Redis (`rahat_redis_data`)
  - Graph node (`rahat_pg_graph_data`)
  - IPFS (`rahat_ipfs_data`)
- Creates Docker networks (`rahat_platform`, `rahat_projects`)
- Starts Docker Compose services for dev tools and graph node

### 6. **Database Setup**

- Generates Prisma client
- Runs database migrations
- Seeds development data for multiple projects:
  - El Salvador settings
  - C2C (Cash-to-Cash) settings
  - AA (Anticipatory Action) settings
  - CVA (Cash and Voucher Assistance) settings
  - RP (Rahat Platform) settings
  - Kenya settings
  - Cambodia settings
  - Chain settings
  - Communication settings
  - Offramp settings

### 7. **Smart Contracts & Graph**

- Deploys smart contracts to local Ganache network
- Configures The Graph indexing protocol
- Generates graph code
- Creates and deploys local graph node
- Outputs the Graph URL for querying

### 8. **Optional Project Setup**

- Prompts to set up Rahat Project AA (Anticipatory Action)
- If accepted, runs:
  - `triggersBootstrap.sh` - Sets up rahat-project-triggers
  - `aaBootstrap.sh` - Sets up rahat-project-aa

## 🔧 Additional Scripts

### Triggers Bootstrap

Sets up the rahat-project-triggers:

```bash
curl -sSL https://raw.githubusercontent.com/dipesh-rumsan/bootstrap-scripts/main/triggersBootstrap.sh | bash
```

**This script:**

- Clones rahat-project-triggers repository
- Installs dependencies with pnpm
- Builds the project
- Creates `.env` files
- Runs database migrations and seeding

### AA Bootstrap

Sets up the rahat-project-aa (requires triggers to be set up first):

```bash
curl -sSL https://raw.githubusercontent.com/dipesh-rumsan/bootstrap-scripts/main/aaBootstrap.sh | bash
```

**This script:**

- Checks for rahat-project-triggers as a prerequisite
- Clones rahat-project-aa repository
- Switches to `seed-setup` branch
- Creates `.env` files
- Sets up project-specific configuration

## 🛠️ Manual Setup Functions

The bootstrap script includes several utility functions that can be used independently:

- `create_env` - Create environment files from examples
- `generate_mnemonic` - Generate blockchain wallet mnemonics
- `create_rahat_volumes` - Create Docker volumes
- `start_dev_tools` - Start Docker Compose services
- `stop_dev_tools` - Stop Docker Compose services
- `remove_rahat_volumes` - Remove Docker volumes
- `migrate_seed` - Run database migrations and seeding
- `contract_setup` - Deploy smart contracts and setup graph
- `graph_setup` - Configure and deploy The Graph
- `reset` - Stop services, remove volumes, and clean modules

## ⚠️ Troubleshooting

### Script Fails with Git Errors

- Ensure you have SSH keys configured for GitHub
- Or modify the git clone commands to use HTTPS instead

### Docker Services Won't Start

- Verify Docker Desktop is running
- Check if ports are already in use (5432, 6379, 8545, etc.)
- Run `docker ps` to see running containers

### pnpm Commands Fail

- Install pnpm globally: `npm install -g pnpm`
- Verify Node.js version: `node --version`

### Database Migration Errors

- Ensure Docker PostgreSQL container is running
- Check database connection settings in `.env` files
- Try restarting Docker services: `docker compose down && docker compose up -d`

## 📁 Directory Structure After Setup

```
.
├── rahat-platform/          # Main platform repository
│   ├── tools/
│   │   └── docker-compose/  # Docker configurations
│   ├── prisma/              # Database schemas and migrations
│   └── ...
├── rahat-project-triggers/  # (Optional) Triggers project
└── rahat-project-aa/        # (Optional) Anticipatory Action project
```

## 🔄 Resetting the Environment

If you need to start fresh, the bootstrap script includes a reset function:

```bash
# This will:
# - Stop all Docker services
# - Remove Docker volumes
# - Remove node_modules and build artifacts
reset
```

## 🎯 Next Steps

After successful setup:

1. **Access Services:**
   - PgAdmin: http://localhost:5050
   - Ganache: http://localhost:8545
   - Graph Node: Check terminal output for URL

2. **Start Development:**

   ```bash
   cd rahat-platform
   pnpm dev
   ```

3. **View Documentation:**
   - Check the rahat-platform README for development guidelines
   - Review environment variables in `.env` files

## 💡 Tips

- The script uses color-coded output:
  - 🟢 Green: Success messages
  - 🔵 Blue: Information/Process messages
  - 🔴 Red: Error messages
  - 🟡 Yellow: Warning messages

- All Docker volumes persist data between restarts
- The setup includes multiple country-specific configurations (Kenya, Cambodia, El Salvador)
- Graph URL is automatically exported to environment variables

## 📝 License

Refer to individual project repositories for license information.

## 🤝 Contributing

For issues or contributions, please refer to the main Rahat Platform repository.

---

**Happy coding! 🚀**
