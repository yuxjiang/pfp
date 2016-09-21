function [dist] = pfp_semdist(ont, eia, term1, term2, k)
    %PFP_SEMDIST Semantic distance
    %
    % [icd] = PFP_SEMDIST(ont, eia, term1, term2);
    %
    %   Returns the "semantic distance" of order 2 between two terms.
    %
    % [icd] = PFP_SEMDIST(ont, eia, term1, term2, k);
    %
    %   Returns the "semantic distance" of order k between two terms.
    %
    % Input
    % -----
    % [struct]
    % ont:      The ontology structure.
    %
    % [double]
    % eia:      The corresponding estimated information accretion for each term.
    %
    % [char or struct]
    % term1:    [char]   -  ID of term 1.
    %           [struct] - term structure.
    %
    % [char or struct]
    % term2:    [char]   -  ID of term 2.
    %           [struct] - term structure.
    %
    % (optional)
    % [double]
    % k:    Order.
    %       default: 2
    %
    % Output
    % ------
    % [double]
    % dist: The semantic distance.
    %
    % Dependency
    % ----------
    % [>] pfp_ancestortermidx.m
    % [>] pfp_ontbuild.m
    % [>] pfp_eia.m

    % check inputs {{{
    if nargin < 4 || nargin > 5
        error('pfp_semdist:InputCount', 'Expected 4 or 5 inputs.');
    end

    if nargin == 4
        k = 2;
    end

    % check the 1st input 'ont' {{{
    validateattributes(ont, {'struct'}, {'nonempty'}, '', 'ont', 1);
    % }}}

    % check the 2nd input 'eia' {{{
    n = numel(ont.term);
    validateattributes(eia, {'double'}, {'numel', n}, '', 'eia', 2);
    % }}}

    % check the 3rd input 'term1' {{{
    validateattributes(term1, {'char', 'struct'}, {'nonempty'}, '', 'term1', 3);
    % }}}

    % check the 4th input 'term2' {{{
    validateattributes(term2, {'char', 'struct'}, {'nonempty'}, '', 'term2', 4);
    % }}}

    % check the 5th input 'k' {{{
    validateattributes(k, {'double'}, {'real'}, '', 'k', 5);
    % }}}
    % }}}

    % compute semantic distance {{{
    id1 = pfp_ancestortermidx(ont, term1);
    id2 = pfp_ancestortermidx(ont, term2);

    d1 = sum(eia(setdiff(id1, id2)));
    d2 = sum(eia(setdiff(id2, id1)));

    if isinf(k)
        dist = max(d1, d2);
        return;
    end

    dist = (d1 .^ k + d2 .^ k) .^ (1/k);
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 02:39:49 PM E
