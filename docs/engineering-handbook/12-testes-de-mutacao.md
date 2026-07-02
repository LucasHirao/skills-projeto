# 12 — Testes de mutação

> **Versão:** 1.0  
> **Última atualização:** julho/2026  
> **Escopo:** mutation testing transversal na plataforma `{nome-projeto}` (multi-repo)

---

## Objetivo

Definir **como aplicamos mutation testing** para medir qualidade real dos testes unitários: meta **90% mutation score** em módulos de lógica de negócio. Cobertura de linha sozinha não basta — mutation verifica se os testes **falhariam** se o código mudasse.

Mutation testing responde: *"seu teste detecta bugs ou só executa o código?"*

---

## Para quem serve

| Público | Uso |
|---------|-----|
| **Desenvolvedor(a)** | Rodar mutmut/PIT localmente |
| **Revisor** | Exigir testes que matam mutantes |
| **Plataforma** | Gate de CI e exclusões padronizadas |
| **Júnior** | Entender mutante sobrevivente |
| **Sênior** | Escopo de mutation e exceções |

---

## Problemas que estes padrões resolvem

| Problema | Sintoma | Mutation detecta |
|----------|---------|------------------|
| Assert fraco | `assert result is not None` | Mutante altera valor, teste passa |
| Teste ausente em branch | Coverage 90% com `if` não testado | Mutante inverte condição |
| Teste de mock apenas | Mock retorna fixo | Código real quebrado |
| Regressão silenciosa | PR verde com bug | Mutante equivalente ao bug |

---

## Princípios

1. **90% mutation score** em `domain/`, `application/`, `transforms/` — onde há lógica.
2. **Complemento à cobertura** — não substitui TaaC ([11](11-taac-testes-integrados-na-pipeline.md)).
3. **Escopo focado** — não rodar mutation em DTO, config, handler fino.
4. **CI gate** — PR falha se score abaixo do threshold no escopo definido.
5. **Mutante sobrevivente = bug de teste** — corrigir teste ou documentar exceção rara.
6. **Tempo aceitável** — rodar em módulos focados, não no monólito inteiro.
7. **Mesmas regras multi-repo** — cada repo configura sua ferramenta.

---

## Decisões arquiteturais

| Stack | Ferramenta | Escopo mutation |
|-------|------------|-----------------|
| Python | mutmut | `src/domain`, `src/application`, `transforms/` |
| Java | PIT (pitest-maven) | `domain.*`, `application.*` |
| Glue | mutmut em transforms puras | Sem SparkSession |
| Lambda | mutmut | domain + application |
| Airflow | Opcional (callbacks com lógica) | Funções puras em `plugins/` |
| dbt | Não aplicável (SQL) | Testes dbt + unit tests dbt |
| Terraform | Não aplicável | `terraform test` |

| Decisão | Escolha | Motivo |
|---------|---------|--------|
| Threshold | 90% | Alinhado a cobertura |
| Onde rodar | CI em PR + nightly completo | Balance feedback/tempo |
| Exclusões | Centralizadas no config | Evitar `# pragma` espalhado |

---

## Trade-offs

| Trade-off | A | B | A quando | B quando |
|-----------|---|---|----------|----------|
| Mutation em CI | Todo PR | Nightly | Módulo pequeno | Suite > 15 min |
| Matar mutante | Teste mais forte | `# pragma: no mutate` | Regra testável | Código boilerplate |
| PIT modo | `FAST` | `FULL` | CI PR | Release |
| mutmut | `run` incremental | `run` full | Desenvolvimento | Antes release |

---

## Quando usar / quando não usar

### Use mutation quando

- Lógica de negócio, validação, cálculo, transformação, regras de elegibilidade.
- Código onde bug tem impacto financeiro/regulatório.
- Módulo já com 90% coverage mas review desconfia dos testes.

### Não use mutation quando

- DTO/record/getter-setter sem lógica.
- Código gerado (OpenAPI, protobuf).
- Config Spring / wiring Terraform.
- SQL dbt — use testes de dados e unit tests dbt.

---

## Estrutura de repositório e pastas

```
# Python — pyproject.toml ou setup.cfg
[tool.mutmut]
paths_to_mutate = ["src/domain/", "src/application/"]
runner = "python -m pytest -x -q"

# Java — pom.xml
<plugin>
  <groupId>org.pitest</groupId>
  <artifactId>pitest-maven</artifactId>
  <configuration>
    <mutationThreshold>90</mutationThreshold>
    <targetClasses>
      <param>com.org.dominio.domain.*</param>
      <param>com.org.dominio.application.*</param>
    </targetClasses>
  </configuration>
</plugin>
```

