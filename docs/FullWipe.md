# Wipe completo

O servidor Docker usa `live` com recompensas de playtest desligadas. `Pwipe`
passa a significar uma nova wipe sem progresso herdado. A votação de wipe usa
o mesmo fluxo do comando administrativo.

## Escopo

| Estado | Resultado |
| --- | --- |
| Personagens, slots, Feats, skills, progression trees e grants | Apagados no ambiente ativo |
| Economia, bancos, recompensas, facções, cargos e Grand Regent | Zerados |
| Itens, NPCs persistidos, corpos, blueprints e decorações | Apagados |
| Construções, backups e segmentos de mapa, áreas e controle planetário | Apagados; retorna o mapa compilado |
| Ano, heróis, história, ranks e jobs | Reiniciados |
| Retratos, músicas e backups de hotkeys | Apagados |
| Administradores, bans, regras, notas, tela de login e logs | Preservados |
| Restrições de admins/hospedagem e políticas administrativas | Preservadas por allowlist |
| Configuração `GAIN` | Preservada |
| Demais ajustes de gameplay em `Misc` | Retornam aos padrões do código |

São removidos `Misc`, `Year`, `Hero`, `Ranks`, `Jobs`, `STORY`, `CustomDecors`,
o diretório legado `DBZ Character Saves/` e os arquivos de `data/`, incluindo
subdiretórios desconhecidos. As exceções em `data/` são `Logs/`, `Bugs`, o
sinalizador do inspetor de mídia e os saves/Feats/controle planetário do outro
ambiente. A separação desses namespaces não torna seguro compartilhar um
diretório de runtime entre live e playtest: mapas e estado global são comuns.

`Admin`, `BANS`, `Rules`, `Notes`, `Login Menu`, `GAIN`, `Errors.log`, credenciais
locais e artefatos do servidor ficam intactos. Em `Votes`, apenas `RP President`
é apagado; Head Admin e impedimentos de votação permanecem. `WipeAdministration`
guarda somente os campos administrativos permitidos de `Misc` para restaurá-los
quando o mundo inicia sem esse arquivo. Saves normais de `Misc` têm precedência
sobre esse snapshot nas inicializações seguintes.

## Execução e recuperação

1. `Pwipe` exige confirmação de um administrador de nível 4. O pedido é
   gravado em `.nexus-full-wipe.json` antes de bloquear logins e saves de jogadores.
2. O mundo salva os dados operacionais atuais, anuncia a limpeza e reinicia
   após 10 segundos. Saves de gameplay que terminem nesse intervalo também
   serão descartados.
3. No próximo startup, antes de carregar a persistência, o runtime confere o
   ambiente do pedido e limpa os arquivos. Os diretórios ficam disponíveis
   para os serviços de upload e para novos saves.
4. O marcador só é removido após sucesso. O log registra
   `NEXUS_FULL_WIPE_COMPLETED`; o mundo então inicializa com o mapa compilado.

Uma falha de exclusão ou um pedido inválido interrompe o startup com
`NEXUS_FULL_WIPE_FAILED`, mantendo o pedido. Corrija a permissão/caminho ou
restaure um backup consistente antes de reiniciar. A limpeza pode ter sido
parcial; não remova o marcador para liberar um mundo parcialmente apagado.
Repetir um pedido válido é seguro; sem marcador, o boot não repete o wipe.

O Compose usa o volume novo `nexus_live_state`; o volume antigo de playtest não
é apagado nem migrado. A cópia de dados operacionais entre volumes é uma etapa
separada da implantação. Alterar o código e publicar o PR não executa o wipe.

## Verificação

`runWorldWipeSmokeTests()` usa árvores de arquivos isoladas em
`data/.wipe-smoke/`, apenas no smoke automatizado. Exercita exclusão recursiva,
segmentos de mapa com lacunas, preservação administrativa, isolamento de
ambientes, duplicidade, pedidos inválidos e não repetição após conclusão.
O baseline também verifica inicialização limpa e com dados versionados.
