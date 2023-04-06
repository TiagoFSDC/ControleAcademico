create database CursoNotas;
Go
use CursoNotas

create TABLE Aluno(
    RA int not null,
    Nome varchar(120) not null,

    CONSTRAINT PK_Aluno primary key(RA)
)
Go

create table Disciplina(
    Codigo int,
    Nome varchar(15) not null,
    Carga_Horaria int not null,

    CONSTRAINT PK_Disciplina primary key(Codigo),
)

Go
create table Matricula(
    ID int identity(1,1) not null,
    RA int not null,
    Ano int not null,
    Semestre INT not null,

    CONSTRAINT PK_Matricula primary key(ID),
    CONSTRAINT FK_Matricula_Aluno FOREIGN KEY(RA) REFERENCES Aluno(RA),
    CONSTRAINT UN_Matricula unique (RA,ano,semestre)
)

Go
create table Item_Matricula(
    IDMatricula int not null,
    Codigo int not null,
    Nota1 decimal(4,2), 
    Nota2 decimal(4,2),
    Sub decimal(4,2),
    Situação varchar(19) not null,
    Falta int not null,

    CONSTRAINT PK_Item_Matricula primary key (IDMatricula,Codigo),
    CONSTRAINT FK_Item_Matricula_Disciplina FOREIGN KEY (Codigo) REFERENCES Disciplina(Codigo),
    constraint FK_Item_Matricula_Matricula FOREIGN KEY(IDMatricula) REFERENCES Matricula --- Implícito que é a chave primaria 
)
Go

insert into Aluno values(1,'Giovani');
insert into Aluno(nome, ra) values('Ana Maria', 2);
insert into aluno values(3,'Felipe')

select ra,nome from Aluno
order by 1

insert into Disciplina Values(1,'Banco de dados', 80), (2,'IA',80), (3,'SO',60)
SELECT * from disciplina
insert into Matricula values(3,2023,2)
select * from Matricula

update Disciplina set nome = 'Inteligencia Ar', Carga_Horaria = 100
where codigo = 2



update Disciplina set nome = 'Banco de dados', Carga_Horaria = 80
where codigo = 1

SELECT * from disciplina
delete Disciplina
where Carga_Horaria <= 80

-- Disciplinas da matricula de cada aluno

insert into Item_Matricula (IDMatricula,codigo,Falta,situação) VALUES(1,1,0,'Matriculado')
select * from Item_Matricula
insert into Item_Matricula (IDMatricula,codigo,Falta,situação) VALUES(3,1,0,'Matriculado')
insert into Item_Matricula (IDMatricula,codigo,Falta,situação) VALUES(1,2,0,'Matriculado')


select m.Ano, m.Semestre,m.id, a.Nome,d.nome
from Aluno a join Matricula m on a.ra= m.ra
    join Item_Matricula im on m.ID = im.IDMatricula
    join Disciplina d on im.Codigo = d.Codigo

select m.Ano, m.Semestre,m.id, a.Nome, d.nome, im.Nota1, im.nota2, im.sub ,im.Falta, im.Situação
from Aluno a join Matricula m on a.ra= m.ra
    join Item_Matricula im on m.ID = im.IDMatricula
    join Disciplina d on im.Codigo = d.Codigo
where a.nome = 'giovani'

select *from Item_Matricula
update Item_Matricula set SUB = 6
where Codigo = 3
Go

select m.ano, m.semestre, m.ID, a.nome, d.nome, im.nota1, im.nota2, im.sub,
        Case   
            when (Sub is null) then (nota1+nota2)/2
            when (Sub > nota1) and (nota1<nota2) then (sub+nota2)/2 
            when (Sub > nota2) and (nota2<nota1) then (sub+nota1)/2 
        end as 'Media'
from Aluno a join Matricula m on a.ra = m.ra
    join Item_Matricula im on m.id = im.IDMatricula
    join Disciplina d on im.codigo = d.codigo
where a.nome = 'Giovani';
Go

-- Criação trigger para calculo da media das notas após o updaate

CREATE OR ALTER TRIGGER TGR_Media_Insert ON Item_Matricula AFTER UPDATE, INSERT
AS
BEGIN
    IF(UPDATe(nota2))
    Begin
        DECLARE @id INT, @codigo INT, @nota1 DECIMAL(4,2), @nota2 DECIMAL(4,2), @media DECIMAL(4,2)

        SELECT @id = IDMatricula, @codigo = Codigo, @nota1 = Nota1, @nota2 = Nota2 FROM inserted
        SET @media = (@nota1 + @nota2)/2

        UPDATE Item_Matricula SET media = @media
        WHERE IDMatricula = @id AND Codigo = @codigo
    END
END;
Go
-- Criação trigger para atualizar o campo da situação do aluno

CREATE OR ALTER TRIGGER TGR_Situação_Update on Item_Matricula AFTER UPDATE 
AS
BEGIN
    IF(UPDATE(Media))
    Begin
        DECLARE @id INT, @codigo INT, @media DECIMAL(4,2), @situação varchar(19)

        SELECT @id = IDMatricula, @codigo = Codigo, @situação = Situação, @media = Media FROM inserted

        Set @situação = CASE 
            when(@media >= 5) THEN 'Aprovado'
            when(@media < 5)  THEN 'Reprovado'
        END;
        PRINT(@situação)

        UPDATE Item_Matricula SET situação = @situação WHERE IDMatricula = @id AND Codigo = @codigo
    End
END;

GO
Create or Alter TRIGGER Trigger_Faltas on Item_Matricula  AFTER UPDATE
AS
Begin
    IF(UPDATE(Falta))
    BEGIN
        DECLARE @id INT, @situação varchar(19), @cargahoraria int, @falta int, @codigo int

        SELECT  @id = i.IDMatricula, @situação = i.Situação, @falta = i.Falta, @codigo = i.Codigo, @cargahoraria = d.Carga_Horaria
        From Inserted i 
        inner join disciplina d on i.codigo = d.codigo AND i.IDMatricula = i.IDMatricula

        --Select @id = IDMatricula, @situação = Situação, @falta = Falta, @codigo = Codigo from Inserted
        --SELECT @cargahoraria = Carga_Horaria From Disciplina where Codigo = @codigo

        SET @situação = Case 
            when (@falta > (@cargahoraria/2)) then 'REPROVADO POR FALTAS'
            else @situação
        end 

        Update Item_Matricula set Situação = @situação where IDMatricula = @id AND Codigo = @codigo
    END
End;

UPDATE Item_Matricula SET nota1 = 7.00, nota2 = 8.00 where IDMatricula = 1 AND codigo = 1
update Item_Matricula set Falta = 15 WHERE IDMatricula = 1 AND Codigo = 1

update Item_Matricula set Situação = 'Matriculado' where IDMatricula = 1 AND Codigo = 1
Alter table Item_Matricula ADD
    Media decimal(4,2) null

GO
Insert Into Item_Matricula (IDMAtricula,Codigo, Nota1,Nota2,situação, falta) Values(
    3,
    2,
    5,
    7,
    'Aprovado',
    2
)

select * from Aluno
select * from Matricula
select * from Disciplina
Select * from Item_Matricula
Go