---

## Convenções e naming

| Item | Convenção |
|------|-----------|
| Relatório CI | Artefato `mutation-report.html` |
| PR | Mencionar score se alterou lógica de domínio |
| Exceção | Issue + comentário `// no mutate: motivo` |
| Revisor | Verificar mutantes sobreviventes no relatório |

---

## Práticas obrigatórias

- [ ] Mutation score ≥ 90% no escopo definido antes de merge
- [ ] Config versionada (`mutmut` / `pitest` no repo)
- [ ] CI executa mutation em alterações que tocam `domain/` ou `application/`
- [ ] Mutante sobrevivente tratado (teste novo ou exclusão justificada)
- [ ] Não reduzir threshold global para passar PR
- [ ] Relatório anexado ou linkado no CI

---

## Práticas recomendadas

- Rodar mutmut local antes do PR em mudanças de regra
- `mutmut results` / `mutmut show <id>` para debug
- PIT `mutationCoverage` no SonarQube se disponível
- Focar em boundary conditions e erros
- Pair review em mutantes sobreviventes persistentes

---

## Anti-padrões

```python
# ❌ Assert que qualquer mutação passa
assert resultado is not None

# ❌ Desabilitar mutation globalmente para passar CI
# mutmut --disable-mutation

# ❌ Teste que mocka o próprio SUT
with patch.object(use_case, "executar", return_value=ok):
    assert use_case.executar() == ok

# ❌ Ignorar mutante sem issue
# pragma: no mutate em todo arquivo
```

---

## Exemplos (bom vs ruim)

### Teste que mata mutante — bom

```python
def test_deve_somar_desconto_apenas_itens_elegiveis():
    pedido = Pedido(itens=[
        Item(valor=100, elegivel_desconto=True),
        Item(valor=50, elegivel_desconto=False),
    ])
    assert calcular_desconto(pedido, percentual=0.1) == 10.0
```

Se mutante mudar `== True` para `== False` ou `percentual * 0.1` para `* 0.0`, o teste **falha**.

### Teste fraco — ruim

```python
def test_calcular_desconto():
    pedido = pedido_fixture()
    result = calcular_desconto(pedido, 0.1)
    assert result >= 0  # mutante retorna 0 sempre — passa
```

### mutmut config — bom

```ini
# setup.cfg
[mutmut]
paths_to_mutate=src/domain/
                src/application/
tests_dir=tests/unit/
runner=python -m pytest -x -q --tb=no
```

```bash
mutmut run
mutmut results
# killed: 45, survived: 3, timeout: 0 → score = 45/48 = 93.75%
```

### PIT config — bom

```xml
<configuration>
  <mutationThreshold>90</mutationThreshold>
  <coverageThreshold>90</coverageThreshold>
  <mutators>
    <mutator>DEFAULTS</mutator>
  </mutators>
  <avoidCallsTo>
    <avoidCallsTo>java.util.logging</avoidCallsTo>
  </avoidCallsTo>
</configuration>
```

### Corrigir mutante sobrevivente — bom

```python
# Mutante: trocou > por >= na regra de valor mínimo
def test_deve_rejeitar_valor_zero():
    with pytest.raises(ValorInvalidoError):
        validar_valor(0)

def test_deve_aceitar_valor_minimo_positivo():
    assert validar_valor(0.01) == 0.01
```

---

## Estratégia de testes

```
Unitário (cobertura 90%) → Mutation (qualidade 90%) → TaaC (wiring)
```

| Fase | Ação |
|------|------|
| Desenvolvimento | `mutmut run` em arquivos alterados |
| PR CI | Mutation no escopo `domain` + `application` |
| Nightly | Mutation full + relatório histórico |
| Release | Gate 90% sem exceção pendente |

Ferramentas:

| Stack | Comando |
|-------|---------|
| Python | `mutmut run && mutmut results` |
| Java | `./mvnw org.pitest:pitest-maven:mutationCoverage` |

---

## Observabilidade (Datadog)

- Métrica CI: `mutation.score`, `mutation.survived_count`
- Alerta se score médio do repo cai abaixo de 85% por 3 builds
- Dashboard de qualidade de testes por squad (opcional)

Ver [13 — Observabilidade](13-observabilidade.md).

---

## Performance e custo

