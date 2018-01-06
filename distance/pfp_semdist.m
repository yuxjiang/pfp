function [dist] = pfp_semdist(ont, eia, term1, term2, p)
    %PFP_SEMDIST Semantic distance
    %
    %   [icd] = PFP_SEMDIST(ont, eia, term1, term2);
    %
    %       Returns the "semantic distance" of order 2 between two terms.
    %
    %   [icd] = PFP_SEMDIST(ont, eia, term1, term2, p);
    %
    %       Returns the "semantic distance" of order p between two terms.
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
    % term1:    [char]   - ID of term 1.
    %           [struct] - term structure.
    %
    % [char or struct]
    % term2:    [char]   - ID of term 2.
    %           [struct] - term structure.
    %
    % (optional)
    % [double]
    % p:    Order.
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
        p = 2;
    end

    % ont
    validateattributes(ont, {'struct'}, {'nonempty'}, '', 'ont', 1);

    % eia
    n = numel(ont.term);
    validateattributes(eia, {'double'}, {'numel', n}, '', 'eia', 2);

    % term1
    validateattributes(term1, {'char', 'struct'}, {'nonempty'}, '', 'term1', 3);

    % term2
    validateattributes(term2, {'char', 'struct'}, {'nonempty'}, '', 'term2', 4);

    % p
    validateattributes(p, {'double'}, {'real'}, '', 'p', 5);
    % }}}

    % compute semantic distance {{{
    id1 = pfp_ancestortermidx(ont, term1);
    id2 = pfp_ancestortermidx(ont, term2);
    d1  = sum(eia(setdiff(id1, id2)));
    d2  = sum(eia(setdiff(id2, id1)));
    if isinf(p)
        dist = max(d1, d2);
        return;
    end
    dist = (d1 .^ p + d2 .^ p) .^ (1/p);
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Thu 07 Dec 2017 11:50:00 PM E
