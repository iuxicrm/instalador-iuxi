#!/bin/bash
# 
# system management

#######################################
# creates user
# Arguments:
#   None
#######################################
system_create_user() {
  print_banner
  printf "${YELLOW} 💻 Agora, vamos criar o usuário para a instancia...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  # Check if user already exists
  if id "deploy" &>/dev/null; then
    echo "User deploy already exists"
  else
    # Create user with home directory and proper shell
    useradd -m -s /bin/bash deploy
    # Add to sudo group
    usermod -aG sudo deploy
    # Set password
    echo "deploy:${mysql_root_password}" | chpasswd
    # Ensure sudo works without password
    echo "deploy ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/deploy
  fi
EOF

  sleep 2
}

#######################################
# clones repostories using git
# Arguments:
#   None
#######################################
system_git_clone() {
  print_banner
  printf "${YELLOW} 💻 Fazendo download do código Whaticket...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  # Solicita username e token
  read -p "Digite seu GitHub username: " github_username
  read -s -p "Digite seu GitHub token: " github_token
  echo ""

  # Constrói link com autenticação
  if [[ $link_git == *"github.com"* ]]; then
    repo_url=$(echo "$link_git" | sed -E "s#https://#https://${github_username}:${github_token}@#")
    sudo -u deploy git clone "$repo_url" /home/deploy/${instancia_add}/
  else
    sudo -u deploy git clone "$link_git" /home/deploy/${instancia_add}/
  fi

  # Permissões
  sudo chown -R deploy:deploy /home/deploy/${instancia_add}

  sleep 2
}

#######################################
# updates system
# Arguments:
#   None
#######################################
system_update() {
  print_banner
  printf "${YELLOW} 💻 Vamos atualizar o sistema Whaticket...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -y
  apt-get upgrade -y
  apt-get install -y libxshmfence-dev libgbm-dev wget unzip fontconfig locales gconf-service \
    libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 \
    libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 \
    libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 \
    libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 \
    ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils
EOF

  sleep 2
}



#######################################
# delete system
# Arguments:
#   None
#######################################
deletar_tudo() {
  print_banner
  printf "${YELLOW} 💻 Vamos deletar o Whaticket...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  docker container rm redis-${empresa_delete} --force
  cd && rm -rf /etc/nginx/sites-enabled/${empresa_delete}-frontend
  cd && rm -rf /etc/nginx/sites-enabled/${empresa_delete}-backend  
  cd && rm -rf /etc/nginx/sites-available/${empresa_delete}-frontend
  cd && rm -rf /etc/nginx/sites-available/${empresa_delete}-backend
  
  sleep 2

  sudo su - postgres
  dropuser ${empresa_delete}
  dropdb ${empresa_delete}
  exit
EOF

sleep 2

sudo su - deploy <<EOF
 rm -rf /home/deploy/${empresa_delete}
 pm2 delete ${empresa_delete}-frontend ${empresa_delete}-backend
 pm2 save
EOF

  sleep 2

  print_banner
  printf "${YELLOW} 💻 Remoção da Instancia/Empresa ${empresa_delete} realizado com sucesso ...${GRAY_LIGHT}"
  printf "\n\n"


  sleep 2

}

#######################################
# bloquear system
# Arguments:
#   None
#######################################
configurar_bloqueio() {
  print_banner
  printf "${YELLOW} 💻 Vamos bloquear o Whaticket...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

sudo su - deploy <<EOF
 pm2 stop ${empresa_bloquear}-backend
 pm2 save
EOF

  sleep 2

  print_banner
  printf "${YELLOW} 💻 Bloqueio da Instancia/Empresa ${empresa_bloquear} realizado com sucesso ...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2
}


#######################################
# desbloquear system
# Arguments:
#   None
#######################################
configurar_desbloqueio() {
  print_banner
  printf "${YELLOW} 💻 Vamos Desbloquear o Whaticket...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

sudo su - deploy <<EOF
 pm2 start ${empresa_bloquear}-backend
 pm2 save
EOF

  sleep 2

  print_banner
  printf "${YELLOW} 💻 Desbloqueio da Instancia/Empresa ${empresa_desbloquear} realizado com sucesso ...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2
}

