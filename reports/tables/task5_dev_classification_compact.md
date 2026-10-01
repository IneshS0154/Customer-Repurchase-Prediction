**DEVELOPMENT — USED FOR SELECTION.** Rule: smallest mean development Brier. Selected: LASSO.

| Model                    |   Predictors |   Brier ↓ |   ROC-AUC ↑ |   AP ↑ | Cal. intercept / slope   |   Precision@10% ↑ |   Lift@10% ↑ | Verdict and evidence                            |
|:-------------------------|-------------:|----------:|------------:|-------:|:-------------------------|------------------:|-------------:|:------------------------------------------------|
| Full logistic            |          9   |    0.2032 |       0.778 |  0.712 | -0.31 / 0.92             |             0.864 |         2.35 | Worse than selected (CI above 0)                |
| Forward selection        |          5.5 |    0.203  |       0.779 |  0.713 | -0.30 / 0.95             |             0.862 |         2.34 | Worse than selected (CI above 0)                |
| Backward selection       |          5.5 |    0.203  |       0.779 |  0.713 | -0.30 / 0.95             |             0.862 |         2.34 | Worse than selected (CI above 0)                |
| Best subset              |          5.5 |    0.203  |       0.779 |  0.713 | -0.30 / 0.95             |             0.862 |         2.34 | Worse than selected (CI above 0)                |
| Ridge                    |          9   |    0.2027 |       0.778 |  0.713 | -0.31 / 0.96             |             0.864 |         2.35 | Indistinguishable from selected (CI includes 0) |
| LASSO                    |          7.2 |    0.2026 |       0.779 |  0.713 | -0.30 / 0.96             |             0.864 |         2.35 | Selected under the Brier rule                   |
| Elastic net              |          7.5 |    0.2028 |       0.778 |  0.713 | -0.30 / 0.97             |             0.863 |         2.34 | Worse than selected (CI above 0)                |
| Constant (training rate) |          —   |    0.2471 |       0.5   |  0.388 | N/A                      |             0.414 |         1.08 | Baseline (not eligible)                         |
| Recency rank             |          —   |    —      |       0.719 |  0.587 | N/A                      |             0.67  |         1.81 | Baseline (not eligible)                         |
