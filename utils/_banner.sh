#!/bin/bash
#
# Print banner art.

#######################################
# Print a board. 
# Globals:
#   BG_BROWN
#   NC
#   WHITE
#   CYAN_LIGHT
#   RED
#   GREEN
#   YELLOW
# Arguments:
#   None
#######################################
print_banner() {

  clear

  printf "\n\n"

  printf "${YELLOW}";
  printf "                                                     ▄▄█▀▀▀▀▀▀▀█▄▄  \n";
  printf "                                                   ${YELLOW}▄█▀${NC}   ${YELLOW}▄▄${NC}      ${YELLOW}▀█▄\n";
  printf "                                                   ${YELLOW}█${NC}    ${YELLOW}███${NC}         ${YELLOW}█\n";
  printf "                                                   ${YELLOW}█${NC}    ${YELLOW}██▄         ${YELLOW}█${NC}\n";
  printf "                                                   ${YELLOW}█${NC}     ${YELLOW}▀██▄${NC} ${YELLOW}██${NC}    ${YELLOW}█\n";
  printf "                                                   ${YELLOW}█${NC}       ${YELLOW}▀███▀${NC}    ${YELLOW}█\n";
  printf "                                                   ${YELLOW}▀█▄           ▄█▀\n";
  printf "                                                    ▄█    ▄▄▄▄█▀▀  \n";
  printf "                                                    █  ▄█▀        \n";
  printf "                                                    ▀▀▀▀          \n";
  printf "${NC}";

  printf "\n"

printf "${YELLOW}";  
printf "██╗██╗   ██╗██╗  ██╗██╗\n";
printf "██║██║   ██║╚██╗██╔╝██║\n";
printf "██║██║   ██║ ╚███╔╝ ██║\n";
printf "██║╚██╗ ██╔╝ ██╔██╗ ██╗\n";
printf "██║ ╚████╔╝ ██╔╝╚██╗██║\n";
printf "╚═╝  ╚═══╝  ╚═╝  ╚═╝╚═╝\n";
printf "${NC}";
  
  

  printf "\n"
}
