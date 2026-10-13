-- =====================================================================
-- Consultas SQL do projeto E-commerce
--
-- Cada consulta responde a uma pergunta de negocio e indica as clausulas
-- que utiliza. Organizacao por clausula do desafio:
--   A. SELECT simples          D. ORDER BY
--   B. WHERE                   E. JOIN
--   C. Atributos derivados     F. GROUP BY + HAVING
-- Requer MySQL 8.0+ (usa CTEs com WITH).
-- =====================================================================
USE ecommerce;


-- =====================================================================
-- A. RECUPERACOES SIMPLES (SELECT)
-- =====================================================================

-- A1) Quais produtos estao cadastrados e quanto custam?
--     Clausulas: SELECT
SELECT idProduto, nome, categoria, valor
FROM produto;

-- A2) Em quais localidades existem estoques?
--     Clausulas: SELECT DISTINCT
SELECT DISTINCT localizacao
FROM estoque;


-- =====================================================================
-- B. FILTROS (WHERE)
-- =====================================================================

-- B1) Quais produtos eletronicos custam mais de R$ 500?
--     Clausulas: SELECT, WHERE (AND)
SELECT nome, valor
FROM produto
WHERE categoria = 'ELETRONICO'
  AND valor > 500;

-- B2) Quais pedidos confirmados foram feitos em setembro de 2026?
--     Clausulas: SELECT, WHERE (AND, intervalo de datas)
SELECT idPedido, idCliente, dataPedido, frete
FROM pedido
WHERE status = 'CONFIRMADO'
  AND dataPedido >= '2026-09-01'
  AND dataPedido <  '2026-10-01';

-- B3) Quais pagamentos ainda nao foram concluidos (pendentes ou recusados)?
--     Clausulas: SELECT, WHERE (IN)
SELECT idPagamento, idPedido, valor, parcelas, status
FROM pagamento
WHERE status IN ('PENDENTE', 'RECUSADO');

-- B4) Quais entregas ja foram postadas, mas ainda nao chegaram ao destino?
--     Clausulas: SELECT, WHERE (NOT IN, IS NOT NULL)
SELECT idPedido, status, codigoRastreio, transportadora, previsaoEntrega
FROM entrega
WHERE status NOT IN ('PREPARANDO', 'ENTREGUE', 'DEVOLVIDO')
  AND codigoRastreio IS NOT NULL;


-- =====================================================================
-- C. ATRIBUTOS DERIVADOS (expressoes)
-- =====================================================================

-- C1) Qual o nome completo e a idade de cada cliente pessoa fisica?
--     Clausulas: SELECT (CONCAT, TIMESTAMPDIFF), JOIN
SELECT c.idCliente,
       CONCAT(pf.nome, ' ', pf.sobrenome)                AS nome_completo,
       TIMESTAMPDIFF(YEAR, pf.dataNascimento, CURDATE()) AS idade
FROM cliente c
JOIN cliente_pf pf ON pf.idCliente = c.idCliente;

-- C2) Qual o subtotal de cada item vendido e o preco unitario com 10% de
--     desconto para pagamento a vista?
--     Clausulas: SELECT (multiplicacao, ROUND), JOIN
SELECT i.idPedido,
       pr.nome                           AS produto,
       i.quantidade,
       i.precoUnitario,
       i.quantidade * i.precoUnitario    AS subtotal,
       ROUND(i.precoUnitario * 0.90, 2)  AS preco_unitario_a_vista
FROM item_pedido i
JOIN produto pr ON pr.idProduto = i.idProduto;

-- C3) Qual o total de cada pedido (itens + frete), quanto ja foi pago e
--     quanto ainda esta em aberto? (pedidos cancelados ficam de fora)
--     Clausulas: SELECT (soma, COALESCE, subtracao), WHERE, JOIN, ORDER BY
WITH total_pedido AS (
    SELECT p.idPedido,
           SUM(i.quantidade * i.precoUnitario) + p.frete AS total
    FROM pedido p
    JOIN item_pedido i ON i.idPedido = p.idPedido
    WHERE p.status <> 'CANCELADO'
    GROUP BY p.idPedido, p.frete
),
total_pago AS (
    SELECT idPedido, SUM(valor) AS pago
    FROM pagamento
    WHERE status = 'APROVADO'
    GROUP BY idPedido
)
SELECT t.idPedido,
       t.total                          AS total_pedido,
       COALESCE(pg.pago, 0)             AS total_pago,
       t.total - COALESCE(pg.pago, 0)   AS saldo_em_aberto
