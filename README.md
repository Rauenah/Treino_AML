# 🛡️ Projeto AML – Detecção de Padrões Suspeitos em Transações  
Este repositório contém um estudo prático de **Anti-Money Laundering (AML)** utilizando SQL para identificar comportamentos suspeitos em uma base fictícia de transações.  
O objetivo é demonstrar como análises simples podem gerar insights relevantes para times de **Risco, Compliance, Prevenção à Fraude e AML**.

---

# 📁 1. Sobre o Projeto

Este projeto foi desenvolvido como exercício técnico para:

- Praticar consultas SQL aplicadas a cenários reais de AML  
- Criar regras de detecção de anomalias  
- Simular investigações de risco financeiro  
- Demonstrar conhecimento prático para processos seletivos  

A base utilizada é fictícia, mas os padrões analisados são inspirados em práticas reais de monitoramento.

---

# 🧱 2. Estrutura da Tabela `db_risco`

A tabela contém informações essenciais para análise de risco:

```sql
Table: db_risco
Columns:
id_transacao int AI PK 
valor decimal(10,2) 
qtd_produto int 
id_comprador bigint 
id_vendedor bigint 
data_venda date 
horario_venda int 
status_venda varchar(50) 
qtd_parcela int 
tipo_pagamento varchar(10) 
categoria_produto varchar(100)
```

Esses campos permitem análises de comportamento, padrão de compra, risco operacional e possíveis tentativas de ocultação de origem de recursos.

---

# 🔍 3. Regras e Consultas AML Implementadas

A seguir estão as consultas SQL criadas para detectar padrões suspeitos.

---

## 🧩 3.1 Detecção de Smurfing (Fragmentação de Valores)

Smurfing ocorre quando um cliente divide valores maiores em várias transações pequenas para evitar alertas.

```sql
SELECT 
    id_comprador,
    COUNT(*) AS qtd_transacoes_pequenas,
    SUM(valor) AS total_fragmentado,
    MIN(data_venda) AS primeira_transacao,
    MAX(data_venda) AS ultima_transacao
FROM db_risco
WHERE valor < 100
  AND data_venda >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY id_comprador
HAVING SUM(valor) > 150;
```

**Objetivo:**  
Identificar clientes que realizam muitas transações pequenas em curto período — comportamento típico de lavagem de dinheiro.

---

## 🌙 3.2 Transações em Horários Atípicos

Compras entre 00h e 05h podem indicar risco: uso indevido de cartão, bots, apostas ou comportamento compulsivo.

```sql
SELECT
   id_comprador,
   COUNT(*) AS qtd_transacoes,
   AVG(valor) AS valor_medio,
   SUM(valor) AS total_gasto
FROM db_risco
WHERE horario_venda BETWEEN 0 AND 5
GROUP BY id_comprador
ORDER BY total_gasto DESC;
```

**Objetivo:**  
Detectar clientes que operam em horários incomuns, o que pode indicar fraude ou comportamento anômalo.

---

## 📈 3.3 Spike Detection – Aumento Repentino de Gastos

Regra: se o cliente gastou **70% do valor do mês apenas na última semana**, isso é considerado um spike suspeito.

```sql
SELECT
  d.id_comprador,
  SUM(CASE
        WHEN d.data_venda >= DATE_SUB(m.max_data, INTERVAL 7 DAY)
        THEN d.valor
        ELSE 0
      END) AS m_max_data_7_dias,
  SUM(CASE
        WHEN d.data_venda >= DATE_SUB(m.max_data, INTERVAL 30 DAY)
        THEN d.valor
        ELSE 0
      END) AS m_max_data_30_dias
FROM db_risco d
CROSS JOIN (
  SELECT MAX(data_venda) AS max_data
  FROM db_risco
) m
GROUP BY d.id_comprador
HAVING m_max_data_7_dias > (m_max_data_30_dias * 0.7);
```

**Objetivo:**  
Identificar explosões repentinas de consumo, que podem indicar:

- Uso indevido de conta  
- Lavagem de dinheiro  
- Tentativa de esvaziar limite rapidamente  

---

## 💳 3.4 Abuso de Parcelamento

Compras parceladas em excesso podem indicar risco financeiro ou tentativa de mascarar gastos.

```sql
SELECT 
    id_comprador,
    COUNT(*) AS qtd_parceladas,
    SUM(valor) AS total_parcelado,
    AVG(qtd_parcela) AS media_parcelas
FROM db_risco
WHERE qtd_parcela > 1
GROUP BY id_comprador
ORDER BY total_parcelado DESC;
```

**Objetivo:**  
Detectar clientes que utilizam parcelamento de forma incomum ou excessiva.




