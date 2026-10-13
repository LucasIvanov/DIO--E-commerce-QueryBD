-- =====================================================================
-- Persistencia de dados para teste (dados ficticios)
-- CPFs, CNPJs, e-mails e telefones nao correspondem a pessoas reais.
--
-- O que o conjunto de dados permite demonstrar:
--   * clientes PF e PJ, e clientes SEM nenhum pedido (LEFT JOIN / HAVING)
--   * cliente com varias formas de pagamento cadastradas
--   * pedidos pagos com mais de uma forma de pagamento
--   * entregas em todos os status, algumas com atraso
--   * empresas que sao vendedor terceiro E fornecedor ao mesmo tempo
--   * produtos sem fornecedor (vendidos so por terceiros)
--   * produtos com estoque baixo
-- =====================================================================
USE ecommerce;

-- ---------------------------------------------------------------------
-- Clientes: o supertipo recebe o tipo, o subtipo recebe os dados especificos
-- ---------------------------------------------------------------------
INSERT INTO cliente (idCliente, tipo, email, telefone, endereco, dataCadastro) VALUES
    (1,  'PF', 'maria.silva@email.com',        '11911110001', 'Rua das Flores, 100 - Sao Paulo/SP',          '2026-01-10 09:00:00'),
    (2,  'PF', 'joao.souza@email.com',         '21911110002', 'Av. Atlantica, 200 - Rio de Janeiro/RJ',      '2026-01-15 14:20:00'),
    (3,  'PJ', 'compras@techsolucoes.com',     '1133330003',  'Rua da Industria, 300 - Campinas/SP',         '2026-02-01 10:00:00'),
    (4,  'PF', 'ana.pereira@email.com',        '31911110004', 'Rua da Bahia, 45 - Belo Horizonte/MG',        '2026-02-12 16:45:00'),
    (5,  'PF', 'carlos.lima@email.com',        '41911110005', 'Rua XV de Novembro, 880 - Curitiba/PR',       '2026-03-03 11:10:00'),
    (6,  'PJ', 'financeiro@bompreco.com',      '8133330006',  'Av. Boa Viagem, 1500 - Recife/PE',            '2026-03-20 08:30:00'),
    (7,  'PF', 'beatriz.costa@email.com',      '51911110007', 'Rua Padre Chagas, 77 - Porto Alegre/RS',      '2026-04-05 19:00:00'),
    (8,  'PJ', 'contato@escritorioalfa.com',   '1144440008',  'Av. Paulista, 2000 - Sao Paulo/SP',           '2026-04-18 13:25:00'),
    (9,  'PF', 'pedro.santos@email.com',       '71911110009', 'Rua Chile, 12 - Salvador/BA',                 '2026-05-09 15:40:00'),
    (10, 'PF', 'fernanda.rocha@email.com',     '85911110010', 'Av. Beira Mar, 900 - Fortaleza/CE',           '2026-06-01 10:15:00');

INSERT INTO cliente_pf (idCliente, nome, sobrenome, cpf, dataNascimento) VALUES
    (1,  'Maria',    'Silva',   '11111111111', '1990-04-12'),
    (2,  'Joao',     'Souza',   '22222222222', '1985-09-30'),
    (4,  'Ana',      'Pereira', '44444444444', '1978-11-23'),
    (5,  'Carlos',   'Lima',    '55555555555', '1995-02-07'),
    (7,  'Beatriz',  'Costa',   '77777777777', '2000-07-19'),
    (9,  'Pedro',    'Santos',  '99999999999', '1988-12-01'),
    (10, 'Fernanda', 'Rocha',   '10101010101', '1992-03-15');

INSERT INTO cliente_pj (idCliente, razaoSocial, nomeFantasia, cnpj) VALUES
    (3, 'Tech Solucoes Ltda',            'TechSol',          '11222333000144'),
    (6, 'Mercadinho Bom Preco Ltda',     'Bom Preco',        '55666777000188'),
    (8, 'Escritorio Alfa Contabil S/S',  'Alfa Contabil',    '66777888000199');

