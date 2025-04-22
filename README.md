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

![image](https://github.com/user-attachments/assets/da998aa9-deb2-48fc-9025-06d3e1dfb0d1)

## 🧱 Componentes da Solução Global ez-frame

| **Componente** | **Finalidade** | **Justificativa** |
| --- | --- | --- |
| **Clean Architecture** | Organização interna da solução | Foi escolhida para garantir uma estrutura modular, de fácil manutenção e testes. Essa separação clara entre regras de negócio e infraestrutura facilita a escalabilidade da solução ao longo do tempo, conforme o sistema evolui. |
| **Java 21** | Linguagem principal para implementação | A linguagem Java foi adotada em substituição ao .NET por uma decisão estratégica, considerando a expertise da equipe com o ecossistema Java. Essa escolha visa otimizar o desenvolvimento, reduzir a curva de aprendizado e garantir eficiência na evolução e manutenção da solução. |
| **Apache Maven** | Gerenciamento de dependências e build | Ferramenta amplamente utilizada no ecossistema Java, facilita a organização do projeto, o versionamento de dependências e o processo de build e deploy. |
| **Amazon EKS** | Orquestração dos microsserviços da solução | Solução gerenciada baseada em Kubernetes, que facilita o deploy, a escalabilidade e o gerenciamento dos microsserviços (`generator`, `ingestion`, `notification`), mantendo a consistência da infraestrutura. |
| **Amazon SES** | Envio de e-mails de notificação em caso de erro | Atende ao requisito de notificação automática para o usuário em caso de falha no processamento. É um serviço simples, eficiente e com baixo custo, ideal para esse tipo de comunicação. |
| **GitHub Actions** | Automatização de build, testes e deploys | O GitHub Actions foi escolhido por estar amplamente consolidado no mercado e por oferecer uma integração direta com repositórios GitHub, simplificando pipelines de entrega contínua. Além disso, a equipe já possui familiaridade com a ferramenta, o que reduz tempo de configuração e acelera o processo de entrega contínua. |
| **Amazon Cognito**           | Autenticação e segurança no microsserviço de usuários                          | Solução gerenciada que facilita a implementação de autenticação com usuário e senha, atendendo ao requisito de proteger o sistema e controlando o acesso de forma segura e padronizada.                                                                                                               |
| **Amazon SQS**               | Gerenciamento da fila de processamento de vídeos                               | Utilizamos SQS para garantir que os vídeos sejam processados de forma assíncrona e segura, sem perda de requisições, mesmo em momentos de pico. Isso também ajuda a escalar o sistema com segurança.                                                                                                   |
| **DynamoDB**                 | Armazenamento dos metadados e arquivos gerados (como ZIPs de frames)           | Optamos pelo DynamoDB por ser altamente escalável e disponível, atendendo bem à necessidade de processar múltiplos vídeos em paralelo. Seu modelo NoSQL permite evoluir a estrutura dos dados sem migrações complexas, o que é útil caso futuramente a solução precise armazenar também os vídeos.     |
| **Amazon S3** | Armazenamento de vídeos e arquivos ZIP gerados | O S3 foi adotado por ser um serviço de armazenamento de objetos altamente durável, escalável e econômico, perfeito para armazenar vídeos enviados pelos usuários e arquivos ZIP gerados pelo `ez-frame-generator-ms` (bucket `ez-frame-video-storage`). Permite o compartilhamento seguro dos arquivos gerados via presigned URLs e suporta vídeos grandes e múltiplos uploads com facilidade. |

## Video de apresentação da arquitetura

[Desenho de Arquitetura](https://youtu.be/ry-GS9WqmaU)

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
