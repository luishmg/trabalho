# Trabalho 17CLD
Obs:. Comentários preenchidos dentro de ++ devem ser completados de acordo com o seu ambiente
link do github: https://github.com/luishmg/trabalho

## Acesse o servidor apache-server
### Configurando o Servidor Apache
Digite os comandos abaixo para criar um usuário que possa utilizar o sudo sem precisar digitar a senha

Comando para conectar no servidor cliente caso já não esteja conectado no mesmo

    $ ssh +usuario+@+ip do servidor apache+

Essa sequencia de comandos serve para criar o usuário chef configurar uma senha para
mesmo e configurar o mesmo no sudoers

    $ sudo useradd -m -d /home/chef -c 'Chef User' -G sudo chef
    $ echo 'chef:tbfiap@2019' | sudo chpasswd
    $ sudo vim /etc/sudoers.d/chef

Adicione a linha abaixo dentro do arquivo:

chef ALL=(ALL) NOPASSWD:ALL

    $ sudo systemctl restart sshd

## Acesse o chef-server
### Criando um novo usuário e uma nova organização
obs:. Pule essa etapa caso já tenha um usuário e uma organização

Os comandos abaixo servem para criar um diretório comum para armazenar as chaves do chef,
criar o usuário e criar uma organização no chef server

    $ sudo mkdir /opt/chefkeys
    $ sudo chef-server-ctl user-create lgomes Luis Gomes luis.miyasiro.gomes@gmail.com 'tbfiap2019' --filename /opt/chefkeys/lgomes.pem
    $ sudo chef-server-ctl org-create llabs 'Luis Labs' --association_user lgomes --filename /opt/chefkeys/llabs.pem

### Configurando o chefdk e preparando os cookbooks

Os comandos servem para clonar os arquivos do github, instalar
o python e copiar a chave para dentro do diretório .chef

    $ git clone https://github.com/luishmg/trabalho.git 
    $ cd trabalho
    $ sudo apt-get update
    $ sudo apt-get install -y ruby

Agora vamos roda um script em ruby que gera um template padrão 
para trabalhar com o chefdk, coloca os arquivos dos cookbooks
dentro do templade e instala o chefdk caso o mesmo não esteja instalado

    $ ruby configureWorkstation.rb
    $ cp +Chave do seu usuário chef+.pem ~/.chef/
    $ cd ~/chef-repo
    $ knife configure -k ~/.chef/+chave do usuário chef+.pem -u +usuário chef+ --validation-client-name +usuário chef+ --validation-key ~/.chef/+chave do usuário chef+.pem -s "https://+ip do chef server+/organizations/+sigla da ornaização+" -r ~/chef-repo
    $ echo 'cookbook_path ["~/chef-repo/cookbooks"]' >> ~/.chef/knife.rb
    $ eval "$(chef shell-init bash)"
    $ echo -E 'eval "$(chef shell-init bash)"' >> ~/.bash_profile
    $ knife ssl fetch
    $ knife upload cookbooks/apachevh
    $ knife upload cookbooks/ctoaccess
    $ knife data bag create users && knife data bag from file users ctouser.json

### Instalando o chef-client via knife bootstrap

    $ knife bootstrap +ip do servidor apache+:22 -x chef -P tbfiap@2019 -N apache-server --sudo

### Adicionando cookbooks ao runlist do host

Esse comando faz com que a receita apachevh seja executada no apache-server

    $ knife node run_list add apache-server 'recipe[apachevh::default]'

Esse comando faz com que a receita ctoaccess seja executada no apache-server

    $ knife node run_list add apache-server 'recipe[ctoaccess::default]'

Digite os comando a seguir para logar no apache server e rodar o chefclient

    $ ssh chef@+ip do servidor apache+
    $ sudo chef-client

## Informações para o acesso do CTO
usuário: ctouser

senha: tbfiap@2019

port: 2022

## Endereços dos servidores
mbafiap.dev.com.br

mbafiap.qa.com.br

mbafiap.prod.com.br

### Colocar no /etc/hosts para testar
Você tem de digitar o comando a seguir e preencher o arquivo com a informação abaixo

    $ sudo vim /etc/hosts

+ip do servidor apache+ mbafiap.dev.com.br 

+ip do servidor apache+ mbafiap.qa.com.br 

+ip do servidor apache+ mbafiap.prod.com.br 
