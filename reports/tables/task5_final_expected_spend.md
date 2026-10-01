**RETROSPECTIVE TEMPORAL EVALUATION — all-customer expected spend.**

|                                         | Role             |      N |   RMSE |   MAE |   Median AE |   Mean predicted |   Mean observed |
|:----------------------------------------|:-----------------|-------:|-------:|------:|------------:|-----------------:|----------------:|
| P × Log-OLS + Duan smearing             | LOCKED           | 5253.0 | 2268.7 | 399.8 |       100.6 |            293.9 |           530.3 |
| P × Gamma GLM (log link)                | Descriptive only | 5253.0 | 2296.6 | 406.0 |       104.4 |            286.5 |           530.3 |
| P × Training mean                       | Descriptive only | 5253.0 | 3098.0 | 503.6 |       187.4 |            314.1 |           530.3 |
| Constant (training mean, all customers) | Benchmark        | 5253.0 | 3153.5 | 613.1 |       333.9 |            333.9 |           530.3 |