-- ---------------------------------------------------------------------
-- Formas de pagamento: um cliente pode ter varias cadastradas
-- (a Maria tem tres; a Ana, dois; o Mercadinho, tres; o cliente 8, nenhuma)
-- ---------------------------------------------------------------------
INSERT INTO forma_pagamento (idFormaPagamento, idCliente, tipo, apelido, nomeTitular, bandeira, finalCartao, validadeCartao, chavePix) VALUES
    (1,  1,  'CARTAO_CREDITO', 'Cartao principal', 'MARIA SILVA',    'VISA',       '1234', '2030-12-01', NULL),
    (2,  1,  'CARTAO_CREDITO', 'Cartao reserva',   'MARIA SILVA',    'MASTERCARD', '5678', '2029-06-01', NULL),
    (3,  1,  'PIX',            'Pix e-mail',       NULL,             NULL,         NULL,   NULL,         'maria.silva@email.com'),
    (4,  2,  'BOLETO',         NULL,               NULL,             NULL,         NULL,   NULL,         NULL),
    (5,  3,  'TRANSFERENCIA',  'Conta empresa',    NULL,             NULL,         NULL,   NULL,         NULL),
    (6,  4,  'CARTAO_DEBITO',  'Debito Nubank',    'ANA PEREIRA',    'ELO',        '9012', '2029-03-01', NULL),
    (7,  4,  'PIX',            'Pix CPF',          NULL,             NULL,         NULL,   NULL,         '44444444444'),
    (8,  5,  'CARTAO_CREDITO', 'Cartao Itau',      'CARLOS LIMA',    'VISA',       '3456', '2028-10-01', NULL),
    (9,  6,  'BOLETO',         NULL,               NULL,             NULL,         NULL,   NULL,         NULL),
    (10, 6,  'TRANSFERENCIA',  'Conta corrente',   NULL,             NULL,         NULL,   NULL,         NULL),
    (11, 6,  'CARTAO_CREDITO', 'Cartao empresa',   'BOM PRECO LTDA', 'MASTERCARD', '7788', '2031-01-01', NULL),
    (12, 7,  'PIX',            'Pix celular',      NULL,             NULL,         NULL,   NULL,         '51911110007'),
    (13, 9,  'CARTAO_CREDITO', 'Cartao Bradesco',  'PEDRO SANTOS',   'VISA',       '1111', '2030-05-01', NULL),
    (14, 9,  'PIX',            'Pix e-mail',       NULL,             NULL,         NULL,   NULL,         'pedro.santos@email.com'),
    (15, 10, 'CARTAO_CREDITO', 'Cartao Santander', 'FERNANDA ROCHA', 'ELO',        '2222', '2029-09-01', NULL);

-- ---------------------------------------------------------------------
-- Catalogo
-- ---------------------------------------------------------------------
INSERT INTO produto (idProduto, nome, categoria, descricao, valor) VALUES
    (1, 'Fone Bluetooth',        'ELETRONICO', 'Fone sem fio com cancelamento de ruido', 250.00),
    (2, 'Camiseta Basica',       'VESTIMENTA', 'Camiseta de algodao',                     49.90),
    (3, 'Notebook 14"',          'ELETRONICO', 'Notebook 16GB RAM, 512GB SSD',          4200.00),
    (4, 'Smartphone 128GB',      'ELETRONICO', 'Smartphone com tela de 6,5 polegadas',  1800.00),
    (5, 'Boneco de Acao',        'BRINQUEDO',  'Boneco articulado de 30 cm',              89.90),
    (6, 'Cadeira de Escritorio', 'MOVEIS',     'Cadeira ergonomica com apoio lombar',    650.00),
    (7, 'Cafe Premium 500g',     'ALIMENTO',   'Cafe torrado e moido, graos selecionados', 32.50),
    (8, 'Jaqueta Jeans',         'VESTIMENTA', 'Jaqueta jeans unissex',                  189.90),
    (9, 'Quebra-Cabeca 1000',    'BRINQUEDO',  'Quebra-cabeca de 1000 pecas',             74.90);

-- Fornecedores: dois deles (Eletro Import e Moda Express) tambem aparecem
-- como vendedor terceiro, com o mesmo CNPJ
INSERT INTO fornecedor (idFornecedor, razaoSocial, cnpj, contato) VALUES
    (1, 'Distribuidora Alfa Ltda',    '12345678000190', '1144440001'),
    (2, 'Eletro Import S/A',          '22333444000155', '1155550002'),
    (3, 'Moveis Forte Ltda',          '33444555000166', '4733330003'),
    (4, 'Moda Express ME',            '98765432000110', '3155550001'),
    (5, 'Cafeeira Serra Verde Ltda',  '77888999000100', '3533330005');

INSERT INTO vendedor_terceiro (idVendedor, razaoSocial, nomeFantasia, cnpj, localizacao, contato) VALUES
    (1, 'Moda Express ME',         'Moda Express',    '98765432000110', 'Belo Horizonte/MG', '3155550001'),
    (2, 'Brinquedos Feliz Ltda',   'Brinquedos Feliz','44555666000177', 'Curitiba/PR',       '4133330002'),
    (3, 'Eletro Import S/A',       'Eletro Import',   '22333444000155', 'Sao Paulo/SP',      '1155550002');

INSERT INTO estoque (idEstoque, localizacao) VALUES
    (1, 'Sao Paulo/SP'),
    (2, 'Recife/PE'),
    (3, 'Curitiba/PR');

