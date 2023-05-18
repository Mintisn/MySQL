 -- 19) 以日历表格式列出2022年2月每周每日基金购买总金额，输出格式如下：
-- week_of_trading Monday Tuesday Wednesday Thursday Friday
select week_of_trading, 
sum(if(id = 0, amount, null)) as Monday,
sum(if(id = 1, amount, null)) as Tuesday,
sum(if(id = 2, amount, null)) as Wednesday,
sum(if(id = 3, amount, null)) as Thursday,
sum(if(id = 4, amount, null)) as Friday

from 
(select week(pro_purchase_time) - 5 as week_of_trading, weekday(pro_purchase_time) as id, sum(pro_quantity * f_amount) as amount
from property, fund
where pro_pif_id = f_id and pro_purchase_time like "2022-02-%" and pro_type = 3
group by pro_purchase_time) as weektable
group by week_of_trading;
 
 -- 18) 查询至少有一张信用卡余额超过5000元的客户编号，以及该客户持有的信用卡总余额，总余额命名为credit_card_amount。
SELECT b_c_id ,sum(b_balance) as credit_card_amount from bank_card
where b_type="信用卡"
group by b_c_id
having count(b_balance >= 5000 and b_type = '信用卡') >= 1
order by b_c_id; 
 /* TODO 为什么要加or null */

-- 17 查询2022年2月购买基金的高峰期。至少连续三个交易日，所有投资者购买基金的总金额超过100万(含)，则称这段连续交易日为投资者购买基金的高峰期。只有交易日才能购买基金,但不能保证每个交易日都有投资者购买基金。2022年春节假期之后的第1个交易日为2月7日,周六和周日是非交易日，其余均为交易日。请列出高峰时段的日期和当日基金的总购买金额，按日期顺序排序。总购买金额命名为total_amount。
# TODO 没看懂
select t3.t as pro_purchase_time, t3.amount as total_amount
from (select *, count(*) over(partition by t2.workday - t2.rownum) cnt
    from (select  *, row_number() over(order by workday) rownum
        from (select pro_purchase_time t, sum(pro_quantity * f_amount) amount,
                @row := datediff(pro_purchase_time, "2021-12-31") - 2 * week(pro_purchase_time) workday
            from property, fund, (select @row) a
            where pro_purchase_time like "2022-02-%"
            and pro_type = 3
            and pro_pif_id = f_id
            group by pro_purchase_time
        ) t1
        where amount > 1000000
    ) t2
) t3
where t3.cnt >= 3;


-- 16) 查询持有相同基金组合的客户对，如编号为A的客户持有的基金，编号为B的客户也持有，反过来，编号为B的客户持有的基金，编号为A的客户也持有，则(A,B)即为持有相同基金组合的二元组，请列出这样的客户对。为避免过多的重复，如果(1,2)为满足条件的元组，则不必显示(2,1)，即只显示编号小者在前的那一对，这一组客户编号分别命名为c_id1,c_id2。
# TODO https://gist.github.com/Mintisn/0db64dee84e52f851ebaca16bfde28c2
with t(c_id, f_id) as (
    select
        pro_c_id as c_id,
        group_concat(distinct pro_pif_id order by pro_pif_id) as f_id
    from property
    where pro_type = 3
    group by pro_c_id
)
select
    t1.c_id as c_id1,
    t2.c_id as c_id2
from t t1, t t2
where t1.c_id < t2.c_id
and t1.f_id = t2.f_id;

-- 15) 查询资产表中客户编号，客户基金投资总收益,基金投资总收益的排名(从高到低排名)。
--     总收益相同时名次亦相同(即并列名次)。总收益命名为total_revenue, 名次命名为rank。
--     第一条SQL语句实现全局名次不连续的排名，
--     第二条SQL语句实现全局名次连续的排名。

-- (1) 基金总收益排名(名次不连续)
select pro_c_id,sum(pro_income)as total_revenue, 
rank() over(ORDER by sum(pro_income)DESC)as rank1
from property
where pro_type=3
group by pro_c_id

