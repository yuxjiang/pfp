# PFP

A MATLAB library for protein function prediction.

Matlab functions in this package uses "`pfp_`" (aka. Protein Function Prediction) as the file name prefix.

## Commonly used data structures
1. `ONT`, the ontology structure, see [`pfp_ontbuild.m`](./ontology/pfp_ontbuild.m). This structure has the following fields:
    * required fields:
        * `term`: a list of term structures (`id`, `name`).
        * `rel_code`: a list of relationship codes, e.g. {`is_a`, `part_of`}.
        * `DAG`: the relationship matrix,
          `DAG(i, j) = k (k>0)` means term(i) has k-th relationship of `rel_code` with term(j).
        * `ont_type`: the ontology type, e.g. `molecular_function`.
        * `date`: the date that this structure is built.
    * optional fields:
        * `alt_list`: the alternate term ID list.

2. `OA`, the ontology annotation structure, see [`pfp_oabuild.m`](./annotation/pfp_oabuild.m). This structure has the following fields:
    * required fields:
        * `object`: the object (sequence) list.
        * `ontology`: the associated ontology structure.
        * `annotation`: the annotation matrix,
          `annotation(i, j) = 1` means object(i) is annotated with term(j).
        * `date`: the date that this structure is built.

3. `PRED`, the prediction structure, see (built by any prediction methods, similar to `OA`). This structure has the following fields:
    * required fields:
        * `object`: the object (sequence) list.
        * `ontology`: the associated ontology structure.
        * `score`: the predicted score matrix,
          `score(i,j)` is the predicted score for the association of object(i) and term(j).
        * `date`: the date that this prediction is made.
    * optional fields:
        * `author`: the author of this predictor.
        * `model`: the model number.
        * `keywords`: the keywords of this predictor.
        * `tag`: some additional information.

4. `NET`, the network structure, see [`pfp_netbuild.m`](./network/pfp_netbuild.m). This structure has the following fields:
    * required fields:
        * `object`: the object (node) list.
        * `ADJ`: the adjacency matrix.
        * `date`: the date that this network is built.

## The Matlab functions in this package has been categorized into the following subfolders:

### [Ontology](./ontology/)

### [Annotation](./annotation/)

### [Evaluation](./evaluation/)

### [Utility](./util/)

### [Network](./network/)

### [Parse](./parse/)
