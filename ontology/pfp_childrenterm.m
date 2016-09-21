function [c, idx] = pfp_childrenterm(ont, term)
    %PFP_CHILDRENTERM (Immediate) children term
    %
    % [c, idx] = PFP_CHILDRENIDX(ont, term);
    %
    %   Returns the (immediate) children and their indices of a given term in an
    %   ontology.
    %
    % Input
    % -----
    % [struct]
    % ont:  The ontology structure. See pfp_ontbuild.m
    %
    % [struct, char]
    % term: [struct] - A term structure.
    %       [char]   - A (char) term ID.
    %
    % Output
    % ------
    % [struct]
    % c:    The children term structures.
    %
    % [double]
    % idx:  The index of the children terms.
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
        error('pfp_childrenterm:InputCount', 'Expected 2 inputs.');
    end

    % ont
    validateattributes(ont, {'struct'}, {'nonempty'}, '', 'ont', 1);

    % term
    validateattributes(term, {'struct', 'char'}, {'nonempty'}, '', 'term', 2);

    if isstruct(term) && numel(term) > 1
        error('pfp_childrenterm:InputErr', 'Expected 1 term structure.');
    end

    if isstruct(term)
        term = term.id;
    end
    % }}}

    % find index of the term {{{
    [~, index] = pfp_getterm(ont, term);
    if index == 0
        error('pfp_childrenterm:InvalidID', 'Invalid ID [%s].', term);
    end
    % }}}

    % get child(ren) {{{
    ischild = (ont.DAG(:, index) ~= 0);
    c       = ont.term(ischild);
    idx     = reshape(find(ischild), 1, []);
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 01:11:38 PM E
