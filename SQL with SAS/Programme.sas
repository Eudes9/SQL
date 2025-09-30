/*sas  base : */

/*1*/
%macro file_import(path=, file=, out=);
    proc import datafile="&path.&file."
        out=&out
        dbms=dlm
        replace;
        delimiter='09'x; 
        getnames=yes;
    run;
%mend file_import;

/*2*/
%file_import(path=/home/u63750353/project/, file=customers.txt, out=customers);
%file_import(path=/home/u63750353/project/, file=order_items.txt, out=order_items);
%file_import(path=/home/u63750353/project/, file=order_payments.txt, out=order_payments);
%file_import(path=/home/u63750353/project/, file=orders.txt, out=orders);
%file_import(path=/home/u63750353/project/, file=products_translation.txt, out=products_translation);
%file_import(path=/home/u63750353/project/, file=products.txt, out=products);

/*4*/
data customers1;
    set customers; 

    if substr(customer_state, 1, 1) in ('A', 'B', 'C') then state_group = 'Groupe1';
    else if substr(customer_state, 1, 1) in ('D', 'E', 'G') then state_group = 'Groupe2';
    else if substr(customer_state, 1, 1) in ('M', 'P', 'R') then state_group = 'Groupe3';
    else if substr(customer_state, 1, 1) in ('S', 'T') then state_group = 'Groupe4';
run;

data customers1;
    set customers1;

    /* Calcul de l'ancienneté en mois */
    anciennete = round((cancellation_date - card_date_subscription) / 30);
run;

/* Tri de la table par 'customer_state' et 'anciennete' */
proc sort data=customers1;
    by customer_state anciennete;
run;

/*5*/
/*a*/
proc freq data=customers1 noprint;
  tables state_group*anciennete / out=customers21(rename=(count=n_contract) drop=percent);

run;

/*b*/
proc freq data=customers1(where=(cancellation=1)) noprint;
  tables state_group*anciennete / out=customers22(rename=(count=n_resiliation) drop=percent);

run;

/*c*/
proc freq data=customers1 noprint;
  tables state_group / out=customers23(rename=(count=n_cohorte) drop=percent);

run;

/*6*/
data customers31;
  merge customers21(in=a) customers22(in=b);
  by state_group anciennete;
  if a and b;
  cum_n_contract + n_contract; 
run;

data customers32;
  merge customers23(in=a) customers31(in=b);
  by state_group; 

/* Initialize estim to 0 for each state_groupe */
  retain estim 0;
  
  if a and b;

/* n_risque */
  n_risque = n_cohorte + n_contract - cum_n_contract;

/* tx_survie */
  tx_survie = log(1 - (n_resiliation / n_risque));

  if first.state_group then estim = 0; 
  estim + tx_survie; /* Cumulative sum of tx_survie */

/* estimateur_survie */
  estimateur_survie = round(exp(estim), 0.00001);
run;


/*exporting customers32 table as xslx file*/

proc export data=work.customers32
    outfile="/home/u63750353/project/customers32.xlsx" 
    dbms=xlsx replace;
run;

/*9:*/
proc SQL;
	Select  count( distinct customer_id)  as nb1 label ="number of customers" , customer_state 
		,loyalty_card_type 
	from customers
	group by customer_state, loyalty_card_type  
	order by 1 DESC
	;
quit;

/*10:*/
proc SQL;
	Select  count(distinct customers.customer_id)  as nb1 label ="number of customers" , customer_state 
		,loyalty_card_type , count(order_id) as nb2 label="nombre de commandes"
	from customers,orders
	where customers.customer_id=orders.customer_id
	and month(datepart(order_approved_date)) = 2
	and year(datepart(order_approved_date)) = 2018
	group by customer_state, loyalty_card_type  
	order by 1 DESC
	;
quit;

/*11:*/
PROC SQL;
	SELECT count(product_id) as nb1 label="nombre de commandes" , product_category_name_english
	from products, products_translation
	where products.product_category_name=products_translation.product_category_name
	AND products.product_weight_g> 25000
	Group by product_category_name_english
	;
Quit;


