# Montagem e validação

## Escrita reversível

Capture bytes/hash de saída, chunks, manifests e registros que serão alterados.
Se a saída difere do último hash registrado, preserve uma cópia e compare a
semântica do DMM. Recupere edições válidas aos chunks antes de regenerar.
Identificadores do dicionário DMM podem mudar sem alterar a geometria.

No parser Nexus, cada stack precisa de exatamente um turf e uma área, depois
dos objetos. Dream Maker já produziu stacks com múltiplos turfs: isso pode
compilar no BYOND e falhar no parser estrito. Não apague o mapa nem remova turfs
arbitrariamente; examine os stacks afetados, preserve o original e normalize
apenas com semântica confirmada. Uma aprovação antiga de --apply não autoriza
descartar novas edições do usuário.

Gere para staging, valide, confira novamente os hashes dos insumos e aplique a
mudança coerente de chunks/saída/metadados. Faça a serialização determinística.
Não bypass o bloqueio de saída manual com flags de descarte como rotina.

## Invariantes úteis

- Componentes de água correspondem às bacias planejadas e ligam as quedas ao
  canal. A camada sob pontes participa desse teste; decks participam da circulação.
- Margens não ocupam água, ruas não invadem reservas e as transições de 4/8
  vizinhos correspondem às máscaras finais. Verifique costuras e cantos de chunks.
- BFS alcança os terraços e saídas previstos com a colisão real. Encontre a rota
  nos dados e caminhe-a no smoke quando houver mecânica afetada.
- Spawns e áreas de chegada preservam coordenadas e espaço transitável; mudar
  a textura do chão pode ser correto, restaurar coordenadas antigas não é.
- Turfs estruturais bloqueiam visão/passagem conforme o contrato, inclusive voo.
  Portais de caverna preservam o planeta, destino e retorno correto.
- Tiles têm dimensão correta, estados existentes, continuidade de material e
  fontes de edição. Registre orçamento de estados DMI/frames, turfs e objetos.

## Geração depois do load

Procure chamadas de GenerateFeatures, GenerateZone, GenerateCliffs, GenerateEdges,
GenerateShoreWaves, hooks New e rotinas de load/build. Execute a rota real de
decoração e chamadas diretas nos testes. Compare terreno e overlays antes/depois.
Teste também uma origem não protegida junto a água/solo protegido quando a
rotina escreve em vizinhos. Não limpe todos os overlays para resolver auto-edges.

No Nexus, a Terra já desativa auto_cliffs/auto_edges/auto_waves por área. Um mapa
novo de Viltrum também precisa de uma decisão explícita sobre essa política;
não presuma que herdou a proteção da Terra. Mantenha sombras/animações legítimas.

O renderer offline não executa todos os hooks de movimento, luz, animação e
decoração. Só declare aparência aprovada depois de feedback visual do usuário;
os testes automatizados fornecem evidência técnica, não gosto ou legibilidade.
