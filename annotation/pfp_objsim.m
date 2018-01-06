function [res] = pfp_objsim(oa, src, dst, varargin)
    %PFP_OBJSIM Object similarity
    %
    % [res] = PFP_OBJSIM(oa, src, dst, varargin);
    %
    %   Computes similarity between annotated objects (e.g., genes/proteins).
    %
    % Reference
    % ---------
    % [1] Schlicker, A, et al., A new measure for functional similarity of gene
    %     products based on Gene Ontology. BMC Bioinformatics, 7, 302, 2006.
    %
    % [2] Altenhoff, AM, et al., Resolving the ortholog conjecture: orthologs
    %     tend to be weakly, but significanly, more similar in function than
    %     paralogs, PLOS Computational Biology, 8(5), e1002514, 2012.
    %
    % Note
    % ----
    % If 'otype' is set to either Jaccard or Maryland-bridge coefficient,
    % 'ttype' will be forced to 'n/a' since term similarity is not used in these
    % cases.
    %
    % Input
    % -----
    % (required)
    % [struct]
    % oa:   The ontology annotation structure. See pfp_oabuild.m
    %
    % [cell or char]
    % src:  The set of "source" object ID. It can be a cell of term IDs, or a
    %       single char of object ID, or empty (which means all objects of 'oa')
    %
    % [cell or char]
    % dst:  The set of "destination" object ID. Same format as 'src'.
    %
    % (optional) Name-value pairs.
    % [double]
    % 'prob'        1-by-m vector of the probability of observing each term. If
    %               it is set to empty, 'oa' will be used to estimate the
    %               probability.
    %               default: []
    %
    % [logical]
    % 'leafonly'    The toggle for using leaf-only term annotations for each
    %               object. If it's set to false, this function uses the
    %               propagated annotation. Note that in the case of 'jaccard'
    %               and 'maryland', we would always use the propagated
    %               annotations.
    %               default: true
    %
    % [char]
    % 'ttype'       The term similarity type used to build object similarity.
    %               See pfp_termsim.m
    %               'resnik'  - The Resnik's similarity.
    %               'lin'     - The Lin's similarity.
    %               'rel'     - The Relative similarity.
    %               default: 'rel'
    %
    % 'otype'       The object similarity type.
    %               'schlicker' - The Schlicker's similarity. See reference [1]
    %               'altenhoff' - The Altenhoff's similarity. See reference [2]
    %               'lord'      - The Lord's similarity.
    %               'jaccard'   - The Jaccard index.
    %               'maryland'  - The Maryland-bridge coefficient.
    %               default: 'schlicker'
    %
    % [struct]
    % 'tmat'        The pre-computed pairwise term similarity structure. See
    %               pfp_termsim.m
    %               .row  [cell]   n1-by-1 cell array of terms for each row.
    %               .col  [cell]   1-by-n2 cell array of terms for each column.
    %               .data [double] n1-by-n2 similarity matrix.
    %               .type [char]   The similarity type.
    %               Note that if this structure is given, 'ttype' will be ignored.
    %               default: "a structure with empty content"
    %
    % Output
    % ------
    % [struct]
    % res:  The resulting similarity structure, which has
    %       .row   [cell]   A cell array of n1 "source" object IDs.
    %       .col   [cell]   A cell array of n2 "destination" object IDs.
    %       .data  [double] n1-by-n2 similarity matrix.
    %       .ttype [char]   The term similarity type.
    %       .otype [char]   The object similarity type.
    %
    % Dependency
    % ----------
    % [>] pfp_jaccard.m
    % [>] pfp_mbcoef.m
    % [>] pfp_assocterm.m
    % [>] pfp_termsim.m
    %
    % See Also
    % --------
    % [>] pfp_oabuild.m

    % check inputs {{{
    if nargin < 3
        error('pfp_objsim:InputCount', 'Expected at least 3 inputs.');
    end

    % oa
    validateattributes(oa, {'struct'}, {'nonempty'}, '', 'oa', 1);
    m = numel(oa.ontology.term);

    % src
    validateattributes(src, {'cell', 'char'}, {}, '', 'src', 2);
    [res.row, index_row] = loc_checkobjs(src, oa);

    % dst
    validateattributes(dst, {'cell', 'char'}, {}, '', 'dst', 3);
    [res.col, index_col] = loc_checkobjs(dst, oa);
    % }}}

    % extra inputs {{{
    p = inputParser;
    defaultPROB      = [];
    defaultLEAFONLY  = true;
    defaultTTYPE     = 'rel';
    defaultOTYPE     = 'schlicker';
    defaultTMAT.row  = {};
    defaultTMAT.col  = {};
    defaultTMAT.data = [];
    defaultTMAT.type = '';
    addParameter(p, 'prob', defaultPROB, @(x) validateattributes(x, {'double'}, {'>=', 0}));
    addParameter(p, 'leafonly', defaultLEAFONLY, @(x) islogical(x));
    addParameter(p, 'tmat', defaultTMAT)
    % addParameter(p, 'tmat', defaultTMAT, @(x) validateattributes(x, {'struct'}));
    addParameter(p, 'ttype', defaultTTYPE, @(x) ismember(x, {'rel', 'resnik', 'lin'}));
    addParameter(p, 'otype', defaultOTYPE, @(x) ismember(x, {'schlicker', 'altenhoff', 'lord', 'jaccard', 'maryland'}));
    parse(p, varargin{:});

    if isempty(p.Results.prob)
        % estimate probability using 'oa'
        prob = full(sum(oa.annotation, 1) ./ numel(oa.object));
    else
        prob = p.Results.prob;
    end
    % }}}

    % output structure {{{
    nrow      = numel(res.row);
    ncol      = numel(res.col);
    res.data  = sparse(nrow, ncol);
    res.ttype = p.Results.ttype;
    res.otype = p.Results.otype;
    % }}}

    % Jaccard and Maryland-bridge {{{
    if ismember(res.otype, {'jaccard', 'maryland'})
        res.ttype = 'n/a'; % term similarity is not used.
        oax = oa.annotation(index_row,:);
        oay = oa.annotation(index_col,:);
        switch res.otype
            case 'jaccard'
                res.data = pfp_jaccard(oax, oay);
            case 'maryland'
                res.data = pfp_mbcoef(oax, oay);
            otherwise
                % nop
        end
        return;
    end
    % }}}

    % compute pairwise term similarities {{{
    % get all terms that are annotated with at least one objects
    tlist_row = pfp_assocterm(oa, res.row, 'leafonly', p.Results.leafonly);
    tlist_col = pfp_assocterm(oa, res.col, 'leafonly', p.Results.leafonly);
    ttype     = p.Results.ttype;
    otype     = p.Results.otype;
    if isempty(p.Results.tmat.row) || isempty(p.Results.tmat.col)
        tmat = pfp_termsim(oa, tlist_row, tlist_col, 'prob', prob, 'type', ttype);
    else
        tmat = p.Results.tmat;
        if ~all(ismember({tlist_row.id}, tmat.row)) || ~all(ismember({tlist_col.id}, tmat.col))
            error('pfp_objsim:TermSimErr', 'Not all term similarities are availble.');
        end
    end
    % }}}

    % compute pairwise object similarities {{{
    for i = 1:nrow
        for j = 1:ncol
            % get the sub-matrix corresp. to this obj(i) and obj(j)
            term_row = pfp_assocterm(oa, res.row{i}, 'leafonly', p.Results.leafonly);
            term_col = pfp_assocterm(oa, res.col{i}, 'leafonly', p.Results.leafonly);
            [~, rind] = ismember({term_row.id}, tmat.row);
            [~, cind] = ismember({term_col.id}, tmat.col);
            sim = tmat.data(rind, cind);

            switch otype
                case 'schlicker'
                    rowscore = mean(max(sim, [], 2));
                    colscore = mean(max(sim, [], 1));
                    res.data(i,j) = max(rowscore, colscore);
                case 'altenhoff'
                    rowscores = reshape(max(sim, [], 2), 1, []);
                    colscores = reshape(max(sim, [], 1), 1, []);
                    res.data(i,j) = mean([rowscores, colscores]);
                case 'lord'
                    res.data(i,j) = mean(sim(:));
                otherwise
            end
        end
    end
    % }}}
end

% function: loc_checkobjs {{{
function [objs, index] = loc_checkobjs(objs, oa)
    if isempty(objs)
        objs  = oa.object;
        index = 1:numel(oa.object);
        return
    elseif ischar(objs)
        objs = {objs};
    end
    [found, index] = ismember(objs, oa.object);
    if ~all(found)
        error('pfp_objsim:GeneErr', 'Some objects are not annotated.');
    end
    objs = reshape(oa.object(index), [], 1);
end
% }}}

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University, Bloomington
% Last modified: Fri 08 Dec 2017 01:43:25 PM E
