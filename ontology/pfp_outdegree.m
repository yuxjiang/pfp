function [degree] = pfp_outdegree(ont, list)
    %PFP_OUTDEGREE Depth
    %
    % [degree] = PFP_OUTDEGREE(ont);
    % [degree] = PFP_OUTDEGREE(ont, list);
    %
    %   Returns the out-degree (number of children) of (a list of) terms in the
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
        error('pfp_outdegree:InputCount', 'Expected 1 or 2 inputs.');
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

    % compute out-degree {{{
    if isstruct(list) % array of structures
        list = {list.id};
    end

    [found, index] = ismember(list, {ont.term.id});
    if ~all(found)
        warning('pfp_outdegree:InputErr', 'Some terms are not found in the ontology.');
    end

    degree = reshape(full(sum(ont.DAG, 1)), 1, []);
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Tue 04 Apr 2017 05:37:43 PM E
