RU na Palma da Mão

Descrição do Projeto

O RU na Palma da Mão é um aplicativo mobile desenvolvido como parte do Trabalho de Conclusão de Curso (TCC) de Wendell Rafael Oliveira Nascimento, sob a orientação de Wilkerson de Lucena Andrade, na UFCG. O objetivo do projeto é melhorar a gestão e o acesso ao Restaurante Universitário (RU), resolvendo problemas como:

Divulgação limitada do cardápio.

Ajustes frequentes devido à disponibilidade de produtos e demanda diária.

Falta de informações nutricionais acessíveis aos estudantes.


Com este aplicativo, os estudantes poderão consultar cardápios diários e semanais, visualizar informações nutricionais e planejar suas refeições. A administração terá ferramentas para ajustes dinâmicos do cardápio com notificações em tempo real.

Funcionalidades Principais

Para os estudantes:

Visualização de cardápios diários e semanais.

Exibição de informações nutricionais.

Planejamento de refeições com base em preferências alimentares.


Para a administração:

Controle dinâmico do cardápio.

Notificações em tempo real para atualizações.

Sistema de gerenciamento eficiente.



Tecnologias Utilizadas

Frontend:

Flutter (Dart)


Backend:

FastAPI (Python)

PostgreSQL (Banco de Dados)

Firebase (Autenticação e Notificações)


Infraestrutura:

Docker (Para containerização e facilidade de deploy)

AWS ou outra solução cloud (opcional, para escalabilidade futura)



Estrutura do Projeto

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

Como Executar

Backend (FastAPI)

1. Instale as dependências:

pip install -r backend/requirements.txt


2. Configure o banco de dados PostgreSQL:

Certifique-se de que o banco está rodando.

Atualize as variáveis de ambiente para a conexão com o banco.



3. Execute o backend:

uvicorn backend.app.main:app --reload



Frontend (Flutter)

1. Instale as dependências:

flutter pub get


2. Execute o frontend:

flutter run



Integração Firebase

Adicione o arquivo google-services.json (Android) e/ou GoogleService-Info.plist (iOS) na pasta apropriada do frontend.


Docker

Se preferir rodar os serviços com Docker:

1. Certifique-se de ter o Docker e o Docker Compose instalados.


2. Execute:

docker-compose up



Roadmap

Novembro/2024: Levantamento de requisitos.

Dezembro/2024: Prototipação da interface.

Janeiro a Março/2025: Desenvolvimento e integração de funcionalidades.

Abril/2025: Testes e validação.

Maio/2025: Finalização da documentação e entrega do TCC.


Autor

Wendell Rafael Oliveira Nascimento
Email: wendell.nascimento@ccc.ufcg.edu.br
Orientador: Wilkerson de Lucena Andrade

Licença

Este projeto está sob a licença MIT. Veja o arquivo LICENSE para mais detalhes.
