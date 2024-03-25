#PSH_TEMPLATE=END
# If we have a linuxbrew directory, we will include the brew path support
# This way installing psh after brew automatically adds the brew path support.
if [ -d "/home/linuxbrew/.linuxbrew" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
