function [oa] = pfp_setannot(oa, target, alist, option)
    %PFP_SETANNOT Set annotation
    %
    % [oa] = PFP_SETANNOT(oa, target, alist, option);
    %
    %   Updates annotations of a target (term or object) in an ontology
    %   annotation structure.
    %
    % Note
    % ----
    % Old annotations of that target (term or object) will be reset.
    %
    % Caveat
    % ------
    % When setting the annotations of a term, annotations of its offsprings
    % might be affected accordingly so as to keep consistency.
    %
    % Input
    % -----
    % [struct]
    % oa:       The ontology annotation structure. See pfp_oabuild.m
    %
    % [char]
    % target:   An object ID or a term ID.
    %
    % [cell]
    % alist:    A list of associated entries to 'target' (term or object).
    %
    % [char]
    % option:   Must be either 'object' or 'term'.
    %           'object' - set annotations to an object.
    %           'term'   - set annotations to a term.
    %
    % Output
    % ------
    % [struct]
    % oa:   The updated ontology annotation structure.
    %
    % Dependency
    % ----------
    % [>] pfp_addannot.m
    % [>] pfp_offspringtermidx.m
    %
    % See Also
    % --------
    % [>] pfp_oabuild.m

    % check inputs {{{
    if nargin ~= 4
        error('pfp_setannot:InputCount', 'Expected 4 inputs.');
    end

    % oa
    validateattributes(oa, {'struct'}, {'nonempty'}, '', 'oa', 1);

    % target
    validateattributes(target, {'char'}, {'nonempty'}, '', 'target', 2);

    % alist
    validateattributes(alist, {'cell'}, {'nonempty', 'vector'}, '', 'alist', 3);

    % option
    option = validatestring(option, {'object', 'term'}, '', 'option', 4);
    % }}}

    % set annotations {{{
    n = numel(alist);

    switch option
        case 'object'
            [found, index] = ismember(target, oa.object);
            if found
                oa.annotation(index, :) = false; % clear exisiting annotation
            end
            oa = pfp_addannot(oa, [repmat({target}, n, 1), reshape(alist, [], 1)]);
        case 'term'
            [found, index] = ismember(target, {oa.ontology.term.id});
            if ~found
                error('pfp_setannot:InvalidID', 'Invalid term ID [%s].', target);
            end

            % clear other annotations (those are not in the 'alist') of its
            % offsprings
            other_obj = ~ismember(oa.object, alist);
            if ~isempty(other_obj)
                offsp_id = pfp_offspringtermidx(oa.ontology, target);
                if ~isempty(offsp_id)
                    oa.annotation(other_obj, offsp_id) = false;
                end
            end
            oa = pfp_addannot(oa, [reshape(alist, [], 1), repmat({target}, n, 1)]);
    end
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 01:08:50 PM E
