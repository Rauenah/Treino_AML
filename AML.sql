-- AML

-- DETECTAR POSSIVEL SMURFING

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

-- Detectar comportamento anômalo por horário (apostas ou compras fora do padrão)

select
   id_comprador,
   count(*) as qtd_transacoes,
   avg(valor) as valor_medio,
   sum(valor) as total_gasto
from db_risco
where horario_venda between 0 and 5
group by id_comprador
order by total_gasto desc;   -- depois fazer esse codigo mostrando horario

-- Identificar clientes com aumento repentino de gastos (spike detection)
-- Se o cliente gastou 70% do valor do mês apenas na última semana, isso é um spike suspeito.

select
  d.id_comprador,
  sum(case
        when d.data_venda >= date_sub(m.max_data, interval 7 day)
        then d.valor
        else 0
      end) as m_max_data_7_dias,
  sum(case
        when d.data_venda >= date_sub(m.max_data, interval 30 day)
        then d.valor
        else 0
      end) as m_max_data_30_dias
from db_risco d
cross join (
  select max(data_venda) as max_data
  from db_risco
) m
group by d.id_comprador
having m_max_data_7_dias > (m_max_data_30_dias * 0.7);

-- Identificar abuso de cartão (muitas compras parceladas)

 SELECT 
    id_comprador,
    COUNT(*) AS qtd_parceladas,
    SUM(valor) AS total_parcelado,
    AVG(qtd_parcela) AS media_parcelas
FROM db_risco
WHERE qtd_parcela > 1
GROUP BY id_comprador
ORDER BY total_parcelado DESC;

  