FROM total_pedido t
LEFT JOIN total_pago pg ON pg.idPedido = t.idPedido
ORDER BY saldo_em_aberto DESC, t.idPedido;


-- =====================================================================
-- D. ORDENACAO (ORDER BY)
-- =====================================================================

-- D1) Qual o ranking de produtos, do mais caro ao mais barato?
--     Clausulas: SELECT, ORDER BY (DESC e desempate por nome)
SELECT nome, categoria, valor
FROM produto
ORDER BY valor DESC, nome;

-- D2) Qual a lista de clientes agrupada por tipo (PF/PJ) e em ordem
--     alfabetica, com o documento correspondente?
--     Clausulas: SELECT (COALESCE), JOIN, ORDER BY (varias colunas)
SELECT c.tipo,
       COALESCE(CONCAT(pf.nome, ' ', pf.sobrenome), pj.razaoSocial) AS cliente,
       COALESCE(pf.cpf, pj.cnpj)                                    AS documento,
       c.email
FROM cliente c
LEFT JOIN cliente_pf pf ON pf.idCliente = c.idCliente
LEFT JOIN cliente_pj pj ON pj.idCliente = c.idCliente
ORDER BY c.tipo, cliente;


-- =====================================================================
-- E. JUNCOES (JOIN)
-- =====================================================================

-- E1) Quantos pedidos foram feitos por cada cliente (inclusive os que nunca
--     compraram)?
--     Clausulas: SELECT, LEFT JOIN, GROUP BY, COUNT, ORDER BY
SELECT c.idCliente,
       COALESCE(CONCAT(pf.nome, ' ', pf.sobrenome), pj.razaoSocial) AS cliente,
       c.tipo,
       COUNT(p.idPedido) AS qtd_pedidos
FROM cliente c
LEFT JOIN cliente_pf pf ON pf.idCliente = c.idCliente
LEFT JOIN cliente_pj pj ON pj.idCliente = c.idCliente
LEFT JOIN pedido p      ON p.idCliente  = c.idCliente
GROUP BY c.idCliente, c.tipo, pf.nome, pf.sobrenome, pj.razaoSocial
ORDER BY qtd_pedidos DESC, cliente;

-- E2) Algum vendedor terceiro tambem e fornecedor? (mesmo CNPJ nas duas tabelas)
--     Clausulas: SELECT, INNER JOIN
SELECT v.idVendedor,
       v.razaoSocial AS vendedor,
       f.idFornecedor,
       f.razaoSocial AS fornecedor,
       v.cnpj
FROM vendedor_terceiro v
JOIN fornecedor f ON f.cnpj = v.cnpj;

-- E3) Qual a relacao de produtos, seus fornecedores e o estoque total?
--     Produtos sem fornecedor ou sem estoque tambem devem aparecer.
--     Clausulas: SELECT, LEFT JOIN (varios), GROUP BY, GROUP_CONCAT, ORDER BY
SELECT pr.idProduto,
       pr.nome                                                         AS produto,
       COALESCE(GROUP_CONCAT(f.razaoSocial ORDER BY f.razaoSocial
                             SEPARATOR ' | '), '(sem fornecedor)')     AS fornecedores,
       COALESCE(e.qtd_estoque, 0)                                      AS qtd_em_estoque
FROM produto pr
LEFT JOIN produto_fornecedor pf ON pf.idProduto   = pr.idProduto
LEFT JOIN fornecedor f          ON f.idFornecedor = pf.idFornecedor
LEFT JOIN (SELECT idProduto, SUM(quantidade) AS qtd_estoque
           FROM produto_estoque
           GROUP BY idProduto) e ON e.idProduto = pr.idProduto
GROUP BY pr.idProduto, pr.nome, e.qtd_estoque
ORDER BY pr.idProduto;

-- E4) Qual a relacao de nomes dos fornecedores e nomes dos produtos que
--     eles fornecem?
--     Clausulas: SELECT, INNER JOIN (tabela associativa), ORDER BY
SELECT f.razaoSocial AS fornecedor,
       pr.nome       AS produto
FROM fornecedor f
JOIN produto_fornecedor pf ON pf.idFornecedor = f.idFornecedor
JOIN produto pr            ON pr.idProduto    = pf.idProduto
ORDER BY f.razaoSocial, pr.nome;

-- E5) Quais produtos nao tem fornecedor e quem os vende (vendedor terceiro)?
--     Clausulas: SELECT, LEFT JOIN + IS NULL, JOIN, WHERE, ORDER BY
SELECT pr.nome                 AS produto,
       v.razaoSocial           AS vendedor_terceiro,
       pv.quantidade           AS qtd_oferecida
