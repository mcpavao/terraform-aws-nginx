# Terraform AWS Ngnix 

Provisionamento de uma EC2 na AWS (eu-west-3, Paris) rodando nginx em container Docker, inteiramente descrito em código.

# COMO RODAR 

O output devolve o IP público. Para remover tudo: `terraform destroy`.

## Decisões

**Terraform em vez do console.** Infraestrutura em código é versionável, reproduzível e revisável. Um `apply` numa conta vazia recria o ambiente inteiro.

**Docker em vez de nginx direto no host.** Isola a aplicação do sistema operacional e torna o mesmo container portável para outro ambiente sem alteração.

**Security group como data source.** Reaproveitei um grupo existente na conta. Numa versão de portfólio completa, ele seria um `resource` gerenciado pelo Terraform, para que o projeto não dependa de nada criado manualmente.

**State fora do versionamento.** O `.gitignore` exclui o tfstate, que contém o inventário da infraestrutura e pode conter dados sensíveis.
EOF