#!/bin/bash

get_mysql_root_password() {
  
  print_banner
  printf "${YELLOW} 💻 Insira senha para o usuario Deploy e Banco de Dados (Não utilizar caracteres especiais):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " mysql_root_password
}

get_link_git() {
  
  print_banner
  printf "${YELLOW} 💻 Insira o link do GITHUB do Whaticket que deseja instalar:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " link_git
}

get_instancia_add() {
  
  print_banner
  printf "${YELLOW} 💻 Informe um nome para a Instancia/Empresa que será instalada (Não utilizar espaços ou caracteres especiais, Utilizar Letras minusculas; ):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " instancia_add
}

get_max_whats() {
  
  print_banner
  printf "${YELLOW} 💻 Informe a Qtde de Conexões/Whats que a ${instancia_add} poderá cadastrar:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " max_whats
}

get_max_user() {
  
  print_banner
  printf "${YELLOW} 💻 Informe a Qtde de Usuarios/Atendentes que a ${instancia_add} poderá cadastrar:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " max_user
}

get_frontend_url() {
  
  print_banner
  printf "${YELLOW} 💻 Digite o domínio do FRONTEND/PAINEL para a ${instancia_add}:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " frontend_url
}

get_backend_url() {
  
  print_banner
  printf "${YELLOW} 💻 Digite o domínio do BACKEND/API para a ${instancia_add}:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " backend_url
}

get_frontend_port() {
  
  print_banner
  printf "${YELLOW} 💻 Digite a porta do FRONTEND para a ${instancia_add}; Ex: 3000 A 3999 ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " frontend_port
}


get_backend_port() {
  
  print_banner
  printf "${YELLOW} 💻 Digite a porta do BACKEND para esta instancia; Ex: 4000 A 4999 ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " backend_port
}

get_redis_port() {
  
  print_banner
  printf "${YELLOW} 💻 Digite a porta do REDIS/AGENDAMENTO MSG para a ${instancia_add}; Ex: 5000 A 5999 ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " redis_port
}

get_empresa_delete() {
  
  print_banner
  printf "${YELLOW} 💻 Digite o nome da Instancia/Empresa que será Deletada (Digite o mesmo nome de quando instalou):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " empresa_delete
}

get_empresa_atualizar() {
  
  # Descobrir automaticamente as instâncias instaladas em /home/deploy
  instances=()

  if [ -d "/home/deploy" ]; then
    for dir in /home/deploy/*/; do
      if [ -d "$dir" ] && [ -d "$dir/frontend" ] && [ -d "$dir/backend" ]; then
        instances+=("$(basename "$dir")")
      fi
    done
  fi

  if [ "${#instances[@]}" -eq 0 ]; then
    print_banner
    printf "${YELLOW} ⚠ Nenhuma instância Whaticket foi encontrada em /home/deploy.${GRAY_LIGHT}\n"
    printf "\n"
    printf "   Verifique se existe ao menos uma instalação antes de tentar atualizar.\n"
    printf "\n"
    printf "   Pressione ENTER para voltar ao menu.\n"
    read -r
    return 1
  fi

  while true; do
    print_banner
    printf "${YELLOW} 💻 Selecione a Instancia/Empresa que deseja Atualizar:${GRAY_LIGHT}\n"
    printf "\n"

    for i in "${!instances[@]}"; do
      idx=$((i + 1))
      printf "   [%d] %s\n" "$idx" "${instances[$i]}"
    done

    printf "\n"
    printf "   Digite o número da instância desejada e pressione ENTER.\n"
    printf "\n"
    read -p "> " instancia_opcao

    # Validar se é número
    if ! [[ "$instancia_opcao" =~ ^[0-9]+$ ]]; then
      printf "\n${YELLOW}   Opção inválida. Digite apenas o número da instância.${GRAY_LIGHT}\n"
      sleep 2
      continue
    fi

    instancia_index=$((instancia_opcao - 1))

    if [ "$instancia_index" -lt 0 ] || [ "$instancia_index" -ge "${#instances[@]}" ]; then
      printf "\n${YELLOW}   Opção fora do intervalo. Tente novamente.${GRAY_LIGHT}\n"
      sleep 2
      continue
    fi

    empresa_atualizar="${instances[$instancia_index]}"
    break
  done
}

get_empresa_bloquear() {
  
  print_banner
  printf "${YELLOW} 💻 Digite o nome da Instancia/Empresa que deseja Bloquear (Digite o mesmo nome de quando instalou):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " empresa_bloquear
}

get_empresa_desbloquear() {
  
  print_banner
  printf "${YELLOW} 💻 Digite o nome da Instancia/Empresa que deseja Desbloquear (Digite o mesmo nome de quando instalou):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " empresa_desbloquear
}

get_empresa_dominio() {
  
  print_banner
  printf "${YELLOW} 💻 Digite o nome da Instancia/Empresa que deseja Alterar os Dominios (Atenção para alterar os dominios precisa digitar os 2, mesmo que vá alterar apenas 1):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " empresa_dominio
}

get_alter_frontend_url() {
  
  print_banner
  printf "${YELLOW} 💻 Digite o NOVO domínio do FRONTEND/PAINEL para a ${empresa_dominio}:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " alter_frontend_url
}

get_alter_backend_url() {
  
  print_banner
  printf "${YELLOW} 💻 Digite o NOVO domínio do BACKEND/API para a ${empresa_dominio}:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " alter_backend_url
}

get_alter_frontend_port() {
  
  print_banner
  printf "${YELLOW} 💻 Digite a porta do FRONTEND da Instancia/Empresa ${empresa_dominio}; A porta deve ser o mesma informada durante a instalação ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " alter_frontend_port
}


get_alter_backend_port() {
  
  print_banner
  printf "${YELLOW} 💻 Digite a porta do BACKEND da Instancia/Empresa ${empresa_dominio}; A porta deve ser o mesma informada durante a instalação ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " alter_backend_port
}


get_urls() {
  get_mysql_root_password
  get_link_git
  get_instancia_add
  get_max_whats
  get_max_user
  get_frontend_url
  get_backend_url
  get_frontend_port
  get_backend_port
  get_redis_port
}

software_update() {
  if ! get_empresa_atualizar; then
    return
  fi

  backup_instance
  update_instance_from_github
}

software_delete() {
  get_empresa_delete
  deletar_tudo
}

software_bloquear() {
  get_empresa_bloquear
  configurar_bloqueio
}

software_desbloquear() {
  get_empresa_desbloquear
  configurar_desbloqueio
}

software_dominio() {
  get_empresa_dominio
  get_alter_frontend_url
  get_alter_backend_url
  get_alter_frontend_port
  get_alter_backend_port
  configurar_dominio
}

inquiry_options() {
  print_banner
  printf "${YELLOW} 💻 Bem vindo(a) ao Gerenciador IUXI, Selecione abaixo a proxima ação!${GRAY_LIGHT}"
  printf "\n\n"
  printf "   [1] Instalar whaticket\n"
  printf "   [2] Atualizar whaticket\n"
  printf "\n"
  read -p "> " option

  case "${option}" in
    1) get_urls ;;
    2)
      software_update
      exit
      ;;
    *) exit ;;
  esac
}