FROM produto pr
LEFT JOIN produto_fornecedor pf ON pf.idProduto = pr.idProduto
JOIN produto_vendedor pv        ON pv.idProduto = pr.idProduto
JOIN vendedor_terceiro v        ON v.idVendedor = pv.idVendedor
WHERE pf.idFornecedor IS NULL
ORDER BY pr.nome;

-- E6) Quais clientes cadastrados nunca fizeram um pedido?
--     Clausulas: SELECT, LEFT JOIN + IS NULL
SELECT c.idCliente,
       c.tipo,
       COALESCE(CONCAT(pf.nome, ' ', pf.sobrenome), pj.razaoSocial) AS cliente,
       c.dataCadastro
FROM cliente c
LEFT JOIN cliente_pf pf ON pf.idCliente = c.idCliente
LEFT JOIN cliente_pj pj ON pj.idCliente = c.idCliente
LEFT JOIN pedido p      ON p.idCliente  = c.idCliente
WHERE p.idPedido IS NULL;

-- E7) Quais entregas chegaram depois da data prevista e com quantos dias de
--     atraso? (mostra o cliente, a transportadora e o codigo de rastreio)
--     Clausulas: SELECT (DATEDIFF), JOIN (4 tabelas), WHERE, ORDER BY
SELECT p.idPedido,
       COALESCE(CONCAT(pf.nome, ' ', pf.sobrenome), pj.razaoSocial) AS cliente,
       e.transportadora,
       e.codigoRastreio,
       e.previsaoEntrega,
       DATE(e.dataEntrega)                                          AS entregue_em,
       DATEDIFF(DATE(e.dataEntrega), e.previsaoEntrega)             AS dias_de_atraso
FROM entrega e
JOIN pedido p           ON p.idPedido  = e.idPedido
JOIN cliente c          ON c.idCliente = p.idCliente
LEFT JOIN cliente_pf pf ON pf.idCliente = c.idCliente
LEFT JOIN cliente_pj pj ON pj.idCliente = c.idCliente
WHERE e.status = 'ENTREGUE'
  AND DATE(e.dataEntrega) > e.previsaoEntrega
ORDER BY dias_de_atraso DESC;

-- E8) Qual o acompanhamento de cada pedido: status do pedido, status da
--     entrega e codigo de rastreio?
--     Clausulas: SELECT, JOIN, ORDER BY
SELECT p.idPedido,
       p.status  AS status_pedido,
       e.status  AS status_entrega,
       e.codigoRastreio,
       e.transportadora,
       e.previsaoEntrega
FROM pedido p
JOIN entrega e ON e.idPedido = p.idPedido
ORDER BY p.idPedido;


-- =====================================================================
-- F. AGRUPAMENTOS E FILTROS DE GRUPO (GROUP BY + HAVING)
-- =====================================================================

-- F1) Quais clientes fizeram mais de um pedido e quanto gastaram no total?
--     (considera apenas pedidos nao cancelados)
--     Clausulas: SELECT, JOIN, WHERE, GROUP BY, HAVING, ORDER BY
WITH total_pedido AS (
    SELECT p.idPedido,
           p.idCliente,
           SUM(i.quantidade * i.precoUnitario) + p.frete AS total
    FROM pedido p
    JOIN item_pedido i ON i.idPedido = p.idPedido
    WHERE p.status <> 'CANCELADO'
    GROUP BY p.idPedido, p.idCliente, p.frete
)
SELECT c.idCliente,
       c.tipo,
       COALESCE(CONCAT(pf.nome, ' ', pf.sobrenome), pj.razaoSocial) AS cliente,
       COUNT(*)                                                     AS qtd_pedidos,
       SUM(t.total)                                                 AS total_gasto,
       ROUND(AVG(t.total), 2)                                       AS ticket_medio
FROM total_pedido t
JOIN cliente c          ON c.idCliente  = t.idCliente
LEFT JOIN cliente_pf pf ON pf.idCliente = c.idCliente
LEFT JOIN cliente_pj pj ON pj.idCliente = c.idCliente
GROUP BY c.idCliente, c.tipo, pf.nome, pf.sobrenome, pj.razaoSocial
HAVING COUNT(*) > 1
ORDER BY total_gasto DESC;

-- F2) Quais pedidos foram pagos com mais de uma forma de pagamento e quais
--     foram elas?
--     Clausulas: SELECT, JOIN, GROUP BY, GROUP_CONCAT, HAVING
SELECT pg.idPedido,
       COUNT(*)                                           AS qtd_pagamentos,
       SUM(pg.valor)                                      AS total_pago,
       GROUP_CONCAT(fp.tipo ORDER BY fp.tipo SEPARATOR ', ') AS formas_utilizadas