-- Produto x Fornecedor: o fone e o notebook tem mais de um fornecedor;
-- os brinquedos (5 e 9) nao tem nenhum (so sao vendidos por terceiros)
INSERT INTO produto_fornecedor (idProduto, idFornecedor) VALUES
    (1, 1), (1, 2),
    (3, 1), (3, 2),
    (4, 2),
    (6, 3),
    (2, 4), (8, 4),
    (7, 5);

-- Produto x Vendedor terceiro
INSERT INTO produto_vendedor (idVendedor, idProduto, quantidade) VALUES
    (1, 2, 120),
    (1, 8, 60),
    (2, 5, 80),
    (2, 9, 40),
    (3, 1, 25),
    (3, 4, 30);

-- Produto x Estoque: o quebra-cabeca (9) e a cadeira (6) estao com estoque baixo
INSERT INTO produto_estoque (idProduto, idEstoque, quantidade) VALUES
    (1, 1, 50), (1, 3, 20),
    (2, 2, 300),
    (3, 1, 15),
    (4, 1, 40), (4, 2, 0),
    (5, 3, 60),
    (6, 1, 12), (6, 2, 8),
    (7, 2, 200),
    (8, 2, 90),
    (9, 3, 5);

-- ---------------------------------------------------------------------
-- Pedidos (13): confirmados, aguardando pagamento e um cancelado
-- ---------------------------------------------------------------------
INSERT INTO pedido (idPedido, idCliente, status, descricao, frete, dataPedido) VALUES
    (1,  1,  'CONFIRMADO',           'Compra de fone e camiseta',   20.00, '2026-08-03 10:15:00'),
    (2,  2,  'AGUARDANDO_PAGAMENTO', 'Compra de camiseta',          15.00, '2026-08-05 17:30:00'),
    (3,  3,  'CONFIRMADO',           'Notebook corporativo',         0.00, '2026-08-10 09:45:00'),
    (4,  4,  'CONFIRMADO',           'Smartphone e cafe',           18.50, '2026-08-20 20:10:00'),
    (5,  5,  'CONFIRMADO',           'Cadeira e jaqueta',           25.00, '2026-09-02 12:00:00'),
    (6,  6,  'CONFIRMADO',           'Reposicao de cafe e camisetas', 40.00, '2026-09-05 08:50:00'),
    (7,  9,  'CONFIRMADO',           'Brinquedos',                  12.00, '2026-09-10 14:35:00'),
    (8,  10, 'CANCELADO',            'Fone e jaqueta',              20.00, '2026-09-12 21:05:00'),
    (9,  1,  'CONFIRMADO',           'Duas jaquetas',               15.00, '2026-09-18 11:20:00'),
    (10, 5,  'AGUARDANDO_PAGAMENTO', 'Notebook',                    30.00, '2026-10-05 16:00:00'),
    (11, 1,  'CONFIRMADO',           'Smartphone',                   0.00, '2026-10-08 10:30:00'),
    (12, 3,  'CONFIRMADO',           'Cadeiras e fones',            35.00, '2026-10-09 15:15:00'),
    (13, 4,  'CONFIRMADO',           'Cafe',                        10.00, '2026-10-10 09:05:00');

INSERT INTO item_pedido (idPedido, idProduto, quantidade, precoUnitario) VALUES
    (1,  1, 1,  250.00),
    (1,  2, 2,   49.90),
    (2,  2, 1,   49.90),
    (3,  3, 1, 4200.00),
    (4,  4, 1, 1800.00),
    (4,  7, 2,   32.50),
    (5,  6, 1,  650.00),
    (5,  8, 1,  189.90),
    (6,  7, 40,  32.50),
    (6,  2, 30,  49.90),
    (7,  5, 2,   89.90),
    (7,  9, 1,   74.90),
    (8,  1, 1,  250.00),
    (8,  8, 1,  189.90),
    (9,  8, 2,  189.90),
    (10, 3, 1, 4200.00),
    (11, 4, 1, 1800.00),
    (12, 6, 4,  650.00),
    (12, 1, 2,  250.00),
    (13, 7, 3,   32.50);

