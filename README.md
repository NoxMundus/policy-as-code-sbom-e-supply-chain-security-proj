# api-pagamentos - Projeto Integrador de DevSecOps, SBOM e Supply Chain Security

## Visão geral

Este projeto demonstra uma esteira DevSecOps voltada para segurança de cadeia de suprimentos de software. A aplicação usada como base é uma API fictícia de pagamentos, chamada `api-pagamentos`, criada para servir como alvo de validações automatizadas de segurança, conformidade, assinatura de artefatos, geração de SBOM, controle de admissão em Kubernetes e auditoria contínua.

O objetivo principal não é criar uma aplicação de negócio complexa, mas sim demonstrar como uma organização pode controlar, validar e rastrear tudo que acontece entre o código-fonte, a imagem de container publicada e a execução dessa imagem em um cluster Kubernetes.

Em outras palavras, o projeto responde a uma pergunta central:

> Como garantir que a imagem executada em produção foi construída por uma esteira confiável, a partir de um repositório conhecido, com dependências rastreáveis, sem vulnerabilidades críticas não tratadas, com assinatura verificável e com evidências de provenance?

---

## Contexto do projeto

Ambientes modernos de desenvolvimento dependem de diversos componentes externos, como bibliotecas, imagens base, registries, ferramentas de build, pipelines e sistemas de orquestração. Essa cadeia aumenta a produtividade, mas também amplia a superfície de ataque.

Ataques de supply chain exploram justamente essa dependência entre componentes. Uma imagem adulterada, uma biblioteca vulnerável, uma dependência com licença inadequada ou um artefato publicado fora do pipeline oficial podem comprometer a segurança do ambiente mesmo quando o código da aplicação parece correto.

Este projeto foi criado para simular uma resposta prática a esse problema, usando controles automatizados em diferentes pontos da esteira:

- Validação de políticas antes do deploy.
- Geração de SBOM para rastrear componentes.
- Validação de licenças.
- Análise de vulnerabilidades.
- Assinatura de imagem.
- Geração de provenance SLSA.
- Verificação no admission controller do Kubernetes.
- Produção de evidências para auditoria.

---

## Objetivos

O projeto tem como objetivos principais:

1. Demonstrar uma esteira DevSecOps com controles de segurança automatizados.
2. Aplicar Policy as Code para validar requisitos técnicos antes da implantação.
3. Gerar SBOM em formatos reconhecidos para rastreabilidade de componentes.
4. Validar riscos de licenciamento de dependências.
5. Executar análise de vulnerabilidades baseada no SBOM.
6. Assinar imagens de container com identidade verificável.
7. Gerar provenance SLSA para comprovar origem e processo de build.
8. Aplicar um gate de admissão em Kubernetes para impedir imagens não confiáveis.
9. Produzir evidências que possam ser usadas em auditoria, apresentação técnica ou avaliação acadêmica.
10. Relacionar os controles técnicos com práticas reconhecidas de segurança e governança.

---

## Arquitetura conceitual

A arquitetura do projeto pode ser entendida como uma cadeia de confiança dividida em quatro grandes momentos:

### 1. Desenvolvimento e validação inicial

O código da aplicação, os manifestos Kubernetes, as políticas de segurança e os scripts de apoio ficam versionados no GitHub. A cada alteração relevante, a esteira executa validações para confirmar se o projeto continua aderente aos requisitos definidos.

Nessa etapa, entram controles como testes da aplicação, testes OPA/Rego, validação de estrutura e geração inicial de evidências.

### 2. Build e geração de evidências

Quando uma versão é liberada, a esteira gera a imagem de container da aplicação e produz evidências associadas a ela. Entre essas evidências estão o SBOM, relatórios de vulnerabilidade, validações de licença e registros de verificação.

O SBOM funciona como uma lista de componentes da imagem. Ele permite saber quais pacotes, bibliotecas e dependências estão presentes no artefato que será distribuído.

### 3. Assinatura e provenance

Após a imagem ser criada, o projeto aplica mecanismos de assinatura e atestação. A assinatura com Cosign keyless permite verificar que a imagem foi produzida por uma identidade confiável, sem depender de chaves privadas longas armazenadas manualmente.

