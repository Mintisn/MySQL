
-- 6

UPDATE property
JOIN client ON property.pro_c_id = client.c_id
SET property.pro_id_card = client.c_id_card;
-- 5
UPDATE property
SET pro_status = '冻结'
WHERE pro_c_id IN (
    SELECT c_id FROM client WHERE c_phone = '13686431238'
);

UPDATE property
JOIN client ON property.pro_c_id = client.c_id
SET pro_status = "冻结"
WHERE client.c_phone = "13686431238";
-- 4
delete from client
where not exists(
    select b_c_id from bank_card where b_c_id=c_id
);

delete from client
where not exists(
    select b_c_id from bank_card -- TODO: 为什么这个不能过
);
-- https://gist.githubusercontent.com/Mintisn/3ed558e8dc14056f50658d1fc5a213c6/raw/4d371b984233d468b48bb743e82cb7f5c2829fb8/%E5%88%A0%E9%99%A4client%E8%A1%A8%E4%B8%AD%E6%B2%A1%E6%9C%89%E9%93%B6%E8%A1%8C%E5%8D%A1%E7%9A%84%E5%AE%A2%E6%88%B7%E4%BF%A1%E6%81%AF.md

-- 3
INSERT into client
select * from new_client;

-- 2
INSERT into client(c_id,c_name,c_id_card,c_phone,c_password)
values(33,"蔡依婷","350972199204227621","18820762130","MKwEuc1sc6");
-- 1
INSERT into client values(1,"林惠雯","960323053@qq.com","411014196712130323","15609032348","Mop5UPkl");
INSERT into client values(2,"吴婉瑜","1613230826@gmail.com","420152196802131323","17605132307","QUTPhxgVNlXtMxN");
INSERT into client values(3,"蔡贞仪","252323341@foxmail.com","160347199005222323","17763232321","Bwe3gyhEErJ7");