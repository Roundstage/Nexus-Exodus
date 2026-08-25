# Inventário do pacote BYONDexe 516.1687

## Estado da Fase 0

- Data da verificação: 24 de agosto de 2026
- Branch: `feat/byondexe-phase-0`
- Commit de referência do jogo: `3b1da6dcb08359563fb20419af2fbde9a6acab79`
- Resultado: pacote oficial íntegro e documentação inventariada
- Desbloqueio do build: **não autorizado / bloqueado**
- Motivo: não há Hub oficial configurado no repositório e não foi possível confirmar acesso do proprietário à aba Distribution nem a existência de uma chave BYONDexe válida

Nenhum executável foi gerado ou executado. Nenhum binário BYOND foi adicionado ao repositório.

## Origem e integridade

| Campo | Valor |
| --- | --- |
| Arquivo | `516.1687_byondexe.zip` |
| Origem | `https://www.byond.com/download/build/516/516.1687_byondexe.zip` |
| Índice oficial | `https://www.byond.com/download/build/516/` |
| Publicação indicada pelo servidor | 13 de agosto de 2026, 21:25:05 GMT |
| Download local | 24 de agosto de 2026 |
| Tamanho | 7.405.533 bytes |
| SHA-256 | `fe2cb843ec8591269d7b0b43a1ae84b01dbd6edc2db4e22a7a0bbc03bd8b6c02` |
| Validação ZIP | todos os membros passaram em `unzip -t` |

O arquivo veio diretamente do domínio oficial, sem mirror. O índice oficial identifica o pacote 516.1687 e a página de download classifica 516.1687 como stable para Windows 10/11. A mesma página informa que o pacote Linux é apenas para desenvolvimento/hospedagem e que o cliente Windows requer WebView2 32-bit e os runtimes Visual C++.

## READMEs lidos integralmente

| Documento | Linhas | SHA-256 | Papel |
| --- | ---: | --- | --- |
| `README.txt` | 86 | `8c48f41b954e6752e10d15a5e4fcf31aa02ffe1a0cd39aa8ba7d4171b7cc4bb0` | Opções do gerador, outputs, atualização e instalador |
| `README-CONFIG.txt` | 697 | `a5db36c862105400af0fd0d498964232c6b7f2a16677b35e1d70c2bec9b37e83` | Splash/login, instalação local, cache, Hub e customização |

Os originais permanecem sem modificação na extração local usada nesta auditoria. Eles não foram copiados ao Git.

### Resumo de `README.txt`

- `key`, `byond`, `include` e `exe` são obrigatórios.
- `key` é específica do jogo e deve ser solicitada ao staff do BYOND.
- `byond` aponta para o diretório `bin` que contém Dream Seeker e DLLs do runtime.
- `include` aceita uma lista ordenada de diretórios. Arquivos posteriores substituem duplicatas anteriores.
- Arquivos `.rsc` incluídos recebem tratamento especial para importação no primeiro carregamento.
- `exe` gera um executável distribuível sem instalador. Na primeira execução, ele extrai o executável real para o diretório de usuário do BYOND.
- `out` cria a composição redistribuível usada pelo modo de instalador.
- `update` produz um ZIP de atualização sem `.rsc`; ele é aplicado conforme a Hub Version e Update URL do Hub.
- `install` usa NSIS e `install.nsh`; requer `out` e uma instalação local do NSIS.
- `icon`, `company`, `product` e `version` controlam ícone e metadados do executável.
- `version` espera `Major.Minor.Build.HubVersion` seguido de texto opcional. O quarto componente é comparado à Hub Version.
- A edição de versão depende do `verpatch.exe` incluído.

### Resumo de `README-CONFIG.txt`

