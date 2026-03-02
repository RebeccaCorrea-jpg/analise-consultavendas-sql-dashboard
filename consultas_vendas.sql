-- (Query 1) Receita, leads, conversão e ticket médio mês a mês 
-- Colunas: mês, leads (#), vendas (#), receita (K,R$), conversão (%), ticket médio(K, R$)

with leads as(
Select
date_trunc('month', visit_page_date)::date as visit_page_month,
count(*) as visit_page_count
From sales.funnel
group by visit_page_month
order by visit_page_month
),

payments as (
Select 
date_trunc('month', fun.paid_date)::date as paid_month,
count(fun.paid_date) as paid_count,
sum(pro.price * (1+fun.discount)) as receita

from sales.funnel as fun
left join sales.products as pro
on fun.product_id = pro.product_id
where fun.paid_date is not null
group by paid_month
order by paid_month
)

SELECT
    leads.visit_page_month AS "mês",
    leads.visit_page_count AS "leads (#)",
    payments.paid_count AS "vendas (#)",
    ROUND(payments.receita::numeric / 1000, 0) AS "receita (k, R$)",
    ROUND(
        (payments.paid_count::numeric / NULLIF(leads.visit_page_count, 0)) * 100,
        0
    )::text || '%' AS "conversão (%)",
    ROUND(
        (payments.receita::numeric / NULLIF(payments.paid_count, 0) / 1000),
        1
    ) AS "ticket médio (k, R$)"
FROM leads
LEFT JOIN payments
    ON leads.visit_page_month = payments.paid_month
ORDER BY leads.visit_page_month;

-- (Query 2) Estados que mais venderam
-- Colunas País, Estado e Vendas (#)

select
'Brazil' as país, 
cus.state as estado,
count(fun.paid_date) as "vendas (#)"

from sales.funnel as fun
left join sales.customers as cus
on fun.customer_id = cus.customer_id
where paid_date between '2021-08-01' and '2021-08-31'
group by país, estado
order by "vendas (#)" desc
limit 5

-- (Query 3) Marcas que mais venderam no mês
-- Colunas: Marca, vendas (#)

select
pro.brand as marca,
count(fun.paid_date) as "vendas (#)"

from sales.funnel as fun
left join sales.products as pro
on fun.product_id = pro.product_id
where paid_date between '2021-08-01' and '2021-08-31'
group by marca
order by "vendas (#)" desc
limit 5

-- (Query 4) Lojas que mais venderam
-- Colunas: Lojas, vendas (#)

select
sto.store_name as loja,
count(fun.paid_date) as "vendas (#)"

from sales.funnel as fun
left join sales.stores as sto
on fun.store_id = sto.store_id
where paid_date between '2021-08-01' and '2021-08-31'
group by loja
order by "vendas (#)" desc
limit 5

-- (Query 5) Dias da semana com maior número de visitas ao site
-- Colunas: dia_semana, dia da semana, visitas(#)

select
extract('dow' from visit_page_date) as dia_semana,
case
when extract('dow' from visit_page_date)=0 then 'domingo'
when extract('dow' from visit_page_date)=1 then 'segunda'
when extract('dow' from visit_page_date)=2 then 'terça'
when extract('dow' from visit_page_date)=3 then 'quarta'
when extract('dow' from visit_page_date)=4 then 'quinta'
when extract('dow' from visit_page_date)=5 then 'sexta'
when extract('dow' from visit_page_date)=6 then 'sabado'
else null end as "dia da semana",
count (*) as "visitas (#)"

from sales.funnel
where visit_page_date between '2021-08-01' and '2021-08-31'
group by dia_semana
order by dia_semana