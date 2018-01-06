function [d] = pfp_depth(ont, list)
    %PFP_DEPTH Depth
    %
    % [d] = PFP_DEPTH(ont);
    %
    %   Returns the depth of an ontology.
    %
    % [d] = PFP_DEPTH(ont, list);
    %
    %   Returns the depth of (a list of) terms in the ontology.
    %
    % Definition
    % ----------
    % Term depth: Length of the shortest path from the root to this term.
    % Ontology depth: The maximum "term depth" in this ontology.
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
    % list: [struct] - an array of m term structures.
    %       [cell]   - a cell of m (char) term IDs.
    %       If list is given as empty, the function returns the depth for the
    %       ontology.
    %       default: {}
    %
    % Output
    % ------
    % [double]
    % d:    The depth information.
    %       If querying the ontology depth, d is a single value, otherwise, d is
    %       a 1-by-m vector of depth.
    %       Note that unfound terms correspond to a NaN in d.
    %
    % Dependency
    % ----------
    % [>] pfp_rootterm.m
    %
    % See Also
    % --------
    % [>] pfp_ontbuild.m
    % [>] pfp_level.m

    % check inputs {{{
    if nargin ~= 1 && nargin ~= 2
        error('pfp_depth:InputCount', 'Expected 1 or 2 inputs.');
    end

    if nargin == 1
        list = {};
    end

    % ont
    validateattributes(ont, {'struct'}, {'nonempty'}, '', 'ont', 1);

    % list
    validateattributes(list, {'struct', 'cell'}, {}, '', 'list', 2);
    if isempty(list)
        depth_mode = 'ont'; % compute the ontology depth
    else
        depth_mode = 'term'; % compute the term depth
    end
    % }}}

    % compute depth {{{
    switch depth_mode
        case 'ont'
            touched = false(1, numel(ont.term));
            [~, idx] = pfp_rootterm(ont);
            touched(idx) = true;

            d = 1;
            while ~all(touched)
                touched(any(ont.DAG(:, touched), 2)) = true;
                d = d + 1;
            end
        case 'term'
            if isstruct(list) % array of structures
                list = {list.id};
            end

            [found, index] = ismember(list, {ont.term.id});
            if ~all(found)
                warning('pfp_depth:InputErr', 'Some terms are not found in the ontology.');
            end

            D = zeros(numel(ont.term), 1);
            [~, idx] = pfp_rootterm(ont);
            D(idx) = 1;

            depth = 1;
            while ~all(D(index(found)) > 0)
                depth = depth + 1;
                % only update [term depth] of those unreached terms (D == 0)
                D(D == 0 & any(ont.DAG(:, D>0), 2)) = depth;
            end
            d = nan(1, numel(list));
            d(found) = reshape(D(index(found)), 1, []);
        otherwise
            % nop
    end
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 11 Oct 2017 09:15:51 AM E
