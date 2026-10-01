**Paired bootstrap (2,000 replicates) of locked model minus benchmark, evaluation period.**

|                                               |   LASSO − benchmark |   95% CI low |   95% CI high |
|:----------------------------------------------|--------------------:|-------------:|--------------:|
| ('Full logistic', 'Brier')                    |             -0.0009 |      -0.0012 |       -0.0005 |
| ('Full logistic', 'Log-loss')                 |             -0.0036 |      -0.0048 |       -0.0024 |
| ('Full logistic', 'ROC-AUC')                  |              0.0020 |       0.0012 |        0.0027 |
| ('Full logistic', 'AP')                       |              0.0022 |       0.0014 |        0.0031 |
| ('Full logistic', 'Precision@10%')            |              0.0038 |      -0.0038 |        0.0114 |
| ('Constant (training rate)', 'Brier')         |             -0.0579 |      -0.0637 |       -0.0521 |
| ('Constant (training rate)', 'Log-loss')      |             -0.1042 |      -0.1205 |       -0.0869 |
| ('Constant (training rate)', 'ROC-AUC')       |              0.2914 |       0.2793 |        0.3034 |
| ('Constant (training rate)', 'AP')            |              0.3243 |       0.3092 |        0.3397 |
| ('Constant (training rate)', 'Precision@10%') |              0.4373 |       0.3935 |        0.4924 |
| ('Recency rank', 'ROC-AUC')                   |              0.0298 |       0.0228 |        0.0368 |
| ('Recency rank', 'AP')                        |              0.0767 |       0.0600 |        0.0917 |
| ('Recency rank', 'Precision@10%')             |              0.1312 |       0.0951 |        0.1692 |
