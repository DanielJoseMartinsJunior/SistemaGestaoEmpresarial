-- CRIAÇÃO DO BANCO DE DADOS:
CREATE DATABASE bd_sistema_gestao_empresarial;

-- SELECIONANDO O BANCO DE DADOS:
USE bd_sistema_gestao_empresarial;

-- CRIAÇÃO DAS TABELAS:
CREATE TABLE enderecos (
    id_enderecos INT AUTO_INCREMENT PRIMARY KEY,
    logradouro VARCHAR(255) NOT NULL,
    numero INT NOT NULL,
    complemento VARCHAR(255),
    bairro VARCHAR(100) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    uf CHAR(2) NOT NULL,
    cep VARCHAR(8) NOT NULL
);

CREATE TABLE contatos (
    id_contatos INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    telefone_01 VARCHAR(11) NOT NULL,
    telefone_02 VARCHAR(11)
);

CREATE TABLE clientes (
    id_clientes INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(11) UNIQUE,
    id_enderecos INT NOT NULL,
    id_contatos INT NOT NULL,
    data_atualizacao DATETIME NOT NULL,
    FOREIGN KEY (id_enderecos) REFERENCES enderecos(id_enderecos),
    FOREIGN KEY (id_contatos) REFERENCES contatos(id_contatos)
);

CREATE TABLE fornecedores (
    id_fornecedores INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cnpj VARCHAR(14) UNIQUE,
    id_enderecos INT NOT NULL,
    id_contatos INT NOT NULL,
    data_atualizacao DATETIME NOT NULL,
    FOREIGN KEY (id_enderecos) REFERENCES enderecos(id_enderecos),
    FOREIGN KEY (id_contatos) REFERENCES contatos(id_contatos)
);

CREATE TABLE produtos (
    id_produtos INT AUTO_INCREMENT PRIMARY KEY,
    codigo_de_barras BIGINT NOT NULL UNIQUE,
    descricao VARCHAR(100) NOT NULL,
    categoria VARCHAR(100) NOT NULL,
    preco_de_custo DECIMAL(8, 2) NOT NULL,
    preco_de_venda DECIMAL(8, 2) NOT NULL,
    data_atualizacao DATETIME NOT NULL
);

CREATE TABLE estoque (
    id_produto INT,
    quantidade INT NOT NULL,
    estoque_minimo INT,
    estoque_maximo INT,
    PRIMARY KEY (id_produto),
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produtos)
);

CREATE TABLE compras (
    id_compras INT AUTO_INCREMENT PRIMARY KEY,
    data_compra DATETIME NOT NULL,
    subtotal DECIMAL(8,2),
    data_atualizacao DATETIME NOT NULL
);

CREATE TABLE vendas (
    id_vendas INT AUTO_INCREMENT PRIMARY KEY,
    data_venda DATETIME NOT NULL,
    subtotal DECIMAL(8,2),
    total_recebido DECIMAL(8,2),
    troco DECIMAL(8,2),
    data_atualizacao DATETIME NOT NULL
);

CREATE TABLE itens_compra (
    id_compras INT,
    id_produtos INT,
    quantidade INT NOT NULL,
    preco_custo DECIMAL(8,2) NOT NULL,
    total_item DECIMAL(8,2),
    data_atualizacao DATETIME NOT NULL,
    PRIMARY KEY (id_compras, id_produtos),
    FOREIGN KEY (id_compras) REFERENCES compras(id_compras),
    FOREIGN KEY (id_produtos) REFERENCES produtos(id_produtos)
);

CREATE TABLE itens_venda (
    id_vendas INT,
    id_produtos INT,
    quantidade INT NOT NULL,
    preco_venda DECIMAL(8,2) NOT NULL,
    total_item DECIMAL(8,2),
    data_atualizacao DATETIME NOT NULL,
    PRIMARY KEY (id_vendas, id_produtos),
    FOREIGN KEY (id_vendas) REFERENCES vendas(id_vendas),
    FOREIGN KEY (id_produtos) REFERENCES produtos(id_produtos)
);

CREATE TABLE status_pagamento (
    id_status INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(50) NOT NULL
);

CREATE TABLE contas_pagar (
    id_contas_pagar INT AUTO_INCREMENT PRIMARY KEY,
    id_fornecedores INT,
    valor DECIMAL(8,2) NOT NULL,
    data_vencimento DATETIME NOT NULL,
    data_de_pagamento DATETIME,
    id_status_pagamento INT NOT NULL,
    descricao VARCHAR(100),
    data_atualizacao DATETIME NOT NULL,
    FOREIGN KEY (id_fornecedores) REFERENCES fornecedores(id_fornecedores),
    FOREIGN KEY (id_status_pagamento) REFERENCES status_pagamento(id_status)
);

CREATE TABLE contas_receber (
    id_contas_receber INT AUTO_INCREMENT PRIMARY KEY,
    id_clientes INT,
    valor DECIMAL(8,2) NOT NULL,
    data_vencimento DATETIME NOT NULL,
    data_de_pagamento DATETIME,
    id_status_pagamento INT NOT NULL,
    descricao VARCHAR(100),
    data_atualizacao DATETIME NOT NULL,
    FOREIGN KEY (id_clientes) REFERENCES clientes(id_clientes),
    FOREIGN KEY (id_status_pagamento) REFERENCES status_pagamento(id_status)
);

