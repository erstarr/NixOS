{ ... }:

{

  # Let HM manage bash
  programs.bash = {
    enable = true;

    # bash-completion equivalent
    enableCompletion = true;

    # HISTCONTROL=erasedups
    historyControl = [ "erasedups" ];

    # HISTSIZE and HISTFILESIZE
    historySize = 1000;
    historyFileSize = 10000;

    # ~/.bash_logout content
    logoutExtra = ''
      clear
      reset
    '';

    # PS1 customisation - goes in initExtra since HM has no promptInit -- This is customised for nix ==> (adds nix specific stuff + duration block)
    initExtra = ''
      _cmd_timer_active=0
      _cmd_start=$EPOCHREALTIME

      _prompt_timer_start() {
        if (( _cmd_timer_active == 0 )); then
          _cmd_start=$EPOCHREALTIME
          _cmd_timer_active=1
        fi
      }
      trap '_prompt_timer_start' DEBUG

      __prompt() {
        local s=$?
        local _now=$EPOCHREALTIME

        local status
        if (( s == 0 )); then
          status="\[\e[32m\]$s\[\e[0m\]"
        else
          status="\[\e[31m\]$s\[\e[0m\]"
        fi

        local _s1=''${_cmd_start%.*}
        local _u1=''${_cmd_start#*.}
        local _s2=''${_now%.*}
        local _u2=''${_now#*.}
        local _diff_s=$(( _s2 - _s1 ))
        local _diff_u=$(( 10#$_u2 - 10#$_u1 ))
        if (( _diff_u < 0 )); then
          (( _diff_s-- ))
          (( _diff_u += 1000000 ))
        fi

        local duration
        if (( _diff_s >= 3600 )); then
          duration=" \[\e[90m\][$(( _diff_s / 3600 ))h$(( (_diff_s % 3600) / 60 ))m$(( _diff_s % 60 ))s]\[\e[0m\]"
        elif (( _diff_s >= 60 )); then
          duration=" \[\e[90m\][$(( _diff_s / 60 ))m$(( _diff_s % 60 ))s]\[\e[0m\]"
        elif (( _diff_s >= 1 )); then
          duration=" \[\e[90m\][$_diff_s.$(( _diff_u / 100000 ))s]\[\e[0m\]"
        else
          duration=" \[\e[90m\][$(( _diff_u / 1000 ))ms]\[\e[0m\]"
        fi

        local nix_shell=""
        if [[ -n "$IN_NIX_SHELL" ]]; then
          local nix_type
          case "$IN_NIX_SHELL" in
            pure)   nix_type="pure"    ;;
            impure) nix_type="impure"  ;;
            1)      nix_type="develop" ;;
            *)      nix_type="$IN_NIX_SHELL" ;;
          esac
          local nix_name=""
          [[ -n "$name" ]] && nix_name=":$name"
          nix_shell=" \[\e[33m\][nix·''${nix_type}''${nix_name}]\[\e[0m\]"
        fi

        local direnv_indicator=""
        if [[ -n "$DIRENV_DIR" ]]; then
          direnv_indicator=" \[\e[35m\][direnv]\[\e[0m\]"
        fi

        local flake_indicator=""
        local _d="$PWD"
        while [[ -n "$_d" ]]; do
          [[ -f "$_d/flake.nix" ]] && { flake_indicator=" \[\e[36m\][❄]\[\e[0m\]"; break; }
          [[ "$_d" == "/" ]] && break
          _d="''${_d%/*}"
          _d="''${_d:-/}"
        done

        local git_branch=""
        local _g="$PWD"
        while [[ -n "$_g" ]]; do
          if [[ -f "$_g/.git/HEAD" ]]; then
            local _head
            read -r _head < "$_g/.git/HEAD"
            if [[ "$_head" == ref:* ]]; then
              git_branch=" \[\e[32m\][ ''${_head##*/}]\[\e[0m\]"
            else
              git_branch=" \[\e[32m\][ ''${_head:0:7}]\[\e[0m\]"
            fi
            break
          fi
          [[ "$_g" == "/" ]] && break
          _g="''${_g%/*}"
          _g="''${_g:-/}"
        done

        local ssh_indicator=""
        if [[ -n "$SSH_CLIENT" || -n "$SSH_CONNECTION" ]]; then
          ssh_indicator=" \[\e[93m\][ssh]\[\e[0m\]"
        fi

        PS1="┌──(\[\e[94;1m\]\u@\h\[\e[0m\]$ssh_indicator)-[\w] {\j} [''${status}]''${nix_shell}''${direnv_indicator}''${flake_indicator}''${git_branch}''${duration}\n╰─\[\e[94;1m\]>>\[\e[0m\] "

        _cmd_timer_active=0
      }

      PROMPT_COMMAND="__prompt''${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
    '';
  };

  # history will survive reboots since it's persisted

}
