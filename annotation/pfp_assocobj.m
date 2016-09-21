function [object] = pfp_assocobj(oa, list)
    %PFP_ASSOCOBJ Associated object
    %
    % [object] = PFP_ASSOCOBJ(oa, list);
    %
    %   Returns objects associated with a list of terms
    %
    % Input
    % -----
    % [struct]
    % oa:   The ontology annotation structure. See pfp_oabuild.m
    %
    % [cell, char or struct]
    % list: [cell]   - An array of (char) term IDs.
    %       [char]   - A single (char) term ID.
    %       [struct] - An array of term structures.
    %
    % Output
    % ------
    % [cell]
    % object:   An array of (char) object IDs.
    %
    % Dependency
    % ----------
    % [>] pfp_getterm.m
    %
    % See Also
    % --------
    % [>] pfp_oabuild.m

    % check inputs {{{
    if nargin ~= 2
        error('pfp_assocobj:InputCount', 'Expected 2 inputs.');
    end

    % oa
    validateattributes(oa, {'struct'}, {'nonempty'}, '', 'oa', 1);

    % list
    validateattributes(list, {'cell', 'char', 'struct'}, {'nonempty'}, '', 'list', 2);
    % }}}

    % check term list {{{
    [~, index] = pfp_getterm(oa.ontology, list);
    if all(index == 0)
        error('pfp_assocobj:InvalidID', 'No valid ID.');
    end
    if any(index == 0)
        warning('pfp_assocobj:InvalidID', 'Some IDs are invalid.');
    end
    % }}}

    % prepare output {{{
    object = oa.object(any(oa.annotation(:, index(found)), 2));
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 01:01:52 PM E