| Prática | Motivo |
|---------|--------|
| Escopo restrito a domain | Mutation é O(mutantes × testes) |
| `mutmut run --paths-to-mutate file.py` | Iteração local |
| PIT `threads` = cores CI | Paralelizar |
| Cache `.mutmut-cache` | Incremental |

Mutation completo em monólito pode levar 30+ min — **não é aceitável em todo PR**; use escopo ou path filter.

Ver [14 — Performance](14-performance.md).

---

## Segurança

- Relatórios mutation não contêm secrets
- Não desabilitar mutation em security-critical code

Ver [17 — Segurança](17-seguranca-conformidade-e-dados-sensiveis.md).

---

## Documentação

- README: seção "Mutation testing" com comandos
- PR: score antes/depois se módulo crítico
- Exceções `no mutate` com comentário e issue

Ver [15 — Documentação](15-documentacao.md).

---

## Checklist de implementação

- [ ] Config mutmut/PIT no repo
- [ ] Escopo = lógica de negócio apenas
- [ ] CI step com threshold 90%
- [ ] Testes fortalecidos para mutantes sobreviventes
- [ ] Relatório publicado como artefato

---

## Checklist de code review

- [ ] Lógica nova tem testes que matariam mutantes óbvios?
- [ ] Asserts específicos (valor, exceção, estado)?
- [ ] Score mutation CI verde?
- [ ] Exclusões `no mutate` justificadas?
- [ ] Não apenas mock do SUT?

Ver [16 — Code review](16-code-review.md).

---

## Checklist operacional

- [ ] Runner CI com recursos para mutation (< 15 min)
- [ ] Histórico de score monitorado
- [ ] Mutantes sobreviventes crônicos viram débito técnico visível

---

## Critérios de aceite

1. Mutation score ≥ 90% no escopo configurado.
2. Nenhum mutante sobrevivente crítico sem issue.
3. CI verde com relatório disponível.
4. Alteração de regra de negócio acompanhada de teste que mata mutante equivalente.

---

## Definition of Done (tema mutation)

- [ ] Score ≥ 90% em domain/application/transforms
- [ ] Config CI atualizada se novo pacote de lógica
- [ ] Mutantes sobreviventes resolvidos ou documentados
- [ ] [18 — Definition of Done](18-definition-of-done.md)

---

## FAQ

**Coverage 95%, mutation 60% — merge?**  
Não. Fortaleça testes ou reduza escopo incorreto de coverage.

**mutmut muito lento?**  
Restrinja `paths_to_mutate`; rode só arquivos alterados no PR.

**PIT mata poucos mutantes em getter/setter?**  
Exclua pacote `dto` do target.

**SQL/dbt precisa mutation?**  
Não. Use `dbt test`, unit tests dbt, TaaC de dados.

**Posso baixar para 80% temporariamente?**  
Só com ADR + prazo; não é prática aceita por padrão.

**Mutante equivalente ao comportamento desejado?**  
Documente e use `equivalent` mutants (PIT) ou exclusão pontual.

---

## Guia de uso para júnior

1. Escreva teste unitário com assert no **valor exato** ou exceção.
2. Rode `mutmut run` no seu arquivo.
3. Se `survived`, rode `mutmut show <id>` e veja a mutação.
4. Adicione teste que falha com essa mutação.
5. Repita até score ≥ 90%.

[20 — Onboarding técnico](20-onboarding-tecnico.md).

---

## Foco de revisão sênior

- Escopo de mutation adequado ao risco
- Mutantes sobreviventes aceitáveis vs dívida
- Testes que congelam implementação incorreta
- Custo de CI vs benefício em módulos legados
- Estratégia de legado com score baixo (plano incremental)

---

## Documentos relacionados

| # | Documento |
|---|-----------|
| 07 | [Lambda Python](07-lambda-python.md) |
| 08 | [Java Spring Boot](08-java-spring-boot.md) |
| 09 | [AWS Glue](09-aws-glue.md) |
| 10 | [Testes unitários](10-testes-unitarios.md) |
| 11 | [TaaC](11-taac-testes-integrados-na-pipeline.md) |
| 13 | [Observabilidade (Datadog)](13-observabilidade.md) |
| 14 | [Performance](14-performance.md) |
| 15 | [Documentação](15-documentacao.md) |
| 16 | [Code review](16-code-review.md) |
| 17 | [Segurança](17-seguranca-conformidade-e-dados-sensiveis.md) |
| 18 | [Definition of Done](18-definition-of-done.md) |
| 19 | [Padrões para uso de IA](19-padroes-para-uso-de-ia.md) |
| 20 | [Onboarding técnico](20-onboarding-tecnico.md) |
