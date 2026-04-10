#! /bin/bash

# check if git and docker is installed or not if not exit 
if ! command -v git &> /dev/null
then
    echo "git could not be found, please install git and try again"
    exit
fi

if ! command -v docker &> /dev/null
then
    echo "docker could not be found, please install docker and try again"
    exit
fi

# Color utility functions
echo_green() {
  echo -e "\033[32m$1\033[0m"
}

echo_blue() {
  echo -e "\033[34m$1\033[0m"
}

echo_red() {
  echo -e "\033[31m$1\033[0m"
}

echo_yellow() {
  echo -e "\033[33m$1\033[0m"
}

# check if rahat-platform directory exists if not exist then clone the repo
if [ -d "rahat-platform" ]; then
  echo_green "rahat-platform directory already exists. Skipping cloning."
  cd rahat-platform || exit
else
  echo_blue "Cloning rahat-platform repository..."
  git clone git@github.com:rahataid/rahat-platform.git
  echo_green "rahat-platform repository cloned successfully."
  cd rahat-platform || exit
  git fetch origin main
  git switch dev
  echo_green "rahat-platform repository switched to dev branch successfully."
fi

echo "Setting up the development environment for rahat-platform..."
sleep 2


# in blue color saying "Installing dependencies..."
echo_blue "Installing dependencies..."
pnpm i

echo_green "Dependencies installed successfully."
sleep 3

current_dir="$PWD"

# log the currnt directory in green color
echo_green "Current directory: $current_dir"
sleep 1

create_env() {
  # dev tools directory
  declare -a projectDirs=(
    "$current_dir" #for root project as well
    "$current_dir/tools/docker-compose/dev-tools"
  )

  for project in "${projectDirs[@]}"; do
    env_file="$project/.env"
    example_content=$(<"$project/.env.example")
    echo "$example_content" >"$env_file"
    cat "$env_file"
  done

  # check if .env files are created
  for project in "${projectDirs[@]}"; do
    env_file="$project/.env"
    if [ -f "$env_file" ]; then
      echo_green ".env file created successfully in $project"
    else
      echo_red "Failed to create .env file in $project"
    fi
  done
}

generate_mnemonic() {
  pnpm generate:mnemonic $current_dir
}

get_ganache_accounts() {
  docker cp ganache-rahat:/db/accounts ./accounts.json
}

migrate_seed() {
  echo_blue "Running database migrations and seeding data..."
  pnpm prisma:generate
  pnpm migrate:dev
  pnpm seed:eldevsettings $current_dir
  pnpm seed:c2cdevsettings $current_dir
  pnpm seed:aadevsettings $current_dir
  pnpm seed:cvadevsettings $current_dir
  pnpm seed:rpdevsettings $current_dir
  pnpm seed:kenyadevsettings $current_dir
  pnpm seed:cambodiadevsettings $current_dir
  pnpm seed:chainsettings
  npx ts-node prisma/seed.communication-settings.ts
  npx ts-node prisma/seed.offramp.ts
  sleep 3
  echo_green "Database migrations and seeding completed successfully."
  sleep 2
}

create_rahat_volumes() {
  docker volume create rahat_pg_data &&
    docker volume create rahat_pg_admin_data &&
    docker volume create rahat_ganache_data &&
    docker volume create rahat_redis_data &&
    docker volume create rahat_pg_graph_data &&
    docker volume create rahat_ipfs_data
}

start_dev_tools() {
  stop_dev_tools
  docker network create rahat_platform
  docker network create rahat_projects
  declare -a composeDirs=(
    "$current_dir/tools/docker-compose/dev-tools"
    "$current_dir/tools/docker-compose/graph"
  )

  for project in "${composeDirs[@]}"; do
    compose_file="$project/docker-compose.yml"
    docker compose -f $compose_file up -d
  done

  echo_blue "Waiting for dev tools to start..."
  sleep 10
}

