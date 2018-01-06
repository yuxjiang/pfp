function [l] = pfp_level(ont, list)
    %PFP_LEVEL Level
    %
    % [l] = PFP_LEVEL(ont);
    %
    %   Returns the level of an ontology.
    %
    % [l] = PFP_LEVEL(ont, list);
    %
    %   Returns the level of (a list of) terms in the ontology.
    %
    % Definition
    % ----------
    % Term level: Length of the longest path from the root to this term.
    % Ontology level: The maximum "term level" in this ontology.
    %
    % Caveat
    % ------
    % This function assumes single root of the ontology.
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
    %       If list is given as empty, the function returns the level for the
    %       ontology.
    %       default: {}
    %
    % Output
    % ------
    % [double]
    % l:    The level information.
    %       If querying the ontology level, l is a single value, otherwise, l is
    %       a 1-by-m vector of level.
    %       Note that unfound terms correspond to a NaN in l.
    %
    % Dependency
    % ----------
    % [>] pfp_rootterm.m
    %
    % See Also
    % --------
    % [>] pfp_ontbuild.m
    % [>] pfp_depth.m

    % check inputs {{{
    if nargin ~= 1 && nargin ~= 2
        error('pfp_level:InputCount', 'Expected 1 or 2 inputs.');
    end

    if nargin == 1
        list = {};
    end

    % ont
    validateattributes(ont, {'struct'}, {'nonempty'}, '', 'ont', 1);

    % list
    validateattributes(list, {'struct', 'cell'}, {}, '', 'list', 2);
    if isempty(list)
        level_mode = 'ont'; % compute the ontology depth
    else
        level_mode = 'term'; % compute the term depth
    end
    % }}}

    % compute level {{{
    level = 0;
    [~, next_level] = pfp_rootterm(ont);
    L = zeros(1, numel(ont.term));
    while ~isempty(next_level)
        level = level + 1;
        L(next_level) = level;
        next_level = find(any(ont.DAG(:, next_level), 2));
    end
    switch level_mode
        case 'ont'
            l = max(L);
        case 'term'
            if isstruct(list) % array of structures
                list = {list.id};
            end
            [found, index] = ismember(list, {ont.term.id});
            if ~all(found)
                warning('pfp_level:InputErr', 'Some terms are not found in the ontology.');
            end
            l = nan(1, numel(list));
            l(found) = L(index(found));
        otherwise
            % nop
    end
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 11 Oct 2017 09:29:26 AM E
