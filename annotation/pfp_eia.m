function [eia] = pfp_eia(DAG, A, base)
    %PFP_EIA Estimated information accretion
    %
    % [eia] = PFP_EIA(DAG, A);
    % [eia] = PFP_EIA(DAG, A, base);
    %
    %   Estimates the information accretion for each term in the ontology.
    %
    % Note
    % ----
    % Only terms with at least one annotation will be estimated, otherwise, a
    % zero information accretion will be place for them.
    %
    % Definition
    % ----------
    % Information accretion: The negative logarithm of the conditional
    % probability of a term being annotated given that all of its parents are
    % annotated:
    % ia(t) = -log P(t=1 | Pa(t)=1),
    % where Pa(t) is the parents of term t.
    %
    % See the [Reference] below for details.
    %
    % Reference
    % ---------
    % W. Clark and P. Radivojac, Information theoretic evaluation of predicted
    % ontology annotations. Bioinformatics, 2013.
    %
    % Input
    % -----
    % [double]
    % DAG:  The m-by-m adjacency matrix.
    %       DAG(i, j) ~= 0 means term i has a relationship to term j.
    %
    % [logical]
    % A:    An n-by-m, the ontology annotation matrix.
    %       A(i, j) = true indicates object i is annotated to have term j.
    %
    % [char]
    % base: The base of logarithm, options are {'e', '2', '10'}
    %       default: 'e'
    %
    % Output
    % ------
    % [double]
    % eia:  An 1-by-m array of estimated information accretion.

    % check inputs {{{
    if nargin < 2
        error('pfp_eia:InputCount', 'Expected at least 2 inputs.');
    end

    if nargin == 2
        base = 'e';
    end

    % DAG
    validateattributes(DAG, {'double'}, {'square'}, '', 'DAG', 1);
    m = size(DAG, 1);

    % A
    validateattributes(A, {'logical'}, {'ncols', m}, '', 'A', 2);

    % base
    base = validatestring(base, {'e', '2', '10'}, '', 'base', 3);
    % }}}

    % find annotated "sub-ontology" {{{
    has_seq = any(A, 1);
    subDAG  = DAG(has_seq, has_seq) ~= 0; % make it logical
    subA    = A(:, has_seq);
    % }}}

    % calculate eia for annotated sub-ontology {{{
    k      = size(subDAG, 1);
    subeia = zeros(1, k);

    for i = 1 : k
        p        = subDAG(i, :); % parent term(s)
        support  = all(subA(:, p), 2);
        S        = sum(support);
        subia(i) = sum(support & subA(:, i)) / S;
    end
    % }}}

    % prepare output {{{
    eia = zeros(1, m);
    switch base
        case 'e'
            eia(has_seq) = -log(subia);
        case '2'
            eia(has_seq) = -log2(subia);
        case '10'
            eia(has_seq) = -log10(subia);
        otherwise
            % nop
    end
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 01:02:40 PM E