A provenance SLSA complementa esse controle ao registrar informações sobre o processo de build, como origem, workflow, commit e digest da imagem. Isso ajuda a responder se o artefato realmente veio do processo esperado.

### 4. Execução controlada no Kubernetes

No cluster Kubernetes, o Sigstore Policy Controller e a ClusterImagePolicy atuam como gate de admissão. A função desse controle é impedir que imagens sem assinatura válida ou sem as evidências exigidas sejam executadas no namespace protegido.

Com isso, o projeto fecha o ciclo entre desenvolvimento, build, publicação e execução.

---

## Componentes principais

### Aplicação api-pagamentos

A aplicação é uma API simples em Node.js criada para representar um serviço de pagamentos. Ela existe como objeto de teste para a esteira DevSecOps.

A simplicidade da aplicação é intencional. O foco do projeto está nos controles de segurança, não na complexidade funcional do sistema.

### Dockerfile

O Dockerfile define como a aplicação é empacotada em uma imagem de container. Ele também incorpora decisões de endurecimento, como a execução com usuário não privilegiado e redução da superfície de ataque da imagem final.

Uma das decisões relevantes do projeto foi remover componentes desnecessários em runtime, reduzindo o número de pacotes vulneráveis presentes na imagem final.

### Manifests Kubernetes

Os manifests Kubernetes definem como a aplicação será implantada no cluster. Eles incluem namespace, deployment, service e configurações de segurança do container.

Esses manifests são analisados pelas políticas antes da implantação, garantindo que requisitos mínimos sejam atendidos.

### Policies Rego

As políticas Rego representam regras de segurança escritas como código. Elas validam aspectos como:

- Uso de tag explícita em imagem.
- Bloqueio de tag `latest`.
- Restrição de registry permitido.
- Configurações de security context.
- Definição de requests e limits.
- Presença de evidências relacionadas ao SBOM.
- Bloqueio de licenças proibidas.

Essas políticas permitem que decisões de segurança sejam tratadas de forma objetiva, versionada e automatizada.

### SBOM

O SBOM é uma das principais evidências do projeto. Ele descreve os componentes presentes na imagem de container e permite rastrear dependências, versões e possíveis riscos.

O projeto considera dois formatos de SBOM:

- CycloneDX.
- SPDX.

O uso de mais de um formato aumenta a interoperabilidade com ferramentas diferentes e demonstra aderência a práticas modernas de segurança de supply chain.

### Validação de licenças

A validação de licenças verifica se há componentes com licenças consideradas proibidas ou sensíveis para determinados contextos corporativos.

Esse controle é importante porque risco de software não é apenas técnico. Dependências também podem representar risco jurídico, especialmente quando envolvem licenças restritivas ou incompatíveis com o modelo de uso pretendido.

### Análise de vulnerabilidades

A análise de vulnerabilidades usa o SBOM como base para identificar componentes com falhas conhecidas. O objetivo é impedir que vulnerabilidades críticas sigam sem tratamento adequado.

O projeto também demonstra uma abordagem madura para vulnerabilidades sem correção disponível: em vez de simplesmente ignorar alertas, o risco deve ser documentado, justificado e reavaliado.

### Cosign keyless

O Cosign é usado para assinar imagens e gerar attestations. A abordagem keyless evita o uso de chaves privadas estáticas de longa duração.

A identidade usada na assinatura é derivada do provedor OIDC do GitHub Actions, permitindo associar a assinatura ao workflow que produziu o artefato.

### SLSA Provenance

A provenance SLSA registra informações sobre a origem e o processo de construção da imagem. Ela ajuda a comprovar que o artefato foi gerado pelo fluxo esperado, a partir de um repositório e workflow conhecidos.

No projeto, a geração de provenance é feita por um workflow reutilizável do SLSA GitHub Generator. Isso explica por que a interface do GitHub Actions pode exibir jobs internos adicionais durante a etapa de provenance.

### Sigstore Policy Controller

O Sigstore Policy Controller atua no cluster Kubernetes para validar imagens durante o processo de admissão. Ele impede que workloads não conformes sejam executados.

