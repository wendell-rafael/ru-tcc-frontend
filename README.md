# RU na Palma da Mão

## Descrição do Projeto

O **RU na Palma da Mão** é um aplicativo mobile desenvolvido como parte do Trabalho de Conclusão de Curso (TCC) de Wendell Rafael Oliveira Nascimento, sob a orientação de Wilkerson de Lucena Andrade, na UFCG. O objetivo do projeto é melhorar a gestão e o acesso ao Restaurante Universitário (RU), resolvendo problemas como:

- Divulgação limitada do cardápio.
- Ajustes frequentes devido à disponibilidade de produtos e demanda diária.
- Falta de informações nutricionais acessíveis aos estudantes.

Com este aplicativo, os estudantes poderão consultar cardápios diários e semanais, visualizar informações nutricionais e planejar suas refeições. A administração terá ferramentas para ajustes dinâmicos do cardápio com notificações em tempo real.

## Funcionalidades Principais

- **Para os estudantes:**
  - Visualização de cardápios diários e semanais.
  - Exibição de informações nutricionais.
  - Planejamento de refeições com base em preferências alimentares.

- **Para a administração:**
  - Controle dinâmico do cardápio.
  - Notificações em tempo real para atualizações.
  - Sistema de gerenciamento eficiente.

## Tecnologias Utilizadas

- **Frontend:**
  - Flutter (Dart)

- **Backend:**
  - FastAPI (Python)
  - PostgreSQL (Banco de Dados)
  - Firebase (Autenticação e Notificações)

- **Infraestrutura:**
  - Docker (Para containerização e facilidade de deploy)
  - AWS ou outra solução cloud (opcional, para escalabilidade futura)

## Estrutura do Projeto

```plaintext
ru-tcc/
├── backend/          # Código do backend (FastAPI)
│   ├── app/          # Lógica principal do backend
│   ├── requirements.txt  # Dependências do backend
│   └── Dockerfile     # Configuração para containerização
├── frontend/         # Código do frontend (Flutter)
│   ├── lib/          # Código principal do Flutter
│   ├── pubspec.yaml  # Configurações e dependências do Flutter
│   └── Dockerfile    # Configuração para containerização
├── db/               # Scripts e configurações do banco de dados
├── docker-compose.yml # Configuração para orquestração dos serviços
└── README.md         # Documento atual