stop_dev_tools() {
  declare -a composeDirs=(
    "$current_dir/tools/docker-compose/dev-tools"
    "$current_dir/tools/docker-compose/graph"
  )

  for project in "${composeDirs[@]}"; do
    compose_file="$project/docker-compose.yml"
    docker compose -f $compose_file down
  done
}

remove_rahat_volumes() {
  docker volume rm rahat_pg_data &&
    docker volume rm rahat_pg_admin_data &&
    docker volume rm rahat_ganache_data &&
    docker volume rm rahat_redis_data &&
    docker volume rm rahat_pg_graph_data &&
    docker volume rm rahat_ipfs_data
}

rm_modules() {
  rm -rf dist node_modules tmp
}

contract_setup() {
  echo_green "Setting up contracts and graph..."
  pnpm seed:contracts
  pnpm seed:graph $current_dir
  echo_green "\nContracts and graph setup completed successfully.\n"
}

graph_setup() {
  echo_green "Setting up the graph..."
  pnpm graph:codegen
  pnpm graph:create-local
  graph_url=$(pnpm graph:deploy-local | grep -o 'http://[^ ]*' | tail -1)
  echo_blue "Graph URL: $graph_url\n"
  export graph_url
  echo_green "Graph setup completed successfully.\n"
}

reset() {
  stop_dev_tools
  remove_rahat_volumes
  rm_modules
}

create_env

generate_mnemonic

create_rahat_volumes

start_dev_tools

get_ganache_accounts

migrate_seed

echo_green "\nDevelopment environment setup completed successfully.\n"

contract_setup
graph_setup

# Green color
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}"
cat << "EOF"

██╗    ██╗███████╗██╗      ██████╗ ██████╗ ███╗   ███╗███████╗
██║    ██║██╔════╝██║     ██╔════╝██╔═══██╗████╗ ████║██╔════╝
██║ █╗ ██║█████╗  ██║     ██║     ██║   ██║██╔████╔██║█████╗  
██║███╗██║██╔══╝  ██║     ██║     ██║   ██║██║╚██╔╝██║██╔══╝  
╚███╔███╔╝███████╗███████╗╚██████╗╚██████╔╝██║ ╚═╝ ██║███████╗
 ╚══╝╚══╝ ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝

████████╗ ██████╗     ██████╗  █████╗ ██╗  ██╗ █████╗ ████████╗
╚══██╔══╝██╔═══██╗    ██╔══██╗██╔══██╗██║  ██║██╔══██╗╚══██╔══╝
   ██║   ██║   ██║    ██████╔╝███████║███████║███████║   ██║   
   ██║   ██║   ██║    ██╔══██╗██╔══██║██╔══██║██╔══██║   ██║   
   ██║   ╚██████╔╝    ██║  ██║██║  ██║██║  ██║██║  ██║   ██║   
   ╚═╝    ╚═════╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   

██████╗ ██╗      █████╗ ████████╗███████╗ ██████╗ ██████╗ ███╗   ███╗
██╔══██╗██║     ██╔══██╗╚══██╔══╝██╔════╝██╔═══██╗██╔══██╗████╗ ████║
██████╔╝██║     ███████║   ██║   █████╗  ██║   ██║██████╔╝██╔████╔██║
██╔═══╝ ██║     ██╔══██║   ██║   ██╔══╝  ██║   ██║██╔══██╗██║╚██╔╝██║
██║     ███████╗██║  ██║   ██║   ██║     ╚██████╔╝██║  ██║██║ ╚═╝ ██║
╚═╝     ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝      ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝

EOF
echo -e "${NC}"
cd .. || exit

echo_green "You can now start developing on rahat-platform! Happy coding! 🚀"

echo -n "Do you want to setup Rahat Project AA? (y/n) "
read answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
  echo_green "Setting up Rahat Project AA..."
  echo_yellow "This will run the setup script for Rahat Project AA which will deploy the necessary contracts and subgraph for the project. This may take a few minutes..."
  sleep 3
  echo_green "Rahat Project AA setup completed successfully."
else
  echo_yellow "Skipping Rahat Project AA setup. You can set it up later by running 'pnpm setup:project-aa'."
fi