#######################################
# alter dominio system
# Arguments:
#   None
#######################################
configurar_dominio() {
  print_banner
  printf "${YELLOW} 💻 Vamos Alterar os Dominios do Whaticket...${GRAY_LIGHT}"
  printf "\n\n"

sleep 2

  sudo su - root <<EOF
  cd && rm -rf /etc/nginx/sites-enabled/${empresa_dominio}-frontend
  cd && rm -rf /etc/nginx/sites-enabled/${empresa_dominio}-backend  
  cd && rm -rf /etc/nginx/sites-available/${empresa_dominio}-frontend
  cd && rm -rf /etc/nginx/sites-available/${empresa_dominio}-backend
EOF

sleep 2

  sudo su - deploy <<EOF
  cd && cd /home/deploy/${empresa_dominio}/frontend
  sed -i "1c\REACT_APP_BACKEND_URL=https://${alter_backend_url}" .env
  cd && cd /home/deploy/${empresa_dominio}/backend
  sed -i "2c\BACKEND_URL=https://${alter_backend_url}" .env
  sed -i "3c\FRONTEND_URL=https://${alter_frontend_url}" .env 
EOF

sleep 2
   
   backend_hostname=$(echo "${alter_backend_url/https:\/\/}")

 sudo su - root <<EOF
  cat > /etc/nginx/sites-available/${empresa_dominio}-backend << 'END'
server {
  server_name $backend_hostname;
  location / {
    proxy_pass http://127.0.0.1:${alter_backend_port};
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_cache_bypass \$http_upgrade;
  }
}
END
ln -s /etc/nginx/sites-available/${empresa_dominio}-backend /etc/nginx/sites-enabled
EOF

sleep 2

frontend_hostname=$(echo "${alter_frontend_url/https:\/\/}")

sudo su - root << EOF
cat > /etc/nginx/sites-available/${empresa_dominio}-frontend << 'END'
server {
  server_name $frontend_hostname;
  location / {
    proxy_pass http://127.0.0.1:${alter_frontend_port};
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_cache_bypass \$http_upgrade;
  }
}
END
ln -s /etc/nginx/sites-available/${empresa_dominio}-frontend /etc/nginx/sites-enabled
EOF

 sleep 2

 sudo su - root <<EOF
  service nginx restart
EOF

  sleep 2

  backend_domain=$(echo "${backend_url/https:\/\/}")
  frontend_domain=$(echo "${frontend_url/https:\/\/}")

  sudo su - root <<EOF
  certbot -m $deploy_email \
          --nginx \
          --agree-tos \
          --non-interactive \
          --domains $backend_domain,$frontend_domain
EOF

  sleep 2

  print_banner
  printf "${YELLOW} 💻 Alteração de dominio da Instancia/Empresa ${empresa_dominio} realizado com sucesso ...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2
}

#######################################
# installs node
# Arguments:
#   None
#######################################
system_node_install() {
  print_banner
  printf "${YELLOW} 💻 Instalando nodejs...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
  apt-get install -y nodejs
  sleep 2
  npm install -g npm@latest
  sleep 2
  sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
  wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
  sudo apt-get update -y && sudo apt-get -y install postgresql
  sleep 2
  sudo timedatectl set-timezone America/Sao_Paulo
  
EOF

  sleep 2
}
#######################################
# installs docker
# Arguments:
#   None
#######################################
system_docker_install() {
  print_banner
  printf "${YELLOW} 💻 Instalando docker...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  apt install -y apt-transport-https \
                 ca-certificates curl \
                 software-properties-common

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"

  apt install -y docker-ce
EOF

  sleep 2
}

