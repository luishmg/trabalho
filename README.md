# Trabalho 17CLD
Obs:. Comentários preenchidos dentro de ++ devem ser completados de acordo com o seu ambiente

## Acesse o servidor apache-server
### Configurando o Servidor Apache
$ ssh +usuario+@+apache server IP+

$ sudo useradd -m -d /home/chef -c 'Chef User' -G sudo chef

$ echo 'chef:tbfiap@2019' | sudo chpasswd

$ sudo visudo 

adicione a linha abaixo dentro do arquivo

chef ALL:(ALL) NOPASSWD:ALL

$ sudo systemctl restart sshd

## Acesse o chef-server
### Criando um novo usuário e uma nova organização
$ sudo mkdir /opt/chefkeys

$ sudo chef-server-ctl user-create lgomes Luis Gomes luis.miyasiro.gomes@gmail.com 'tbfiap2019' --filename /opt/chefkeys/lgomes.pem

$ sudo chef-server-ctl org-create llabs 'Luis Labs' --association_user lgomes --filename /opt/chefkeys/llabs.pem

## Utilize o chef-server ou workstation
### Configurando workstation
$ git clone https://github.com/luishmg/trabalho.git 

$ cd 17cld-trabalho

$ ruby configureWorkstation.rb

$ eval "$(chef shell-init bash)"

$ echo -E 'eval "$(chef shell-init bash)"' >> ~/.bash_profile

$ knife ssl fetch

$ cd ~/chef-repo 

$ knife upload cookbooks/apachevh

$ knife upload cookbooks/ctoaccess

$ knife data bag create users && knife data bag from file users ctouser.json

### Instalando o chef-client via knife bootstrap
$ knife bootstrap +apache server IP+:22 -x chef -P tbfiap@2019 -N apache-server

### Adicionando cookbooks ao runlist do host
$ knife bootstrap +apache server IP+:22 -x chef -P tbfiap@2019 -N apache-server --sudo

$ knife node run_list add apache-server 'recipe[apachevh::default]'

$ knife node run_list add apache-server 'recipe[ctoaccess::default]'

$ knife ssh 'name:apache-server' 'sudo chef-client' -x chef

## Informações para o acesso do CTO
usuário: ctouser

senha: tbfiap@2019

port: 2022

## Endereços dos servidores
mbafiap.dev.com.br

mbafiap.qa.com.br

mbafiap.prod.com.br

### Colocar no /etc/hosts para testar
+apache server ip+ mbafiap.dev.com.br 

+apache server ip+ mbafiap.qa.com.br 

+apache server ip+ mbafiap.prod.com.br 
