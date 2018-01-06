function [degree] = pfp_indegree(ont, list)
    %PFP_INDEGREE Depth
    %
    % [degree] = PFP_INDEGREE(ont);
    % [degree] = PFP_INDEGREE(ont, list);
    %
    %   Returns the in-degree (number of parents) of (a list of) terms in the
    %   ontology.
    %
    % Input
    % -----
    % [struct]
    % ont:  The ontology structure. See pfp_ontbuild.m
    %
    % (optional)
    % [struct or cell]
    % list: [struct] - an array of term structures.
    %       [cell]   - a cell of (char) term IDs.
    %
    % Output
    % ------
    % [double]
    % degree:   A 1-by-k vector of degree for each of the k query terms.
    %
    % See Also
    % --------
    % [>] pfp_ontbuild.m

    % check inputs {{{
    if nargin ~= 1 && nargin ~= 2
        error('pfp_indegree:InputCount', 'Expected 1 or 2 inputs.');
    end

    if nargin == 1
        list = {};
    end

    % ont
    validateattributes(ont, {'struct'}, {'nonempty'}, '', 'ont', 1);

    % list
    validateattributes(list, {'struct', 'cell'}, {}, '', 'list', 2);
    if isempty(list)
        list = ont.term;
    end
    % }}}

    % compute in-degree {{{
    if isstruct(list) % array of structures
        list = {list.id};
    end

    [found, index] = ismember(list, {ont.term.id});
    if ~all(found)
        warning('pfp_indegree:InputErr', 'Some terms are not found in the ontology.');
    end

    degree = reshape(full(sum(ont.DAG, 2)), 1, []);
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Tue 04 Apr 2017 05:35:37 PM E
