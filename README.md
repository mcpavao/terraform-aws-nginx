# Terraform AWS Ngnix 

![Terraform CI](https://github.com/mcpavao/terraform-aws-nginx/actions/workflows/terraform.yml/badge.svg)

Provisionamento de uma EC2 na AWS (eu-west-3, Paris) rodando nginx em container Docker, inteiramente descrito em código.

# COMO RODAR 

O output devolve o IP público. Para remover tudo: `terraform destroy`.

## Decisões

**Terraform em vez do console.** Infraestrutura em código é versionável, reproduzível e revisável. Um `apply` numa conta vazia recria o ambiente inteiro.

**Docker em vez de nginx direto no host.** Isola a aplicação do sistema operacional e torna o mesmo container portável para outro ambiente sem alteração.

**Security group como data source.** Reaproveitei um grupo existente na conta. Numa versão de portfólio completa, ele seria um `resource` gerenciado pelo Terraform, para que o projeto não dependa de nada criado manualmente.

**State fora do versionamento.** O `.gitignore` exclui o tfstate, que contém o inventário da infraestrutura e pode conter dados sensíveis.
EOF

**State remoto no S3.** O state é a fonte de verdade sobre o que existe na AWS. Mantê-lo apenas na máquina local significa depender dela e inviabilizar trabalho em equipe. O bucket tem versionamento habilitado, então um state corrompido ou apagado pode ser recuperado, e `encrypt = true` garante criptografia em repouso.

**Locking via `use_lockfile` em vez de DynamoDB.** O padrão até então era uma tabela DynamoDB para impedir dois `apply` simultâneos. A partir do Terraform 1.10 o lock é feito por arquivo no próprio S3, e o parâmetro `dynamodb_table` está depreciado. Adotei a forma atual, o que elimina um recurso da infraestrutura.

**Bucket criado via CLI, fora deste Terraform.** Dependência circular: o backend precisa existir antes do `terraform init`. A alternativa seria um projeto de bootstrap separado.

**Ansible em vez de `user_data`.** O `user_data` executa apenas uma vez, no primeiro boot: qualquer mudança de configuração exigiria recriar a instância. O playbook é idempotente e reexecutável na máquina viva, e separa responsabilidades — Terraform provisiona a infraestrutura, Ansible configura o que roda dentro dela.

**Inventário estático.** O IP é escrito no `inventory.ini` a partir do output do Terraform. A evolução natural seria o inventário dinâmico da AWS, que descobre as instâncias por tag.

**Chave pública como variável.** A primeira versão lia `~/.ssh/id_rsa.pub` com `file()`, o que acoplava a configuração à máquina local — o pipeline de CI falhou ao não encontrar o arquivo. Passando o conteúdo da chave como variável, o código deixa de depender do sistema de arquivos de quem executa.

## Como rodar

```bash
terraform apply -var="public_key=$(cat ~/.ssh/id_rsa.pub)"
printf '[web]\n%s ansible_user=ec2-user\n' "$(terraform output -raw public_ip)" > inventory.ini
ansible-playbook -i inventory.ini playbook.yml
```

Para remover tudo: `terraform destroy`.