-- (2) 基金总收益排名(名次连续)
select pro_c_id,sum(pro_income)as total_revenue, 
dense_rank() over(ORDER by sum(pro_income)DESC)as "rank"
from property
where pro_type=3
group by pro_c_id;

-- 14) 查询每份保险金额第4高保险产品的编号和保险金额。
--     在数字序列8000,8000,7000,7000,6000中，
--     两个8000均为第1高，两个7000均为第2高,6000为第3高。
select i_id,i_amount FROM (
    select i_id,i_amount, DENSE_RANK() over(ORDER BY i_amount DESC)AS rank1
    from insurance
)as ranked_insurance
where rank1=4
ORDER by i_id;
# TODO 如果把order by放在里面是会报错的
select i_id,i_amount FROM (
    select i_id,i_amount, DENSE_RANK() over(ORDER BY i_amount DESC,i_id)AS rank1
    from insurance
)as ranked_insurance
where rank1=4;
/* 这段代码与第一段代码的主要区别在于 DENSE_RANK() 函数的排序条件。它首先按照保险金额 i_amount 进行降序排序，然后在 i_amount 值相同的情况下，再按照保险产品编号 i_id 进行升序排序。在外部查询中，筛选出排名为 4 的保险产品。

可能的情况是，当保险金额 i_amount 相同时，保险产品编号 i_id 的顺序也可能不同。因此，第一段代码中按照保险产品编号 i_id 进行排序可能会影响最终的结果，而第二段代码没有指定 ORDER BY 子句，因此结果的顺序可能是不确定的。 */
-- 13 计算总资产
/* 别名重复：外层SELECT子句中的别名"total_property"被定义了两次。你可以移除第二次的别名声明。

无效的表别名：在子查询（a1、a2）中，使用了表别名"a1"和"a2"，但是这些别名没有分配给任何表。你可以移除这些别名，因为它们是不必要的。

列引用不明确：在子查询中，存在对"client.c_id"和"client.c_name"等列的引用。然而，在这些子查询的FROM子句中没有明确指定"client"表。你需要在每个子查询的FROM子句中包含"client"表。

不必要的联合操作：两个子查询几乎完全相同，除了JOIN语句中的条件。你可以将条件合并为一个子查询，并根据"pro_type"的值在不同的表上进行左连接（LEFT JOIN）操作。

分组问题：在外层SELECT子句中，你只对"c_id"进行了分组，但是却选择了"c_id"和"c_name"。由于"c_name"没有包含在GROUP BY子句中，在某些数据库系统中可能会引发错误。要么将"c_name"包含在GROUP BY子句中，要么将其从SELECT子句中移除。 */
SELECT c_id, c_name, SUM(part_property) AS total_property
FROM (
    SELECT client.c_id, client.c_name,
        SUM(
            CASE
                WHEN property.pro_type = 1 THEN pro_quantity * finances_product.p_amount+ property.pro_income
                WHEN property.pro_type = 2 THEN pro_quantity * insurance.i_amount+ property.pro_income
                WHEN property.pro_type = 3 THEN pro_quantity * fund.f_amount+ property.pro_income
                ELSE 0
            END
        ) AS part_property
    FROM client
    LEFT JOIN property ON client.c_id = property.pro_c_id
    LEFT JOIN finances_product ON property.pro_type = 1 AND property.pro_pif_id = finances_product.p_id
    LEFT JOIN insurance ON property.pro_type = 2 AND property.pro_pif_id = insurance.i_id
    LEFT JOIN fund ON property.pro_type = 3 AND property.pro_pif_id = fund.f_id
    GROUP BY client.c_id, client.c_name
    
    UNION
    
    SELECT client.c_id, client.c_name,
        SUM(
            CASE
                WHEN bank_card.b_type = '储蓄卡' THEN b_balance
                WHEN bank_card.b_type = '信用卡' THEN -b_balance
                ELSE 0
            END
        ) AS part_property
    FROM client
    LEFT JOIN bank_card ON client.c_id = bank_card.b_c_id
    GROUP BY client.c_id, client.c_name
) AS subquery
GROUP BY c_id, c_name -- cname是不可少的
ORDER BY c_id;
-- 12) 综合客户表(client)、资产表(property)、理财产品表(finances_product)、保险表(insurance)和
 --     基金表(fund)，列出客户的名称、身份证号以及投资总金额（即投资本金，
 --     每笔投资金额=商品数量*该产品每份金额)，注意投资金额按类型需要查询不同的表，
 --     投资总金额是客户购买的各类资产(理财,保险,基金)投资金额的总和，总金额命名为total_amount。
 --     查询结果按总金额降序排序。
