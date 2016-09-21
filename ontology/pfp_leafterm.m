function [terms, idx] = pfp_leafterm(ont)
    %PFP_LEAFTERM Leaf terms
    %
    % [terms, idx] = PFP_LEAFTERM(ont);
    %
    %   Returns leaf terms of an ontology.
    %
    % Input
    % -----
    % [struct]
    % ont:  The ontology structure. See pfp_leafterm.m
    %
    % Output
    % ------
    % [struct]
    % terms:    An array of leaf term structures.
    %
    % [double]
    % idx:      The indicies of leaf terms.
    %
    % Dependency
    % ----------
    % [>] pfp_ontbuild.m

    % check inputs {{{
    if nargin ~= 1
        error('pfp_leafterm:InputCount', 'Expected 1 input.');
    end

    % ont
    validateattributes(ont, {'struct'}, {'nonempty'}, '', 'ont', 1);
    % }}}

    % leaf terms {{{
    isleaf = ~any(ont.DAG ~= 0, 1);
    terms  = ont.term(isleaf);
    idx    = reshape(find(isleaf), 1, []);
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 01:13:04 PM E