/*12:*/
PROC SQL;
    SELECT 
        customers.loyalty_card_type as type LABEL="loyalty_card_type",
        COUNT(orders.order_id) AS nb_commandes LABEL="NB_commandes",
        SUM(order_payments.payment_value) AS chiffre_affaire LABEL="CA_total",
        MIN(order_payments.payment_value) AS min_chiffre_affaire LABEL="CA_min",
        AVG(order_payments.payment_value) AS moyenne_chiffre_affaire LABEL="CA_moy",
        MAX(order_payments.payment_value) AS max_chiffre_affaire LABEL="CA_max",
        STD(order_payments.payment_value) AS ecart_type_chiffre_affaire LABEL="CA_std"
    FROM 
        customers, orders, order_payments
    WHERE 
        customers.customer_id = orders.customer_id 
        AND orders.order_id = order_payments.order_id 
    GROUP BY 
        customers.loyalty_card_type;
QUIT;

/*13:*/
proc sql;
   create table state_sales_summary as
   select 
      c.customer_state, 
      sum(p.payment_value) as CA_total, 
      count(distinct o.order_id) as NB_commandes, 
      count(distinct c.customer_id) as NB_clients, 
      count(i.order_item_id) as NB_produits, 
      sum(p.payment_value) / count(distinct o.order_id) as Panier_moyen, 
     
      (select avg(product_count) from 
         (select o2.order_id, count(distinct i2.product_id) as product_count
          from WORK.ORDER_ITEMS i2
          inner join WORK.ORDERS o2 on i2.order_id = o2.order_id
          group by o2.order_id
         ) as product_counts
      ) as NB_uvc 

   from WORK.CUSTOMERS c
   inner join WORK.ORDERS o on c.customer_id = o.customer_id
   inner join WORK.ORDER_PAYMENTS p on o.order_id = p.order_id
   inner join WORK.ORDER_ITEMS i on o.order_id = i.order_id
   
   group by c.customer_state
   order by NB_commandes desc;
quit;




/* partie 03:

/*Programme AS1:*/

data customers_sample;
    set customers;
    i = ranuni(0); 
run;

proc sort data=customers_sample;
    by i; 
run;

data customers_sample(drop=i);
    set customers_sample;
    if _N_ <= 5000; 
run;

/*Programme AS2:*/

%let input_table = customers; /* Input table name */
%let output_table = customers_sample; /* Output table name */
%let sample_size = 5000; /* Sample size */

data &output_table.;
    set &input_table.;
    i = ranuni(0);
run;

proc sort data=&output_table. out=&output_table._sorted;
    by i;
run;

data &output_table.;
    set &output_table._sorted;
    if _N_ <= &sample_size.;
run;

/*Programme AS3:*/
%let input_table = customers;
%let output_table = customers_sample;
%let sample_percent = 20; 


data _null_;
    set &input_table. nobs=nobs_var end=end_of_file;
    if end_of_file then call symputx('sample_size', nobs_var * &sample_percent. / 100, 'G');
run;

%put &=sample_size; 

data &output_table.;
    set &input_table.;
    i = ranuni(0);
run;

proc sort data=&output_table. out=&output_table._sorted;
    by i;
run;


data &output_table.;
    set &output_table._sorted;
    if _N_ <= %sysevalf(&sample_size.);
run;

/*Programme AS4:*/
%macro AS(input_table, output_table, sample_percent);

/* the number of observations to sample */
data _null_;
    set &&input_table. nobs=nobs_var end=end_of_file;
    if end_of_file then call symputx('sample_size', nobs_var * &sample_percent / 100, 'G');
run;

%put &=sample_size; 

data &&output_table.;
    set &&input_table.;
    i = ranuni(0);
run;

proc sort data=&&output_table. out=&&output_table._sorted;
    by i;
run;

/* the calculated sample size */
data &&output_table.;
    set &&output_table._sorted;
    if _N_ <= %sysevalf(&sample_size.);
run;

proc datasets library=work; 
    delete &&output_table._sorted;
quit;

%mend AS;

/*Programme ASTR1*/
%macro ASTR1(data=, stratvar=);
    proc sql noprint;
        select distinct &stratvar., count(*) into :stratum1-, :count1-
        from &data
        where &stratvar. is not null
        group by &stratvar.;
    %let numstrata = &sqlobs.;
    
    /* Print the values of the macro variables to the log */
    %do i = 1 %to &numstrata;
        %put Stratum &i: &&stratum&i;
        %put Count &i: &&count&i;
    %end;
    %put Number of strata: &numstrata;
