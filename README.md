# Paso 1:

Acceder a EC2 y crear una maquina virtual Ubuntu con 1GB RAM y 8GB almacenamiento.

# Paso 2:
Abrir puertos TCP y UDP 27015 en "Security Groups" con source 0.0.0.0/0

# Paso 3:

Crear una IP Elastica y asociarla a la instancia creada

# Paso 4:

Ir a key pais y descargar el .pem para poder acceder al ssh

# Paso 5:

Ir a Powershell y parado donde se encuentra el .pem ejecutar :
ssh -i "cs_server_key.pem" ubuntu@18.230.97.105

# Paso 6:
Parado en el home ejecutar :
git clone https://github.com/leonelf91/cs16.git

# Paso 7:

Instalar :
- Docker : https://phoenixnap.com/kb/how-to-install-docker-on-ubuntu-18-04
- Descargar imagen : docker pull febley/counter-strike_server (fuente: https://github.com/febLey/counter-strike_server)
- Docker-compose

# Paso 8:

Parado en el directorio cs16 :

sudo docker-compose up -d