#######################################
# Ask for file location containing
# multiple URL for streaming.
# Globals:
#   WHITE
#   GRAY_LIGHT
#   BATCH_DIR
#   PROJECT_ROOT
# Arguments:
#   None
#######################################
system_puppeteer_dependencies() {
  print_banner
  printf "${YELLOW} 💻 Instalando puppeteer dependencies...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  apt-get install -y libxshmfence-dev \
                      libgbm-dev \
                      wget \
                      unzip \
                      fontconfig \
                      locales \
                      gconf-service \
                      libasound2 \
                      libatk1.0-0 \
                      libc6 \
                      libcairo2 \
                      libcups2 \
                      libdbus-1-3 \
                      libexpat1 \
                      libfontconfig1 \
                      libgcc1 \
                      libgconf-2-4 \
                      libgdk-pixbuf2.0-0 \
                      libglib2.0-0 \
                      libgtk-3-0 \
                      libnspr4 \
                      libpango-1.0-0 \
                      libpangocairo-1.0-0 \
                      libstdc++6 \
                      libx11-6 \
                      libx11-xcb1 \
                      libxcb1 \
                      libxcomposite1 \
                      libxcursor1 \
                      libxdamage1 \
                      libxext6 \
                      libxfixes3 \
                      libxi6 \
                      libxrandr2 \
                      libxrender1 \
                      libxss1 \
                      libxtst6 \
                      ca-certificates \
                      fonts-liberation \
                      libappindicator1 \
                      libnss3 \
                      lsb-release \
                      xdg-utils
EOF

  sleep 2
}

#######################################
# installs pm2
# Arguments:
#   None
#######################################
system_pm2_install() {
  print_banner
  printf "${YELLOW} 💻 Instalando pm2...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  npm install -g pm2

EOF

  sleep 2
}

#######################################
# installs snapd
# Arguments:
#   None
#######################################
system_snapd_install() {
  print_banner
  printf "${YELLOW} 💻 Instalando snapd...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  apt install -y snapd
  snap install core
  snap refresh core
EOF

  sleep 2
}

#######################################
# installs certbot
# Arguments:
#   None
#######################################
system_certbot_install() {
  print_banner
  printf "${YELLOW} 💻 Instalando certbot...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  apt-get remove certbot
  snap install --classic certbot
  ln -s /snap/bin/certbot /usr/bin/certbot
EOF

  sleep 2
}

#######################################
# installs nginx
# Arguments:
#   None
#######################################
system_nginx_install() {
  print_banner
  printf "${YELLOW} 💻 Instalando nginx...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  apt install -y nginx
  rm /etc/nginx/sites-enabled/default
EOF

  sleep 2
}

#######################################
# restarts nginx
# Arguments:
#   None
#######################################
system_nginx_restart() {
  print_banner
  printf "${YELLOW} 💻 reiniciando nginx...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  service nginx restart
EOF

  sleep 2
}

#######################################
# setup for nginx.conf
# Arguments:
#   None
#######################################
system_nginx_conf() {
  print_banner
  printf "${YELLOW} 💻 configurando nginx...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

sudo su - root << EOF

cat > /etc/nginx/conf.d/deploy.conf << 'END'
client_max_body_size 100M;
END

EOF

  sleep 2
}

#######################################
# installs nginx
# Arguments:
#   None
#######################################
system_certbot_setup() {
  print_banner
  printf "${YELLOW} 💻 Configurando certbot...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  backend_domain=$(echo "${backend_url/https:\/\/}")
  frontend_domain=$(echo "${frontend_url/https:\/\/}")

  sudo su - root <<EOF
  certbot -m $deploy_email \
          --nginx \
          --agree-tos \
          --non-interactive \
          --domains $backend_domain,$frontend_domain

EOF

  sleep 2
}