CREATE TABLE historico_precos (
    id_historico_precos INT AUTO_INCREMENT PRIMARY KEY,
    id_produto INT NOT NULL,
    data_alteracao DATETIME NOT NULL,
    preco_custo_antigo DECIMAL(8,2) NOT NULL,
    preco_custo_novo DECIMAL(8,2) NOT NULL,
    preco_venda_antigo DECIMAL(8,2) NOT NULL,
    preco_venda_novo DECIMAL(8,2) NOT NULL,
    tipo_alteracao VARCHAR(50),
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produtos)
);

CREATE TABLE historico_estoque (
    id_historico_estoque INT AUTO_INCREMENT PRIMARY KEY,
    id_produto INT NOT NULL,
    data_alteracao DATETIME NOT NULL,
    quantidade_antiga INT NOT NULL,
    quantidade_nova INT NOT NULL,
    tipo_alteracao VARCHAR(50),
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produtos)
);

-- CRIAÇÃO DAS TRIGGERS:
-- Define o delimitador padrão
DELIMITER $$

-- Atualiza a quantidade em estoque após a inserção de uma compra
CREATE TRIGGER atualiza_estoque_compra_apos_insercao
AFTER INSERT ON itens_compra
FOR EACH ROW
BEGIN
    UPDATE estoque
    SET quantidade = quantidade + NEW.quantidade
    WHERE id_produtos = NEW.id_produtos;
END $$

-- Atualiza a quantidade em estoque após a atualização de uma compra
CREATE TRIGGER atualiza_estoque_compra_apos_atualizacao
AFTER UPDATE ON itens_compra
FOR EACH ROW
BEGIN
    UPDATE estoque
    SET quantidade = quantidade - OLD.quantidade + NEW.quantidade
    WHERE id_produtos = NEW.id_produtos;
END $$

-- Atualiza a quantidade em estoque após a exclusão de uma compra
CREATE TRIGGER atualiza_estoque_compra_apos_exclusao
AFTER DELETE ON itens_compra
FOR EACH ROW
BEGIN
    UPDATE estoque
    SET quantidade = quantidade - OLD.quantidade
    WHERE id_produtos = OLD.id_produtos;
END $$

-- Atualiza a quantidade em estoque após a inserção de uma venda
CREATE TRIGGER atualiza_estoque_venda_apos_insercao
AFTER INSERT ON itens_venda
FOR EACH ROW
BEGIN
    UPDATE estoque
    SET quantidade = quantidade - NEW.quantidade
    WHERE id_produtos = NEW.id_produtos;
END $$

-- Atualiza a quantidade em estoque após a atualização de uma venda
CREATE TRIGGER atualiza_estoque_venda_apos_atualizacao
AFTER UPDATE ON itens_venda
FOR EACH ROW
BEGIN
    UPDATE estoque
    SET quantidade = quantidade + OLD.quantidade - NEW.quantidade
    WHERE id_produtos = NEW.id_produtos;
END $$

-- Atualiza a quantidade em estoque após a exclusão de uma venda
CREATE TRIGGER atualiza_estoque_venda_apos_exclusao
AFTER DELETE ON itens_venda
FOR EACH ROW
BEGIN
    UPDATE estoque
    SET quantidade = quantidade + OLD.quantidade
    WHERE id_produtos = OLD.id_produtos;
END $$

-- Insere no histórico de preços se houver alteração no preço de custo
CREATE TRIGGER atualiza_historico_preco_apos_atualizacao_custo
AFTER UPDATE ON produtos
FOR EACH ROW
BEGIN
    IF OLD.preco_de_custo != NEW.preco_de_custo THEN
        INSERT INTO historico_precos (id_produtos, data_alteracao, preco_custo_antigo, preco_custo_novo, preco_venda_antigo, preco_venda_novo, tipo_alteracao)
        VALUES (NEW.id_produtos, NOW(), OLD.preco_de_custo, NEW.preco_de_custo, OLD.preco_de_venda, NEW.preco_de_venda, 'Atualização do Preço de Custo');
    END IF;
END $$

-- Insere no histórico de preços se houver alteração no preço de venda
CREATE TRIGGER atualiza_historico_preco_apos_atualizacao_venda
AFTER UPDATE ON produtos
FOR EACH ROW
BEGIN
    IF OLD.preco_de_venda != NEW.preco_de_venda THEN
        INSERT INTO historico_precos (id_produtos, data_alteracao, preco_custo_antigo, preco_custo_novo, preco_venda_antigo, preco_venda_novo, tipo_alteracao)
        VALUES (NEW.id_produtos, NOW(), OLD.preco_de_custo, NEW.preco_de_custo, OLD.preco_de_venda, NEW.preco_de_venda, 'Atualização do Preço de Venda');
    END IF;
END $$