-- ---------------------------------------------------------------------
-- Pagamentos: a soma dos pagamentos de cada pedido fecha com itens + frete.
-- Pedidos 1, 4, 6 e 11 sao pagos com mais de uma forma de pagamento.
-- ---------------------------------------------------------------------
INSERT INTO pagamento (idPedido, idFormaPagamento, idCliente, valor, parcelas, status, dataPagamento) VALUES
    (1,  1,  1,  200.00,  2, 'APROVADO',  '2026-08-03 10:20:00'),
    (1,  3,  1,  169.80,  1, 'APROVADO',  '2026-08-03 10:21:00'),
    (2,  4,  2,   64.90,  1, 'PENDENTE',  NULL),
    (3,  5,  3, 4200.00,  1, 'APROVADO',  '2026-08-10 11:00:00'),
    (4,  6,  4,  883.50,  1, 'APROVADO',  '2026-08-20 20:12:00'),
    (4,  7,  4, 1000.00,  1, 'APROVADO',  '2026-08-20 20:13:00'),
    (5,  8,  5,  864.90,  3, 'APROVADO',  '2026-09-02 12:03:00'),
    (6,  9,  6, 1000.00,  1, 'APROVADO',  '2026-09-06 09:00:00'),
    (6,  10, 6, 1000.00,  1, 'APROVADO',  '2026-09-06 09:05:00'),
    (6,  11, 6,  837.00,  1, 'APROVADO',  '2026-09-05 08:55:00'),
    (7,  13, 9,  266.70,  2, 'APROVADO',  '2026-09-10 14:37:00'),
    (8,  15, 10, 459.90,  1, 'RECUSADO',  '2026-09-12 21:06:00'),
    (9,  2,  1,  394.80,  1, 'APROVADO',  '2026-09-18 11:22:00'),
    (10, 8,  5, 4230.00, 10, 'PENDENTE',  NULL),
    (11, 3,  1,  800.00,  1, 'APROVADO',  '2026-10-08 10:32:00'),
    (11, 1,  1, 1000.00,  3, 'APROVADO',  '2026-10-08 10:33:00'),
    (12, 5,  3, 3135.00,  1, 'APROVADO',  '2026-10-09 16:00:00'),
    (13, 7,  4,  107.50,  1, 'APROVADO',  '2026-10-10 09:06:00');

-- ---------------------------------------------------------------------
-- Entregas: uma por pedido, com status e (apos a postagem) codigo de rastreio.
-- Entregas 4 e 6 chegaram depois da previsao (atraso).
-- ---------------------------------------------------------------------
INSERT INTO entrega (idPedido, status, codigoRastreio, transportadora, enderecoEntrega, dataEnvio, previsaoEntrega, dataEntrega) VALUES
    (1,  'ENTREGUE',          'BR123456789XX', 'Correios',               'Rua das Flores, 100 - Sao Paulo/SP',       '2026-08-04 09:00:00', '2026-08-10', '2026-08-09 14:30:00'),
    (2,  'PREPARANDO',         NULL,           NULL,                     'Av. Atlantica, 200 - Rio de Janeiro/RJ',   NULL,                  NULL,         NULL),
    (3,  'ENTREGUE',          'BR987654321YY', 'Jadlog',                 'Rua da Industria, 300 - Campinas/SP',      '2026-08-11 08:30:00', '2026-08-16', '2026-08-15 10:10:00'),
    (4,  'ENTREGUE',          'BR555000111AA', 'Correios',               'Rua da Bahia, 45 - Belo Horizonte/MG',     '2026-08-21 09:15:00', '2026-08-28', '2026-08-30 16:45:00'),
    (5,  'ENTREGUE',          'BR555000222BB', 'Jadlog',                 'Rua XV de Novembro, 880 - Curitiba/PR',    '2026-09-03 10:00:00', '2026-09-09', '2026-09-08 13:20:00'),
    (6,  'ENTREGUE',          'BR555000333CC', 'Transportadora Rapida',  'Av. Boa Viagem, 1500 - Recife/PE',         '2026-09-06 11:30:00', '2026-09-12', '2026-09-14 09:50:00'),
    (7,  'ENTREGUE',          'BR555000444DD', 'Correios',               'Rua Chile, 12 - Salvador/BA',              '2026-09-11 08:45:00', '2026-09-17', '2026-09-16 15:05:00'),
    (8,  'PREPARANDO',         NULL,           NULL,                     'Av. Beira Mar, 900 - Fortaleza/CE',        NULL,                  NULL,         NULL),
    (9,  'DEVOLVIDO',         'BR555000555EE', 'Correios',               'Rua das Flores, 100 - Sao Paulo/SP',       '2026-09-19 09:40:00', '2026-09-25', NULL),
    (10, 'PREPARANDO',         NULL,           NULL,                     'Rua XV de Novembro, 880 - Curitiba/PR',    NULL,                  NULL,         NULL),
    (11, 'POSTADO',           'BR555000777GG', 'Correios',               'Rua das Flores, 100 - Sao Paulo/SP',       '2026-10-09 10:00:00', '2026-10-16', NULL),
    (12, 'EM_TRANSITO',       'BR555000888HH', 'Transportadora Rapida',  'Rua da Industria, 300 - Campinas/SP',      '2026-10-10 14:00:00', '2026-10-15', NULL),
    (13, 'SAIU_PARA_ENTREGA', 'BR555000999II', 'Jadlog',                 'Rua da Bahia, 45 - Belo Horizonte/MG',     '2026-10-11 08:00:00', '2026-10-14', NULL);
