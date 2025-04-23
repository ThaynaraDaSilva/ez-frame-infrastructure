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

## 🧩 Desenho de Arquitetura

![image](https://github.com/user-attachments/assets/da998aa9-deb2-48fc-9025-06d3e1dfb0d1)

---

## 🎥 Vídeo de Apresentação da Arquitetura

[Desenho de Arquitetura](https://youtu.be/ry-GS9WqmaU)

---

## 📊 Modelagem do Banco de Dados

O `ez-video-ingestion-ms` utiliza o **DynamoDB** para armazenar metadados dos vídeos processados na tabela `video_metadata`. Estrutura da tabela:

- **Nome da Tabela**: `video_metadata`
- **Partition Key**: `videoId` (String, ex.: `vid123`)
- **Possui atributos, tais como**:
  - `originalFilename`: Nome do arquivo processado (String, ex.: `video_processed.mp4`)
  - `status`: Status do processamento (String, ex.: `COMPLETED`, `FAILED`)
  - `errorMessage`: Mensagem de erro, se aplicável (String, ex.: `Erro no processamento`)
  - `processedAt`: Data/hora do processamento (String, ex.: `2025-04-19T10:10:00Z`)
  - `resultObjectKey`: Guarda a presignedURL
 
**A criação do banco de dados ocorre via Terraform, sem a necessidade de execução de qualquer script a parte. O ambiente pode ser criado via pipeline.**

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

## ✅ Pré-requisitos para solução ez-frame (Todos os Microserviços)

- ☕ **Java 21**
- 📦 **Maven**
- 🔐 **Credenciais AWS configuradas no repositório como GitHub Secrets**  
  - `AWS_ACCESS_KEY_ID`  
  - `AWS_SECRET_ACCESS_KEY`
- 👤 **Criar UserPool e AppClient no Amazon Cognito**
- 📄 **Configurar as filas**:
  - `video-processing-queue`
  - `video-processing-queue-dlq`
- 📧 **Criar Entity (e-mail verificado) no Amazon SES**
- 🛡️ **Criar usuário IAM com política SES para envio de e-mails**  
  - Permissões necessárias: `ses:SendEmail` e `ses:SendRawEmail`
  - Exemplo de **policy JSON** para colar na criação da política no IAM:

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

Para este repositório, optamos por manter o pipeline trigger como workflow_dispatch para maior controle de quando a pipeline deve ser executada, devido ao custo e complexidade do ambiente.

---

## ✅ Requisito - Deploy dos Microsserviços

É necessário realizar o deploy dos microsserviços na seguinte ordem:

1. [Infra](https://github.com/ThaynaraDaSilva/ez-frame-infrastructure)
2. [Ingestion](https://github.com/ThaynaraDaSilva/ez-video-ingestion-ms)
3. [Generator](https://github.com/ThaynaraDaSilva/ez-frame-generator-ms)
4. [Notification](https://github.com/ThaynaraDaSilva/ez-frame-notification-ms)

---

## 🎥 Vídeos de apresentação

[📐 Desenho de Arquitetura](https://youtu.be/ry-GS9WqmaU)

[🔧 Github Rulesets, Pipelines e Sonarqube](https://youtu.be/jqO4ldizBwY)

[🔐 Jornada de Login e Upload de Vídeo](https://youtu.be/sk-AvQ9TnIw)

[📧 Jornada de Envio de Notificação](https://youtu.be/mE9PhuUo4Co)

[🖼️ Jornada de Geração de Frames](https://youtu.be/bfRUG1w-S8w)

---

## 👨‍💻 Desenvolvido por

@tchfer — RM357414  
@ThaynaraDaSilva — RM357418
