# Branch Protection & Rulesets

[English](#english) | [Português](#português)

## English

### Overview

Configuration guidelines for GitHub branch protection rules and rulesets to ensure code quality and enforce best practices.

### Prerequisites

- Repository owner/admin access
- GitHub CLI (optional, for automation)

### Branch Protection Rules for `main`

Configure these settings for the `main` branch:

#### 1. Require Pull Request Reviews

- ✅ **Require a pull request before merging**
- ✅ **Require approvals**: 1
- ✅ **Require review from Code Owners**: No (optional)
- ✅ **Dismiss stale pull request approvals**: Yes
- ✅ **Require approval of the most recent reviewable push**: Yes

#### 2. Require Status Checks

- ✅ **Require status checks to pass before merging**
- ✅ **Require branches to be up to date before merging**: Yes

**Select status checks**:

- `Lint` - PSScriptAnalyzer code quality
- `Validate` - Project structure validation
- `Security` - Security scanning
- `Documentation` - Markdown validation

#### 3. Require Commits to be Signed

- ✅ **Require a pull request before merging** (already above)
- ⚠️ **Require commit signatures**: Optional (recommended for production)

#### 4. Restrict Force Pushes

- ✅ **Allow force pushes**: Disabled
- ✅ **Allow deletions**: Disabled

#### 5. Require Linear History

- ✅ **Require linear history**: Yes

This prevents merge commits and enforces a clean history.

#### 6. Automatically Delete Head Branches

- ✅ **Delete head branches**: Yes

Clean up feature branches automatically after merge.

### GitHub Rulesets (New Feature)

Rulesets provide more granular control than branch protection:

#### For `main` branch

```yaml
Name: Main Branch Protection
Target: Branch "main"

Rules:
  - Require pull requests
    - Require status checks: Lint, Validate, Security, Documentation
    - Require code review: 1 approval
    - Require latest reviews: Yes
    - Dismiss stale reviews: Yes
  
  - Require commit signatures: Optional
  
  - Require linear history: Yes
  
  - Restrict force pushes: Enabled
  
  - Restrict deletions: Enabled
```

#### For Pull Requests (all branches)

```yaml
Name: PR Quality Gates
Target: All branches except main

Rules:
  - Require at least 1 status check (PR Checks)
  - Require conventional commit format
  - Block force pushes
```

### Setting Up via GitHub CLI

Install GitHub CLI: <https://cli.github.com>

#### Create Main Branch Protection

```bash
gh repo rule create \
  --ruleset-name "Main Branch Protection" \
  --target branch \
  --branch main \
  --require-pull-requests \
  --require-status-checks \
  --require-linear-history
```

#### Create PR Quality Gates

```bash
gh repo rule create \
  --ruleset-name "PR Quality Gates" \
  --target pull_request \
  --require-status-checks
```

### Manual Setup in GitHub UI

1. Go to **Settings** → **Branches**
2. Click **Add rule** or edit existing `main` branch protection
3. Configure settings as shown above
4. Save

### Status Checks Required

These must pass before merging to `main`:

| Check | Purpose | Failure = Block |
| --- | --- | --- |
| **Lint** | PSScriptAnalyzer code quality | ✅ Yes |
| **Validate** | Project structure & completeness | ✅ Yes |
| **Security** | Security scanning & credential check | ✅ Yes |
| **Documentation** | Markdown validation | ✅ Yes |
| **PR Checks** | PR validation (optional) | ⚠️ No |

### Enforcement Summary

| Rule | Enforced | Reason |
| --- | --- | --- |
| 1 approval required | ✅ | Code review |
| Linear history | ✅ | Clean git log |
| All checks pass | ✅ | Quality assurance |
| Force push blocked | ✅ | Protect history |
| Signature required | ⚠️ | Optional (recommended) |

### Merge Strategy

Only allow: **Squash and merge**

This keeps history clean with one commit per PR.

### Labels (Recommended)

Set up these labels for PR organization:

- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation
- `ci` - CI/CD
- `chore` - Maintenance
- `breaking` - Breaking change

### Protection Exemptions

Consider exempting for:

- **Dependabot** - Automatic dependency updates
- **Release bot** - Automated releases

### Verification Checklist

After setup, verify:

- [ ] PR requires 1 approval minimum
- [ ] All 4 status checks required to pass
- [ ] Force push to main is disabled
- [ ] Branch deletion is disabled
- [ ] Linear history is enforced
- [ ] Head branches auto-delete after merge
- [ ] Stale reviews are dismissed

---

## Português

### Visão Geral

Guia de configuração para regras de proteção de branch e rulesets do GitHub para garantir qualidade de código.

### Pré-requisitos

- Acesso de owner/admin no repositório
- GitHub CLI (opcional, para automação)

### Regras de Proteção para Branch `main`

Configure essas opções para a branch `main`:

#### 1. Exigir Pull Request Reviews

- ✅ **Exigir pull request antes de fazer merge**
- ✅ **Exigir aprovações**: 1
- ✅ **Exigir revisão de Code Owners**: Não (opcional)
- ✅ **Descartar revisões obsoletas**: Sim
- ✅ **Exigir aprovação do push mais recente**: Sim

#### 2. Exigir Status Checks

- ✅ **Exigir que os checks de status passem antes de fazer merge**
- ✅ **Exigir que branches estejam atualizadas**: Sim

**Selecione os checks**:

- `Lint` - Qualidade de código PSScriptAnalyzer
- `Validate` - Validação de estrutura do projeto
- `Security` - Verificação de segurança
- `Documentation` - Validação de markdown

#### 3. Commits Assinados

- ⚠️ **Exigir assinatura de commits**: Opcional (recomendado para produção)

#### 4. Bloquear Force Pushes

- ✅ **Permitir force push**: Desativado
- ✅ **Permitir exclusões**: Desativado

#### 5. Exigir Histórico Linear

- ✅ **Exigir histórico linear**: Sim

Previne merge commits e garante histórico limpo.

#### 6. Deletar Branches Automaticamente

- ✅ **Deletar branches**: Sim

Remove branches de feature automaticamente após merge.

### GitHub Rulesets (Recurso Novo)

Rulesets oferecem controle mais granular:

#### Para branch `main`

```yaml
Nome: Proteção Main
Alvo: Branch "main"

Regras:
  - Exigir pull requests
    - Exigir checks de status
    - Exigir 1 aprovação
    - Exigir revisão mais recente
  
  - Exigir histórico linear
  - Bloquear force push
  - Bloquear exclusão
```

### Configuração via GitHub CLI

```bash
# Instalar GitHub CLI
# https://cli.github.com

# Criar proteção para main
gh repo rule create \
  --ruleset-name "Proteção Main" \
  --target branch \
  --branch main \
  --require-pull-requests \
  --require-status-checks
```

### Configuração Manual via UI

1. **Settings** → **Branches**
2. Clique em **Add rule**
3. Configure como acima
4. Salve

### Checks de Status Obrigatórios

| Check | Propósito | Bloqueia |
| --- | --- | --- |
| **Lint** | Qualidade de código | ✅ Sim |
| **Validate** | Estrutura do projeto | ✅ Sim |
| **Security** | Verificação de segurança | ✅ Sim |
| **Documentation** | Validação markdown | ✅ Sim |

### Checklist de Verificação

Após configuração, verifique:

- [ ] PR exige 1 aprovação
- [ ] Todos os 4 checks são obrigatórios
- [ ] Force push para main está desativado
- [ ] Exclusão de branch está desativada
- [ ] Histórico linear é aplicado
- [ ] Branches auto-deletam após merge
- [ ] Revisões obsoletas são descartadas

### Estratégia de Merge

Permita apenas: **Squash and merge**

Mantém o histórico limpo com 1 commit por PR.

### Resumo Final

Com essas configurações, o repositório terá:

✅ Qualidade garantida (todos os checks passam)
✅ Histórico limpo (linear, sem merge commits)
✅ Proteção contra acidentes (sem force push/delete)
✅ Revisão obrigatória (1 aprovação mínimo)
✅ Automação (GitHub Actions validam tudo)

---

**Próximo passo**: Após fazer push para GitHub, configure essas regras na UI ou via CLI.
