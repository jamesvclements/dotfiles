SPACESHIP_PACKAGE_SHOW=false

# Keep async on (fast response)
SPACESHIP_PROMPT_ASYNC=true

# Git: show branch only, skip slow status checks
SPACESHIP_GIT_STATUS_SHOW=false

# Reorder: put git at the end so async load doesn't shift other sections
SPACESHIP_PROMPT_ORDER=(
  dir
  node
  exec_time
  git
  line_sep
  char
)