A política de admissão avalia se a imagem possui assinatura e attestations esperadas. Isso transforma o cluster em uma camada ativa de enforcement, não apenas em um ambiente passivo de execução.

### Auditoria e dashboard

O projeto também contempla geração de relatório e dashboard de conformidade. A ideia é demonstrar que segurança não deve ser apenas um controle pontual, mas um processo contínuo de acompanhamento.

Os indicadores permitem visualizar se releases possuem assinatura, provenance e SBOM, além de apoiar apresentações e auditorias.

---

## Fluxo lógico da esteira

O fluxo do projeto pode ser resumido da seguinte forma:

1. O código e os artefatos de configuração são versionados no GitHub.
2. A esteira de verificação valida aplicação, políticas e evidências iniciais.
3. Uma release oficial aciona o fluxo de publicação.
4. A imagem é construída e publicada no registry.
5. O SBOM é gerado para representar os componentes da imagem.
6. As licenças e vulnerabilidades são avaliadas.
7. A imagem é assinada com Cosign.
8. Evidências adicionais são anexadas como attestations.
9. A provenance SLSA é gerada.
10. O Kubernetes usa uma política de admissão para aceitar ou negar a execução da imagem.
11. Relatórios e dashboard consolidam a conformidade do processo.

---

## Controles implementados

| Área | Controle | Finalidade |
|---|---|---|
| Policy as Code | Políticas Rego | Validar requisitos técnicos antes do deploy |
| Segurança de imagem | Registry permitido e tag explícita | Reduzir risco de imagem não controlada |
| Segurança de runtime | Security context restritivo | Reduzir privilégios do container |
| Governança de recursos | Requests e limits | Evitar consumo descontrolado no cluster |
| SBOM | CycloneDX e SPDX | Rastrear componentes da imagem |
| Licenciamento | Política de licenças proibidas | Reduzir risco jurídico |
| Vulnerabilidades | Análise baseada em SBOM | Identificar falhas conhecidas |
| Assinatura | Cosign keyless | Verificar origem e integridade da imagem |
| Provenance | SLSA | Comprovar processo de build |
| Admission control | ClusterImagePolicy | Impedir execução de imagens não confiáveis |
| Auditoria | Relatórios e dashboard | Acompanhar conformidade ao longo do tempo |

---

## Relação com DevSecOps

O projeto representa uma abordagem DevSecOps porque integra segurança diretamente ao ciclo de desenvolvimento e entrega. Em vez de tratar segurança como uma etapa manual no final do processo, os controles são versionados, automatizados e executados pela esteira.

Isso reduz dependência de validações manuais, melhora a rastreabilidade e permite resposta mais rápida a problemas de segurança.

A abordagem também favorece colaboração entre desenvolvimento, operações, segurança e governança, pois as evidências ficam disponíveis no próprio fluxo de entrega.

---

## Relação com supply chain security

A segurança de cadeia de suprimentos de software busca garantir que cada etapa entre o código-fonte e o ambiente de execução seja confiável.

Este projeto aborda esse tema com os seguintes mecanismos:

- Controle do repositório de origem.
- Build automatizado.
- Geração de SBOM.
- Validação de vulnerabilidades.
- Assinatura de imagem.
- Geração de provenance.
- Verificação no Kubernetes.
- Produção de evidências auditáveis.

Esses controles ajudam a reduzir riscos como adulteração de imagem, uso de dependência vulnerável, publicação fora da esteira oficial e execução de artefatos não confiáveis.

---

## Relação com frameworks de referência

O projeto se conecta a práticas reconhecidas em frameworks de segurança e governança.

### NIST SSDF

O NIST Secure Software Development Framework orienta práticas para desenvolvimento seguro de software. O projeto se relaciona a esse framework ao automatizar validações, produzir evidências, rastrear componentes e tratar vulnerabilidades.

### SLSA

O SLSA é voltado especificamente para integridade da cadeia de build e distribuição de artefatos. O projeto usa provenance para demonstrar a origem e o processo de geração da imagem.

### ISO 27001

A ISO 27001 trata governança e gestão de segurança da informação. O projeto contribui para objetivos de controle relacionados a desenvolvimento seguro, gestão de vulnerabilidades, criptografia, configuração segura e conformidade contínua.

