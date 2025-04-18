# Introdução

Este repositório contém a **configuração do ambiente na AWS** para os microsserviços **order-ms**, **payment-ms**, **catalog-ms** e **user-ms** do projeto **ez-fastfood**. Toda a infraestrutura, incluindo rede, computação, banco de dados e mensageria, é provisionada via Terraform, garantindo uma gestão eficiente e modular.

Os principais recursos provisionados incluem:

- **Rede**: VPC, Internet Gateway, Subnets, NAT e Rotas.
- **Computação**: AWS EKS e seus Nodes.
- **Balanceamento de Carga**: Application Load Balancer (ALB).
- **Segurança**: Security Groups para controle de acesso.
- **Banco de Dados**:
  - AWS RDS Postgres para os microsserviços **order-ms**, **payment-ms** e **catalog-ms**.
  - AWS Document para o microsserviço **user-ms**.
- **Mensageria**: AWS SQS para fila de pagamento, utilizada por order-ms e payment-ms.

## Desenho de Arquitetura

![Image](https://github.com/user-attachments/assets/6e22f311-0201-40d3-b06a-1f95c494fb54)

## Video de apresentação da arquitetura

## Modelagem BD - Schema: EZ_FASTFOOD_ORDER
![Image](https://github.com/user-attachments/assets/90cf4f0f-7c17-4168-9abc-32a437f99866)

## Modelagem BD - Schema: EZ_FASTFOOD_PAYMENT
![Image](https://github.com/user-attachments/assets/ce4193ab-0e5b-462d-b161-ef04167c1b40)

## Modelagem BD - Schema: EZ_FASTFOOD_CATALOG
![Image](https://github.com/user-attachments/assets/34139a6d-bf65-4465-9b8e-083ba6519ffd)

## Mongo DB - Estrutura utilizada:
![Image](https://github.com/user-attachments/assets/a2a12a1b-ab29-40f8-88f7-7eb779c27344)

**OBS...**: Foram criados três schemas dentro de uma única instância de banco de dados para garantir o isolamento lógico dos microsserviços, ao mesmo tempo em que se otimiza os custos. Essa abordagem evita a necessidade de provisionar múltiplas instâncias de banco de dados, reduzindo o consumo de recursos da AWS e simplificando a administração da infraestrutura, sem comprometer a separação dos dados entre os serviços.

## 1. Pré requisitos - ambiente AWS

1. Credenciais AWS para permitir o provisionamento de recursos. No pipeline configurado no GitHub Actions, as credenciais foram armazenadas como secret variables para evitar exposição direta no código:
   - AWS_ACCESS_KEY_ID
   - AWS_SECRET_ACCESS_KEY
  
2. Execução da pipeline de criação de infraestrutura. Para este repositório, optamos por manter o pipeline trigger como **workflow_dispatch** para maior controle de quando a pipeline deve ser executada, devido a custo e complexidade do ambiente.

3. Execução manual do arquivo **postgres-dbs.sql**, disponível na raiz deste repositório: https://github.com/ThaynaraDaSilva/ez-fastfood-infrastructure. A execução deve ocorrer uma única vez, logo após a criação do recurso de banco de dados e antes de subir os microsserviços.

4. Criação manual do **sibling** e **collection**, igual a definição que está no arquivo **init-mongo.js**, disponível na raiz deste repositório. A execução deve ocorrer uma única vez, logo após a criação do recurso de banco de dados e antes de subir o microsserviço **user-ms**

## 2. Pré requisitos - deploy dos microsserviços

É necessário realizar deploy dos microsserviços nesta ordem:

1. ez-fastfood-user: https://github.com/ThaynaraDaSilva/ez-fastfood-user-ms 
2. ez-fastfood-catalog: https://github.com/ThaynaraDaSilva/ez-fastfood-catalog-ms
3. ez-fastfood-payment: https://github.com/ThaynaraDaSilva/ez-fastfood-payment-ms
4. ez-fastfood-order: https://github.com/ThaynaraDaSilva/ez-fastfood-order-ms

## Desenvolvido por:
@tchfer : RM357414<br>
@ThaynaraDaSilva : RM357418<br>