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

if ! command -v git &> /dev/null
then
    echo_red "git could not be found, please install git and try again"
    exit
fi

if ! command -v docker &> /dev/null
then
    echo_red "docker could not be found, please install docker and try again"
    exit
fi

# Detect if we're already inside rahat-project-aa
current_folder=$(basename "$PWD")
is_inside_aa=false

if [[ "$current_folder" == "rahat-project-aa" ]]; then
  is_inside_aa=true
fi

#  it is prerequesite for the project to have Rahat Project Triggers already setup.
# Check for triggers directory - sibling if inside AA, or in current dir otherwise
if [[ "$is_inside_aa" == true ]]; then
  triggers_path="../rahat-project-triggers"
else
  triggers_path="rahat-project-triggers"
fi

if [ ! -d "$triggers_path" ]; then
  echo_red "rahat-project-triggers directory not found. Assuming you have not setup Rahat Project Triggers yet."
  echo -n "Do you want to setup Rahat Project AA anyways? (y/n) "
  read answer < /dev/tty
  if [[ "$answer" == "n" || "$answer" == "N" ]]; then
    echo_yellow "Exiting setup. You can run this script again after setting up Rahat Project Triggers."
    echo_blue "To setup Rahat Project Triggers, run the following command:"
    echo_blue "curl -sSL https://raw.githubusercontent.com/dipesh-rumsan/bootstrap-scripts/main/triggersBootstrap.sh | bash"
    return 2>/dev/null || exit 0
  fi
fi

# Handle directory setup based on detected location
if [[ "$is_inside_aa" == true ]]; then
  # Already inside the project directory
  echo_green "Already inside rahat-project-aa directory. Using current directory."
elif [ -d "rahat-project-aa" ]; then
  # Project folder exists, cd into it
  echo_green "rahat-project-aa directory found. Entering directory."
  cd rahat-project-aa || exit
  git fetch origin main
  git switch seed-setup
  echo_green "rahat-project-aa repository switched to seed-setup branch successfully."
else
  # Need to clone
  echo_blue "Cloning rahat-project-aa repository..."
  git clone git@github.com:rahataid/rahat-project-aa.git
  echo_green "rahat-project-aa repository cloned successfully."
  cd rahat-project-aa || exit
  git fetch origin main
  git switch seed-setup
  echo_green "rahat-project-aa repository switched to seed-setup branch successfully."
fi

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

  if [ -f "$current_dir/prisma/seed-evm-settings.ts" ]; then
    npx tsx prisma/seed-evm-settings.ts
  else
    echo_red "seed-evm-settings.ts file not found in $current_dir/prisma"
  fi

  npx tsx prisma/seed-forecast-tab.ts
  npx tsx prisma/seed-fundmangement-tab.ts;
  npx tsx prisma/seed-offramp.ts;
  npx tsx prisma/seed-payout-config.ts;
  npx tsx prisma/seed-project-nav.ts;
  npx tsx prisma/seed-project.ts;

  sleep 2
  echo_green "Database migrations and seeding completed successfully."
}

create_project() {
  echo_blue "Creating a new project using the CLI..."
  # Collect project details for seed script
  echo_yellow "Please provide the following details for project setup:"
  echo -n "Enter project name: "
  read project_name < /dev/tty
  echo -n "Enter project description: "
  read project_description < /dev/tty
  echo -n "Enter private key: "
  stty -echo < /dev/tty
  read private_key < /dev/tty
  stty echo < /dev/tty
  echo ""  # New line after hidden input

  npx tsx tools/scripts/seed.aa.ts .env "$project_name" "$project_description" "$private_key"

  if [ $? -ne 0 ]; then
    echo_red "Failed to run seed script. See error above."
    exit 1
  fi

  # check if this file "project-setup-summary.json" exist or not in the current directory
  if [ -f "$current_dir/project-setup-summary.json" ]; then
    echo_green "Project setup summary file created successfully."
    echo_green "Make sure to use same project uuid in .env file which is mentioned in project-setup-summary.json file"
    echo_blue "Project setup summary:"
    cat "$current_dir/project-setup-summary.json"
  else
    echo_red "Failed to create project setup summary file."
  fi

  sleep 2
  echo_green "Project created successfully."
}


echo "Setting up the development environment for rahat-project-aa..."
sleep 2


echo_blue "Installing dependencies..."
pnpm i

echo_green "Dependencies installed successfully."
sleep 3

current_dir="$PWD"

# log the currnt directory in green color
echo_green "Current directory: $current_dir"
sleep 1
create_env
migrate_seed
create_project

cd .. || exit

GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}"
cat << "EOF"

██████╗  █████╗ ██╗  ██╗ █████╗ ████████╗
██╔══██╗██╔══██╗██║  ██║██╔══██╗╚══██╔══╝
██████╔╝███████║███████║███████║   ██║   
██╔══██╗██╔══██║██╔══██║██╔══██║   ██║   
██║  ██║██║  ██║██║  ██║██║  ██║   ██║   
╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   

██████╗ ██████╗  ██████╗      ██╗███████╗ ██████╗████████╗
██╔══██╗██╔══██╗██╔═══██╗     ██║██╔════╝██╔════╝╚══██╔══╝
██████╔╝██████╔╝██║   ██║     ██║█████╗  ██║        ██║   
██╔═══╝ ██╔══██╗██║   ██║██   ██║██╔══╝  ██║        ██║   
██║     ██║  ██║╚██████╔╝╚█████╔╝███████╗╚██████╗   ██║   
╚═╝     ╚═╝  ╚═╝ ╚═════╝  ╚════╝ ╚══════╝ ╚═════╝   ╚═╝   

 █████╗  █████╗ 
██╔══██╗██╔══██╗
███████║███████║
██╔══██║██╔══██║
██║  ██║██║  ██║
╚═╝  ╚═╝╚═╝  ╚═╝

EOF
echo -e "${NC}"

echo_green "You can now start developing on Rahat Project AA! Happy coding! 🚀"
