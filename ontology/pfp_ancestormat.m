function [A] = pfp_ancestormat(ont, list)
    %PFP_ANCESTORMAT Ancestor matrix
    %
    % [A] = PFP_ANCESTORMAT(ont);
    %
    %   Returns the "ancestor matrix" of an ontology.
    %
    % [A] = PFP_ANCESTORMAT(ont, list);
    %
    %   Returns the "ancestor matrix" of an ontology with a subset of terms.
    %
    % Note
    % ----
    % Each term is set to an ancestor term of itself.
    %
    % Definition
    % ----------
    % "Ancestor matrix (A)" is a binary (logical) matrix whose entry A(i,j) is
    % true iff one of the following is true:
    % 1. i = j;
    % 2. term(j) is an ancestor of term(i).
    %
    % Input
    % -----
    % (required)
    % [struct]
    % ont:  The ontology structure. See pfp_ontbuild.m
    %
    % (optional)
    % [cell or struct]
    % list: The list of term ID or an array of term structures.
    %       default: ont.term (all terms in the ontology)
    %
    % Output
    % ------
    % [double]
    % A:    The ancestor matrix.
    %
    % Dependency
    % ----------
    % [>] pfp_getterm.m
    % [>] Bioinformatics Toolbox:graphtopoorder
    %
    % See Also
    % --------
    % [>] pfp_ontbuild.m

    % check inputs {{{
    if nargin < 1
        error('pfp_ancestormat:InputCount', 'Expected 1 or 2 inputs.');
    end

    if nargin == 1
        list = ont.term;
    end

    % ont
    validateattributes(ont, {'struct'}, {'nonempty'}, '', 'ont', 1);

    % list
    validateattributes(list, {'cell', 'struct'}, {'nonempty'}, '', 'list', 2);
    if isstruct(list)
        list = {list.id};
    end
    % check term list if specified
    if nargin == 2
        [~, index] = pfp_getterm(ont, list);
        if any(index == 0)
            error('pfp_ancestormat:TermErr', 'Some terms are not in the ontology.');
        end
    end
    % }}}

    % make the matrix {{{
    DAG = (ont.DAG ~= 0);

    n = numel(ont.term);
    A = logical(sparse(n, n));

    % topologically walk through: root -> leaves
    order = flip(graphtopoorder(DAG));
    for i = 1:n
        idx = order(i);
        % set itself to be its ancestor
        A(idx, idx) = true;
        % pass down all ancestors of the current working set to their children
        c = find(DAG(:, idx));
        A(c, :) = A(c, :) | repmat(A(idx, :), numel(c), 1);
    end
    if nargin == 2
        A = A(index, index);
    end
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University, Bloomington
% Last modified: Wed 21 Sep 2016 01:10:33 PM E
