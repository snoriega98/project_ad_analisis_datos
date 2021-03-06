** PROJECT: ANALISIS DE DATOS
** PROGRAM: regresion_lineal_inferencia.do
** PROGRAM TASK: INFERENCE ON LINEAR REGRESSION
** AUTHOR: RODRIGO TABORDA
** DATE CREATEC: 2018/09/24
** DATE REVISION 1: 2020/04/07
** DATE REVISION #:

********************************************************************;
** #0
********************************************************************;

** PROGRAM SETUP

    pause on
    #delimit ;
        /*COMMAND LINES WILL ONLY END ONCE SEMICOLON IS FOUND*/

** #0.1 ** SET PATH FOR READING/SAVING DATA;

********************************************************************;
** #10 ** EXECUTE DATA-IN ROUTINE;
********************************************************************;



********************************************************************;
** #20 ** INFERENCE AFTER LINEAR REGRESSION;
********************************************************************;

** #20.1 ** REGRESSION;

    regress var_y var_x1 var_x#;

    /*RETURN ERETURN*/
    ereturn list /*ESTIMATION RESULTS AFTER REGRESSION OR OTHER COMMAND*/
    return list

** #20.2 ** CRITICAL VALUE, CONFIDENCE INTERVAL, T-STAT AND P-VALUE;

    /*T-STAT*/
    scalar tstat = (_b[expl var] - 0) / _se[expl var]
    local tstat = (_b[expl var] - 0) / _se[expl var]

    /*CRITICAL VALUE*/
    scalar tc975 = invttail(n-(k+1),0.025)
    local tc975 = invttail(n-(k+1),0.025)

    /*CONFIDENCE INTERVALS*/
    scalar ulb = _b[expl var] +- tc975*_se[expl var]

    /*P-VALUE*/
    scalar pvalue = ttail(n-(k+1),abs(tstat))*2

    /*GRAPH*/
    twoway function y = tden(n-(k+1),x), range(-4 4) xline(`tstat') xlabel(-`tc975' `tc975' `tstat') ||
        function y = tden(n-k+1,x), range(-4 -`tc975') recast(area) color(dknavy)||
        function y = tden(n-k+1,x), range(`tc975' 4) recast(area) color(dknavy) legend(off) ytitle(Densidad) xtitle(t)

    /*EXAMPLE AUTO DATASET*/;
    sysuse auto
    reg price mpg weight
    scalar t_mpg = (_b[mpg] - 0) / _se[mpg]
    local t_mpg = (_b[mpg] - 0) / _se[mpg]
    scalar tc975 = invttail(74-(2+1),0.025)
    local tc975 = invttail(74-(2+1),0.025)
    scalar ub_mpg = _b[mpg] + tc975*_se[mpg]
    scalar lb_mpg = _b[mpg] - tc975*_se[mpg]
    display lb_mpg " " ub_mpg
    scalar pvalue_mpg = ttail(74-(2+1),abs(t_mpg))*2
    display pvalue_mpg
    twoway (function y = tden(74-(2+1),x), range(-4 4) xline(`t_mpg') xlabel(-`tc975' `tc975' `t_mpg')) (function y = tden(74-(2+1),x), range(-4 -`tc975') recast(area) color(dknavy)) (function y = tden(74-(2+1),x), range(`tc975' 4) recast(area) color(dknavy) legend(off) ytitle(Densidad) xtitle(t))

    /*HIPOTHESIS TEST*/
    test var
    test (var=0)
    test (_b[var]=0)
    test (var=0) (var=0)
    test 2.x1 3.x1 /*TEST FOR INDICATOR VARIABLES EQUAL TO ZERO*/
    test (2.x1=0) (3.x1=1) /*TEST FOR INDICATOR VARIABLES EQUAL TO ZERO AND ONE*/
    testparm i.x1 /*TEST FOR INDICATOR VARIABLES ALL AT ONCE*/
    test 2.x1 = 3.x1 /*TEST IF 2 AND 3 ARE EQUAL*/
    lincom 2.x1 - 3.x1 /*TEST IF 2 MINUS 3 ARE ZERO*/

    /*HIPOTHESIS TEST OF LINEAR COMBINATION*/
    lincom x1 + x2

    /*NONLINEAR MODEL*/
    reg y x2 x2^2
        /*PREDICTED*/
        gen y_hat = _[_cons] + _b[x1]*x1 + _b[x2]*x2 + _b[x2^2]*x2^2
        twoway (connected y_hat x2, sort)
        /*OPTIMUM X2*/
        scalar x2_opt = -_b[x2]/2*_b[x2^2]
        nlcom -_b[x2]/2*_b[x2^2]

    /*MAXIMUM LIKELIHOOD TEST*/
    reg y x2 x2^2
        estimates store m1
    reg y x2
        estimats store m2 if e(sample)

    lrtest m1 m2

** #20.3 ** NORMALITY TEST;

    /*JARQUE-BERA*/
    scalar jb = (r(N)/6)*( (r(skewness)^2) + ((r(kurtosis)-3)^2)/4 )
        di "Jarque-Bera Statistic = " jb
    scalar chic = invchi2tail(2,.05)
        di "Chi-square(2) 95th percentile = " chic
    scalar pvalue = chi2tail(2,jb)
        di "Jarque-Bera p-value = " pvalue

** #20.3 ** MODEL SELECTION;

    /*R2*/
    scalar r2 = e(mss)/(e(mss)+e(rss))

    /*INFORMATION CRITERIA*/
    estat ic