-- Insere no histórico de preços após a inserção de um novo produto
CREATE TRIGGER insere_historico_preco_apos_insercao
AFTER INSERT ON produtos
FOR EACH ROW
BEGIN
    INSERT INTO historico_precos (id_produtos, data_alteracao, preco_custo_antigo, preco_custo_novo, preco_venda_antigo, preco_venda_novo, tipo_alteracao)
    VALUES (NEW.id_produtos, NOW(), NEW.preco_de_custo, NULL, NEW.preco_de_venda, NULL, 'Inserção de um novo produto');
END $$

-- Insere no histórico de preços após a exclusão de um produto
CREATE TRIGGER insere_historico_preco_apos_exclusao
AFTER DELETE ON produtos
FOR EACH ROW
BEGIN
    INSERT INTO historico_precos (id_produtos, data_alteracao, preco_custo_antigo, preco_custo_novo, preco_venda_antigo, preco_venda_novo, tipo_alteracao)
    VALUES (OLD.id_produtos, NOW(), OLD.preco_de_custo, NULL, OLD.preco_de_venda, NULL, 'Exclusão de um produto');
END $$

-- Insere no histórico de estoque após a inserção de uma compra
CREATE TRIGGER atualiza_historico_estoque_apos_compra
AFTER INSERT ON itens_compra
FOR EACH ROW
BEGIN
    INSERT INTO historico_estoque (id_produtos, data_alteracao, quantidade_antiga, quantidade_nova, tipo_alteracao)
    VALUES (NEW.id_produtos, NOW(), (SELECT quantidade FROM estoque WHERE id_produtos = NEW.id_produtos) - NEW.quantidade, (SELECT quantidade FROM estoque WHERE id_produtos = NEW.id_produtos), 'Inserção de Compra');
END $$

-- Insere no histórico de estoque após a inserção de uma venda
CREATE TRIGGER atualiza_historico_estoque_apos_venda
AFTER INSERT ON itens_venda
FOR EACH ROW
BEGIN
    INSERT INTO historico_estoque (id_produtos, data_alteracao, quantidade_antiga, quantidade_nova, tipo_alteracao)
    VALUES (NEW.id_produtos, NOW(), (SELECT quantidade FROM estoque WHERE id_produtos = NEW.id_produtos) + NEW.quantidade, (SELECT quantidade FROM estoque WHERE id_produtos = NEW.id_produtos), 'Inserção de Venda');
END $$

-- Insere no histórico de estoque após a atualização de uma compra
CREATE TRIGGER atualiza_historico_estoque_apos_atualizacao_compra
AFTER UPDATE ON itens_compra
FOR EACH ROW
BEGIN
    INSERT INTO historico_estoque (id_produtos, data_alteracao, quantidade_antiga, quantidade_nova, tipo_alteracao)
    VALUES (NEW.id_produtos, NOW(), (SELECT quantidade FROM estoque WHERE id_produtos = NEW.id_produtos) + OLD.quantidade - NEW.quantidade, (SELECT quantidade FROM estoque WHERE id_produtos = NEW.id_produtos), 'Atualização de Compra');
END $$

-- Insere no histórico de estoque após a atualização de uma venda
CREATE TRIGGER atualiza_historico_estoque_apos_atualizacao_venda
AFTER UPDATE ON itens_venda
FOR EACH ROW
BEGIN
    INSERT INTO historico_estoque (id_produtos, data_alteracao, quantidade_antiga, quantidade_nova, tipo_alteracao)
    VALUES (NEW.id_produtos, NOW(), (SELECT quantidade FROM estoque WHERE id_produtos = NEW.id_produtos) - OLD.quantidade + NEW.quantidade, (SELECT quantidade FROM estoque WHERE id_produtos = NEW.id_produtos), 'Atualização de Venda');
END $$

-- Insere no histórico de estoque após a exclusão de uma compra
CREATE TRIGGER atualiza_historico_estoque_apos_exclusao_compra
AFTER DELETE ON itens_compra
FOR EACH ROW
BEGIN
    INSERT INTO historico_estoque (id_produtos, data_alteracao, quantidade_antiga, quantidade_nova, tipo_alteracao)
    VALUES (OLD.id_produtos, NOW(), (SELECT quantidade FROM estoque WHERE id_produtos = OLD.id_produtos) + OLD.quantidade, (SELECT quantidade FROM estoque WHERE id_produtos = OLD.id_produtos), 'Exclusão de Compra');
END $$

-- Insere no histórico de estoque após a exclusão de uma venda
CREATE TRIGGER atualiza_historico_estoque_apos_exclusao_venda
AFTER DELETE ON itens_venda
FOR EACH ROW
BEGIN
    INSERT INTO historico_estoque (id_produtos, data_alteracao, quantidade_antiga, quantidade_nova, tipo_alteracao)
    VALUES (OLD.id_produtos, NOW(), (SELECT quantidade FROM estoque WHERE id_produtos = OLD.id_produtos) + OLD.quantidade, (SELECT quantidade FROM estoque WHERE id_produtos = OLD.id_produtos), 'Exclusão de Venda');
END $$

-- Restaura o delimitador padrão
DELIMITER ;
