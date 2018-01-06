function [gene] = pfp_hgncgene(hgnc, query, verbose)
    %PFP_HGNCGENE HGNC gene
    %
    % [gene] = PFP_HGNCGENE(hgnc, query);
    % [gene] = PFP_HGNCGENE(hgnc, query, true);
    %
    %   Returns HGNC gene structure array.
    %
    % Note
    % ----
    % 1. Some gene symbols could appear both in "approved" and "previous" by
    %    HGNC, so for symbols that are the "previous" of some "previous" symbol,
    %    apply this function twice on them could have different answers, which
    %    is not what it should be.
    %
    % 2. To make this function "idempotent" search for symbols is applied
    %    multiple times until the symbol is not changing.
    %    [gene] = PFP_HGNCGENE(hgnc, query, false);
    %    Returns HGNC gene structure array in a "quiet" mode.
    %
    % Input
    % -----
    % (required)
    % [struct]
    % hgnc:     The HGNC structure. See pfp_hgncupdate.m.
    %
    % [char, cell or double]
    % query:    A query list, could be one of the following,
    %           [cell]   - a list of (char) HGNC symbol.
    %           [double] - a list of (double) HGNC ID.
    %           [char]   - a single (char) HGNC gene symbol.
    %
    % (optional)
    % [logical]
    % verbose:  To output warning message if "true".
    %           default: true.
    %
    % Output
    % ------
    % [struct]
    % gene:     The gene structure array, which has
    %           .id     - HGNC ID
    %           .symbol - HGNC symbol

    % check inputs {{{
    if nargin < 2 || nargin > 3
        error('pfp_hgncgene:InputCount', 'Expected 2 or 3 inputs.');
    end

    if nargin == 2
        verbose = true;
    end

    % check the 1st input 'hgnc'
    validateattributes(hgnc, {'struct'}, {'nonempty'}, '', 'hgnc', 1);

    % check the 2nd input 'query'
    validateattributes(query, {'cell', 'double', 'char'}, {'nonempty'}, '', 'query', 2);

    % check the 3rd input 'verbose'
    validateattributes(verbose, {'logical'}, {'nonempty'}, '', 'logical', 3);
    % }}}

    % get gene {{{
    if isnumeric(query)
        gene = loc_get_gene_by_id(hgnc, query, verbose);
    else % cell or char
        if ischar(query)
            query = {query};
        end

        gene = loc_get_gene_by_symbol(hgnc, query, verbose);

        % make this function "idempotent"
        gene2 = loc_get_gene_by_symbol(hgnc, {gene.symbol}, false);
        while ~all(strcmp({gene.symbol}, {gene2.symbol}))
            gene = gene2;
            gene2 = loc_get_gene_by_symbol(hgnc, {gene.symbol}, false);
        end
    end
    % }}}
end

% function: loc_get_gene_by_id {{{
function gene = loc_get_gene_by_id(hgnc, id, verbose)
    %
    %   id: a list of HGNC ID
    %
    [found, index] = ismember(id, [hgnc.id]);

    if verbose && ~all(found)
        warning('pfp_hgncgene:InputErr', 'Invalid IDs detected.');
        invalid = find(~found);
        for i = 1 : numel(invalid)
            fprintf('[%d]\n', id(invalid(i)));
        end
    end

    acc = reshape(id, [], 1);
    tag = cell(numel(id), 1);
    tag(found) = hgnc.symbol(index(found));

    gene = cell2struct([num2cell(acc), tag], {'id', 'symbol'}, 2);
end
% }}}

% function: loc_get_gene_by_symbol {{{
function gene = loc_get_gene_by_symbol(hgnc, symbol, verbose)
    %
    %   symbol: a list of HGNC gene symbol
    %
    %   Symbol mapping stratergy:
    %   ----
    %   - first, try to match with special symbols
    %   - for remaining symbols, try to match "Approved Symbol"
    %   - for remaining symbols, try to match "Previous Symbol"
    %   - for remaining symbols, try to match "Synonyms"
    %   - for remaining symbols, return NaN as accession

    if ischar(symbol) % single symbol
        symbol = {symbol};
    end

    symbol = reshape(symbol, [], 1); % make a column vector

    [is_special, index_sp] = ismember(symbol, hgnc.special.symbol);
    [is_approved, index_a] = ismember(symbol, hgnc.symbol);
    [is_previous, index_p] = ismember(symbol, hgnc.previous.symbol);

    is_previous = is_previous & ~is_special;
    is_approved = is_approved & ~is_special;

    % print warning message for ambiguous symbols
    % ------
    % Define: [ambiguous symbol]
    %   a symbol appears both in "approved" and "previous" list
    %   but not in "special" list
    %
    % These ambiguous symbols will be mapped to currently approved list.
    is_ambiguous = is_previous & is_approved;
    if verbose && any(is_ambiguous)
        warning('pfp_hgncgene:AmbiguousSymb', 'Some symbols are ambiguous.');
    end

    is_previous = is_previous & ~is_ambiguous;

    [is_synonyms, index_s] = ismember(symbol, hgnc.synonyms.symbol);
    is_synonyms = is_synonyms & ~is_approved & ~is_previous & ~is_ambiguous & ~is_special;

    acc = nan(numel(symbol), 1);
    acc(is_special)  = hgnc.special.id(index_sp(is_special));
    acc(is_approved) = hgnc.id(index_a(is_approved));
    acc(is_previous) = hgnc.previous.id(index_p(is_previous));
    acc(is_synonyms) = hgnc.synonyms.id(index_s(is_synonyms));

    tag = symbol;
    tag(is_approved) = hgnc.symbol(index_a(is_approved));

    [~, index_sp2ap] = ismember(acc(is_special), hgnc.id);
    [~, index_pr2ap] = ismember(acc(is_previous), hgnc.id);
    [~, index_sy2ap] = ismember(acc(is_synonyms), hgnc.id);
    tag(is_special)  = hgnc.symbol(index_sp2ap);
    tag(is_previous) = hgnc.symbol(index_pr2ap);
    tag(is_synonyms) = hgnc.symbol(index_sy2ap);

    found = is_special | is_approved | is_previous | is_synonyms;
    if verbose && ~all(found)
        warning('pfp_hgncgene:InvalidSymb', 'Invalid symbols detected.');
        invalid = find(~found);
        for i = 1 : numel(invalid)
            fprintf('[%s]\n', symbol{invalid(i)});
        end
    end

    gene = cell2struct([num2cell(acc), tag], {'id', 'symbol'}, 2);
end
% }}}

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Sun 09 Apr 2017 07:03:55 PM E
