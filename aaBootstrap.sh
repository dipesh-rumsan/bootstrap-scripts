
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

# check if rahat-project-aa directory exists if not exist then clone the repo
if [ -d "rahat-project-aa" ]; then
  echo_green "rahat-project-aa directory already exists. Skipping cloning."
  cd rahat-project-aa || exit
else
  echo_blue "Cloning rahat-project-aa repository..."
  git clone git@github.com:rahataid/rahat-project-aa.git
  echo_green "rahat-project-aa repository cloned successfully."
  cd rahat-project-aa || exit
  git fetch origin main
  git switch dev
  echo_green "rahat-project-aa repository switched to dev branch successfully."
fi

echo "Setting up the development environment for rahat-project-aa..."
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