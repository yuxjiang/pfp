function [p, idx] = pfp_parentterm(ont, term)
    %PFP_PARENTTERM Parent term
    %
    % [p, idx] = PFP_PARENTTERM(ont, term);
    %
    %   Returns (immediate) parents of a term in an ontology.
    %
    % Input
    % -----
    % [struct]
    % ont:  The ontology structure. See pfp_ontbuild.m
    %
    % [struct or char]
    % term: [struct] - A term structure.
    %       [char]   - A (char) term ID.
    %
    % Output
    % ------
    % [struct]
    % p:    An array of parents term structure.
    %
    % [double]
    % idx:  An array of indices of parents term(s).
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
        error('pfp_parentterm:InputCount', 'Expected 2 inputs.');
    end

    % ont
    validateattributes(ont, {'struct'}, {'nonempty'}, '', 'ont', 1);

    % term
    validateattributes(term, {'struct', 'char'}, {'nonempty'}, '', 'term', 2);
    % }}}

    % find the requested term {{{
    [~, index] = pfp_getterm(ont, term);
    if numel(index) > 1
        error('pfp_parentterm:MoreThanOneTerm', 'Expected 1 term.');
    end

    if index == 0
        error('pfp_parentterm:InvalidID', 'Invalid ID.');
    end
    % }}}

    % get parent(s) {{{
    isparent = (ont.DAG(index, :) ~= 0);
    p        = ont.term(isparent);
    idx      = reshape(find(isparent), 1, []);
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 01:16:26 PM E
