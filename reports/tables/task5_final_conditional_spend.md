**RETROSPECTIVE TEMPORAL EVALUATION — conditional positive spend.**

|                                | Role                         |      N |   RMSE |    MAE |   Median AE |   Mean predicted |   Mean observed |
|:-------------------------------|:-----------------------------|-------:|-------:|-------:|------------:|-----------------:|----------------:|
| Log-OLS + Duan smearing        | LOCKED                       | 2278.0 | 3357.6 |  657.0 |       222.0 |            808.3 |          1223.0 |
| Gamma GLM (log link)           | Descriptive only             | 2278.0 | 3397.5 |  667.8 |       218.2 |            785.8 |          1223.0 |
| Training mean                  | Descriptive only             | 2278.0 | 4693.5 | 1090.0 |       672.5 |           1042.4 |          1223.0 |
| Training median (illustrative) | Illustrative (median target) | 2278.0 | 4756.4 |  954.6 |       274.0 |            430.9 |          1223.0 |