- A skin standalone usa `hub.ini`, `hub.html`, `hub.css` e, opcionalmente, `live.css`/`livetest.html`.
- `hub.zip` deve ser o pacote regular criado pelo Dream Maker, contendo `.dmb`, `.rsc` e dependências. Ele é instalado localmente na primeira execução e depois removido.
- Um `.rsc` incluído é carregado no cache local. `PreloadRscUrl` acompanha mudanças futuras da URL de preload.
- Opções documentadas de `hub.ini`:
  - `WindowSize`
  - `Name`
  - `RequireUpdate` (`false`, `true`, `auto`)
  - `LoginFirst`
  - `LoginOptional`
  - `NoGuest`
  - `SkipSplash` (`false`, `true`, `launch`)
  - `PreloadRscUrl`
  - `IsServer`
  - `AutoControlFreak`
  - `CommandLine`
  - `DebugBrowser`
- `LoginOptional = true` permite entrada automática como Guest.
- `SkipSplash = true` exige `LoginOptional = true` e inicia diretamente a instalação local.
- `SkipSplash = launch` mantém o splash e abre jogos em outra instância.
- `CommandLine` é uma string de opções adicionais do runtime; o README cita apenas `-threads off`, `-map-threads off` e `-isserver`. Nenhuma flag de conexão remota foi inferida.
- `AutoControlFreak` vem habilitado por padrão e pode alterar o comportamento configurado pelo mundo.
- O HTML suporta blocos para jogos live, instalação local, servidores locais e escolha de servidor, além de links `pager://...` e `byond://[hub path]##local`.
- Os créditos do BYOND no diálogo About são exigidos pelo guia por razões legais.
- As funções e variáveis JavaScript documentadas personalizam apresentação, login, listagem, saves e callbacks; elas não constituem uma API de launcher externo.

## Inconsistências e lacunas documentais

1. `README-CONFIG.txt` ainda afirma que o browser embutido usa Internet Explorer. Isso está desatualizado para 516: o pacote contém `WebView2Loader.dll`, a página oficial exige WebView2 32-bit e as notas 516 dizem que os browser controls migraram para WebView2.
2. Os READMEs do ZIP não explicam App ID, `GetAPI()` ou `CheckPassport()`. A presença de `steam_api.dll` e as notas de release comprovam suporte Steam no runtime, mas não documentam como associar legitimamente um App ID ao build. Isso precisa ser esclarecido no Hub/Distribution ou com o BYOND antes do Gate B.
3. As notas 516.1668 registram que o BYONDexe passou a encaminhar argumentos de linha de comando vindos da Steam e introduziu `AutoControlFreak`. O pacote 516.1687 contém essa revisão de `mydream.exe`.
4. As notas 516.1680 registram correções de splash/WebView2 e de caminhos de instalação cirílicos.
5. As notas 516.1687 registram uma correção de race condition ao carregar `preload_rsc`; isso justifica usar 516.1687 em vez de 516.1686 para o spike.
6. O pacote não contém `hub.ini`, `hub.zip`, ícone de exemplo nem um arquivo específico de configuração Steam/App ID. Esses itens dependem do jogo e/ou do fluxo autorizado no Hub.

## Inventário de arquivos

Todos os executáveis e DLLs são PE32 x86. Isso é coerente com a exigência do runtime WebView2 32-bit.

