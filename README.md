# Medicamento

Aplicativo mobile desenvolvido com Flutter para cadastrar, visualizar e acompanhar medicamentos no dia a dia.

Os dados são armazenados localmente em um banco SQLite, permitindo que a lista continue disponível mesmo após fechar o aplicativo.

## Funcionalidades

- Cadastrar medicamentos com nome, dosagem e horário/observação.
- Evitar cadastros semelhantes por meio de uma confirmação antes de salvar.
- Listar os medicamentos em ordem alfabética.
- Visualizar os detalhes de cada medicamento.
- Editar os dados cadastrados.
- Excluir medicamentos com confirmação.
- Marcar um medicamento como tomado ou não tomado.
- Registrar automaticamente a data e o horário da última marcação como tomado.

## Tecnologias

- [Flutter](https://flutter.dev/)
- [Dart](https://dart.dev/)
- [SQLite](https://www.sqlite.org/) com o pacote `sqflite`
- Material Design

## Estrutura do projeto

```text
lib/
├── main.dart
├── database/
│   └── dao_medication.dart
├── models/
│   └── medication_model.dart
└── screens/
    ├── form_screen.dart
    ├── home_screen.dart
    └── medication_detail_screen.dart
```

- `main.dart`: configuração do aplicativo e tema.
- `models/medication_model.dart`: modelo dos dados do medicamento.
- `database/dao_medication.dart`: criação e operações do banco SQLite.
- `screens/home_screen.dart`: lista principal e ações rápidas.
- `screens/form_screen.dart`: cadastro e edição.
- `screens/medication_detail_screen.dart`: detalhes e alteração do status.

## Armazenamento

O aplicativo usa o banco local `listmedications.db` e cria automaticamente a tabela `medications` na primeira execução.

Campos armazenados:

| Campo | Tipo | Descrição |
| --- | --- | --- |
| `id` | INTEGER | Identificador gerado automaticamente |
| `name` | TEXT | Nome do medicamento |
| `dosage` | TEXT | Dosagem |
| `schedule` | TEXT | Horário ou observação, opcional |
| `is_taken` | BOOLEAN | Indica se o medicamento está marcado como tomado |
| `taken_at` | TEXT | Data e horário registrados no formato ISO 8601 |

## Pré-requisitos

- Flutter SDK configurado no ambiente
- Dart SDK incluído na instalação do Flutter
- Dispositivo físico ou emulador Android/iOS
- Para Android: Android Studio e ferramentas do SDK

O projeto utiliza o SDK do Dart `^3.13.0` e o pacote `sqflite ^2.4.6`.

## Como executar

1. Clone o repositório:

   ```bash
   git clone https://github.com/juvenal2022/medicamento.git
   cd medicamento
   ```

2. Instale as dependências:

   ```bash
   flutter pub get
   ```

3. Inicie o aplicativo:

   ```bash
   flutter run
   ```

Para executar em uma plataforma específica:

```bash
flutter run -d android
flutter run -d ios
```

## Verificação

Antes de enviar alterações, execute:

```bash
flutter analyze
```

## Aplicativo

Versão atual: `0.1.0+1`

## Autor

Projeto desenvolvido para fins acadêmicos na disciplina de Programação para Dispositivos Móveis I da Fatec.
