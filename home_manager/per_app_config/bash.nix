{...}:

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
    historyFileSize = 2500;




    # ~/.bash_logout content
    logoutExtra = ''
      clear
      reset
    '';


    # PS1 customisation - goes in initExtra since HM has no promptInit
    initExtra = ''
      __prompt() {
        local s=$?

        local status
        if (( s == 0 )); then
          status="\[\e[32m\]$s\[\e[0m\]"
        else
          status="\[\e[31m\]$s\[\e[0m\]"
        fi

        PS1="┌──(\[\e[94;1m\]\u@\h\[\e[0m\])-[\w] {\j} [''${status}]\n╰─\[\e[94;1m\]>>\[\e[0m\] "
      }

      PROMPT_COMMAND="__prompt''${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
    '';

    };


  # history will survive reboots since it's persisted


}