#######################################
# Lista todas as instalações e portas ocupadas
# Arguments:
#   None
#######################################
list_instalacoes() {
  print_banner
  printf "${YELLOW} 📋 Listando todas as instalações e portas ocupadas...${GRAY_LIGHT}"
  printf "\n\n"
  
  printf "${YELLOW}═══════════════════════════════════════════════════════════════${NC}\n"
  printf "${YELLOW}                    INSTALAÇÕES ATIVAS${NC}\n"
  printf "${YELLOW}═══════════════════════════════════════════════════════════════${NC}\n\n"
  
  instance_count=0
  
  # Buscar instâncias do diretório /home/deploy/
  if [ -d "/home/deploy" ]; then
    printf "${YELLOW}🔍 Instâncias encontradas em /home/deploy/:${NC}\n\n"
    
    for dir in /home/deploy/*/; do
      if [ -d "$dir" ]; then
        instance_name=$(basename "$dir")
        
        # Verificar se tem frontend e backend (é uma instalação whaticket)
        if [ -d "$dir/frontend" ] && [ -d "$dir/backend" ]; then
          instance_count=$((instance_count + 1))
          
          printf "${GREEN}📦 Instância: ${instance_name}${NC}\n"
          
          # Buscar portas dos arquivos .env
          frontend_port=""
          backend_port=""
          redis_port=""
          
          if [ -f "$dir/frontend/.env" ]; then
            frontend_port=$(grep -E "^PORT=" "$dir/frontend/.env" 2>/dev/null | cut -d'=' -f2 | tr -d ' ' | tr -d '"')
          fi
          
          if [ -f "$dir/backend/.env" ]; then
            backend_port=$(grep -E "^PORT=" "$dir/backend/.env" 2>/dev/null | cut -d'=' -f2 | tr -d ' ' | tr -d '"')
            redis_uri=$(grep -E "^REDIS_URI=" "$dir/backend/.env" 2>/dev/null | cut -d'=' -f2)
            if [ -n "$redis_uri" ]; then
              redis_port=$(echo "$redis_uri" | grep -oE ':[0-9]+' | cut -d':' -f2 | head -1)
            fi
          fi
          
          # Buscar portas do nginx se não encontrou no .env
          if [ -f "/etc/nginx/sites-available/${instance_name}-frontend" ]; then
            nginx_frontend_port=$(grep -oE 'proxy_pass http://127.0.0.1:[0-9]+' "/etc/nginx/sites-available/${instance_name}-frontend" 2>/dev/null | grep -oE '[0-9]+')
            if [ -n "$nginx_frontend_port" ]; then
              frontend_port="$nginx_frontend_port"
            fi
          fi
          
          if [ -f "/etc/nginx/sites-available/${instance_name}-backend" ]; then
            nginx_backend_port=$(grep -oE 'proxy_pass http://127.0.0.1:[0-9]+' "/etc/nginx/sites-available/${instance_name}-backend" 2>/dev/null | grep -oE '[0-9]+')
            if [ -n "$nginx_backend_port" ]; then
              backend_port="$nginx_backend_port"
            fi
          fi
          
          # Buscar porta do Redis Docker
          redis_container=$(docker ps -a --format "{{.Names}}" 2>/dev/null | grep "^redis-${instance_name}$" | head -1)
          if [ -n "$redis_container" ]; then
            docker_redis_port=$(docker port "$redis_container" 2>/dev/null | grep -oE '[0-9]+' | head -1)
            if [ -n "$docker_redis_port" ]; then
              redis_port="$docker_redis_port"
            fi
          fi
          
          [ -n "$frontend_port" ] && printf "   ${YELLOW}Frontend:${NC} Porta ${GREEN}$frontend_port${NC}\n" || printf "   ${YELLOW}Frontend:${NC} ${RED}Porta não encontrada${NC}\n"
          [ -n "$backend_port" ] && printf "   ${YELLOW}Backend:${NC} Porta ${GREEN}$backend_port${NC}\n" || printf "   ${YELLOW}Backend:${NC} ${RED}Porta não encontrada${NC}\n"
          [ -n "$redis_port" ] && printf "   ${YELLOW}Redis:${NC} Porta ${GREEN}$redis_port${NC}\n" || printf "   ${YELLOW}Redis:${NC} ${RED}Porta não encontrada${NC}\n"
          
          # Verificar status do PM2 - executar como usuário deploy
          if command -v pm2 &> /dev/null; then
            pm2_frontend=$(sudo su - deploy -c "pm2 list --no-color 2>/dev/null | grep '${instance_name}-frontend' | head -1" 2>/dev/null)
            pm2_backend=$(sudo su - deploy -c "pm2 list --no-color 2>/dev/null | grep '${instance_name}-backend' | head -1" 2>/dev/null)
            
            if [ -n "$pm2_frontend" ]; then
              status=$(echo "$pm2_frontend" | awk '{print $10}')
              printf "   ${YELLOW}PM2 Frontend:${NC} ${GREEN}${status}${NC}\n"
            else
              printf "   ${YELLOW}PM2 Frontend:${NC} ${RED}Não encontrado${NC}\n"
            fi
            if [ -n "$pm2_backend" ]; then
              status=$(echo "$pm2_backend" | awk '{print $10}')
              printf "   ${YELLOW}PM2 Backend:${NC} ${GREEN}${status}${NC}\n"
            else
              printf "   ${YELLOW}PM2 Backend:${NC} ${RED}Não encontrado${NC}\n"
            fi
          fi
          
          printf "\n"
        fi
      fi
    done
  fi
  
  if [ $instance_count -eq 0 ]; then
    printf "${YELLOW}Nenhuma instalação encontrada.${NC}\n\n"
  fi
  
  # Listar portas ocupadas (3000-5999)
  printf "${YELLOW}═══════════════════════════════════════════════════════════════${NC}\n"
  printf "${YELLOW}                   PORTAS OCUPADAS (3000-5999)${NC}\n"
  printf "${YELLOW}═══════════════════════════════════════════════════════════════${NC}\n\n"
  
  occupied_count=0
  for port in {3000..5999}; do
    if command -v ss &> /dev/null; then
      if ss -tuln 2>/dev/null | grep -q ":$port "; then
        occupied_count=$((occupied_count + 1))
        printf "   ${YELLOW}Porta $port${NC} - "
        # Tentar identificar qual processo está usando
        process=$(lsof -ti:$port 2>/dev/null | head -1)
        if [ -n "$process" ]; then
          process_name=$(ps -p "$process" -o comm= 2>/dev/null)
          printf "${GREEN}$process_name${NC}"
        else
          printf "${GREEN}Em uso${NC}"
        fi
        printf "\n"
      fi
    elif command -v netstat &> /dev/null; then
      if netstat -tuln 2>/dev/null | grep -q ":$port "; then
        occupied_count=$((occupied_count + 1))
        printf "   ${YELLOW}Porta $port${NC} - "
        process=$(lsof -ti:$port 2>/dev/null | head -1)
        if [ -n "$process" ]; then
          process_name=$(ps -p "$process" -o comm= 2>/dev/null)
          printf "${GREEN}$process_name${NC}"
        else
          printf "${GREEN}Em uso${NC}"
        fi
        printf "\n"
      fi
    fi
  done
  
  if [ $occupied_count -eq 0 ]; then
    printf "${YELLOW}Nenhuma porta ocupada encontrada no intervalo 3000-5999.${NC}\n"
  fi
  
  printf "\n"
  printf "${YELLOW}═══════════════════════════════════════════════════════════════${NC}\n\n"
  
  printf "${YELLOW}Pressione ENTER para continuar...${NC}\n"
  read -r
}

#######################################
# Lista containers Docker ativos
# Arguments:
#   None
#######################################
list_docker_containers() {
  print_banner
  printf "${YELLOW} 🐳 Listando containers Docker ativos...${GRAY_LIGHT}"
  printf "\n\n"
  
  # Verificar se Docker está instalado
  if ! command -v docker &> /dev/null; then
    printf "${RED}❌ Docker não está instalado!${NC}\n"
    printf "${YELLOW}Pressione ENTER para continuar...${NC}\n"
    read -r
    return 1
  fi
  
  # Verificar permissões Docker
  if ! docker ps &> /dev/null; then
    DOCKER_CMD="sudo docker"
    printf "${YELLOW}⚠ Usando sudo para acessar Docker...${NC}\n\n"
  else
    DOCKER_CMD="docker"
  fi
  
  printf "${YELLOW}═══════════════════════════════════════════════════════════════${NC}\n"
  printf "${YELLOW}                CONTAINERS DOCKER ATIVOS${NC}\n"
  printf "${YELLOW}═══════════════════════════════════════════════════════════════${NC}\n\n"
  
  # Listar containers rodando
  printf "${YELLOW}🟢 Containers em execução:${NC}\n\n"
  
  running_containers=$($DOCKER_CMD ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null)
  
  if [ -n "$running_containers" ]; then
    echo "$running_containers" | while IFS= read -r line; do
      if [[ "$line" == *"NAMES"* ]] || [[ "$line" == *"----"* ]]; then
        printf "${YELLOW}${line}${NC}\n"
      else
        container_name=$(echo "$line" | awk '{print $1}')
        printf "${GREEN}${line}${NC}\n"
      fi
    done
  else
    printf "${YELLOW}Nenhum container em execução.${NC}\n"
  fi
  
  printf "\n"
  
  # Listar containers parados
  printf "${YELLOW}🔴 Containers parados:${NC}\n\n"
  
  stopped_containers=$($DOCKER_CMD ps -a --filter "status=exited" --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.CreatedAt}}" 2>/dev/null)
  
  if [ -n "$stopped_containers" ]; then
    echo "$stopped_containers" | while IFS= read -r line; do
      if [[ "$line" == *"NAMES"* ]] || [[ "$line" == *"----"* ]]; then
        printf "${YELLOW}${line}${NC}\n"
      else
        printf "${RED}${line}${NC}\n"
      fi
    done
  else
    printf "${YELLOW}Nenhum container parado.${NC}\n"
  fi
  
  printf "\n"
  
  # Estatísticas
  printf "${YELLOW}═══════════════════════════════════════════════════════════════${NC}\n"
  printf "${YELLOW}                      ESTATÍSTICAS${NC}\n"
  printf "${YELLOW}═══════════════════════════════════════════════════════════════${NC}\n\n"
  
  total_containers=$($DOCKER_CMD ps -a -q 2>/dev/null | wc -l)
  running_count=$($DOCKER_CMD ps -q 2>/dev/null | wc -l)
  stopped_count=$($DOCKER_CMD ps -a --filter "status=exited" -q 2>/dev/null | wc -l)
  
  printf "   ${YELLOW}Total de containers:${NC} ${total_containers}\n"
  printf "   ${GREEN}Rodando:${NC} ${running_count}\n"
  printf "   ${RED}Parados:${NC} ${stopped_count}\n"
  
  printf "\n"
  
  # Listar containers do transcreveAPI especificamente
  printf "${YELLOW}═══════════════════════════════════════════════════════════════${NC}\n"
  printf "${YELLOW}              CONTAINERS TRANSCREVEAPI${NC}\n"
  printf "${YELLOW}═══════════════════════════════════════════════════════════════${NC}\n\n"
  
  transcreve_containers=$($DOCKER_CMD ps -a --format "{{.Names}}" 2>/dev/null | grep "transcreve-api" || true)
  
  if [ -n "$transcreve_containers" ]; then
    echo "$transcreve_containers" | while IFS= read -r container_name; do
      instance_name=$(echo "$container_name" | sed 's/^transcreve-api-//')
      container_status=$($DOCKER_CMD inspect --format='{{.State.Status}}' "$container_name" 2>/dev/null || echo "unknown")
      container_ports=$($DOCKER_CMD inspect --format='{{range $p, $conf := .NetworkSettings.Ports}}{{(index $conf 0).HostPort}}->{{$p}} {{end}}' "$container_name" 2>/dev/null || echo "N/A")
      
      printf "   ${YELLOW}Container:${NC} ${container_name}\n"
      printf "     ${YELLOW}Instância:${NC} ${instance_name}\n"
      
      if [ "$container_status" = "running" ]; then
        printf "     ${YELLOW}Status:${NC} ${GREEN}${container_status}${NC}\n"
      else
        printf "     ${YELLOW}Status:${NC} ${RED}${container_status}${NC}\n"
      fi
      
      printf "     ${YELLOW}Portas:${NC} ${container_ports}\n"
      printf "\n"
    done
  else
    printf "${YELLOW}Nenhum container transcreveAPI encontrado.${NC}\n"
  fi
  
  printf "${YELLOW}═══════════════════════════════════════════════════════════════${NC}\n\n"
  
  printf "${YELLOW}Pressione ENTER para continuar...${NC}\n"
  read -r
}
