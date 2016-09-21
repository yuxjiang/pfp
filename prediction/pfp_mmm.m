function [mmm] = pfp_mmm(qseqid, B, oa, varargin)
    %PFP_MMM Max-Mean-Min Maximum, mean and minimum
    %
    % [mmm] = PFP_MMM(qseqid, B, oa);
    %
    %   Returns Max-Mean-Min of sequence identity in BLAST result 'B'.
    %
    % Note
    % ----
    % 1. Unlike other prediction structures which have a single prediction
    %    matrix 'score', this function returns a special one desired to be fed
    %    into pfp_fanngomakeds.m. It has three scoring matrices: smaxi, smean,
    %    and smini.
    % 2. By default the three scores for each sequence are constructed as
    %    follows:
    %    'smaxi' - maximum R_SCORE of annotated hits. Basically a BLAST
    %              predictor, with 'feature' set to 'rscore'.
    %    'smean' - average R_SCORE of annotated hits. Proportional to a GOtcha
    %              predictor (without normalization)
    %    'smini' - minimum non-zero R_SCORE of annotated hits if exist. Note
    %              that for some terms, all annotated hits are 0, which results
    %              a 0 obviously.
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
    % mmm:  The MMM prediction structure.
    %       .object   [cell]    A cell array of n-by-1 query ID list
    %       .ontology [struct]  the ontology structure (containing m terms)
    %       .smaxi    [double]  An n-by-m "maximal" R_SCORE
    %       .smean    [double]  An n-by-m "mean" R_SCORE
    %       .smini    [double]  An n-by-m "minimal" R_SCORE
    %       .date     [char]
    %
    % See Also
    % --------
    % [>] pfp_fanngomakeds.m
    % [>] pfp_importblastp.m
    % [>] pfp_oabuild.m

    % check inputs {{{
    if nargin < 3
        error('pfp_mmm:InputCount', 'Expected at least 3 inputs.');
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
    mmm.object   = reshape(qseqid, [], 1);
    mmm.ontology = oa.ontology;
    n = numel(qseqid);
    m = numel(oa.ontology.term);
    mmm.maxi = sparse(n, m);
    mmm.mean = sparse(n, m);
    mmm.mini = sparse(n, m);
    % }}}

    % compute the MMM prediction {{{
    [found, index] = ismember(mmm.object, B.qseqid)
    for i = 1:n
        if found(i)
            l = index(i); % l: the index of qseqid in B
            k = numel(B.info{l}.sseqid); % number of hits
            % make the annotation matrix of hits of this query sequence
            anno_mat = sparse(k, m);
            % annotated hits and their indices in oa.object
            [a_hits, a_ids] = ismember(B.info{l}.sseqid, oa.object);
            if ~any(a_hits)
                % all hits aren't annotated, predicted scores are left as zeros
                continue;
            end

            % crop the value to be within [0, MAX_RSCORE]
            % R_SCORE = -log(E_VALUE) + 2
            f = -log(B.info{l}.evalue(a_hits)) + 2;
            f(f > MAX_RSCORE) = MAX_RSCORE;
            f(f < 0) = 0;

            A        = oa.annotation(a_ids(a_hits), :);
            n_hits   = sum(A, 1); % # of annotated sseq/hits per term
            has_hits = n_hits > 0;

            % Only keep col. with >= 1 annotated hits, others have zero score.
            A = A(:, has_hits);
            S = bsxfun(@times, A, f);
            mmm.smaxi(i, has_hits) = max(S, [], 1);
            mmm.smean(i, has_hits) = sum(S, [], 1) ./ n_hits(has_hits);
            % set unannodated terms to be Inf to exclude them from computing minimum.
            S(~A) = Inf;
            mmm.smini(i, has_hits) = min(S, [], 1);
        end
    end
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 12:53:12 PM E
