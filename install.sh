main() {
  set -e
  echo $(blue "$(bold "Testing Internet connection")")
  ping -c 4 google.com


  echo $(blue "$(bold "Cloning mateusmrn/dotfiles repo from GitHub")")
  if [ ! -d "dotfiles "]; then
    git clone https://github.com/mateusmrn/dotfiles.git
  else
    echo $(blue "$(bold "Repo already exists")")
  fi
}


green() {
  printf '\033[0;32m%s\033[0m' "$1"
}

yellow() {
  printf '\033[0;33m%s\033[0m' "$1"
}

red() {
  printf '\033[0;31m%s\033[0m' "$1"
}

blue() {
  printf '\033[0;34m%s\033[0m' "$1"
}

bold() {
  printf '\033[1m%s\033[0m' "$1"
}

italic() {
  printf '\033[3m%s\033[0m' "$1"
}

main "$@"
