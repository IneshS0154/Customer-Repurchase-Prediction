**DEVELOPMENT — all-customer expected spend.** Selected: P × Log-OLS + Duan smearing.

| candidate                               |      N |   RMSE |   MAE |   Median AE |   Mean predicted |   Mean observed |   RMSE P1 |   RMSE P2 |   RMSE P3 |   RMSE P4 |
|:----------------------------------------|-------:|-------:|------:|------------:|-----------------:|----------------:|----------:|----------:|----------:|----------:|
| P × Log-OLS + Duan smearing             | 4297.0 | 1377.4 | 404.7 |       178.5 |            463.9 |           420.4 |    1756.0 |    1605.6 |     931.7 |    1216.3 |
| P × Gamma GLM (log link)                | 4297.0 | 1386.2 | 403.8 |       179.2 |            448.3 |           420.4 |    1794.1 |    1504.6 |     925.9 |    1320.3 |
| P × Training mean                       | 4297.0 | 1990.8 | 547.3 |       334.2 |            474.2 |           420.4 |    2902.4 |    1532.9 |    1587.5 |    1940.6 |
| Constant (training mean, all customers) | 4297.0 | 2038.5 | 610.9 |       466.5 |            466.5 |           420.4 |    2966.5 |    1550.8 |    1643.3 |    1993.5 |
