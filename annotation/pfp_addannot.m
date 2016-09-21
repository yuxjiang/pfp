function [oa] = pfp_addannot(oa, list)
    %PFP_ADDANNOT Add annotation
    %
    % [oa] = PFP_ADDANNOT(oa, list);
    %
    %   Adds annotations to an ontology annotation structure.
    %
    % Input
    % -----
    % [struct]
    % oa:   The ontology annotation structure. See pfp_oabuild.m
    %
    % [cell]
    % list: A list of (object, term) pairs. It must be a n-by-2 cell array,
    %       where the 1st column contains object IDs and the 2nd column contains
    %       term IDs.
    %
    % Output
    % ------
    % [struct]
    % oa:   The updated ontology annotation structure.
    %
    % Dependency
    % ----------
    % [>] pfp_oaproj.m
    % [>] pfp_annotprop.m
    %
    % See Also
    % --------
    % [>] pfp_oabuild.m

    % check inputs {{{
    if nargin ~= 2
        error('pfp_addannot:InputCount', 'Expected 2 inputs.');
    end
    % oa
    validateattributes(oa, {'struct'}, {'nonempty'}, '', 'oa', 1);

    % list
    validateattributes(list, {'cell'}, {'nonempty', 'ncols', 2}, '', 'list', 2);
    % }}}

    % justify 'list' {{{
    [found, index] = ismember(list(:, 2), {oa.ontology.term.id});
    if ~any(found)
        error('pfp_addannot:AllInvalidID', 'No valid term ID.');
    end
    if ~all(found)
        warning('pfp_addannot:SomeInvalidID', 'Some term IDs are invalid.');
    end
    list(~found, :) = []; % remove pairs with invalid term id
    % }}}

    % add annotations {{{
    % Project 'oa' onto the union of the original object list and the new list
    % Note that this might change the order of 'oa.object' because of 'unique'.
    new_objects = unique([oa.object; list(:, 1)]);
    oa          = pfp_oaproj(oa, new_objects, 'object');
    [~, index1] = ismember(list(:, 1), oa.object);
    [~, index2] = ismember(list(:, 2), {oa.ontology.term.id});

    for i = 1 : size(list, 1)
        oa.annotation(index1(i), index2(i)) = true;
    end

    % propagate annotations
    oa.annotation = pfp_annotprop(oa.ontology.DAG, oa.annotation);
    oa.date       = datestr(now, 'mm/dd/yyyy HH:MM');
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 01:00:45 PM E
