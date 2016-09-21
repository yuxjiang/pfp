function [pred] = pfp_gotcha(qseqid, B, oa, varargin)
    %PFP_GOTCHA GOtcha (predictor)
    %
    % [pred] = PFP_GOTCHA(qseqid, B, oa);
    %
    %   Returns the GOtcha prediction.
    %
    % Note
    % ----
    % 1. This function requries the prased blastp output results 'B'.
    % 2. This function assumes 'oa' has been propagated.
    %
    % Reference
    % ---------
    % David MA Martin, et al. GOtcha: a new method for prediction of protein
    % function assessed by the annotation of seven genomes, BMC Bioinfo. 2004
    %
    % Input
    % -----
    % (required)
    % [cell]
    % qseqid:   An n-by-1 cell array of query sequence ID.
    %           The sequence ID can of any type, as long as they are the same as
    %           those used in 'B.qseqid'. One can simply feed the function with
    %           'B.qseqid' as the 1st input so as to get the BLAST prediction of
    %           all sequences in 'B'.
    %
    % [struct]
    % B:        The imported blastp results. Typically, blast test set against
    %           training set sequences. See pfp_importblastp.m for instructions
    %           of running blastp. Note that one needs to make sure that the
    %           query sequence ID of 'B' uses the same type as that of the 1st
    %           input ('qseqid').
    %
    % [struct]
    % oa:       The reference ontology annotation structure. Typically, it's the
    %           annotation structure of the training set. See pfp_oabuild.m.
    %
    % (optional) Name-value pairs.
    % [double]
    % maxr: The maximum R_SCORE to consider. This is needed in cases where the
    %       E_VALUE of some hits are extremely tiny, or even 0.0 (-log(E) -> inf)
    %       default: 500 (E_VALUE < 1e-500 results in no greater R_SCORE)
    %
    % Output
    % ------
    % [struct]
    % pred: The GOtcha prediction structure.
    %       .object   [cell]    query ID list
    %       .ontology [struct]  the ontology structure
    %       .score    [double]  predicted association scores (I_SCORE)
    %       .date     [char]
    %
    % Dependency
    % ----------
    % [>] pfp_rootterm.m
    %
    % See Also
    % --------
    % [>] pfp_importblastp.m
    % [>] pfp_oabuild.m

    % check inputs {{{
    if nargin < 3
        error('pfp_gotcha:InputCount', 'Expected at least 3 inputs.');
    end

    % qseqid
    validateattributes(qseqid, {'cell'}, {'nonempty'}, '', 'qseqid', 1);

    % B
    validateattributes(B, {'struct'}, {'nonempty'}, '', 'B', 2);

    % oa
    validateattributes(oa, {'struct'}, {'nonempty'}, '', 'oa', 3);
    % }}}

    % extra inputs {{{
    p = inputParser;
    defaultMAXR = 500;
    addParameter(p, 'maxr', defaultMAXR, @(x) validateattributes(x, {'double'}, {'positive'}));
    parse(p, varargin{:});
    MAX_RSCORE = p.Results.maxr;
    % }}}

    % preparing output {{{
    pred.object   = reshape(qseqid, [], 1);
    pred.ontology = oa.ontology;
    n = numel(pred.object);
    m = numel(pred.ontology.term);
    pred.score = sparse(n, m);
    pred.date  = datestr(now, 'mm/dd/yyyy HH:MM');
    % }}}

    % compute R_SCORE {{{
    [found, index] = ismember(pred.object, B.qseqid);
    for i = 1 : n
        if found(i)
            l = index(i);
            k = numel(B.info{l}.sseqid);
            anno_mat = sparse(k, m);
            [sfound, sindex] = ismember(B.info{l}.sseqid, oa.object);
            if all(~sfound)
                % all hits aren't annotated, predicted scores are left as zeros
                continue;
            end

            % crop the value to be within [0, MAX_RSCORE]
            f = -log(B.info{l}.evalue(sfound)) + 2;
            f(f > MAX_RSCORE) = MAX_RSCORE;
            f(f < 0) = 0;

            anno_mat(sfound, :) = bsxfun(@times, oa.annotation(sindex(sfound), :), f);
            pred.score(i, :) = sum(anno_mat, 1);
        end
    end
    % }}}

    % normalize R_SCORES to get I_SCORES {{{
    [~, rootidx] = pfp_rootterm(oa.ontology);
    C_SCORE = pred.score(:, rootidx);
    C_SCORE(C_SCORE < 1e-8) = 1; % to avoid "divide-by-zero" error
    pred.score = bsxfun(@rdivide, pred.score, C_SCORE);
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 12:45:22 PM E