%mend ASTR1;


%ASTR1(data=WORK.CUSTOMERS, stratvar=loyalty_card_type);


/*Programme ASTR2*/

%macro ASTR2(data=, stratvar=);
    proc sql noprint;
        /* variables macro pour les strates et leurs comptes */
        select distinct &stratvar., count(*) into :stratum1-, :count1-
        from &data
        where &stratvar. is not null
        group by &stratvar.;
    %let numstrata = &sqlobs.;
    
    /* une table pour chaque strate */
    %do i = 1 %to &numstrata;
        %let currentStratum = &&stratum&i.;
        proc sql;
            create table WORK.stratum_&currentStratum. as
            select * from &data
            where &stratvar. = "&&stratum&i.";
        quit;
    %end;

    
    data WORK.strata_counts;
        length stratum $50; 
        retain stratum count;
        %do i = 1 %to &numstrata;
            stratum = "&&stratum&i";
            count = &&count&i;
            output;
        %end;
    run;
%mend ASTR2;


%ASTR2(data=WORK.CUSTOMERS, stratvar=loyalty_card_type);





/*Programme ASTR3*/
%macro ASTR3(data=, stratvar=, sample_rate=);
    proc sql noprint;
        /* variables macro pour les strates et leurs comptes */
        select distinct &stratvar., count(*) into :stratum1-, :count1-
        from &data
        where &stratvar. is not null
        group by &stratvar.;
    %let numstrata = &sqlobs.;
    
    /* une table pour chaque strate et un sous-échantillon pour chaque */
    %do i = 1 %to &numstrata;
        %let currentStratum = &&stratum&i.;
        proc sql;
            create table WORK.stratum_&currentStratum as
            select * from &data
            where &stratvar. = "&&stratum&i.";
        quit;
        
        /*  sous-échantillon pour la strate courante */
        data WORK.sample_stratum_&currentStratum;
            set WORK.stratum_&currentStratum;
            if ranuni(0) < &sample_rate;
        run;
    %end;

    /*  un dataset pour stocker les résultats des comptes de strates */
    data WORK.strata_counts;
        length stratum $50; 
        retain stratum count;
        %do i = 1 %to &numstrata;
            stratum = "&&stratum&i";
            count = &&count&i;
            output;
        %end;
    run;
%mend ASTR3;

/* le macro avec un taux d'échantillonnage 10% */
%ASTR3(data=WORK.CUSTOMERS, stratvar=loyalty_card_type, sample_rate=0.1);

/*Programme ASTR4*/
%macro ASTR4(data=, stratvar=, sample_rate=);
    proc sql noprint;
        /* variables macro pour les strates et leurs comptes */
        select distinct &stratvar., count(*) into :stratum1-, :count1-
        from &data
        where &stratvar. is not null
        group by &stratvar.;
    %let numstrata = &sqlobs.;
    
    /* une table pour chaque strate et un sous-échantillon pour chaque */
    %do i = 1 %to &numstrata;
        %let currentStratum = &&stratum&i.;
        proc sql;
            create table WORK.stratum_&currentStratum as
            select * from &data
            where &stratvar. = "&&stratum&i.";
        quit;
        
        /*  sous-échantillon pour la strate courante */
        data WORK.sample_stratum_&currentStratum;
            set WORK.stratum_&currentStratum;
            if ranuni(0) < &sample_rate;
        run;
    %end;

    /* une liste pour combiner tous les ensembles de données */
    %let datasets_list = ;

    /* une liste de tous les ensembles de données de sous-échantillon */
    %do i = 1 %to &numstrata;
        %let datasets_list = &datasets_list WORK.sample_stratum_&&stratum&i. ;
    %end;

    /* tous les sous-échantillons dans une seule table */
    data WORK.combined_sample;
        set &datasets_list;
    run;

    /* un dataset pour stocker les résultats des comptes de strates */
    data WORK.strata_counts;
        length stratum $50;
        retain stratum count;
        %do i = 1 %to &numstrata;
            stratum = "&&stratum&i";
            count = &&count&i;
            output;
        %end;
    run;
%mend ASTR4;

/*  macro avec un taux d'échantillonnage de 10% */
%ASTR4(data=WORK.CUSTOMERS, stratvar=loyalty_card_type, sample_rate=0.1);


