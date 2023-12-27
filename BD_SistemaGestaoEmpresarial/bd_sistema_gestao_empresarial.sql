-- CRIAÇÃO DO BANCO DE DADOS:
CREATE DATABASE IF NOT EXISTS bd_sistema_gestao_empresarial;

-- SELECIONANDO O BANCO DE DADOS:
USE bd_sistema_gestao_empresarial;

-- CRIAÇÃO DAS TABELAS:

-- Armazena informações sobre endereços de clientes, fornecedores.
CREATE TABLE IF NOT EXISTS enderecos (
    id_enderecos INT AUTO_INCREMENT PRIMARY KEY,
    logradouro VARCHAR(255) NOT NULL,
    numero VARCHAR(6) NOT NULL,
    complemento VARCHAR(255),
    bairro VARCHAR(100) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    uf CHAR(2) NOT NULL,
    cep VARCHAR(8) NOT NULL
);

-- Armazena informações de contato de clientes, fornecedores.
CREATE TABLE IF NOT EXISTS contatos (
    id_contatos INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    telefone_01 VARCHAR(11) NOT NULL,
    telefone_02 VARCHAR(11)
);

-- Armazena os status de pagamento de contas a pagar e a receber.
CREATE TABLE IF NOT EXISTS status_pagamento (
    id_status_pagamento INT AUTO_INCREMENT PRIMARY KEY,
    descricao ENUM('Pendente', 'Pago', 'Atrasado') NOT NULL
);

-- Armazena informações sobre clientes, como nome, CPF, endereço e contatos.
CREATE TABLE IF NOT EXISTS clientes (
    id_clientes INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(11) UNIQUE,
    id_enderecos INT NOT NULL,
    id_contatos INT NOT NULL,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_enderecos) REFERENCES enderecos(id_enderecos) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_contatos) REFERENCES contatos(id_contatos) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Armazena informações sobre fornecedores, como nome, CNPJ, endereço e contatos.
CREATE TABLE IF NOT EXISTS fornecedores (
    id_fornecedores INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cnpj VARCHAR(14) UNIQUE,
    id_enderecos INT NOT NULL,
    id_contatos INT NOT NULL,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_enderecos) REFERENCES enderecos(id_enderecos) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_contatos) REFERENCES contatos(id_contatos) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Armazena informações sobre produtos, como código de barras, descrição, categoria, preço de custo e preço de venda.
CREATE TABLE IF NOT EXISTS produtos (
    id_produtos INT AUTO_INCREMENT PRIMARY KEY,
    codigo_de_barras BIGINT NOT NULL UNIQUE,
    descricao VARCHAR(100) NOT NULL,
    categoria VARCHAR(100) NOT NULL,
    preco_de_custo DECIMAL(8, 2) NOT NULL,
    preco_de_venda DECIMAL(8, 2) NOT NULL,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Armazena a quantidade de produtos em estoque.
CREATE TABLE IF NOT EXISTS estoque (
    id_produto INT,
    quantidade INT NOT NULL,
    estoque_minimo INT,
    estoque_maximo INT,
    PRIMARY KEY (id_produto),
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produtos) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Armazena informações sobre compras, como data, subtotal e data de atualização.
CREATE TABLE IF NOT EXISTS compras (
    id_compras INT AUTO_INCREMENT PRIMARY KEY,
    data_compra TIMESTAMP NOT NULL,
    subtotal DECIMAL(8, 2),
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Armazena informações sobre vendas, como data, subtotal, total recebido e troco.
CREATE TABLE IF NOT EXISTS vendas (
    id_vendas INT AUTO_INCREMENT PRIMARY KEY,
    data_venda TIMESTAMP NOT NULL,
    subtotal DECIMAL(8, 2),
    total_recebido DECIMAL(8, 2),
    troco DECIMAL(8, 2),
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Armazena a relação entre uma compra e os produtos comprados.
CREATE TABLE IF NOT EXISTS itens_compra (
    id_compras INT,
    id_produtos INT,
    quantidade INT NOT NULL,
    preco_custo DECIMAL(8, 2) NOT NULL,
    total_item DECIMAL(8, 2),
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id_compras, id_produtos),
    FOREIGN KEY (id_compras) REFERENCES compras(id_compras) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_produtos) REFERENCES produtos(id_produtos) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Armazena a relação entre uma venda e os produtos vendidos.
CREATE TABLE IF NOT EXISTS itens_venda (
    id_vendas INT,
    id_produtos INT,
    quantidade INT NOT NULL,
    preco_venda DECIMAL(8, 2) NOT NULL,
    total_item DECIMAL(8, 2),
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id_vendas, id_produtos),
    FOREIGN KEY (id_vendas) REFERENCES vendas(id_vendas) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_produtos) REFERENCES produtos(id_produtos) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Armazena informações sobre contas a pagar, como data de vencimento, valor, data de pagamento e status de pagamento.
CREATE TABLE IF NOT EXISTS contas_pagar (
    id_contas_pagar INT AUTO_INCREMENT PRIMARY KEY,
    id_fornecedores INT,
    valor DECIMAL(8, 2) NOT NULL,
    data_vencimento TIMESTAMP NOT NULL,
    data_de_pagamento TIMESTAMP,
    id_status_pagamento INT NOT NULL,
    descricao VARCHAR(100),
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_fornecedores) REFERENCES fornecedores(id_fornecedores) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_status_pagamento) REFERENCES status_pagamento(id_status_pagamento)
);

