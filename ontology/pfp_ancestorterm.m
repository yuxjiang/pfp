function [ancs, idx] = pfp_ancestorterm(ont, list)
    %PFP_ANCESTORTERM Ancestor term
    %
    % [ancs, idx] = PFP_ANCESTORTERM(ont, list);
    %
    %   Returns the union of the ancestors and their indices of the given terms
    %   (self-included).
    %
    % Input
    % -----
    % [struct]
    % ont:  The ontology structure. See pfp_ontbuild.m
    %
    % [cell, char or struct]
    % list: [cell]   - A cell of (char) term IDs.
    %       [char]   - A single (char) term ID.
    %       [struct] - An array of term structures.
    %
    % Output
    % ------
    % [struct]
    % ancs: An array of ancestor term structures.
    %
    % [double]
    % idx:  An array of ancestor term indices.
    %
    % Dependency
    % ----------
    % [>] pfp_getterm.m
    %
    % See Also
    % --------
    % [>] pfp_ontbuild.m

    % check inputs {{{
    if nargin ~= 2
        error('pfp_ancestorterm:InputCount', 'Expected 2 inputs.');
    end

    % ont
    validateattributes(ont, {'struct'}, {'nonempty'}, '', 'ont', 1);

    % list
    validateattributes(list, {'cell', 'char', 'struct'}, {'nonempty'}, '', 'list', 2);
    % }}}

    % find indices {{{
    [~, index] = pfp_getterm(ont, list);
    index(index == 0) = [];
    % }}}

    % find ancestors {{{
    walking = false(1, numel(ont.term));
    walking(index) = true;
    visited = walking;
    while any(walking)
        visited = visited | walking;
        walking = full(any(ont.DAG(walking, :), 1)) & ~visited;
    end
    ancs = ont.term(visited);
    idx  = reshape(find(visited), 1, []);
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 01:10:58 PM E