FROM pagamento pg
JOIN forma_pagamento fp ON fp.idFormaPagamento = pg.idFormaPagamento
GROUP BY pg.idPedido
HAVING COUNT(*) > 1
ORDER BY pg.idPedido;

-- F3) Quais clientes tem mais de uma forma de pagamento ativa cadastrada?
--     Clausulas: SELECT, JOIN, WHERE, GROUP BY, HAVING, ORDER BY
SELECT c.idCliente,
       c.email,
       COUNT(fp.idFormaPagamento)                            AS qtd_formas_pagamento,
       GROUP_CONCAT(fp.tipo ORDER BY fp.tipo SEPARATOR ', ') AS formas
FROM cliente c
JOIN forma_pagamento fp ON fp.idCliente = c.idCliente
WHERE fp.ativo
GROUP BY c.idCliente, c.email
HAVING COUNT(fp.idFormaPagamento) > 1
ORDER BY qtd_formas_pagamento DESC, c.idCliente;

-- F4) Quais produtos estao com estoque total abaixo de 20 unidades
--     (candidatos a reposicao)?
--     Clausulas: SELECT, JOIN, GROUP BY, HAVING, ORDER BY
SELECT pr.nome,
       SUM(pe.quantidade) AS qtd_em_estoque
FROM produto pr
JOIN produto_estoque pe ON pe.idProduto = pr.idProduto
GROUP BY pr.idProduto, pr.nome
HAVING SUM(pe.quantidade) < 20
ORDER BY qtd_em_estoque;

-- F5) Quais categorias de produto faturaram mais de R$ 1.000 em pedidos
--     confirmados (sem contar o frete)?
--     Clausulas: SELECT, JOIN (3 tabelas), WHERE, GROUP BY, HAVING, ORDER BY
SELECT pr.categoria,
       SUM(i.quantidade)                  AS unidades_vendidas,
       SUM(i.quantidade * i.precoUnitario) AS faturamento
FROM item_pedido i
JOIN pedido p   ON p.idPedido  = i.idPedido
JOIN produto pr ON pr.idProduto = i.idProduto
WHERE p.status = 'CONFIRMADO'
GROUP BY pr.categoria
HAVING SUM(i.quantidade * i.precoUnitario) > 1000
ORDER BY faturamento DESC;

-- F6) Qual o ticket medio de pedidos de clientes PF e de clientes PJ?
--     Clausulas: SELECT, JOIN, WHERE, GROUP BY, ORDER BY
WITH total_pedido AS (
    SELECT p.idPedido,
           p.idCliente,
           SUM(i.quantidade * i.precoUnitario) + p.frete AS total
    FROM pedido p
    JOIN item_pedido i ON i.idPedido = p.idPedido
    WHERE p.status <> 'CANCELADO'
    GROUP BY p.idPedido, p.idCliente, p.frete
)
SELECT c.tipo,
       COUNT(*)               AS qtd_pedidos,
       ROUND(AVG(t.total), 2) AS ticket_medio
FROM total_pedido t
JOIN cliente c ON c.idCliente = t.idCliente
GROUP BY c.tipo
ORDER BY ticket_medio DESC;

-- F7) Quantas entregas existem em cada status?
--     Clausulas: SELECT, GROUP BY, ORDER BY
SELECT status, COUNT(*) AS qtd_entregas
FROM entrega
GROUP BY status
ORDER BY qtd_entregas DESC, status;


-- ---------------------------------------------------------------------
-- Testes de integridade (cada comando abaixo DEVE falhar)
-- Descomente um por vez para ver as regras do modelo em acao.
-- ---------------------------------------------------------------------

-- a) Cliente PF nao pode ganhar tambem um registro PJ
-- INSERT INTO cliente_pj (idCliente, razaoSocial, cnpj) VALUES (1, 'Maria ME', '55555555000155');

-- b) Cliente PJ nao pode ganhar registro PF
-- INSERT INTO cliente_pf (idCliente, nome, sobrenome, cpf) VALUES (3, 'Teste', 'Teste', '33333333333');

-- c) Pagar o pedido da Maria (cliente 1) com a forma de pagamento do Joao (cliente 2)
-- INSERT INTO pagamento (idPedido, idFormaPagamento, idCliente, valor) VALUES (1, 4, 1, 10.00);

-- d) Entrega postada sem codigo de rastreio
-- UPDATE entrega SET status = 'POSTADO' WHERE idPedido = 2;