---

## Decisões técnicas importantes

### Uso de uma aplicação simples

A API foi mantida simples para que o foco ficasse nos controles de segurança. Isso facilita a avaliação do projeto e evita que regras de negócio complexas desviem a atenção do objetivo principal.

### Uso de Policy as Code

As regras de segurança foram transformadas em código para que possam ser versionadas, testadas e executadas automaticamente.

### Geração de SBOM em dois formatos

Foram considerados os formatos CycloneDX e SPDX para ampliar compatibilidade com ferramentas e práticas de mercado.

### Uso de Cosign keyless

A assinatura keyless reduz o risco de exposição de chaves privadas e usa a identidade do workflow como base de confiança.

### Uso de SLSA Provenance

A provenance reforça a rastreabilidade do build e ajuda a comprovar que a imagem foi gerada pelo processo esperado.

### Uso de admission control

O controle no Kubernetes garante que a segurança não dependa apenas da esteira. Mesmo que alguém tente executar uma imagem diretamente no cluster, o admission controller pode bloquear a execução se as evidências exigidas não existirem.

---

## Evidências esperadas

O projeto produz evidências que podem ser usadas para auditoria, apresentação ou validação acadêmica. Entre elas:

- Resultado dos testes de políticas.
- SBOM em formato CycloneDX.
- SBOM em formato SPDX.
- Relatório de vulnerabilidades.
- Log de validação de licenças.
- Assinatura da imagem.
- Attestations associadas à imagem.
- Provenance SLSA.
- Evidência de bloqueio de imagem não conforme no Kubernetes.
- Relatório mensal de conformidade.
- Dashboard de indicadores.

---

## Indicadores de conformidade

O projeto propõe indicadores para acompanhar a maturidade da esteira ao longo do tempo:

- Percentual de releases assinadas.
- Percentual de releases com provenance.
- Percentual de releases com SBOM CycloneDX.
- Percentual de releases com SBOM SPDX.
- Quantidade de releases avaliadas.
- Evidências de bloqueio de imagens não conformes.

Esses indicadores ajudam a transformar segurança em algo mensurável e acompanhável, em vez de apenas uma validação pontual.

---

## Principais aprendizados

Este projeto demonstra que segurança de supply chain depende da combinação de vários controles. Nenhuma ferramenta isolada resolve todo o problema.

O SBOM mostra o que existe dentro da imagem, mas não garante sozinho que a imagem veio do pipeline correto. A assinatura comprova integridade e origem, mas não substitui análise de vulnerabilidades. A provenance mostra como o artefato foi construído, mas precisa ser verificada por políticas. O admission controller reforça a segurança no runtime, mas depende das evidências geradas anteriormente.

O valor do projeto está justamente na integração desses controles em uma cadeia coerente.

---

## Limitações e pontos de atenção

Este projeto é um laboratório e usa uma aplicação fictícia. Em um ambiente corporativo real, seria necessário adaptar os controles para políticas internas, registries oficiais, ferramentas de gestão de vulnerabilidade, requisitos jurídicos de licenciamento e padrões de operação do cluster.

Também é importante revisar periodicamente as exceções de vulnerabilidade, atualizar imagens base, manter ferramentas de segurança em versões suportadas e validar se as identities usadas nas assinaturas e attestations continuam compatíveis com as políticas de admissão.

---

## Conclusão

O projeto `api-pagamentos` demonstra uma esteira DevSecOps completa voltada para segurança de cadeia de suprimentos de software. Ele integra Policy as Code, SBOM, análise de licenças, análise de vulnerabilidades, assinatura de imagem, SLSA provenance, admission control em Kubernetes e evidências de auditoria.

A principal contribuição do projeto é mostrar que confiança em software moderno precisa ser construída em camadas. O código precisa ser validado, a imagem precisa ser rastreável, o build precisa ser verificável, o artefato precisa ser assinado e o ambiente de execução precisa ser capaz de rejeitar aquilo que não atende às políticas definidas.

Esse conjunto de práticas aproxima o desenvolvimento de software de um modelo mais seguro, auditável e alinhado a frameworks modernos de segurança e governança.