| Caminho relativo | Tamanho (bytes) | SHA-256 |
| --- | ---: | --- |
| `byondexe.exe` | 529.408 | `d02847c9183e69600dce7632eaa87bb760ff1761a7fd892e611745748e3eea5f` |
| `byondexe.ini` | 246 | `7fd7150acef73629badc55149ae78846e70ed671e707f522a614fee535419020` |
| `install.nsh` | 8.544 | `e4e9c9b7433950bf8f3a41e5f3b5036a8e13b8c2e1680b176108e13fdc2ecb23` |
| `README.txt` | 4.294 | `8c48f41b954e6752e10d15a5e4fcf31aa02ffe1a0cd39aa8ba7d4171b7cc4bb0` |
| `README-CONFIG.txt` | 24.070 | `a5db36c862105400af0fd0d498964232c6b7f2a16677b35e1d70c2bec9b37e83` |
| `verpatch.exe` | 110.592 | `a8138a96dd8cc8ef15a545ecb41dede54ed1ebfc9260f133bcbffe47343ba077` |
| `setup/bin/byondcore.dll` | 4.481.536 | `4ff6f320d0c63f006f9330cf2a8ddf855ee46c2d5952aae2a0e38e2da9ae1aa4` |
| `setup/bin/byondext.dll` | 1.976.320 | `99b64bd00d97a21cd3bc5252c52a49b991bf6292abed16802bf035654f771912` |
| `setup/bin/byondwin.dll` | 2.720.768 | `975a1d54ebde8015eccad3ab0db589ba0c3f79304f74c0300e923d3213d12c91` |
| `setup/bin/dd.exe` | 38.400 | `2e3815875c4dcf3c50de70c1c6e017849efe8697c428f02ab9ee77c306c8abf0` |
| `setup/bin/dreamseeker.exe` | 881.152 | `abfd4412e0e22d2e91fb919bd6c1bed449aaf0a909242ea73a63deb9f2f614fa` |
| `setup/bin/mydream.exe` | 1.199.616 | `bf6c27e43680a29a85d5e09014629743651265d61fea08a1ddd086b2e18387d6` |
| `setup/bin/fmodex.dll` | 381.440 | `70d2fb7c17820dd3671f4481dc37b4bc386313a9d8ec5fa73cd2dac375b27312` |
| `setup/bin/steam_api.dll` | 239.904 | `ce6f48938493b90ffa175fc93f2b8ee5189e5db81f1274d5b57c9841d6fe4179` |
| `setup/bin/WebView2Loader.dll` | 117.328 | `93894609e3365b62fbb4d5b4219b4199a271888160669c33dbaadbbaf5aff087` |
| `setup/cfg/hub.css` | 6.644 | `e549d327443d460389f6c39922a3ae7d24b79259c86c242c1d0518ee27477572` |
| `setup/cfg/hub.html` | 421 | `a7bfcfc6dde4c357236876f654288b0a9931e9d15b61e3354fd0cf93d826b0ab` |
| `setup/livetest.html` | 86.572 | `c4bdb4839125af9368b993abc12a7b77ca68be2002293b5629f58d2f4f2be103` |
| `setup/bin/directx/DSETUP.dll` | 89.944 | `def6f245762be36cf18b435ba8b7ebc224b9c21d1a1db606a8e8fafdaa97bba0` |
| `setup/bin/directx/dsetup32.dll` | 1.801.048 | `642d9e7db6d4fc15129f011dce2ea087bf7f7fb015aececf82bf84ff6634a6fb` |
| `setup/bin/directx/DXSETUP.exe` | 537.432 | `046041aba6ba77534c36bb0c2496408d23c6a09f930c46b392f1edc70dfd66de` |
| `setup/bin/directx/dxupdate.cab` | 94.011 | `13393a91201e69e70a9f68d21428453fff3951535dec88f879270269cfe54d6f` |
| `setup/bin/directx/Jun2010_D3DCompiler_43_x86.cab` | 931.471 | `417eebd5b19f45c67c94c2d2ba8b774c0fc6d958b896d7b1ac12cf5a0ea06e0e` |
| `setup/bin/directx/Jun2010_d3dx9_43_x86.cab` | 768.036 | `fcc6cf0966b4853d6fa3d32ab299cde5a9824feaecb0d4f34ea452fb9fd1c867` |

### Função dos componentes

- `byondexe.exe`: gerador comandado por `byondexe.ini`.
- `mydream.exe`: wrapper/template standalone repurposed pelo gerador.
- `dreamseeker.exe` e DLLs BYOND: runtime do cliente.
- `dd.exe`: componente de Dream Daemon incluído no runtime standalone.
- `steam_api.dll`: componente Steam distribuído oficialmente no conjunto BYONDexe; sua mera presença não confirma App ID ou licença do Nexus.
- `WebView2Loader.dll`: loader x86 do browser embutido.
- `fmodex.dll`: runtime de áudio, comprimido com UPX no pacote oficial.
- `directx/*`: redistribuível legado DirectX June 2010 x86.
- `install.nsh`: template NSIS. Solicita nível administrativo, instala runtime Visual C++ x86 quando ausente e oferece componentes de atalhos e DirectX.
- `verpatch.exe`: ferramenta de terceiros usada para metadados/versionamento do executável.
- `setup/cfg/*`: skin padrão que deve ser sobrescrita pela configuração do jogo.