-- Armazena informações sobre contas a receber, como data de vencimento, valor, data de pagamento e status de pagamento.
CREATE TABLE IF NOT EXISTS contas_receber (
    id_contas_receber INT AUTO_INCREMENT PRIMARY KEY,
    id_clientes INT,
    valor DECIMAL(8, 2) NOT NULL,
    data_vencimento TIMESTAMP NOT NULL,
    data_de_pagamento TIMESTAMP,
    id_status_pagamento INT NOT NULL,
    descricao VARCHAR(100),
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_clientes) REFERENCES clientes(id_clientes) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_status_pagamento) REFERENCES status_pagamento(id_status_pagamento)
);

-- Armazena o histórico de preços de produtos, incluindo o preço de custo antigo, o preço de custo novo, o preço de venda antigo, o preço de venda novo e o tipo de alteração.
CREATE TABLE IF NOT EXISTS historico_precos (
    id_historico_precos INT AUTO_INCREMENT PRIMARY KEY,
    id_produto INT NOT NULL,
    data_alteracao TIMESTAMP NOT NULL,
    preco_custo_antigo DECIMAL(8, 2) NOT NULL,
    preco_custo_novo DECIMAL(8, 2) NOT NULL,
    preco_venda_antigo DECIMAL(8, 2) NOT NULL,
    preco_venda_novo DECIMAL(8, 2) NOT NULL,
    tipo_alteracao VARCHAR(50),
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produtos) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Armazena o histórico de quantidade em estoque de produtos, incluindo a quantidade antiga, a quantidade nova e o tipo de alteração.
CREATE TABLE IF NOT EXISTS historico_estoque (
    id_historico_estoque INT AUTO_INCREMENT PRIMARY KEY,
    id_produto INT NOT NULL,
    data_alteracao TIMESTAMP NOT NULL,
    quantidade_antiga INT NOT NULL,
    quantidade_nova INT NOT NULL,
    tipo_alteracao VARCHAR(50),
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produtos) ON DELETE CASCADE ON UPDATE CASCADE
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
BEFORE DELETE ON itens_compra
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
BEFORE DELETE ON itens_venda
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
BEFORE DELETE ON itens_compra
FOR EACH ROW
BEGIN
    INSERT INTO historico_estoque (id_produtos, data_alteracao, quantidade_antiga, quantidade_nova, tipo_alteracao)
    VALUES (OLD.id_produtos, NOW(), (SELECT quantidade FROM estoque WHERE id_produtos = OLD.id_produtos) + OLD.quantidade, (SELECT quantidade FROM estoque WHERE id_produtos = OLD.id_produtos), 'Exclusão de Compra');
END $$

-- Insere no histórico de estoque após a exclusão de uma venda
CREATE TRIGGER atualiza_historico_estoque_apos_exclusao_venda
BEFORE DELETE ON itens_venda
FOR EACH ROW
BEGIN
    INSERT INTO historico_estoque (id_produtos, data_alteracao, quantidade_antiga, quantidade_nova, tipo_alteracao)
    VALUES (OLD.id_produtos, NOW(), (SELECT quantidade FROM estoque WHERE id_produtos = OLD.id_produtos) + OLD.quantidade, (SELECT quantidade FROM estoque WHERE id_produtos = OLD.id_produtos), 'Exclusão de Venda');
END $$

-- Restaura o delimitador padrão
DELIMITER ;
