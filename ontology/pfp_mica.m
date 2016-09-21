function [mica, idx] = pfp_mica(ont, list)
    %PFP_MICA Most informative common ancestors
    %
    % [mica, idx] = PFP_MICA(ont, list);
    %
    %   Returns the set of most informative common ancestors and their indices.
    %
    % Definition
    % ----------
    % "mica" (most informative common ancestors) is defined as the set of "leaf"
    % terms of the sub-DAG of common ancestors. Sometimes termed as the lowest
    % common ancestor (LCA)
    %
    % Note
    % ----
    % One may want to call pfp_ancestormat.m to get an "ancestor matrix" and
    % compute "mica" explicitly if one needs to repeatedly compute "mica".
    %
    % Input
    % -----
    % [struct]
    % ont:  The ontology structure. See pfp_ontbuild.m
    %
    % [cell or struct]
    % list: [cell]   - A cell of (char) term IDs.
    %       [struct] - An array of term structures.
    %
    % Output
    % ------
    % [struct]
    % mica: An array of mica.
    %
    % [double]
    % idx:  The indices of mica.
    %
    % Dependency
    % ----------
    % [>] pfp_ancestorterm.m
    %
    % See Also
    % --------
    % [>] pfp_ontbuild.m
    % [>] pfp_ancestormat.m

    % check inputs {{{
    if nargin ~= 2
        error('pfp_mica:InputCount', 'Expected 2 inputs.');
    end

    % ont
    validateattributes(ont, {'struct'}, {'nonempty'}, '', 'ont', 1);

    % list
    validateattributes(list, {'cell', 'struct'}, {'nonempty'}, '', 'list', 2);
    n = numel(list);
    if n < 2
        error('pfp_mica:InputErr', 'Expected more than one terms.');
    end
    % }}}

    % find the intersect of their ancestors {{{
    if isstruct(list)
        list = {list.id};
    end
    [~, aid] = pfp_ancestorterm(ont, list{1});
    for i = 2 : n
        [~, aid_other] = pfp_ancestorterm(ont, list{i});
        aid = intersect(aid, aid_other);
    end
    % }}}

    % find leaf terms of the ancestors intersection {{{
    isleaf = ~any(ont.DAG(aid, aid) ~= 0, 1);
    mica   = ont.term(aid(isleaf));
    idx    = reshape(aid(isleaf), 1, []);
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 01:13:36 PM E