## Configuração-base confirmada

O template oficial entregue no ZIP é:

```ini
key = KEY_FROM_BYOND
byond = setup/bin
include = setup/cfg
exe = game.exe

#out = MyGame
#update = game_update.zip
#install = game_install.exe
#icon = setup/myicon.ico

company = My Company
product = MyGame Beta
version = 1.0.0.1 beta
```

A configuração candidata do plano é compatível em estrutura, mas não deve ser materializada com chave antes da autorização. `hub.zip` deve ser colocado dentro de um diretório alcançado por `include`, tipicamente `setup/cfg`, e precisa vir do empacotamento do Dream Maker.

## Hub e chave Distribution

### Evidência local

O arquivo `SECRETS.dm` contém atualmente:

```dm
SECRETS_HUB_NAME = ""
SECRETS_HUB_PASSWORD = ""
```

Assim, o código atual não identifica um Hub oficial do Nexus Exodus. O acesso à conta do proprietário e à aba Distribution é estado externo e não pode ser confirmado pelo repositório ou por páginas públicas.

### Bloqueador

Antes de qualquer build BYONDexe, o proprietário precisa fornecer de forma privada:

1. o caminho do Hub oficial do Nexus Exodus;
2. confirmação de que controla a entrada;
3. confirmação de que a aba Distribution está disponível;
4. uma chave BYONDexe válida obtida do BYOND Staff/Distribution, por canal seguro;
5. orientação oficial caso a aba ou chave não exista.

A chave não deve ser enviada em chat, adicionada ao Git, escrita em relatório ou impressa em logs. A Fase 1 permanece bloqueada até essa confirmação.

## Dependências e comportamento de instalação

- Plataforma do pacote: Windows x86, apesar de poder rodar em Windows x86-64.
- Sistemas oficialmente indicados: Windows 10/11.
- Dependências externas: WebView2 32-bit e Visual C++ Redistributable x86.
- O template NSIS pode baixar `vc_redist.x86.exe` de `https://aka.ms/vs/17/release/vc_redist.x86.exe`.
- O template oferece instalação do DirectX June 2010 incluído no pacote.
- O executável sem instalador extrai o runtime real para o diretório de usuário BYOND na primeira execução.
- O local exato do cache e o bug de criação de `Documents/BYOND/bin` devem ser medidos no Gate A em perfil Windows limpo; não foram testados na Fase 0.
- A distribuição de DLLs isoladas fora do fluxo gerado não foi autorizada nem realizada.

## Entradas necessárias para a Fase 1

| Entrada | Estado |
| --- | --- |
| BYONDexe oficial 516.1687 e hash | Confirmado |
| READMEs atuais | Confirmados e lidos |
| Runtime Windows x86 do pacote | Confirmado |
| Hub oficial do Nexus | Ausente/não confirmado |
| Acesso proprietário à Distribution | Não confirmável localmente |
| Chave BYONDexe | Não fornecida; obrigatória |
| Pacote `hub.zip` do Dream Maker 516.1687 | Não gerado, por instrução |
| Ícone `.ico` adequado | Não preparado nesta fase |
| Windows limpo para Gate A | Não disponível nesta fase |
| App ID Steam autorizado | Não necessário para Gate A; não confirmado |

## Decisão da Fase 0

**STOP antes do build.** O pacote oficial e o fluxo básico são tecnicamente adequados para iniciar Gate A, mas as entradas de autorização não estão completas. Não criar `NexusExodus.exe`, templates com secret, probe Steam, launcher Tauri ou teste Proton até que o Hub e a chave Distribution sejam confirmados.

## Referências oficiais

- Arquivo BYOND 516: <https://www.byond.com/download/build/516/>
- Pacote auditado: <https://www.byond.com/download/build/516/516.1687_byondexe.zip>
- Download BYOND: <https://www.byond.com/download/>
- Notas BYOND 516: <https://www.byond.com/docs/notes/516.html>
- Configuração histórica publicada pelo BYOND: <https://www.byond.com/forum/post/1487009>
- Referência DM: <https://www.byond.com/docs/ref/info.html>
