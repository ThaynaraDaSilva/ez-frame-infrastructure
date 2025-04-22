# ⚙️ ez-frame-infrastructure

## 📌 Introdução

Este repositório contém a **configuração do ambiente na AWS** para os microsserviços **ez-video-ingestion-ms**, **ez-frame-generator-ms**, e **ez-frame-notification-ms** da solução **ez-frame**. Toda a infraestrutura, incluindo rede, computação, armazenamento, banco de dados, mensageria, autenticação e notificações, é provisionada via **Terraform**, garantindo uma gestão eficiente, modular e escalável.

Os principais recursos provisionados incluem:

- **Rede**: VPC, Internet Gateway, Subnets, NAT e Rotas.
- **Computação**: AWS EKS e seus Nodes para orquestração dos microsserviços.
- **Segurança**: Security Groups para controle de acesso e permissões IAM para serviços AWS.
- **Armazenamento**: AWS S3 para armazenamento de vídeos e arquivos ZIP (`ez-frame-video-storage`).
- **Banco de Dados**: AWS DynamoDB para armazenamento de metadados dos vídeos (`video_metadata`).
- **Mensageria**: AWS SQS para fila de processamento de vídeos (`video-processing-queue`).
- **Autenticação**: AWS Cognito para autenticação segura de usuários.
- **Notificações**: AWS SES para envio de e-mails em caso de falhas no processamento.

---

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
| **DynamoDB**                 | Armazenamento dos metadados           | Optamos pelo DynamoDB por ser altamente escalável e disponível, atendendo bem à necessidade de processar múltiplos vídeos em paralelo. Seu modelo NoSQL permite evoluir a estrutura dos dados sem migrações complexas, o que é útil caso futuramente a solução precise armazenar também os vídeos.     |
| **Amazon S3** | Armazenamento de vídeos e arquivos ZIP gerados | O S3 foi adotado por ser um serviço de armazenamento de objetos altamente durável, escalável e econômico, perfeito para armazenar vídeos enviados pelos usuários e arquivos ZIP gerados pelo `ez-frame-generator-ms` (bucket `ez-frame-video-storage`). Permite o compartilhamento seguro dos arquivos gerados via presigned URLs e suporta vídeos grandes e múltiplos uploads com facilidade. |

---

## 🎥 Vídeo de Apresentação da Arquitetura

[Desenho de Arquitetura](https://youtu.be/ry-GS9WqmaU)

## ✅ Pré-requisitos - Ambiente AWS

1. **Credenciais AWS** para permitir o provisionamento de recursos. No pipeline configurado no GitHub Actions, as credenciais foram armazenadas como secret variables para evitar exposição direta no código:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

2. **Execução da pipeline de criação de infraestrutura**. Para este repositório, optamos por manter o pipeline trigger como **workflow_dispatch** para maior controle de quando a pipeline deve ser executada, devido ao custo e complexidade do ambiente.

3. **Configuração do Amazon Cognito**:
   - Criar um **UserPool** e um **AppClient** para autenticação dos usuários no `ez-video-ingestion-ms`.

4. **Configuração do Amazon SES**:
   - Criar uma **entidade de e-mail verificado** para envio de notificações pelo `ez-frame-notification-ms`.

5. **Configuração de permissões IAM**:
   - Criar um usuário IAM com políticas para acesso aos serviços utilizados:
     - **SES**: Permissões `ses:SendEmail` e `ses:SendRawEmail`.
     - **S3**: Permissões para leitura/escrita no bucket `ez-frame-video-storage`.
     - **SQS**: Permissões para envio e consumo de mensagens na fila `video-processing-queue`.
     - **DynamoDB**: Permissões para leitura/escrita na tabela `video_metadata`.
   - Exemplo de **policy JSON** para SES (colar na criação da política no IAM):

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ses:SendEmail",
                "ses:SendRawEmail"
            ],
            "Resource": "*"
        }
    ]
}
```

## ✅ Requisito - Deploy dos Microsserviços

É necessário realizar o deploy dos microsserviços na seguinte ordem:

1. [Infra](https://github.com/ThaynaraDaSilva/ez-frame-infrastructure)
2. [Ingestion](https://github.com/ThaynaraDaSilva/ez-video-ingestion-ms)
3. [Generator](https://github.com/ThaynaraDaSilva/ez-frame-generator-ms)
4. [Notification](https://github.com/ThaynaraDaSilva/ez-frame-notification-ms)

## 👨‍💻 Desenvolvido por

@tchfer — RM357414  
@ThaynaraDaSilva — RM357418
