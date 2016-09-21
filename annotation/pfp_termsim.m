function [res] = pfp_termsim(oa, src, dst, varargin)
    %PFP_TERMSIM Term similarity
    %
    % [res] = PFP_TERMSIM(oa, '', '');
    %
    %   Computes pairwise Term similarity between all ontology terms.
    %
    % [res] = PFP_TERMSIM(oa, {...}, {...});
    %
    %   Computes pairwise Term similarity between two sets of ontology terms.
    %
    % Reference
    % ---------
    % (resnik)
    % [1] Philip, R. Semantic similarity in a taxonomy: an information-based
    %     measure and its application to problems of ambiguity in natural
    %     language.  Journal of Aritificial Intelligence Research. 11, 95-130,
    %     1999.
    %
    % (lin)
    % [2] Lin, D. An information-theoretic definition of similarity. In
    %     Proceedings of the 15th International Conference of Machine Learning,
    %     pp. 296-304, 1998.
    %
    % (rel)
    % [3] Schlicker, A, et al., A new measure for functional similarity of gene
    %     products based on Gene Ontology. BMC Bioinformatics, 7, 302, 2006.
    %
    % Input
    % -----
    % (required)
    % [struct]
    % oa:   The ontology annotation structure. See pfp_oabuild.m
    %
    % [cell, char or struct]
    % src:  The set of "source" term ID. It can be a cell of term IDs, an array
    %       of term structures or a single char of term ID, or empty (which
    %       means all terms in the ontology)
    %
    % [cell, char or struct]
    % dst:  The set of "destination" term ID. Same format as 'src'.
    %
    % (optional) Name-value pairs.
    % [double]
    % 'prob'  1-by-m vector of the probability of observing each term. If it is
    %         set to empty, 'oa' will be used to estimate the probability.
    %         default: []
    %
    % 'type'  The similarity type, available options:
    %         'resnik' - The Resnik's similarity.
    %         'lin'    - The Lin's similarity.
    %         'rel'    - The Relative similarity.
    %         See each of the corresponding reference for details.
    %         default: 'rel'
    %
    % Output
    % ------
    % [struct]
    % res:  The resulting similarity structure, which has
    %       .row  [cell]   An n1-by-1 cell array of term IDs for each row.
    %       .col  [cell]   A 1-by-n2 cell array of term IDs for each column.
    %       .data [double] An n1-by-n2 similarity matrix.
    %       .type [char]   The similarity type.
    %
    % Dependency
    % ----------
    % [>] pfp_ancestormat.m
    % [>] pfp_rootterm.m
    % [>] pfp_mica.m
    %
    % See Also
    % --------
    % [>] pfp_oabuild.m

    % check inputs {{{
    if nargin < 3
        error('pfp_termsim:InputCount', 'Expected at least 3 inputs.');
    end

    % oa
    validateattributes(oa, {'struct'}, {'nonempty'}, '', 'oa', 1);
    ontology = oa.ontology;
    m = numel(ontology.term);

    % src
    validateattributes(src, {'cell', 'char', 'struct'}, {}, '', 'src', 2);
    [res.row, irow] = loc_checkterms(src, ontology);
    res.row = reshape(res.row, [], 1);

    % dst
    validateattributes(dst, {'cell', 'char', 'struct'}, {}, '', 'dst', 3);
    [res.col, icol] = loc_checkterms(dst, ontology);
    res.col = reshape(res.col, 1, []);
    % }}}

    % extra inputs {{{
    p = inputParser;
    defaultPROB = [];
    defaultTYPE = 'rel';
    addParameter(p, 'prob', defaultPROB, @(x) validateattributes(x, {'double'}, {'>=', 0}));
    addParameter(p, 'type', defaultTYPE, @(x) ismember(x, {'rel', 'resnik', 'lin'}));
    parse(p, varargin{:});

    if isempty(p.Results.prob)
        % estimate probability using 'oa'
        prob = full(sum(oa.annotation, 1) ./ numel(oa.object));
    else
        if numel(p.Results.prob) ~= m
            error('pfp_termsim:ProbErr', 'The probability vector should be of the same length of the number of terms.');
        end
        prob = p.Results.prob;
    end
    % }}}

    % compute similarity {{{
    nrow     = numel(res.row);
    ncol     = numel(res.col);
    res.data = zeros(nrow, ncol);

    % precompute the "ancestor matrix" to avoid redundant computation
    if nrow*ncol >= 3
        A = pfp_ancestormat(ontology);
        has_A = true;
    else
        has_A = false;
    end

    % pre-compute log(P)
    logp = log(prob);
    if strcmpi(p.Results.type, 'rel')
        partial_rel = logp .* (1-prob);
    end
    [~, rootidx] = pfp_rootterm(ontology);
    for i = 1:nrow
        fprintf('row %d of %d\n', i, nrow);
        if has_A
            CA = bsxfun(@and, A(irow(i),:), A(icol,:));
        end
        for j = 1:ncol
            % get "most informative common ancestors (mica)"
            % One could makes call to pfp_mica.m, however, it repeatedly calls
            % pfp_ancestorterm.m, which suffers a lot overhead.
            if has_A
                ca = find(CA(j,:)); % common ancestors
                k  = find(~any(ontology.DAG(ca, ca), 1)); % mica
                micaidx = ca(k);
            else
                [~, micaidx] = pfp_mica(ontology, {res.row{i}, res.col{j}});
            end

            if all(ismember(micaidx, rootidx))
                % prevent "divide-by-zero" when calculating similarity between the root
                % and itself in 'rel' or 'lin'.
                res.data(i,j) = 0;
                continue;
            end

            switch p.Results.type
                case 'resnik'
                    % Resnik's similarity
                    res.data(i,j) = max(-logp(micaidx));
                case 'lin'
                    % Lin's similarity
                    partial = min(logp(micaidx));
                    res.data(i,j) = 2 * partial / (logp(irow(i))+logp(icol(j)));
                case 'rel'
                    % relative similarity
                    partial = min(partial_rel(micaidx));
                    res.data(i,j) = 2 * partial / (logp(irow(i))+logp(icol(j)));
                otherwise
                    % nop
            end
        end
    end
    res.type = p.Results.type;
    % }}}
end

% function: loc_checkterms {{{
function [terms, index] = loc_checkterms(terms, ontology)
    if isempty(terms)
        terms = {ontology.term.id};
        index = 1:numel(ontology.term);
        return
    elseif ischar(terms)
        terms = {terms};
    elseif isstruct(terms)
        terms = {terms.id};
    end
    [found, index] = ismember(terms, {ontology.term.id});
    if ~all(found)
        error('pfp_termsim:TermErr', 'Some terms are not found in the ontology.');
    end
    terms = reshape({ontology.term(index).id}, [], 1);
end
% }}}

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University, Bloomington
% Last modified: Wed 21 Sep 2016 01:09:52 PM E
