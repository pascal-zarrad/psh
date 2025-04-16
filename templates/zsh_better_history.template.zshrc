#PSH_TEMPLATE=END
# History improvements
# Adapted from source: https://jdhao.github.io/2021/03/24/zsh_history_setup/
export HISTFILE=~/.histfile # history file location
export HISTSIZE=50000  # the number of history items kept in memory
export SAVEHIST=250000  # maximum number of items for the history file
setopt HIST_IGNORE_ALL_DUPS  # do not put duplicated command into history list
setopt HIST_SAVE_NO_DUPS  # do not save duplicated command
setopt HIST_REDUCE_BLANKS  # remove unnecessary blanks
setopt INC_APPEND_HISTORY  # append command to history file immediately after execution
setopt EXTENDED_HISTORY  # record command start time
