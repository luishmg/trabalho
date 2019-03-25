# Trabalho 17CLD
Valores correspondentes ao seu ambiente

link do github: https://github.com/luishmg/trabalho

Irei considerar nesse guia os IP's **10.0.2.4** para o chef server
e **10.0.2.5** para o chef client, caso o seu ambiente seja diferente substitua
de forma correspondente.

## Acesse o servidor chef client
### Configurando o servidor chef client 
Digite os comandos abaixo para criar um usuário que possa utilizar o sudo sem precisar digitar a senha

Comando para conectar no servidor cliente caso já não esteja conectado no mesmo, estaremos considerando
o usuário **chef-admin**, caso no seu ambiente seja diferente mude para o correspondente e mude o ip caso
o mesmo também não seja o correspondente.

    $ ssh chef-admin@10.0.2.5

Essa sequência de comandos serve para criar o usuário chef, configurar uma senha para o
mesmo e configurar o mesmo no sudoers

    $ sudo useradd -m -d /home/chef -c 'Chef User' -G sudo chef
    $ echo 'chef:tbfiap@2019' | sudo chpasswd
    $ sudo vim /etc/sudoers.d/chef

Adicione a linha abaixo dentro do arquivo:

chef ALL=(ALL) NOPASSWD:ALL

    $ sudo systemctl restart sshd

## Acesse o chef-server
### Criando um novo usuário e uma nova organização
obs.: Pule essa etapa caso já tenha um usuário e uma organização

Os comandos abaixo servem para criar um diretório comum para armazenar as chaves do chef,
criar o usuário e criar uma organização no chef server

    $ sudo chef-server-ctl user-create lgomes Luis Gomes luis.miyasiro.gomes@gmail.com 'tbfiap2019' --filename ~/lgomes.pem
    $ sudo chef-server-ctl org-create llabs 'Luis Labs' --association_user lgomes --filename /opt/chefkeys/llabs.pem

### Configurando o chefdk e preparando os cookbooks
obs.: caso tenha pulado o passo anterior mudar os campos lgomes pelo seu usuário, lgomes.pem
pela sua chave e llabs pela organização que você criou.

Os comandos servem para clonar os arquivos do github, instalar
o Ruby e copiar a chave para dentro do diretório .chef

    $ git clone https://github.com/luishmg/trabalho.git 
    $ cd trabalho
    $ sudo apt-get update
    $ sudo apt-get install -y ruby

Agora vamos roda um script em ruby que gera um template padrão 
para trabalhar com o chefdk, coloca os arquivos dos cookbooks
dentro do template e instala o chefdk caso o mesmo não esteja instalado, 
o script pode demorar um pouco para terminar a execução

    $ ruby configureWorkstation.rb
    $ cp ~/lgomes.pem ~/.chef/
    $ cd ~/chef-repo
    $ knife configure -k ~/.chef/lgomes.pem -u lgomes --validation-client-name lgomes --validation-key ~/.chef/lgomes.pem -s "https://10.0.2.4/organizations/llabs" -r ~/chef-repo
    $ echo 'cookbook_path ["~/chef-repo/cookbooks"]' >> ~/.chef/knife.rb
    $ eval "$(chef shell-init bash)"
    $ echo -E 'eval "$(chef shell-init bash)"' >> ~/.bash_profile
    $ knife ssl fetch
    $ knife upload cookbooks/apachevh
    $ knife upload cookbooks/ctoaccess
    $ knife data bag create users && knife data bag from file users ctouser.json

### Instalando o chef-client via knife bootstrap

    $ knife bootstrap 10.0.2.5:22 -x chef -P tbfiap@2019 -N apache-server --sudo

### Adicionando cookbooks ao runlist do host

Esse comando faz com que a receita apachevh seja executada no apache-server

    $ knife node run_list add apache-server 'recipe[apachevh::default]'

Esse comando faz com que a receita ctoaccess seja executada no apache-server

    $ knife node run_list add apache-server 'recipe[ctoaccess::default]'

Digite os comandos a seguir para logar no apache server e rodar o chefclient

    $ ssh chef@10.0.2.5
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

10.0.2.5 mbafiap.dev.com.br 

10.0.2.5 mbafiap.qa.com.br 

10.0.2.5 mbafiap.prod.com.br 
