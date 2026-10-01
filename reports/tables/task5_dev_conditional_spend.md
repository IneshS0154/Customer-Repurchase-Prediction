**DEVELOPMENT — conditional positive spend.** Selected: Log-OLS + Duan smearing.

| candidate                      |      N |   RMSE |   MAE |   Median AE |   Mean predicted |   Mean observed |   RMSE P1 |   RMSE P2 |   RMSE P3 |   RMSE P4 |
|:-------------------------------|-------:|-------:|------:|------------:|-----------------:|----------------:|----------:|----------:|----------:|----------:|
| Log-OLS + Duan smearing        | 1610.5 | 2062.2 | 635.5 |       296.1 |           1092.1 |          1045.7 |    2211.1 |    2665.8 |    1361.4 |    2010.4 |
| Gamma GLM (log link)           | 1610.5 | 2073.7 | 637.5 |       298.0 |           1052.9 |          1045.7 |    2266.0 |    2474.2 |    1326.6 |    2228.2 |
| Training mean                  | 1610.5 | 3123.4 | 998.5 |       703.6 |           1057.2 |          1045.7 |    3816.5 |    2600.9 |    2659.3 |    3417.1 |
| Training median (illustrative) | 1610.5 | 3169.0 | 795.6 |       279.2 |            472.7 |          1045.7 |    3895.7 |    2598.4 |    2711.3 |    3470.4 |
