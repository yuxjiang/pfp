# PFP

[![](https://img.shields.io/badge/license-MIT-blue.svg)]()

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
    * optional fields: (see [CAFA](http://biofunctionprediction.org/cafa/) rules for details of these fields)
        * `author`: the author of this predictor.
        * `model`: the model number.
        * `keywords`: the keywords of this predictor.
        * `tag`: some additional information.

4. `NET`, the network structure, see [`pfp_netbuild.m`](./network/pfp_netbuild.m). This structure has the following fields:
    * required fields:
        * `object`: the object (node) list.
        * `ADJ`: the adjacency matrix.
        * `date`: the date that this network is built.

## How to build baseline predictors (BLAST, GOtcha, Naive)

### *BLAST* predictor

#### Requirements
    - "Training" data
        - Sequences in **FASTA** format.
        - Annotations (MFO terms for exmaple) for each of these sequences. This data
          needs to be prepared ahead of time as a two-column **CSV** file (delimited
          by TAB)

          ```
          [sequence ID]\t[GO term ID]
          ```

          where `[sequence ID]` would be of any system (e.g., UniProt accession
          number), as long as they are consistant with those used in the FASTA file.
    - NCBI BLAST tool (used 2.2.29+ for this document)
    - Query sequences in **FASTA** format.

#### Step-by-step

* ***STEP 1:*** Load annotations of training sequences.

    ```matlab
    oa = pfp_oabuild(ont, 'annotation.dat');
    ```
    where `ont` is a MATLAB structure of ontology which can be built from and OBO
    file (say, 'ontology.obo') as

    ```matlab
    ont = pfp_ontbuild('ontology.obo');
    ```

    Note that a typical gene ontology OBO file contains all three GO ontologies
    (i.e., MFO, BPO, and CCO), therefore, `pfp_ontbuild` returns a cell
    of **THREE** ontology strcutures instead:

    ```matlab
    onts = pfp_ontbuild('go.obo')
    ```

    By default, they are ordered as BPO, CCO, MFO, alphabetically. You can also
    double check the `.ont_type` field of each returning structure.

* ***STEP 2:*** Prepare BLAST results
    - Run `blastp` on the query sequences against the "training" sequences
      by setting output format to be the following:

      ```bash
      blastp ... -outfmt "6 qseqid sseqid evalue length pident nident" -out blastp.out
      ```

    - Load the tabular output file (`blastp.out` as shown above) into MATLAB:

      ```matlab
      B = pfp_importblastp('blastp.out');
      ```

* ***STEP 3:*** Build the *BLAST* predictor

    ```matlab
    blast = pfp_blast(qseqid, B, oa);
    ```

    where `qseqid` is a cell list of query sequences on which you need scores.
    Note that it can be just a subset of all those you BLAST'ed. `B` is the
    structure imported step 2, while `oa` is the ontology annotation structure
    loaded in step 1.

    Also, extra options can be specified as additional arguments to this function.
    See the documentation of `pfp_blast.m` for more details. Thus, `blast` will be
    the *BLAST* predictor in MATLAB for evaluation.

### *GOtcha* predictor

    *GOtcha* predictor can be build in the similar way of *BLAST* predictor.

    ```matlab
    gotcha = pfp_gotcha(qseqid, B, oa);
    ```

### *Naive* predictor

    To build a *naive* predictor, all you need is the ontology annotation structure
    `oa` that you have as in the step 1 of making a *BLAST* predictor. Then run the
    following in MATLAB:

    ```matlab
    naive = pfp_naive(qseqid, oa);
    ```
