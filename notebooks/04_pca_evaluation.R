# 04 - Critical Evaluation of PCA (Task 7)

# Brief section 8. Take a balanced position: PCA is not worthwhile on the ~10-feature
# customer table (interpretability matters, LASSO/elastic net already handle
# correlated predictors), but is useful on the sparse customer x product matrix to
# reveal latent buying patterns.

library(dplyr)
library(ggplot2)
library(readr)

clean <- read_csv("../data/processed/invoice_lines_clean.csv")
customers <- read_csv("../data/processed/customer_table.csv")
theme_set(theme_minimal())

library(factoextra)

# ---- PCA on the customer-level feature table (demonstrate why it's not worthwhile) ----

# TODO: scale FEATURES, prcomp(), show component loadings destroy interpretability
# TODO: factoextra::fviz_eig() scree plot - how many components needed vs how few features you started with

# ---- Customer x Product purchase matrix ----

# TODO: pivot clean to CustomerID x StockCode (purchase count or spend), likely sparse
# TODO: prcomp() / irlba::irlba() on this matrix
# TODO: inspect top-loading products per component -> name the latent pattern

# ---- Does it help the predictive model? ----

# TODO: add top product-matrix component scores as extra features to the Task 5 model, compare AUC

# ---- Conclusion ----

# _Write up: where PCA helps, where it doesn't, and why - tie back to Jolliffe & Cadima (2016)._