SELECT c_name,c_id_card,sum(case when property.pro_type=1 then pro_quantity*finances_product.p_amount
                                when property.pro_type=2 then pro_quantity*insurance.i_amount
                                when property.pro_type=3 then pro_quantity*fund.f_amount
                            else 0 end)as total_amount -- TODO 需要注意这里有个0是必须要的
from client left JOIN property ON client.c_id=property.pro_c_id
left JOIN finances_product on property.pro_type=1 and pro_pif_id=finances_product.p_id
left JOIN insurance on property.pro_type=2 and pro_pif_id=insurance.i_id
left JOIN fund on property.pro_type=3 and pro_pif_id=fund.f_id
group by c_id
ORDER by total_amount DESC;


-- 11) 给出黄姓用户的编号、名称、办理的银行卡的数量(没有办卡的卡数量计为0),持卡数量命名为number_of_cards,
--     按办理银行卡数量降序输出,持卡数量相同的,依客户编号排序。
SELECT c_id,c_name,count(b_c_id) as number_of_cards FROM client
LEFT JOIN bank_card ON c_id=b_c_id
WHERE c_name like "黄%" GROUP BY c_id
ORDER BY number_of_cards DESC,c_id;
-- 10) 查询当前总的可用资产收益(被冻结的资产除外)前三名的客户的名称、身份证号及其总收益，按收益降序输出，总收益命名为total_income。不考虑并列排名情形。
SELECT c_name,c_id_card,sum(pro_income) as total_income FROM client,property
WHERE property.pro_c_id=client.c_id
AND pro_status="可用"
GROUP BY c_id
ORDER BY total_income DESC
LIMIT 3;
-- 9) 查询购买了货币型(f_type='货币型')基金的用户的名称、电话号、邮箱。
-- 筛选货币型基金
SELECT c_name,c_phone,c_mail FROM client
WHERE c_id in(
    select pro_c_id from property 
    WHERE pro_type=3
    AND pro_pif_id in ( -- 货币型基金
        SELECT f_id FROM fund 
        where f_type="货币型"
    )
)ORDER by c_id;
-- 8) 查询持有两张(含）以上信用卡的用户的名称、身份证号、手机号。
select c_name,c_id_card,c_phone from client
where (c_id,"信用卡")in
(select b_c_id,b_type from bank_card group by b_c_id,b_type
having count(c_name) > 1)
ORDER by(c_id);

--7
-- 7) 查询身份证隶属武汉市没有买过任何理财产品的客户的名称、电话号、邮箱。
SELECT c_name,c_phone,c_mail FROM client
WHERE((select left(client.c_id_card,4)=4201) 
    and c_id not in(select pro_c_id from property WHERE pro_type=1));
--6
select pro_income,count(*) as presence
from property group by pro_income 
having count(*)>=all(select count(*) from property group by pro_income);

--5 between
SELECT p_id,p_amount,p_year FROM finances_product
WHERE(
    p_amount between 30000 and 50000
)
ORDER BY p_amount,p_year DESC;

--4 多表连接
SELECT c_name,c_phone,b_number FROM client,bank_card
WHERE (
    c_id=b_c_id AND b_type='储蓄卡'
)
ORDER BY c_id;
--3 嵌套查询
SELECT c_name,c_mail,c_phone FROM client WHERE (
    c_id in (select pro_c_id from property where pro_type=3) AND
    c_id in (select pro_c_id from property where pro_type=2)
)ORDER by c_id;
--2
SELECT c_id,c_name,c_id_card,c_phone FROM client
WHERE(
    c_mail is NULL
);
--1
SELECT c_name,c_phone,c_mail FROM client ORDER BY c_id;